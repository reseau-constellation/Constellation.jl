include("utils.jl")

avecServeurTest() do (port)
    Constellation.avecClient(port) do client
        
        idCompte = Constellation.action(client, "obtIdCompte")
        @test occursin("orbitdb", idCompte)

        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        @test occursin("orbitdb", idBd)

    end
end

"""
idTableau = Constellation.action(client, "bds.ajouterTableauBd", args=Dict([("idBd", idBd)]))
Constellation.action(client, "bds.ajouterNomsBd", args=Dict([("idBd", idBd), ("noms", Dict([("fr": "Météo"), ("த", "காலநிலை")]))]))

fOublier = Constellation.suivre(client, "bds.suivreNomsBd", x->noms=x) do noms
    
end

fOublier()

nomsUneFois = Constellation.suivreUneFois(client, "bds.suivreNomsBd")
Constellation.rechercher(client, "recherche.rechercherVariablesSelonNom")

données = Constellation.obtDonnéesTableau(client, idTableau)
# donnéesRéseau = Constellation.obtDonnéesRéseau()
"""
fermerServeur()