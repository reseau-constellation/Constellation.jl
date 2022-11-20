include("../utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        variables = [Constellation.action(client, "variables.créerVariable", Dict([("catégorie", "numérique")])) for _ in 1:5]

        réponse = Constellation.suivre(
            client, "recherche.rechercherVariableSelonNom", Dict([("nom", "humidité")])
        ) do résultat
            println(résultat)
        end

        fOublier = réponse["fOublier"]
        fChangerN = réponse["fChangerN"]

        Constellation.action(client, "variables.ajouterNomVariable", Dict([("fr", "Humidité")]))

        fOublier()

    end
end
