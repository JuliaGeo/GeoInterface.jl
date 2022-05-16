```@meta
CurrentModule = GeoInterface
```

# Defaults
There are *many* function in SF, but most only apply to a single geometry type.
Of note here are the `ngeom` and `getgeom` for each geometry type, which translate to the following function for each type automatically:

|                            | ngeom       | getgeom       |
|----------------------------|-------------|---------------|
| [`AbstractPointTrait`](@ref)              | -           | -             |
| [`AbstractCurveTrait`](@ref), [`MultiPointTrait`](@ref)  | [`npoint(geom)`](@ref)      | [`getpoint(geom)`](@ref)      |
| [`AbstractPolygonTrait`](@ref)            | [`nring(geom)`](@ref)       | [`getring(geom)`](@ref)       |
| [`AbstractMultiLineStringTrait`](@ref)    | [`nlinestring(geom)`](@ref) | [`getlinestring(geom)`](@ref) |
| [`AbstractMultiPolygonTrait`](@ref)       | [`npolygon(geom)`](@ref)    | [`getpolygon(geom)`](@ref)    |
| [`AbstractPolyhedralSurfaceTrait`](@ref)  | [`npatch(geom)`](@ref)      | [`getpatch(geom)`](@ref)      |
| [`AbstractGeometryCollectionTrait`](@ref) | [`ngeom(geom)`](@ref)       | [`getgeom(geom)`](@ref)       |

## Polygons
Of note are `PolygonTrait`s, which can have holes, for which we automatically add the following
functions based on the `ngeom` implemented by package authors. In some cases, the assumptions here
are not correct (most notably Shapefile), where the second ring is not necessarily a hole, but could
be another exterior.

```julia
getexterior(p::AbstractPolygonTrait, geom) = getring(p, geom, 1)
nhole(p::AbstractPolygonTrait, geom) = nring(p, geom) - 1
gethole(p::AbstractPolygonTrait, geom, i) = getring(p, geom, i + 1)
```
## LineStrings
Similarly for `LineStringTrait`s, we have the following
```julia
startpoint(geom) = getpoint(geom, 1)
endpoint(geom) = getpoint(geom, length(geom))
```

## Fallbacks
In some cases, we know the return value of a function for a specific geometry (sub)type beforehand and have implemented them.

```julia
npoint(::LineTrait, geom) = 2
npoint(::TriangleTrait, geom) = 3
npoint(::RectangleTrait, geom) = 4
npoint(::QuadTrait, geom) = 4
npoint(::PentagonTrait, geom) = 5
npoint(::HexagonTrait, geom) = 6
```

# Implementations
GeoInterface is implemented automatically for `NTuple`s, `NamedTuple`s and `Vector`s to behave as Points.

```julia
a = [1,2,3]
x(a) == 1

b = (1,2,3)
x(b) == 2

c = (;X=1, Y=2)
x(c) == 1
```
