# Approximations

This section of the manual describes the Cartesian decomposition algorithms and
the approximation of high-dimensional convex sets using projections.

```@contents
Pages = ["approximations.md"]
Depth = 3
```

```@meta
CurrentModule = LazySets.Approximations
```

```@docs
Approximations
```

## Cartesian Decomposition

```@docs
decompose
```

### Convenience functions

```@docs
uniform_partition
```

## Overapproximations

```@docs
overapproximate
LazySets.Approximations._overapproximate_zonotope_vrep
LazySets.Approximations._overapproximate_zonotope_cpa
```

## Underapproximations

```@docs
underapproximate
```

## Approximations

```@docs
approximate
```

## Box Approximations

```@docs
box_approximation
interval_hull
symmetric_interval_hull
box_approximation_symmetric
ballinf_approximation
```

## Iterative refinement

```@docs
overapproximate_hausdorff
LocalApproximation
PolygonalOverapproximation
new_approx
addapproximation!
refine(::LocalApproximation, ::LazySet)
tohrep(::PolygonalOverapproximation)
convert(::Type{HalfSpace}, ::LocalApproximation)
```

## Template directions

```@docs
AbstractDirections
isbounding
isnormalized
project(::ConvexSet, ::AbstractVector{Int}, ::Type{<:AbstractDirections})
BoxDirections
DiagDirections
OctDirections
BoxDiagDirections
PolarDirections
SphericalDirections
CustomDirections
```

See also `overapproximate(X::ConvexSet, dir::AbstractDirections)::HPolytope`.

## Hausdorff distance

```@docs
hausdorff_distance
```
