module Constellation

include("serveur.jl")
export avecServeur, lancerServeur, obtVersionServeur

include("client.jl")
export avecClient, Client, suivre, action, suivreUneFois

end
