using Constellation
using Test
@testset "Constellation.jl" begin

    @testset "Serveur" begin
        include("testServeur.jl")
    end

    @testset "Client : action et suivi" begin
        include("client/testActionSuivi.jl")
    end

    @testset "Client : recherche" begin
        include("client/testRecherche.jl")
    end

end
