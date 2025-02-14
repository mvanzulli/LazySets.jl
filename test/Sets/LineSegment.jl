for N in [Float64, Rational{Int}, Float32]
    # random line segment
    rand(LineSegment)

    # construction
    p, q = N[1, 1], N[2, 2]
    l = LineSegment(p, q)

    # dimension
    @test dim(l) == 2

    # support vector
    @test σ(N[1, 1], l) == q
    @test σ(N[0, 1], l) == q
    @test σ(N[-1, 1], l) == q
    @test σ(N[-1, 0], l) == p
    @test σ(N[-1, -1], l) == p
    @test σ(N[0, -1], l) == p
    @test σ(N[1, -1], l) == q
    @test σ(N[1, 0], l) == q

    # boundedness
    @test isbounded(l)

    # membership
    @test N[0, 0] ∉ l
    @test N[1, 1] ∈ l
    @test N[1.5, 1.5] ∈ l
    @test N[3, 4] ∉ l
    @test N[7, 4] ∉ l
    @test N[1.5, 1.6] ∉ l

    # approximate membership test
    if N == Float64
        @test N[1.5, 1.5] ∈ LineSegment(N[1.5, 1.50000000000001], N[1.5, 2.0])
        r = LazySets._rtol(N)
        LazySets.set_rtol(N, 1e-20)
        @test !(N[1.5, 1.5] ∈ LineSegment(N[1.5, 1.50000000000001], N[1.5, 2.0]))
        LazySets.set_rtol(N, r)
    end

    # center/generators
    @test center(l) == N[1.5, 1.5]
    @test collect(generators(l)) ∈ [[N[1/2, 1/2]], [N[-1/2, -1/2]]]
    @test genmat(l) ∈ [hcat(N[1/2 1/2]), hcat(N[-1/2, -1/2])]
    @test ngens(l) == 1
    l_degenerate = LineSegment(p, p)
    @test collect(generators(l_degenerate)) == Vector{N}()
    @test genmat(l_degenerate) == Matrix{N}(undef, 2, 0)
    @test ngens(l_degenerate) == 0

    # is_polyhedral
    @test is_polyhedral(l)

    # isempty
    @test !isempty(l)

    # isuniversal
    answer, w = isuniversal(l, true)
    @test !isuniversal(l) && !answer && w ∉ l

    # an_element function
    @test an_element(l) ∈ l

    # vertices_list function
    vl = vertices_list(l)
    @test ispermutation(vl, [l.p, l.q])

    # translation
    @test translate(l, N[1, 2]) == LineSegment(N[2, 3], N[3, 4])

    # intersection emptiness
    l1 = LineSegment(N[1, 1], N[2, 2])
    l2 = LineSegment(N[2, 1], N[1, 2])
    l3 = LineSegment(N[0, 1], N[0, 2])
    l4 = LineSegment(N[1, 1], N[1, 1])
    l5 = LineSegment(N[0, 0], N[0, 0])
    l6 = LineSegment(N[13//10, 13//10], N[23//10, 23//10])
    l7 = LineSegment(N[3, 3], N[4, 4])
    l8 = LineSegment(N[1, 2], N[2, 3])
    l1_copy = LineSegment(copy(l1.p), copy(l1.q))
    intersection_empty, point = is_intersection_empty(l1, l1, true)
    @test !is_intersection_empty(l1, l1) && !intersection_empty && point ∈ l1
    intersection_empty, point = is_intersection_empty(l1, l2, true)
    @test !is_intersection_empty(l1, l2) && !intersection_empty && point ∈ l1 && point ∈ l2
    @test is_intersection_empty(l1, l3) && is_intersection_empty(l1, l3, true)[1]
    intersection_empty, point = is_intersection_empty(l1, l4, true)
    @test !is_intersection_empty(l1, l4) && !intersection_empty && point ∈ l1 && point ∈ l4
    @test is_intersection_empty(l1, l5) && is_intersection_empty(l1, l5, true)[1]
    intersection_empty, point = is_intersection_empty(l1, l6, true)
    @test !is_intersection_empty(l1, l6) && !intersection_empty && point ∈ l1 && point ∈ l6
    intersection_empty, point = is_intersection_empty(l2, l2, true)
    @test !is_intersection_empty(l2, l2) && !intersection_empty && point ∈ l2
    @test is_intersection_empty(l2, l3) && is_intersection_empty(l2, l3, true)[1]
    @test is_intersection_empty(l2, l4) && is_intersection_empty(l2, l4, true)[1]
    @test is_intersection_empty(l2, l5) && is_intersection_empty(l2, l5, true)[1]
    intersection_empty, point = is_intersection_empty(l2, l6, true)
    @test !is_intersection_empty(l2, l6) && !intersection_empty && point ∈ l2 && point ∈ l6
    intersection_empty, point = is_intersection_empty(l3, l3, true)
    @test !is_intersection_empty(l3, l3) && !intersection_empty && point ∈ l3
    @test is_intersection_empty(l3, l4) && is_intersection_empty(l3, l4, true)[1]
    @test is_intersection_empty(l3, l5) && is_intersection_empty(l3, l5, true)[1]
    @test is_intersection_empty(l3, l6) && is_intersection_empty(l3, l6, true)[1]
    intersection_empty, point = is_intersection_empty(l4, l4, true)
    @test !is_intersection_empty(l4, l4) && !intersection_empty && point ∈ l4
    @test is_intersection_empty(l4, l5) && is_intersection_empty(l4, l5, true)[1]
    @test is_intersection_empty(l4, l6) && is_intersection_empty(l4, l6, true)[1]
    intersection_empty, point = is_intersection_empty(l5, l5, true)
    @test !is_intersection_empty(l5, l5) && !intersection_empty && point ∈ l5
    @test is_intersection_empty(l5, l6) && is_intersection_empty(l5, l6, true)[1]
    intersection_empty, point = is_intersection_empty(l6, l6, true)
    @test !is_intersection_empty(l6, l6) && !intersection_empty && point ∈ l6
    @test is_intersection_empty(l1, l7) && is_intersection_empty(l1, l7, true)[1]
    @test is_intersection_empty(l1, l8) && is_intersection_empty(l1, l8, true)[1]
    intersection_empty, point = is_intersection_empty(l1, l1_copy, true)
    @test !is_intersection_empty(l1, l1_copy) && !intersection_empty && point ∈ l1

    # intersection
    s1 = LineSegment(N[-5.0,-5.0], N[5.0,5.0])
    # colinear shifted down
    s2 = LineSegment(N[-6.0,-6.0], N[4.0,4.0])
    @test intersection(s1, s2) isa LineSegment
    @test isapprox(intersection(s1, s2).p, N[-5,-5])
    @test isapprox(intersection(s1, s2).q, N[4,4])
    # parallel, not intersect
    s3 = LineSegment(N[-5.0,-4.0], N[4.0,5.0])
    @test intersection(s1, s3) isa EmptySet
    # intersect outside of segment
    s4 = LineSegment(N[0.0,10.0], N[6.0,5.0])
    @test intersection(s1, s4) isa EmptySet
    # intersect in segment
    s5 = LineSegment(N[5.0,-5.0], N[-5.0,5.0])
    @test intersection(s1, s5) isa Singleton
    @test isapprox(intersection(s1,s5).element, N[0,0])
    # parallel, no points in common
    s6 = LineSegment(N[10.0, 10.0], N[11.0,11.0])
    @test intersection(s1, s6) isa EmptySet
    # parallel one point in common
    s7 = LineSegment(N[5.0,5.0], N[6.0,6.0])
    @test intersection(s1, s7) isa Singleton
    @test isapprox(intersection(s1,s7).element, N[5,5])
    s8 = LineSegment(N[0.0,0.0], N[1.0,0.0])
    s9 = LineSegment(N[0.0,0.0], N[2.0,0.0])
    @test intersection(s9, s8) isa LineSegment
    @test isapprox(intersection(s9, s8).p, N[0,0])
    @test isapprox(intersection(s9, s8).q, N[1,0])

    # subset
    l = LineSegment(N[1, 1], N[2, 2])
    b1 = Ball1(N[1.5, 1.5], N(1.1))
    b2 = Ball1(N[1.5, 1.5], N(0.4))
    subset, point = ⊆(l, b1, true)
    @test l ⊆ b1 && subset && point == N[]
    subset, point = ⊆(l, b2, true)
    @test l ⊈ b2 && !subset && point ∈ l && point ∉ b2
    h1 = Hyperrectangle(N[1.5, 1.5], N[0.6, 0.8])
    h2 = Hyperrectangle(N[1.5, 1.5], N[0.4, 0.8])
    subset, point = ⊆(l, h1, true)
    @test l ⊆ h1 && subset && point == N[]
    subset, point = ⊆(l, h2, true)
    @test l ⊈ h2 && !subset && point ∈ l && point ∉ h2

    # halfspace_left & halfspace_right
    @test N[1, 2] ∈ halfspace_left(l)
    @test N[2, 1] ∈ halfspace_right(l)

    # constraints list
    l = LineSegment(N[0, 0], N[1, 1])
    clist = constraints_list(l)
    @test ispermutation(clist, [HalfSpace(N[1, -1], N(0)),  # x <= y
                                HalfSpace(N[-1, 1], N(0)),  # x >= y
                                HalfSpace(N[-1, -1], N(0)), # y >= -x
                                HalfSpace(N[1, 1], N(2))])  # y <= 2-x

    # conversion
    z = convert(Zonotope, l)
    G = hcat(N[1//2, 1//2])
    @test center(z) == N[1//2, 1//2] && genmat(z) ∈ [G, -G]

    # sampling
    L = LineSegment(N[0, 0], N[1, 1])
    @test sample(L) ∈ L
    @test all(x -> x ∈ L, sample(L, 10))
end
