<p align="center">
  <a href="https://réseau-constellation.ca" title="Constellation">
    <img src="https://raw.githubusercontent.com/reseau-constellation/Constellation.jl/principale/docu/src/assets/logo.svg"
        alt="Logo Constellation.jl" width="244" 
    />
  </a>
</p>

<h1 align="center">Client Constellation Julia</h1>

<p align="center">Un client Julia pour communiquer avec le réseau Constellation.</p>
<p align="center">
    <a href="https://codecov.io/gh/reseau-constellation/Constellation.jl" > 
        <img 
            src="https://codecov.io/gh/reseau-constellation/Constellation.jl/branch/main/graph/badge.svg?token=1HbFsyDC8y" alt="Statut tests"
        /> 
    </a>
    <a href="https://github.com/reseau-constellation/Constellation.jl/actions/workflows/CI.yml" > 
        <img 
            src="https://github.com/reseau-constellation/Constellation.jl/actions/workflows/CI.yml/badge.svg"
            alt="Couverture tests"
        /> 
    </a>
</p>

## Installation
Ce paquet est tout nouveau et n'est pas encore publié sur le dépôt de paquets Julia. Mais si vous êtes impatiente, vous pouvez l'installer ainsi :

```
pkg> add https://github.com/reseau-constellation/Constellation.jl.git
```

Vous devrez également installer Constellation elle-même (vous aurez besoin de [Node.js](https://nodejs.org/fr/) et [pnpm](https://pnpm.io/), si vous ne l'avez pas déjà):

```sh
$ npm add -g pnpm
$ pnpm add -g @constl/ipa @constl/serveur
```

Et voilà !

## Guide
On vous recommande la documentation complète. Mais en bref, toutes les fonctionnalités de Constellation sont disponsibles.

```julia
import Constellation

# D'abord, lancer le nœud local
Constellation.avecServeur() do port

    # 
    Constellation.avecClient(port) do client
        # Écrire tout le reste de son code ici

        # Par exemple :
        idCompte = Constellation.action(client, "obtIdCompte")
        @test occursin("orbitdb", idCompte)

        idBd = Constellation.action(client, "bds.créerBd", Dict([("licence", "ODbl-1_0")]))
        @test occursin("orbitdb", idBd)
    end
end
```