```@meta
CurrentModule = LazySets
```

# [Empty set (EmptySet)](@id def_EmptySet)

```@docs
EmptySet
∅
dim(::EmptySet)
σ(::AbstractVector, ::EmptySet)
ρ(::AbstractVector, ::EmptySet)
∈(::AbstractVector, ::EmptySet)
an_element(::EmptySet)
rand(::Type{EmptySet})
isbounded(::EmptySet)
isempty(::EmptySet)
isuniversal(::EmptySet{N}, ::Bool=false) where {N}
vertices(::EmptySet)
vertices_list(::EmptySet)
norm(::EmptySet, ::Real=Inf)
radius(::EmptySet, ::Real=Inf)
diameter(::EmptySet, ::Real=Inf)
linear_map(::AbstractMatrix{N}, ::EmptySet{N}) where {N}
translate(::EmptySet, ::AbstractVector)
plot_recipe(::EmptySet{N}, ::Any=zero(N)) where {N}
RecipesBase.apply_recipe(::AbstractDict{Symbol,Any}, ::EmptySet{N}, ::N=zero(N)) where {N}
area(::EmptySet)
volume(::EmptySet{N}) where {N}
chebyshev_center_radius(::EmptySet; kwargs...)
low(::EmptySet)
high(::EmptySet)
low(::EmptySet, ::Int)
high(::EmptySet, ::Int)
rectify(::EmptySet)
```
Inherited from [`ConvexSet`](@ref):
* [`singleton_list`](@ref singleton_list(::ConvexSet))
