import DataFrames

include("../utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        idTableau = Constellation.action(client, "bds.ajouterTableauBd", Dict([("idBd", idBd)]))

        idVariable = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        Constellation.action(
            client, 
            "variables.ajouterNomsVariable", 
            Dict([("id", idVariable), ("noms", Dict([("fr", "Précipitation")]))])
        )
        idColonne = Constellation.action(
            client, 
            "tableaux.ajouterColonneTableau", Dict([("idTableau", idTableau), ("idVariable", idVariable)])
        )
        Constellation.action(
            client, 
            "tableaux.ajouterÉlément", Dict([("idTableau", idTableau), ("vals", Dict([(idColonne, 12.3)]))])
        )

        # Sans spécifier la langue
        donnéesTableau = Constellation.obtDonnéesTableau(client, idTableau)
        @test isequal(
            donnéesTableau,
            DataFrames.DataFrame([Dict([("Précipitation", 12.3)])])
        )
        
        # En spécifiant la langue
        Constellation.action(
            client, 
            "variables.ajouterNomsVariable", 
            Dict([("id", idVariable), ("noms", Dict([("த", "மழை")]))])
        )
        donnéesTableauLangue = Constellation.obtDonnéesTableau(client, idTableau, ["த", "fr"])
        @test isequal(
            donnéesTableauLangue,
            DataFrames.DataFrame([Dict([("மழை", 12.3)])])
        )

        # donnéesRéseau = Constellation.obtDonnéesNuée(client, idNuée)

    end
end
