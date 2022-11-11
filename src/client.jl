using WebSockets
using DataFrames
struct Client
    port::Int
    ws::Websockets.HTTP.Stream

    Client(;port, ws) = new(port, ws)
end

function Client(port)
    WebSockets.open(string("ws://127.0.0.1:", port)) do ws_client
        data, success = readguarded(ws_client)
        if success
            println(stderr, ws_client, " received:", String(data))
        end
    end;
    client = Client(;port, ws=ws_client)
    
    put!(ws_client.in, "test")
end

function action(client::Client, adresseFonction::String, args::Dict{String, Any})
    # Créer requète
    # Créer écoute réponse sur client
    # Envoyer requète au client
    # Attendre et rendre la réponse
end


function suivre(client::Client, adresseFonction::String, écoute::Stream)
    # Créer requète
    # Créer écoute réponse suivrePrêt sur client
    # Créer écoute réponse données sur client
    # Créer fonction oublier
    # Envoyer requète au client
    # Attendre réponse requète et rendre la fonction oublier
end

function suivreUneFois(client::Client, adresseFonction::String, args::Dict{String, Any})
    # Créer canal écoute
    # Appeler suivre
    # Lorsque première réponse, annuler tout
    # Rendre la réponse
end

function obtDonnéesTableau(client::Client, idTableau::String)
    suivreUneFois(client, "tableaux.suivreDonnées", args=Dict([("idTableau", idTableau)]))
end
