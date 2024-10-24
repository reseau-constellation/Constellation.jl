include("../utils.jl")

avecServeurTest() do port, codeSecret
    Constellation.avecClient(port, codeSecret) do client
        
        # Créer 5 variables pour rechercher
        variables = [Constellation.action(client, "variables.créerVariable", Dict([("catégorie", "numérique")])) for _ in 1:4]

        résultatsRecherche = []
        réponse = Constellation.suivre(
            client, "recherche.rechercherVariablesSelonNom", Dict([("nomVariable", "humidité"), ("nRésultatsDésirés", 3)])
        ) do résultat
            résultatsRecherche = résultat
        end

        # Nos fonctions de contrôle
        fOublier = réponse["fOublier"]
        fChangerN = réponse["fChangerN"]

        # Détecter nouvelles variables
        Constellation.action(client, "variables.sauvegarderNomsVariable", Dict([("idVariable", variables[1]), ("noms", Dict([("fr", "Humidite")]))]))
        Constellation.action(client, "variables.sauvegarderNomsVariable", Dict([("idVariable", variables[2]), ("noms", Dict([("fr", "humidite")]))]))
        
        sleep(2)
        @test [r["id"] for r in résultatsRecherche] == [variables[2], variables[1]]

        # Diminuer N
        fChangerN(1)
        sleep(1)
        @test length(résultatsRecherche) == 1
        @test résultatsRecherche[1]["id"] == variables[2]  # Le meilleur résultat devrait être retenu

        # Améliorer résultat recherche
        Constellation.action(client, "variables.sauvegarderNomsVariable", Dict([("idVariable", variables[3]), ("noms", Dict([("fr", "humidité")]))]))
        sleep(2)
        @test résultatsRecherche[1]["id"] == variables[3]

        # Augmenter N
        fChangerN(4)
        sleep(1)
        @test length(résultatsRecherche) == 3

        # Arrêter le suivi
        fOublier()

        # Vérifier que les résultats ne sont plus réactifs
        Constellation.action(client, "variables.sauvegarderNomsVariable", Dict([("idVariable", variables[4]), ("noms", Dict([("fr", "humidité")]))]))
        @test length(résultatsRecherche) == 3

    end
end
