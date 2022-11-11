function obtVersionServeur(exe::String="constl")
    readchomp(`$exe version`)
end

function lancerServeur(port::Int=0, exe::String="constl")
    if port != 0
        optPort = string(" --port ", port)
    else
        optPort = ""
    end
    commande = `$exe lancer $optPort`
    proc = open(commande)
    while true
        sortie = readline(proc)
        if occursin("Serveur prêt sur port :", sortie)
            portFinal = parse(Int, split(sortie, ":")[2])
            return (portFinal, ()->kill(proc))
        end
    end
end
