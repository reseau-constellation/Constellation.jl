include("utils.jl")

lancerServeurTest() do (port, fermerServeur)
    println("ici", 1)
    client = Constellation.Client(port)

    # idCompte = @sync Constellation.action(client, "obtIdCompte")
    # println("idCompte", idCompte)
    # idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
    # println("ici", 4)
end
"""
idTableau = Constellation.action(client, "bds.ajouterTableauBd", args=Dict([("idBd", idBd)]))
Constellation.action(client, "bds.ajouterNomsBd", args=Dict([("idBd", idBd), ("noms", Dict([("fr": "Météo"), ("த", "காலநிலை")]))]))

noms = nothing
fOublier = Constellation.suivre(client, "bds.suivreNomsBd", x->noms=x)

fOublier()

nomsUneFois = Constellation.suivreUneFois(client, "bds.suivreNomsBd")
Constellation.rechercher(client, "recherche.rechercherVariablesSelonNom")

données = Constellation.obtDonnéesTableau(client, idTableau)
# donnéesRéseau = Constellation.obtDonnéesRéseau()
"""
fermerServeur()