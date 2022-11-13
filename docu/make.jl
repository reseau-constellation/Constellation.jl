using Documenter, Constellation

# Info : https://documenter.juliadocs.org/stable/man/guide/
makedocs(
    sitename="Constellation.jl",
    pages = [
        "Accueil" => "index.md",
        "Guide" => Any[
            "Serveur" => "guide/serveur.md",
            "Client" => "guide/client.md"
        ],
        "Librairie" => Any[
            "Serveur" => "librairie/serveur.md",
            "Client" => "librairie/client.md"
        ]
    ]
)
