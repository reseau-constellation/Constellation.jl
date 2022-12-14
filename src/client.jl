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

    f(message) = begin
        if message["id"] == id 
            if message["type"] == "erreur"
                notify(cond , message["erreur"], error=true)
            elseif message["type"] == type
                oublierLorsque(client.émetteur, "message", f)
                if "résultat" in keys(message)
                    notify(cond, message["résultat"])
                elseif "fonctions" in keys(message)
                    notify(cond, message["fonctions"])
                else
                    notify(cond)
                end
            end
        end
    end

    lorsque(client.émetteur, "message", f)
    cond
end

function suivreRéponse(f::Function, client::Client, id::AbstractString, type::AbstractString)
    function fMessage(message)
        if message["id"] == id && message["type"] == type
            f(message["données"])
        end
    end

    lorsque(client.émetteur, "message", fMessage)
    
    () -> oublierLorsque(client.émetteur, "message", fMessage)
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

function suivre(f::Function, client::Client, adresseFonction::String, args::Dict, nomArgFonction::String="f")
    # Créer requète
    id = string(UUIDs.uuid4())
    requète = Dict([
        ("id", id), ("type", "suivre"), ("fonction", split(adresseFonction, ".")), ("args", args),
        ("nomArgFonction", nomArgFonction)
    ])
    
    # Créer écoute réponse suivrePrêt sur client
    suiviPrêt = attendreRéponse(client, id, "suivrePrêt")
    
    # Créer écoute réponse données sur client
    oublierÉcoute = suivreRéponse(client, id, "suivre") do réponse
        f(réponse)
    end
    
    # Envoyer requète au client
    write(client.ws, JSON.json(requète))

    # Attendre réponse requète et rendre la fonction oublier
    retour = wait(suiviPrêt)

    # Rendre fonction oublier
    function fOublier()
        requèteOublier = Dict([
            ("type", "retour"), ("id", id), ("fonction", "fOublier")
        ])
        write(client.ws, JSON.json(requèteOublier))
        oublierÉcoute()
    end

    function générerFRéponse(fn::AbstractString) 
        function fRéponse(args)
            requèteRéponse = Dict([("type", "retour"), ("id", id), ("fonction", fn), ("args", args)])
            write(client.ws, JSON.json(requèteRéponse))
        end

    end

    merge(Dict([("fOublier", fOublier)]), retour == nothing ? Dict([]) : Dict(fn=>générerFRéponse(fn) for fn in retour if fn != "fOublier"))
end


function suivreUneFois(client::Client, adresseFonction::String, args::Dict)
    # Créer variable pour recevoir le résultat
    résultat = nothing

    # Appeler suivre
    retour = suivre(client, adresseFonction, args) do données
        résultat = données
    end
    
    # Lorsque première réponse, annuler tout
    retour["fOublier"]()
    
    # Rendre la réponse
    résultat
end

function obtDonnéesTableau(client::Client, idTableau::AbstractString)
    données = suivreUneFois(client, "tableaux.suivreDonnées", args=Dict([("idTableau", idTableau)]))
    
    DataFrames.DataFrame(données)
end

function obtDonnéesRéseau()

end
