"""
    LocalApproximation{N, VN<:AbstractVector{N}}

Type that represents a local approximation in 2D.

### Fields

- `p1`        -- first inner point
- `d1`        -- first direction
- `p2`        -- second inner point
- `d2`        -- second direction
- `q`         -- intersection of the lines l1 ⟂ d1 at p1 and l2 ⟂ d2 at p2
- `refinable` -- flag stating whether this approximation is refinable
- `err`       -- error upper bound

### Notes

The criteria for being refinable are determined in [`new_approx`](@ref).
"""
struct LocalApproximation{N, VN<:AbstractVector{N}}
    p1::VN
    d1::VN
    p2::VN
    d2::VN
    q::VN
    refinable::Bool
    err::N
end

"""
    convert(::Type{HalfSpace}, approx::LocalApproximation)

Convert a local approximation to a half-space.

### Input

- `approx` -- local approximation

### Output

A half-space.
"""
function convert(::Type{HalfSpace}, approx::LocalApproximation)
    return HalfSpace(approx.d1, dot(approx.d1, approx.p1))
end

"""
    PolygonalOverapproximation{N, SN<:LazySet{N}, VN<:AbstractVector{N}}

Type that represents a polygonal overapproximation of a convex set.

### Fields

- `S`            -- convex set
- `approx_stack` -- stack of local approximations that still need to be examined
- `constraints`  -- vector of half-spaces that are already finalized
                    (i.e., they satisfy the given error bound)
"""
struct PolygonalOverapproximation{N, SN<:LazySet{N}, VN<:AbstractVector{N}}
    S::SN
    approx_stack::Vector{LocalApproximation{N, VN}}
    constraints::Vector{HalfSpace{N, VN}}
end

function PolygonalOverapproximation(S::SN) where {N, SN<:LazySet{N}}
    empty_local_approx = Vector{LocalApproximation{N, Vector{N}}}()
    empty_constraints = Vector{HalfSpace{N,Vector{N}}}()
    return PolygonalOverapproximation(S, empty_local_approx, empty_constraints)
end

"""
    new_approx(S::LazySet, p1::VN, d1::VN,
               p2::VN, d2::VN) where {N<:AbstractFloat, VN<:AbstractVector{N}}

Create a `LocalApproximation` instance for the given excerpt of a polygonal
overapproximation.

### Input

- `S`  -- convex set
- `p1` -- first inner point
- `d1` -- first direction
- `p2` -- second inner point
- `d2` -- second direction

### Output

A local approximation of `S` in the given directions.
"""
function new_approx(S::LazySet, p1::VN, d1::VN,
                    p2::VN, d2::VN) where {N<:AbstractFloat, VN<:AbstractVector{N}}
    if norm(p1-p2, 2) <= _rtol(N)
        # this approximation cannot be refined and we set q = p1 by convention
        q = p1
        refinable = false
        err = zero(N)
    else
        ndir = normalize([p2[2]-p1[2], p1[1]-p2[1]])
        q = element(intersection(Line2D(d1, dot(d1, p1)), Line2D(d2, dot(d2, p2))))
        err = min(norm(q - σ(ndir, S)), dot(ndir, q - p1))
        refinable = (err > _rtol(N)) && (norm(p1-q, 2) > _rtol(N)) &&
                    (norm(q-p2, 2) > _rtol(N))
    end
    return LocalApproximation(p1, d1, p2, d2, q, refinable, err)
end

"""
    addapproximation!(Ω::PolygonalOverapproximation, p1::VN, d1::VN,
                      p2::VN, d2::VN) where {N, VN<:AbstractVector{N}}

### Input

- `Ω`  -- polygonal overapproximation of a convex set
- `p1` -- first inner point
- `d1` -- first direction
- `p2` -- second inner point
- `d2` -- second direction

### Output

The list of local approximations in `Ω` of the set `Ω.S` is updated in-place and
the new approximation is returned by this function.
"""
function addapproximation!(Ω::PolygonalOverapproximation, p1::VN, d1::VN,
                           p2::VN, d2::VN) where {N, VN<:AbstractVector{N}}
    approx = new_approx(Ω.S, p1, d1, p2, d2)
    push!(Ω.approx_stack, approx)
    return approx
