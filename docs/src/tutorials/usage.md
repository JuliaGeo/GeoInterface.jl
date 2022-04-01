# Traits interface
GeoInterface provides a traits interface, not unlike Tables.jl, by 

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
