"""
    implementing_sets(op::Function;
                      signature::Tuple{Vector{Type}, Int}=(Type[], 1),
                      type_args=Float64, binary::Bool=false)

Compute a dictionary containing information about availability of (unary or
binary) concrete set operations.

### Input

- `op`        -- set operation (respectively its `Function` object)
- `signature` -- (optional, default: `Type[]`) the type signature of the
                 function without the `LazySet` type(s) (see also the `index`
                 option and the `Examples` section below)
- `index`     -- (optional, default: `1`) index of the set type in the signature
                 in the unary case (see the `binary` option)
- `type_args` -- (optional, default: `Float64`) type arguments added to the
                 `LazySet`(s) when searching for available methods; valid
                 inputs are a type or `nothing`, and in the unary case (see the
                 `binary` option) it can also be a list of types
- `binary`    -- (optional, default: `false`) flag indicating whether `op` is a
                 binary function (`true`) or a unary function (`false`)

### Output

A dictionary with three keys each mapping to a list:
- `"available"` -- This list contains all set types such that there exists an
                   implementation of `op`.
- `"missing"`   -- This list contains all set types such that there does not
                   exist an implementation of `op`. Note that this is the
                   complement of the `"available"` list.
- `"specific"`  -- This list contains all set types such that there exists a
                   type-specific implementation. Note that those set types also
                   occur in the `"available"` list.

In the unary case, the lists contain set types.
In the binary case, the lists contain pairs of set types.

### Examples

`tovrep` is only available for polytopic set types in vertex or constraint
representation (and `HPolyhedron`).

```jldoctests implementing_sets
julia> using LazySets: implementing_sets

julia> dict = implementing_sets(tovrep);

julia> dict["available"]
6-element Vector{Type}:
 HPolygon
 HPolygonOpt
 HPolyhedron
 HPolytope
 VPolygon
 VPolytope
```

Every convex set type implements the function `σ`.

```jldoctests implementing_sets
julia> dict = implementing_sets(σ; signature=Type[AbstractVector], index=2);

julia> dict["missing"]
6-element Vector{Type}:
 Complement
 LazySets.AbstractStar
 QuadraticMap
 SimpleSparsePolynomialZonotope
 SparsePolynomialZonotope
 VPolygonNC
```

Some operations are not available for sets with rational numbers.

```jldoctests implementing_sets
julia> N = Rational{Int};

julia> dict = implementing_sets(σ; signature=Type[AbstractVector{N}], index=2, type_args=N);

julia> Ball2 ∈ dict["missing"]
true
```

For binary functions, the dictionary contains pairs of set types.
This check takes several seconds because it considers all possible set-type
combinations.

```jldoctests implementing_sets
julia> dict = LazySets.implementing_sets(convex_hull; binary=true);

julia> (HPolytope, HPolytope) ∈ dict["available"]
true
```
"""
function implementing_sets(op::Function;
                           signature::Vector{Type}=Type[],
                           index::Int=1,
                           type_args=Float64,
                           binary::Bool=false)
    function get_unary_dict()
        return Dict{String, Vector{Type}}("available" => Vector{Type}(),
                                          "missing" => Vector{Type}(),
                                          "specific" => Vector{Type}())
    end

    if !binary
        # unary case
        dict = get_unary_dict()
        _implementing_sets_unary!(dict, op, signature, index, type_args)
        return dict
    end

    # binary case by considering all set types as second argument
    binary_dict = Dict{String, Vector{Tuple{Type, Type}}}(
        "available" => Vector{Tuple{Type, Type}}(),
        "missing" => Vector{Tuple{Type, Type}}(),
        "specific" => Vector{Tuple{Type, Type}}())
    signature_copy = copy(signature)
    insert!(signature_copy, 1, LazySet)  # insert a dummy type
    for set_type in subtypes(LazySet, true)
        augmented_set_type = set_type
        try
            if type_args isa Type
                augmented_set_type = set_type{type_args}
            else
                @assert type_args == nothing "for binary functions, " *
                    "`type_args` must not be a list"
            end
        catch e
            # type combination not available
            push!(binary_dict["missing"], (set_type, LazySet))
            continue
        end
        signature_copy[1] = augmented_set_type  # replace dummy type
        unary_dict = get_unary_dict()
        _implementing_sets_unary!(unary_dict, op, signature_copy, 1, type_args)

        # create pairs
        for key in ["available", "missing", "specific"]
            i = 1
            for other_set_type in unary_dict[key]
                push!(binary_dict[key], (set_type, other_set_type))
                i += 1
            end
        end
    end
    return binary_dict
end

function _implementing_sets_unary!(dict, op, signature, index, type_args)
    function create_type_tuple(given_type)
        if isempty(signature)
            return Tuple{given_type}
        end
        # create dynamic tuple
        new_signature = copy(signature)
        insert!(new_signature, index, given_type)
        return Tuple{new_signature...}
    end

    for set_type in subtypes(LazySet, true)
        augmented_set_type = set_type
        try
            if type_args isa Type
                augmented_set_type = set_type{type_args}
            elseif type_args != nothing
                augmented_set_type = set_type{type_args...}
            end
        catch e
            # type combination not available
            push!(dict["missing"], set_type)
            continue
        end
        tuple_set_type = create_type_tuple(augmented_set_type)
        if !hasmethod(op, tuple_set_type)
            # implementation not available
            push!(dict["missing"], set_type)
            continue
        end
        # implementation available
        push!(dict["available"], set_type)

        # check if there is a type-specific method
        super_type = supertype(augmented_set_type)
        tuple_super_type = create_type_tuple(super_type)
        if !hasmethod(op, tuple_super_type)
            continue
        end
        method_set_type = which(op, tuple_set_type)
        method_super_type = which(op, tuple_super_type)
        if method_set_type != method_super_type
            push!(dict["specific"], set_type)
        end
    end
end

# check that the given coordinate i can be used to index an arbitrary element in
# the set X
@inline function _check_bounds(X, i)
    1 <= i <= dim(X) || throw(ArgumentError("there is no index at coordinate " *
        "$i because the set is of dimension $(dim(X))"))
end
