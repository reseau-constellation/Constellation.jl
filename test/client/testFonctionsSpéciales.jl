include("../utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        donnéesTableau = Constellation.obtDonnéesTableau(client, idTableau)
        printf(donnéesTableau)
        @test
        
        donnéesRéseau = Constellation.obtDonnéesNuée(client, idNuée)

        @test
    end
end
