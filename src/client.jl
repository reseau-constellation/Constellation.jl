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
    lorsque(client.émetteur, "message") do message
        println("reçu", message)
    end

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
            println("attendreRéponse", message, message["résultat"])
            notify(cond, message["résultat"])
        end
    end
    cond
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


"""
function suivre(client::Client, adresseFonction::String, args::Dict{String, Any}, f::Fonction)
    # Créer requète
    id = UUIDs.uuidv4()
    requète = Dict([("id", id), ()])

    # Créer écoute réponse suivrePrêt sur client
    attendrePrêt = attendreRéponse(client, id, "suiviPrêt")
    
    # Créer écoute réponse données sur client
    oublierÉcoute = lorsqueRéponse(client, id, "suivi", écoute)
    
    # Envoyer requète au client
    requète = Dict([
        ("type", "suivi"), ("fonction", adresseFonction), ("args", args), ("id", id)
    ])
    
    # Créer fonction oublier
    requèteOublier = Dict([
        ("type", "oublier"), ("id", id)
    ])
    # fOublier = () -> { put!(client.ws, JSON.json(requèteOublier)), oublierÉcoute() }

    # Attendre réponse requète et rendre la fonction oublier
    wait(attendrePrêt)
    # fOublier
end


function suivreUneFois(client::Client, adresseFonction::String, args::Dict{String, Any})
    # Créer canal écoute
    
    # Appeler suivre
    fOublier = suivre(client, adresseFonction, args, canal)
    
    # Lorsque première réponse, annuler tout
    résultat = wait(canal)
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
"""