include("utils.jl")

# Vérifier obtention de la version du serveur
version = Constellation.obtVersionServeur()
@test versionValide(version)

# Vérifier lancement du serveur sur port libre
Constellation.avecServeur() do port
    @test isa(port, Int)
end

# Vérifier lancement du serveur sur port spécifié
Constellation.avecServeur(5002) do port
    @test port == 5002
end

# Vérifier lancement du serveur sur dossier spécifique
Base.Filesystem.mktempdir() do dossier
    Constellation.avecServeur(dossierOrbite=dossier, dossierSFIP=dossier) do port
        @test isa(port, Int)
        attendreDossierExiste(dossier)
    end
end
