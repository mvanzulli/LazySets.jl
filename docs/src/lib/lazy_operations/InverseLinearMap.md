```@meta
CurrentModule = LazySets
```

# [Inverse linear map (InverseLinearMap)](@id def_InverseLinearMap)

```@docs
InverseLinearMap
dim(::InverseLinearMap)
σ(::AbstractVector, ::InverseLinearMap)
ρ(::AbstractVector, ::InverseLinearMap)
∈(::AbstractVector, ::InverseLinearMap)
an_element(::InverseLinearMap)
vertices_list(::InverseLinearMap)
constraints_list(::InverseLinearMap)
linear_map(::AbstractMatrix, ::InverseLinearMap)
```

Inherited from [`AbstractAffineMap`](@ref):
* [`isempty`](@ref isempty(::AbstractAffineMap))
* [`isbounded`](@ref isbounded(::AbstractAffineMap))

Inherited from [`ConvexSet`](@ref):
* [`norm`](@ref norm(::ConvexSet, ::Real))
* [`radius`](@ref radius(::ConvexSet, ::Real))
* [`diameter`](@ref diameter(::ConvexSet, ::Real))
* [`singleton_list`](@ref singleton_list(::ConvexSet))
