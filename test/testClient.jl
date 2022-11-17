include("utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        
        idCompte = Constellation.action(client, "obtIdCompte")
        @test occursin("orbitdb", idCompte)

        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        @test occursin("orbitdb", idBd)

        idTableau = Constellation.action(client, "bds.ajouterTableauBd", Dict([("idBd", idBd)]))
        Constellation.action(client, "bds.ajouterNomsBd", Dict([("id", idBd), ("noms", Dict([("fr", "Météo"), ("த", "காலநிலை")]))]))
        
        dicNoms = Dict([])
        fOublier = Constellation.suivre(client, "bds.suivreNomsBd", Dict([("id", idBd)])) do noms
            dicNoms = noms
        end
        @test dicNoms["fr"] == "Météo" && dicNoms["த"] == "காலநிலை"
        
        Constellation.action(client, "bds.ajouterNomsBd", Dict([("id", idBd), ("noms", Dict([("es", "Meteo")]))]))
        @test dicNoms["es"] == "Meteo"

        fOublier()

        Constellation.action(client, "bds.ajouterNomsBd", Dict([("id", idBd), ("noms", Dict([("हिं", "मौसम")]))]))
        @test !haskey(dicNoms, "हिं")

        nomsUneFois = Constellation.suivreUneFois(client, "bds.suivreNomsBd", Dict([("id", idBd)]))
        @test nomsUneFois["हिं"] == "मौसम"

    end
end

"""



fOublier()


Constellation.rechercher(client, "recherche.rechercherVariablesSelonNom")

données = Constellation.obtDonnéesTableau(client, idTableau)
# donnéesRéseau = Constellation.obtDonnéesRéseau()
"""