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

function lancerServeurTest(f::Function)
    Base.Filesystem.mktempdir() do dossier
        (port, fermerServeur) = Constellation.lancerServeur(dossierOrbite=dossier, dossierSFIP=dossier)
        f((port, fermerServeur))
        fermerServeur()
    end
end

export versionValide, estNumérique, lancerServeurTest
