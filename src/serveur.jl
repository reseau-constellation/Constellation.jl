import JSON

function obtVersionServeur(exe::AbstractString="constl")
    readchomp(`$exe version`)
end


function lancerServeur(;port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString="")
    commande = [exe, "lancer", "-m"]
    if port != 0
        push!(commande, "--port", string(port))
    end
    if dossierSFIP != ""
        push!(commande, "--doss-sfip", dossierSFIP)
    end
    if dossierOrbite != ""
        push!(commande, "--doss-orbite", dossierOrbite)
    end

    proc = open(Cmd(commande), read=true, write=true)
    
    function fFermer()
        print(proc, "\n")
        while true
            sortie = readline(proc)
            if occursin("MESSAGE MACHINE :", sortie)
                message = JSON.parse(split(sortie, "MESSAGE MACHINE :")[2])
                if (message["type"] == "NŒUD FERMÉ")
                    return
                end
            end
        end
    end
    while true
        sortie = readline(proc)
        if occursin("MESSAGE MACHINE :", sortie)
            message = JSON.parse(split(sortie, "MESSAGE MACHINE :")[2])
            if (message["type"] == "NŒUD PRÊT")
                portFinal = message["port"]
                return (portFinal, fFermer)
            end
        end
    end
end


function avecServeur(
    f::Function,
    ;port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString=""
)
    (port, fermerServeur) = lancerServeur(port=port, exe=exe, dossierOrbite=dossierOrbite, dossierSFIP=dossierSFIP)
    f((port))
    fermerServeur()
end
