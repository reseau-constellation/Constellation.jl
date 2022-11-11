include("utils.jl")

# Vérifier obtention de la version du serveur
version = Constellation.obtVersionServeur()
@test versionValide(version)

# Vérifier lancement du serveur sur port libre
(port, fermerServeur) = Constellation.lancerServeur()
@test isa(port, Int)
fermerServeur()