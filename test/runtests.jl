using GeoInterface
using Test

@testset "Comparison operators" begin
    # Points are now compared by value:
    pt1, pt2, pt3 = Point([0.0, 0.0]), Point([0.0, 0.0]), Point([0.0, 1.0])
    @test pt1 == pt1
    @test pt1 == pt2
    @test pt1 != pt3

    # Also, the hash is based on the coordinates
    @test hash(pt1) == hash(pt1)
    @test hash(pt1) == hash(pt2)
    @test hash(pt1) != hash(pt3)

    # Implicitly, this should also work for `isequal`:
    @test isequal(pt1, pt1)
    @test isequal(pt1, pt2)
    @test !isequal(pt1, pt3)

    # Can also do approximate comparisons
    pt4 = Point([0.0, 1.001])
    @test pt3 != pt4
    @test pt3 ≉ pt4  atol=0.0001
    @test pt3 ≉ pt4  rtol=0.0001
    @test pt3 ≈ pt4  atol=0.001
    @test pt3 ≈ pt4  rtol=0.001

    # The same is not true for other geometry types: The representation is not
    # unique, so comparing the coordinates directly might be misleading.
    pg1 = Polygon([[[0.0, 0.0], [1.0, 0.0], [0.0, 1.0]]])
    pg2 = Polygon([[[0.0, 0.0], [1.0, 0.0], [0.0, 1.0]]])
    pg3 = Polygon([[[1.0, 0.0], [0.0, 1.0], [0.0, 0.0]]])
    @test pg1 == pg1   # same objects
    @test pg1 != pg2   # same values, but different objects
    @test pg1 != pg3   # equivalent, but not same values
end
