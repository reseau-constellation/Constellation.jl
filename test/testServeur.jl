include("utils.jl")

# Vérifier obtention de la version du serveur
version = Constellation.obtVersionServeur()
@test versionValide(version)

# Vérifier lancement du serveur sur port spécifié
Base.Filesystem.mktempdir() do dossier
    Constellation.avecServeur(5002, dossierOrbite=dossier, dossierSFIP=dossier) do port
        @test port == 5002
    end
end

# Vérifier lancement du serveur sur port libre et dossier spécifique
Base.Filesystem.mktempdir() do dossier
    Constellation.avecServeur(dossierOrbite=dossier, dossierSFIP=dossier) do port
        @test isa(port, Int)
        attendreDossierExiste(dossier)
    end
end
