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
GeoInterface is implemented for `NTuple`s, `NamedTuple`s and `AbstractVector`s to behave as Points. Note the `eltype` in all cases should be a `Real`. Only the keys `X`, `Y`, `Z`, and `M` are supported for `NamedTuple`s.

```julia
a = [1, 2, 3]
GeoInterface.x(a) == 1

b = (1, 2, 3)
GeoInterface.y(b) == 2

c = (;X=1, Y=2, Z=3)
GeoInterface.z(c) == 3
```

# Wrapper types

It is common that a package does not implement all objects supported by
GeoInterface.jl, and may lack the ability to define features. It is useful
to define generic objects that can be used in testing and for scripting where
geometries need to be constructed from components. Using generic wrappers 
means this is backend agnostic: the same code will work if geometries come from
GeoJSON.jl, Shapefile.jl, LibGEOS.jl, or other packages defining GeoInterface.jl
traits.

Wrapper types are provided for constructing geometries out of any lower-level
components that implement GeoInterface.jl traits. These wrappers can wrap
objects of the same trait (possibly to add extent data), vectors of child
objects, or nested vectors of lower level children, such as points.

As an example, we can construct a polygon from any GeoInterface.jl compatible 
geometries that return `LinearRingTrait` from `GeoInterface.geomtrait`:

```julia
poly = Polygon([interior, hole1, hole2])
```

See the API documentation for each wrapper for more details.

- [`Point`](@ref)
- [`Line`](@ref)
- [`LineString`](@ref)
- [`LinearRing`](@ref)
- [`Polygon`](@ref)
- [`MultiLineString`](@ref)
- [`MultiPolygon`](@ref)
- [`MultiPoint`](@ref)
- [`PolyhedralSurface`](@ref)
- [`GeometryCollection`](@ref)

Wrappers for Triangle, Hexagon and some other geometries are yet to be implemented.
Please make a GitHub issue if you need them.

Feature and FeatureCollection wrappers are also provided, to add properties,
crs and extents to any GeoInterface.jl compatible geometries.

- [`Feature`](@ref)
- [`FeatureCollection`](@ref)

