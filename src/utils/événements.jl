# Inspiré de https://github.com/jkroso/Emitter.jl

const Émetteur = Dict{AbstractString, Union{Vector{Function}, Function}}

lorsque(f::Function, e::Émetteur, nom::AbstractString) = lorsque(e, nom, f)
lorsque(e::Émetteur, nom::AbstractString, f::Function) = begin
  a = get!(e, nom, f)
  a === f && return
  if isa(a, Array)
    push!(a, f)
  else
    e[nom] = Function[a, f]
  end
end

lorsque(e::Émetteur, handlers::Dict) = begin
  for (key,value) in handlers
    lorsque(e, key, value)
  end
end

lorsque(e::Émetteur, nom::AbstractString, handlers::Vector) = begin
  for f in handlers
    lorsque(e, nom, f)
  end
end

oublierLorsque(e::Émetteur, nom::AbstractString, f::Function) = begin
  haskey(e, nom) || return
  if isa(e[nom], Function)
    is(e[nom], f) && delete!(e, nom)
  else
    filter!(x -> !is(x, f), e[nom])
  end
end

émettre(e::Émetteur, nom::AbstractString, args...) = begin
  haskey(e, nom) || return
  isa(e[nom], Function) && return e[nom](args...)
  for f in e[nom] f(args...) end
end