function obtVersionServeur(exe::AbstractString="constl")
    readchomp(`$exe version`)
end


function lancerServeur(;port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString="")
    commande = [exe, "lancer"]
    if port != 0
        push!(commande, "--port", string(port))
    end
    if dossierSFIP != ""
        push!(commande, "--doss-sfip", dossierSFIP)
    end
    if dossierOrbite != ""
        push!(commande, "--doss-orbite", dossierOrbite)
    end

    proc = open(Cmd(commande))
    while true
        sortie = readline(proc)
        if occursin("Serveur prêt sur port :", sortie)
            portFinal = parse(Int, split(sortie, ":")[2])
            return (portFinal, ()->kill(proc))
        end
    end
end

function lancerServeur(
    port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString=""
)
    lancerServeur(port=port, exe=exe, dossierOrbite=dossierOrbite, dossierSFIP=dossierSFIP)
end

function avecServeur(
    f::Function,
    ;port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString=""
)
    (port, fermerServeur) = lancerServeur(port=port, exe=exe, dossierOrbite=dossierOrbite, dossierSFIP=dossierSFIP)
    f((port))
    fermerServeur()
end

function avecServeur(
    f::Function,
    port::Int=0, exe::AbstractString="constl", dossierOrbite::AbstractString="", dossierSFIP::AbstractString=""
)
    avecServeur(f, port=port, exe=exe, dossierOrbite=dossierOrbite, dossierSFIP=dossierSFIP)
end