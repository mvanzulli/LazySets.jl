```@meta
CurrentModule = LazySets
```

# [Line segment (LineSegment)](@id def_LineSegment)

```@docs
LineSegment
dim(::LineSegment)
σ(::AbstractVector, ::LineSegment)
∈(::AbstractVector, ::LineSegment)
center(::LineSegment)
an_element(::LineSegment)
rand(::Type{LineSegment})
halfspace_left(::LineSegment)
halfspace_right(::LineSegment)
vertices_list(::LineSegment)
constraints_list(::LineSegment)
translate(::LineSegment, ::AbstractVector)
generators(::LineSegment)
genmat(::LineSegment)
```
Inherited from [`LazySet`](@ref):
* [`high`](@ref high(::LazySet))
* [`low`](@ref low(::LazySet))

Inherited from [`ConvexSet`](@ref):
* [`norm`](@ref norm(::ConvexSet, ::Real))
* [`radius`](@ref radius(::ConvexSet, ::Real))
* [`diameter`](@ref diameter(::ConvexSet, ::Real))
* [`singleton_list`](@ref singleton_list(::ConvexSet))
* [`high`](@ref high(::ConvexSet, ::Int))
* [`low`](@ref low(::ConvexSet, ::Int))

Inherited from [`AbstractPolytope`](@ref):
* [`isbounded`](@ref isbounded(::AbstractPolytope))
* [`volume`](@ref volume(::AbstractPolytope))

Inherited from [`AbstractCentrallySymmetricPolytope`](@ref):
* [`isempty`](@ref isempty(::AbstractCentrallySymmetricPolytope))
* [`isuniversal`](@ref isuniversal(::AbstractCentrallySymmetricPolytope))

Inherited from [`AbstractZonotope`](@ref):
* [`ngens`](@ref ngens(::AbstractZonotope))
* [`linear_map`](@ref linear_map(::AbstractMatrix, ::AbstractZonotope))
* [`order`](@ref order(::AbstractZonotope))
* [`togrep`](@ref togrep(::AbstractZonotope))
