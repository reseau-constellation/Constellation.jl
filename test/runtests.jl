using Constellation
using Test

include("utils.jl")

@testset "Constellation.jl" begin
    # Vérifier obtention de la version du serveur
    version = Constellation.obtVersionServeur()
    @test versionValide(version)

    # Vérifier lancement du serveur sur port libre
    (port, fermerServeur) = Constellation.lancerServeur()
    @test isa(port, Int)
    fermerServeur()

end
