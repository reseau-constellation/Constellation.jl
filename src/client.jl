import WebSockets
import DataFrames
import JSON
import UUIDs
import Sockets

include("utils/événements.jl")

mutable struct Client
    port::Int
    émetteur::Émetteur
    ws::WebSockets.WebSocket{Sockets.TCPSocket}
    Client(;port, émetteur) = new(port, émetteur)
end

function avecClient(f::Function, port::Int)
    client = Client(;port=port, émetteur=Émetteur())

    WebSockets.open(string("ws://localhost:", port)) do ws_client
        client.ws = ws_client
        @async begin
            while true
                data, success = WebSockets.readguarded(ws_client)
                if success
                    émettre(client.émetteur, "message", JSON.parse(String(data)))
                else
                    break
                end
            end
        end 
        f(client)
    end;
end

function attendreRéponse(client::Client, id::AbstractString, type::AbstractString)
    cond = Condition()

    lorsque(client.émetteur, "message") do message
        if message["id"] == id && message["type"] == type
            notify(cond, message["résultat"])
        end
    end
    cond
end

function suivreRéponse(f::Function, client::Client, id::AbstractString, type::AbstractString)
    function fMessage(message)
        if message["id"] == id && message["type"] == type
            f(message["données"])
        end
    end

    lorsque(client.émetteur, "message", fFinale)
    
    () -> oublierLorsque(client.émetteur, "message", fFinale)
end

function action(client::Client, adresseFonction::String, args::Dict)
    # Créer requète
    id = string(UUIDs.uuid4())
    requète = Dict([
        ("type", "action"), ("fonction", split(adresseFonction, ".")), ("args", args), ("id", id)
    ])

    # Ajouter un écouteur au client
    prêt = attendreRéponse(client, id, "action")
    
    # Envoyer requète au client
    write(client.ws, JSON.json(requète))

    # Attendre et rendre la réponse
    résultat = wait(prêt)
end

function action(client::Client, adresseFonction::String)
    action(client, adresseFonction, Dict())
end

function suivre(f::Function, client::Client, adresseFonction::String, args::Dict{String, Any})
    # Créer requète
    id = UUIDs.uuidv4()
    nomArgFonction = 
    requète = Dict([
        ("id", id), ("type", "suivre"), ("fonction", split(adresseFonction, ".")), ("args", args),
        ("nomArgFonction", nomArgFonction)
    ])

    # Créer écoute réponse suivrePrêt sur client
    suiviPrêt = attendreRéponse(client, id, "suiviPrêt")
    
    # Créer écoute réponse données sur client
    oublierÉcoute = suivreRéponse(client, id, "suivre") do réponse
        f(réponse)
    end
    
    # Envoyer requète au client
    write(client.ws, JSON.json(requète))

    # Attendre réponse requète et rendre la fonction oublier
    wait(suiviPrêt)
    
    # Rendre fonction oublier
    requèteOublier = Dict([
        ("type", "retour"), ("id", id), ("fonction", "fOublier")
    ])

    function fOublier()
        write(client.ws, JSON.json(requèteOublier))
        oublierÉcoute()
    end
end


function suivreUneFois(client::Client, adresseFonction::String, args::Dict{String, Any})
    # Créer condition écoute
    cond = Condition()

    # Appeler suivre
    fOublier = suivre(client, adresseFonction, args) do résultat
        notify(cond, résultat)
    end
    
    # Lorsque première réponse, annuler tout
    résultat = wait(cond)
    fOublier()
    
    # Rendre la réponse
    résultat
end

function recherche()

end

function rechercherUneFois()

end

function obtDonnéesTableau(client::Client, idTableau::String)
    suivreUneFois(client, "tableaux.suivreDonnées", args=Dict([("idTableau", idTableau)]))
end

function obtDonnéesRéseau()

end
