using Constellation
using Test
@testset "Constellation.jl" begin

    @testset "Serveur" begin
        include("testServeur.jl");sleep(1)
    end

    @testset "Client" begin
        include("testClient.jl");sleep(1)
    end

end