end

"""
    refine(approx::LocalApproximation, S::LazySet)

Refine a given local approximation of the polygonal overapproximation of a
convex set by splitting along the normal direction of the approximation.

### Input

- `approx` -- local approximation to be refined
- `S`      -- 2D convex set

### Output

The tuple consisting of the refined right and left local approximations.
"""
function refine(approx::LocalApproximation, S::LazySet)
    @assert approx.refinable
    ndir = normalize([approx.p2[2]-approx.p1[2], approx.p1[1]-approx.p2[1]])
    s = σ(ndir, S)
    ap1 = new_approx(S, approx.p1, approx.d1, s, ndir)
    ap2 = new_approx(S, s, ndir, approx.p2, approx.d2)
    return (ap1, ap2)
end

"""
    tohrep(Ω::PolygonalOverapproximation)

Convert a polygonal overapproximation into a polygon in constraint
representation.

### Input

- `Ω` -- polygonal overapproximation of a convex set

### Output

A polygon in constraint representation.

### Algorithm

Internally, the constraints of `Ω` are already sorted.
"""
function tohrep(Ω::PolygonalOverapproximation)
    # already finalized
    if isempty(Ω.approx_stack)
        return HPolygon(Ω.constraints, sort_constraints=false)
    end
    # some constraints not finalized yet
    P = HPolygon(Ω.constraints, sort_constraints=false)
    for approx in Ω.approx_stack
        # the remaining constraints need to be sorted
        addconstraint!(P, convert(HalfSpace, approx))
    end
    return P
end

"""
    overapproximate_hausdorff(X::S, ε::Real) where {N<:AbstractFloat, S<:LazySet{N}}

Return an ε-close overapproximation of the given 2D convex set (in terms of the
Hausdorff distance) in the form of a polygon in constraint representation.

### Input

- `X` -- 2D convex set
- `ε` -- error bound

### Output

A polygon in constraint representation.
"""
function overapproximate_hausdorff(X::S, ε::Real) where {N<:AbstractFloat, S<:LazySet{N}}
    if !isconvextype(S)
        error("ε-close overapproximation requires a convex set")
    elseif dim(X) != 2
        error("ε-close overapproximation requires a two-dimensional set")
    end

    # initialize box directions
    pe = σ(DIR_EAST(N), X)
    pn = σ(DIR_NORTH(N), X)
    pw = σ(DIR_WEST(N), X)
    ps = σ(DIR_SOUTH(N), X)
    east = dir_east(N, pe)
    north = dir_north(N, pe)
    west = dir_west(N, pe)
    south = dir_south(N, pe)

    Ω = PolygonalOverapproximation(X)

    # add constraints in reverse (i.e., clockwise) order to the stack
    addapproximation!(Ω, ps, south, pe, east)
    addapproximation!(Ω, pw, west, ps, south)
    addapproximation!(Ω, pn, north, pw, west)
    addapproximation!(Ω, pe, east, pn, north)

    approx_stack = Ω.approx_stack
    while !isempty(approx_stack)
        approx = pop!(approx_stack)

        if !approx.refinable || approx.err <= ε
            # if the approximation is not refinable => continue
            push!(Ω.constraints, convert(HalfSpace, approx))
            continue
        end

        # refine
        (la1, la2) = refine(approx, Ω.S)

        if isempty(approx_stack)
            redundant = false
        else
            # check if the next local approximation became redundant
            next = approx_stack[end]
            redundant = (norm(la2.p1-next.p1) <= _rtol(N)) &&
                (norm(la2.q-next.q) <= _rtol(N))
        end
        if redundant
            # replace redundant old constraint
            approx_stack[end] = la2
        else
            # add new constraint
            push!(approx_stack, la2)
        end
        push!(approx_stack, la1)
    end
    return tohrep(Ω)
end
