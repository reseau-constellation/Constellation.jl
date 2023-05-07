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
        println("données tableau", donnéesTableau)
        
        # En spécifiant la langue
        # donnéesTableauLangue = Constellation.obtDonnéesTableau(client, idTableau, ["த", "fr"])
        # println("données tableau langue", donnéesTableauLangue)

        # donnéesRéseau = Constellation.obtDonnéesNuée(client, idNuée)

    end
end
