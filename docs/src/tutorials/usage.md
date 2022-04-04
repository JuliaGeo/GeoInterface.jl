# Traits interface
GeoInterface provides a traits interface, not unlike Tables.jl, by a set of functions and types.

## Functions
(a) a set of functions: 
```julia
isgeometry(geom)
geomtype(geom)
ncoord(geom)
ngeom(geom)
getgeom(geom::geomtype, i)
...
```

## Types
(b) a set of types for dispatching on said functions.

The types tell GeoInterface how to interpret the input object inside a GeoInterface function.

```julia
abstract Geometry
Point <: AbstractPoint <: AbstractGeometry
MultiPoint <: AbstractMultiPointGeometry <:AbstractGeometryCollection <: AbstractGeometry
...
```

## Use
For the [Packages](@ref) that implement GeoInterface, instead of needing to write specific methods
to work with their custom geometries, you can just call the above generic functions. For example:

```
julia> using ArchGDAL
julia> geom = createpolygon(...)::ArchGDAL.IGeometry  # no idea about the interface

# With GeoInterface
julia> isgeometry(geom)
True
julia> geomtype(geom)
GeoInterface.Polygon
julia> ext = exterior(geom);
julia> geomtype(ext)
GeoInterface.LineString
julia> getpoint.(Ref(ext), 1:npoint(ext))
[[1.,2.],[2.,3.],[1.,2.]]
```
