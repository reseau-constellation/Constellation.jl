import DataFrames

include("../utils.jl")

avecServeurTest() do port, codeSecret
    Constellation.avecClient(port, codeSecret) do client
        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        idTableau = Constellation.action(client, "bds.ajouterTableauBd", Dict([("idBd", idBd)]))
        
        idVarPrécip = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        Constellation.action(
            client, 
            "variables.sauvegarderNomsVariable", 
            Dict([("idVariable", idVarPrécip), ("noms", Dict([("fr", "Précipitation")]))])
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

        ## Créer un tableau de référence et assurer que les colonnes sont dans le bon ordre
        référenceTableau = DataFrames.DataFrame([Dict([(idColPrécip, 12.3)])])

        DataFrames.select!(donnéesTableau,circshift(names(référenceTableau),1))
        DataFrames.select!(référenceTableau,circshift(names(référenceTableau),1))

        @test isequal(
            donnéesTableau,
            référenceTableau
        )

        # En spécifiant la langue
        Constellation.action(
            client, 
            "variables.sauvegarderNomsVariable", 
            Dict([("idVariable", idVarPrécip), ("noms", Dict([("த", "மழை")]))])
        )
        donnéesTableauLangue = Constellation.obtDonnéesTableau(client, idTableau, ["த", "fr"])

        ## Créer un tableau de référence et assurer que les colonnes sont dans le bon ordre
        référenceTableauLangue = DataFrames.DataFrame([Dict([("மழை", 12.3)])])
        DataFrames.select!(donnéesTableauLangue,circshift(names(référenceTableauLangue),1))
        DataFrames.select!(référenceTableauLangue,circshift(names(référenceTableauLangue),1))

        @test isequal(
            donnéesTableauLangue,
            référenceTableauLangue
        )

        # Variable sans nom
        idVarTempé = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        idColTempé = Constellation.action(
            client, 
            "tableaux.ajouterColonneTableau", Dict([("idTableau", idTableau), ("idVariable", idVarTempé)])
        )
        x = Constellation.action(
            client, 
            "tableaux.ajouterÉlément", Dict([
                ("idTableau", idTableau), 
                ("vals", Dict([(idColPrécip, 4), (idColTempé, 14.5)]))
            ])
        )

        donnéesTableauVarSansNom = Constellation.obtDonnéesTableau(client, idTableau, ["த"])
        
        ## Créer un tableau de référence et assurer que les colonnes sont dans le bon ordre
        référenceVarSansNom = DataFrames.DataFrame([
            Dict([("மழை", 12.3), (idColTempé, nothing)]), 
            Dict([("மழை", 4), (idColTempé, 14.5)])
        ])

        DataFrames.select!(donnéesTableauVarSansNom,circshift(names(référenceVarSansNom),1))
        DataFrames.select!(référenceVarSansNom,circshift(names(référenceVarSansNom),1))

        @test isequal(
            donnéesTableauVarSansNom,
            référenceVarSansNom
        )
        
    end
end

avecServeurTest() do port, codeSecret
    Constellation.avecClient(port, codeSecret) do client
        idCompte = Constellation.action(client, "obtIdCompte")

        idNuée = Constellation.action(client, "nuées.créerNuée")
        clefTableau = "tableau principal"
        idTableau = Constellation.action(client, "nuées.ajouterTableauNuée", Dict([("idNuée", idNuée), ("clefTableau", clefTableau)]))

        idVarPrécip = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        idVarTempé = Constellation.action(
            client, "variables.créerVariable", Dict([("catégorie", "numérique")])
        )
        Constellation.action(
            client, 
            "variables.sauvegarderNomsVariable", 
            Dict([("idVariable", idVarPrécip), ("noms", Dict([("fr", "Précipitation"), ("த", "மழை")]))])
        )
        idColPrécip = Constellation.action(
            client, 
            "nuées.ajouterColonneTableauNuée", Dict([("idTableau", idTableau), ("idVariable", idVarPrécip)])
        )
        idColTempé = Constellation.action(
            client, 
            "nuées.ajouterColonneTableauNuée", Dict([("idTableau", idTableau), ("idVariable", idVarTempé)])
        )
        sleep(2)
        
        schéma = Constellation.action(
            client, 
            "nuées.générerSchémaBdNuée", Dict([("idNuée", idNuée), ("licence", "ODbl-1_0")])
        )
        idBd = Constellation.action(
            client, 
            "bds.créerBdDeSchéma", Dict([("schéma", schéma)])
        )
        Constellation.action(
            client, 
            "bds.ajouterÉlémentÀTableauParClef", 
            Dict([
                ("idBd", idBd), ("clefTableau", clefTableau), ("vals", Dict([(idColTempé, 12.3), (idColPrécip, 4.5)]))
            ])
        )

        donnéesRéseau = Constellation.obtDonnéesTableauNuée(client, idNuée, clefTableau, ["fr"])

        ## Créer un tableau de référence et assurer que les colonnes sont dans le bon ordre
        référence = DataFrames.DataFrame([
            Dict([
                ("auteur", idCompte),
                ("Précipitation", 4.5),
                (idColTempé, 12.3)
            ])
        ])

        DataFrames.select!(donnéesRéseau,circshift(names(référence),1))
        DataFrames.select!(référence,circshift(names(référence),1))

        @test isequal(
            donnéesRéseau,
            référence
        )
    end
end