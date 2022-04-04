# Defaults
There are *many* function in SF, but most only apply to a single geometry type.
Of note here are the `ngeom` and `getgeom` for each geometry type, which translate to the following function for each type automatically:

|                            | ngeom       | getgeom       |
|----------------------------|-------------|---------------|
| [`AbstractPoint`](@ref)              | -           | -             |
| [`AbstractCurve`](@ref), [`MultiPoint`](@ref)  | [`npoint`](@ref)      | [`getpoint`](@ref)      |
| [`AbstractPolygon`](@ref)            | [`nring`](@ref)       | [`getring`](@ref)       |
| [`AbstractMultiLineString`](@ref)    | [`nlinestring`](@ref) | [`getlinestring`](@ref) |
| [`AbstractMultiPolygon`](@ref)       | [`npolygon`](@ref)    | [`getpolygon`](@ref)    |
| [`AbstractPolyhedralSurface`](@ref)  | [`npatch`](@ref)      | [`getpatch`](@ref)      |
| [`AbstractGeometryCollection`](@ref) | [`ngeom`](@ref)       | [`getgeom`](@ref)       |

## Polygons
Of note are `Polygon`s, which can have holes, for which we automatically add the following
functions based on the `ngeom` implemented by package authors.

```julia
getexterior(p::AbstractPolygon, geom) = getring(p, geom, 1)
nhole(p::AbstractPolygon, geom) = nring(p, geom) - 1
gethole(p::AbstractPolygon, geom, i) = getring(p, geom, i + 1)
```
## LineStrings
Simarly for LineStrings, we have the following
```julia
startpoint(geom) = getpoint(geom, 1)
endpoint(geom) = getpoint(geom, length(geom))
```

## Fallbacks
In some cases, we know the return value of a function for a specific geometry (sub)type beforehand and have implemented them.

```julia
npoint(::Line, _) = 2
npoint(::Triangle, _) = 3
npoint(::Rectangle, _) = 4
npoint(::Quad, _) = 4
npoint(::Pentagon, _) = 5
npoint(::Hexagon, _) = 6
```
