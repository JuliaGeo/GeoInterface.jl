# Traits interface
GeoInterface provides a traits interface, not unlike Tables.jl, by a set of functions and types for geospatial data.

## Functions
(a) a set of functions: 
```julia
isgeometry(geom)
geomtype(geom)
ncoord(geom)
getcoord(geom, i)
ngeom(geom)
getgeom(geom, i)
...
```

## Types
(b) a set of trait-types for dispatching on said functions.

The types tell GeoInterface how to interpret the input object inside a GeoInterface function and are specific for each type of Geometry.

```julia
abstract GeometryTrait
PointTrait <: AbstractPointTrait <: AbstractGeometryTrait
MultiPointTrait <: AbstractMultiPointGeometryTrait <:AbstractGeometryCollectionTrait <: AbstractGeometryTrait
...
```

## Use
For the [Packages](@ref) that implement GeoInterface, instead of needing to write specific methods
to work with their custom geometries, you can just call the above generic functions. For example:

```
julia> using ArchGDAL
julia> geom = createpolygon(...)::ArchGDAL.IGeometry  # no idea about the interface

# Inspect with GeoInterface methods
julia> isgeometry(geom)
True
julia> geomtype(geom)
GeoInterface.PolygonTrait()
julia> ext = exterior(geom);
julia> geomtype(ext)
GeoInterface.LineStringTrait()
julia> getcoords.(getpoint.(Ref(ext), 1:npoint(ext)))
[[1.,2.],[2.,3.],[1.,2.]]
julia> coords(geom)  # fallback based on ngeom & npoint above

```
