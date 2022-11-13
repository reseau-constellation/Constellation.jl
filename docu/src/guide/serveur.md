# Nœud local
Vous devez lancer un nœud Constellation sur votre ordinateur afin d'y connecter le client Julia. Vous pouvez ce faire soit
en installant et en ouvrant l'interface Constellation sur votre ordinateur, soit avec la ligne de commande Constellation.

## Ligne de commande
Une fois le [serveur local Constellation](https://github.com/reseau-constellation/serveur-ws) installé, vous pouvez lancer un nœud comme suit :

```sh
constl lancer
> Serveur prêt sur port : 5001
```

Notez le numéro du port ; vous devrez le passer au client Julia. 

Vous pouvez également lancer un serveur à partir d'un processus Julia :

```julia
(port, fFermerServeur) = Constellation.lancerServeur()

# Lorsque vous en avez assez vu :
fFermerServeur()
```

## Lancer un nœud éphémère
Vous pouvez aussi lancer un nœud Constellation temporaire qui se fermera automatiquement une fois votre code terminé.


!!! warning "Les nœuds indépendants sont plus performants"
    Si vous comptez partager ou obtenir des données du réseau, il est préférable de lancer un nœud indépendant de votre client tel qu'indiqué ci-dessus. Le plus longtemps votre nœud est en ligne, le mieux connecté il sera au réseau. Vous obtiendrez donc de meilleurs résultats avec un nœud qui roule déjà depuis un certain temps.


```julia
import Constellation

Constellation.avecServeur() do port
    Constellation.avecClient(port) do client
        # Écrire tout le reste de son code ici
    end
end
```
