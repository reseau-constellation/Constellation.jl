import DataFrames

include("../utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        idTableau = Constellation.action(client, "bds.ajouterTableauBd", Dict([("idBd", idBd)]))

        idVarPrécip = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        Constellation.action(
            client, 
            "variables.ajouterNomsVariable", 
            Dict([("id", idVarPrécip), ("noms", Dict([("fr", "Précipitation")]))])
        )
        idColPrécip = Constellation.action(
            client, 
            "tableaux.ajouterColonneTableau", Dict([("idTableau", idTableau), ("idVariable", idVarPrécip)])
        )
        Constellation.action(
            client, 
            "tableaux.ajouterÉlément", Dict([("idTableau", idTableau), ("vals", Dict([(idColPrécip, 12.3)]))])
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
            Dict([("id", idVarPrécip), ("noms", Dict([("த", "மழை")]))])
        )
        donnéesTableauLangue = Constellation.obtDonnéesTableau(client, idTableau, ["த", "fr"])
        @test isequal(
            donnéesTableauLangue,
            DataFrames.DataFrame([Dict([("மழை", 12.3)])])
        )

        # Variable sans nom
        idVarTempé = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        idColTempé = Constellation.action(
            client, 
            "tableaux.ajouterColonneTableau", Dict([("idTableau", idTableau), ("idVariable", idVarTempé)])
        )
        Constellation.action(
            client, 
            "tableaux.ajouterÉlément", Dict([("idTableau", idTableau), ("vals", Dict([(idColPrécip, 4), (idColTempé, 14.5)]))])
        )
        donnéesTableauVarSansNom = Constellation.obtDonnéesTableau(client, idTableau, ["த"])

        @test isequal(
            donnéesTableauVarSansNom,
            DataFrames.DataFrame([Dict([("மழை", 12.3), (idVarTempé, nothing)]), Dict([("மழை", 4), (idVarTempé, 14.5)])])
        )

    end
end

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        # donnéesRéseau = Constellation.obtDonnéesNuée(client, idNuée)
    end
end