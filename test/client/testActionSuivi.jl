include("../utils.jl")

avecServeurTest() do port, codeSecret
    Constellation.avecClient(port, codeSecret) do client
        
        # Action sans arguments
        idCompte = Constellation.action(client, "obtIdCompte")
        @test occursin("orbitdb", idCompte)

        # Action avec arguments
        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        @test occursin("orbitdb", idBd)

        # Fonction suivi
        idTableau = Constellation.action(client, "bds.ajouterTableauBd", Dict([("idBd", idBd)]))
        Constellation.action(client, "bds.sauvegarderNomsBd", Dict([("idBd", idBd), ("noms", Dict([("fr", "Météo"), ("த", "காலநிலை")]))]))
        
        dicNoms = Dict([])
        réponse = Constellation.suivre(client, "bds.suivreNomsBd", Dict([("idBd", idBd)])) do noms
            dicNoms = noms
        end
        sleep(2)
        @test dicNoms["fr"] == "Météo" && dicNoms["த"] == "காலநிலை"
        
        # Suivi reste réactif
        Constellation.action(client, "bds.sauvegarderNomsBd", Dict([("idBd", idBd), ("noms", Dict([("es", "Meteo")]))]))
        sleep(2)
        @test dicNoms["es"] == "Meteo"
        
        réponse["fOublier"]()  # Annuler suivi
        
        # Suivi n'est plus réactif après `fOublier()`
        Constellation.action(client, "bds.sauvegarderNomsBd", Dict([("idBd", idBd), ("noms", Dict([("हिं", "मौसम")]))]))
        @test !haskey(dicNoms, "हिं")

        # Suivi une seule fois
        nomsUneFois = Constellation.suivreUneFois(client, "bds.suivreNomsBd", Dict([("idBd", idBd)]))
        @test nomsUneFois["हिं"] == "मौसम"

        # Erreur si la fonction n'existe pas
        @test_throws "n'est pas une fonction." Constellation.action(client, "je.ne.suis.pasUneFonction")

    end
end
