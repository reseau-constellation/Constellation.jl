function versionValide(version::AbstractString)
    composantes = split(version, ".")
    if length(composantes) != 3
        return false
    end
    for x in composantes
        if !estNumérique(x)
            return false
        end
    end
    return true
end

function estNumérique(x)
    return tryparse(Float64, x) != nothing
end

function avecServeurTest(f::Function)
    Base.Filesystem.mktempdir() do dossier
        Constellation.avecServeur(dossierOrbite=dossier, dossierSFIP=dossier) do port
            f(port)
        end
    end
end

function attendreDossierExiste(dossier::AbstractString)
    while true
        if isdir(dossier)
            return
        end
    end
end

export versionValide, estNumérique, avecServeurTest
