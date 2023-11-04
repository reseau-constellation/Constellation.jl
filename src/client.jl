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
                notify(cond, message["erreur"], error=true)
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


function suivreUneFois(client::Client, adresseFonction::String, args::Dict, condition::Function=x->true)
    # Créer variable pour recevoir le résultat
    résultat = nothing
    cond = Base.Event()

    # Appeler suivre
    retour = suivre(client, adresseFonction, args) do données
        résultat = données
        if condition(données)
            notify(cond)
        end
    end

    # Rendre la réponse
    wait(cond)

    # Lorsque première réponse, annuler tout
    retour["fOublier"]()

    résultat
end

function résoudreNomsColonnes(client::Client, données::Vector{Dict{String, Any}}, langues::Vector{String})
    # Extraire les ids des variables
    variables = filter(
        x -> startswith(x, "/orbitdb"), 
        unique(collect(Iterators.flatten(map((x) -> keys(x), données))))
    )

    # Rechercher les noms des variables
    nomsVariables = Dict(
        map(
            v -> (
                v, 
                suivreUneFois(
                    client, "variables.suivreNomsVariable", Dict([("idVariable", v)])
                )
            ),
            variables
        )
    )

    function trouverNom(v::AbstractString)
        # Trouver le nom d'une variable selon les langues préférées

        # Si ce n'est pas une variable, il n'y a rien à faire
        if !(v in keys(nomsVariables))
            return v
        end

        # Langues disponibles pour la variable
        languesDisponibles = collect(keys(nomsVariables[v]))

        # Langues disponible en ordre de préférence
        languesParPréférence = sort(
            languesDisponibles,
            by = x -> isnothing(findfirst(==(x), langues)) ? Inf : findfirst(==(x), langues)
        )

        # Rendre le nom traduit, si possible
        if length(languesParPréférence) > 0
            return nomsVariables[v][languesParPréférence[1]]
        else
            # Si pas possible, rendre l'id de la variable
            return v
        end
    end

    function nommerColonnes(rangée::Dict{String, Any})
        Dict(
            map(
                (c) -> (trouverNom(c), c in keys(rangée) ? rangée[c] : nothing),
                unique(vcat(collect(keys(rangée)), variables))
            )
        )
    end

    map(
        nommerColonnes,
        données
    )
end

function obtDonnéesTableau(client::Client, idTableau::AbstractString, langues::Vector{String} = String[])
    donnéesTableau = suivreUneFois(client, "tableaux.suivreDonnées", Dict([("idTableau", idTableau), ("clefsSelonVariables", true)]))
    données::Vector{Dict{String, Any}} = map((x) -> x["données"], donnéesTableau)

    donnéesAvecNoms = résoudreNomsColonnes(client, données, langues)
    DataFrames.DataFrame(donnéesAvecNoms)
end

function obtDonnéesNuée(
    client::Client, idNuée::AbstractString, clefTableau::AbstractString, langues::Vector{String} = String[], nRésultatsDésirés::Int = 1000
)
    fCond(x) = begin
        length(keys(x)) > 0
    end
    donnéesNuée = suivreUneFois(
        client, 
        "nuées.suivreDonnéesTableauNuée", 
        Dict([("idNuée", idNuée), ("clefTableau", clefTableau), ("nRésultatsDésirés", nRésultatsDésirés), ("clefsSelonVariables", true)]),
        fCond
    )

    données::Vector{Dict{String, Any}} = map(
        x -> merge(x["élément"]["données"], Dict([("Compte", x["idCompte"])])),
        donnéesNuée
    )
    donnéesAvecNoms = résoudreNomsColonnes(client, données, langues)

    DataFrames.DataFrame(donnéesAvecNoms)
end
