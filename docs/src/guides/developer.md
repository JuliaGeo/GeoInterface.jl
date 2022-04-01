# Implementing GeoInterface
GeoInterface requires five functions to be defined for a given geom:

## Required

```julia
GeoInterface.isgeometry(geom::geomtype)::Bool = true
GeoInterface.geomtype(geom::geomtype)::DataType = GeoInterface.X()
GeoInterface.ncoord(geomtype(geom), geom::geomtype)::Integer
GeoInterface.getcoord(geomtype(geom), geom::geomtype, i)::Real  # only for Points
GeoInterface.ngeom(geomtype(geom), geom::geomtype)::Integer
GeoInterface.getgeom(geomtype(geom), geom::geomtype, i)  # geomtype -> GeoInterface.Y
```
Where the `getgeom` could be an iterator (without the i) as well. It will return a new geom with the correct `geomtype`. The `ngeom` and `getgeom` are aliases for their geom specific counterparts, such as `npoints` and `getpoint` for LineStrings.

## Optional

There are also optional generic methods that could help or speed up operations:
```julia
GeoInterface.crs(geom)::Union{Missing, GeoFormatTypes.CoordinateReferenceSystemFormat}
GeoInterface.extent(geom)::Extents.Extent  # geomtype -> GeoInterface.Rectangle
```

And lastly, there are many other optional functions for each specific geometry. GeoInterface provides fallback implementations based on the generic functions above, but these are not optimized. These are detailed in [Fallbacks](@ref).

## Examples

A `geom::geomtype` with "Point"-like traits implements
```julia
GeoInterface.geomtype(geom::geomtype)::DataType = GeoInterface.Point()
GeoInterface.ncoord(::GeoInterface.Point, geom::geomtype)::Integer
GeoInterface.getcoord(::GeoInterface.Point, geom::geomtype, i)::Real

# Defaults
GeoInterface.ngeom(::GeoInterface.Point, geom)::Integer = 0
GeoInterface.getgeom(::GeoInterface.Point, geom::geomtype, i) = nothing
```

A `geom::geomtype` with "LineString"-like traits implements the following methods:
```julia
GeoInterface.geomtype(geom::geomtype)::DataType = GeoInterface.LineString()
GeoInterface.ncoord(::GeoInterface.LineString, geom::geomtype)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::GeoInterface.LineString, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.LineString, geom::geomtype, i) # of geomtype Point

# Optional
GeoInterface.isclosed(::GeoInterface.LineString, geom::geomtype)::Bool
GeoInterface.issimple(::GeoInterface.LineString, geom::geomtype)::Bool
GeoInterface.length(::GeoInterface.LineString, geom::geomtype)::Real
```
A `geom::geomtype` with "Polygon"-like traits can implement the following methods:
```julia
GeoInterface.geomtype(geom::geomtype)::DataType = GeoInterface.Polygon()
GeoInterface.ncoord(::GeoInterface.Polygon, geom::geomtype)::Integer

# These alias for nring and getring
GeoInterface.ngeom(::GeoInterface.Polygon, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.Polygon, geom::geomtype, i)::"LineString"

# Optional
GeoInterface.area(::GeoInterface.Polygon, geom::geomtype)::Real
GeoInterface.centroid(::GeoInterface.Polygon, geom::geomtype)::"Point"
GeoInterface.pointonsurface(::GeoInterface.Polygon, geom::geomtype)::"Point"
GeoInterface.boundary(::GeoInterface.Polygon, geom::geomtype)::"LineString"

```
A `geom::geomtype` with "GeometryCollection"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::geomtype) = GeoInterface.GeometryCollection()
GeoInterface.ncoord(::GeoInterface.GeometryCollection, geom::geomtype)::Integer
GeoInterface.ngeom(::GeoInterface.GeometryCollection, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.GeometryCollection,geom::geomtypem, i)::"Geometry"
```
A `geom::geomtype` with "MultiPoint"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::geomtype) = GeoInterface.MultiPoint()
GeoInterface.ncoord(::GeoInterface.MultiPoint, geom::geomtype)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::GeoInterface.MultiPoint, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.MultiPoint, geom::geomtype, i)::"Point"
```
A `geom::geomtype` with "MultiLineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::geomtype) = GeoInterface.MultiLineString()
GeoInterface.ncoord(::GeoInterface.MultiLineString, geom::geomtype)::Integer

# These alias for nlinestring and getlinestring
GeoInterface.ngeom(::GeoInterface.MultiLineString, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.MultiLineString,geom::geomtypem, i)::"LineString"
```
A `geom::geomtype` with "MultiPolygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::geomtype) = GeoInterface.MultiPolygon()
GeoInterface.ncoord(::GeoInterface.MultiPolygon, geom::geomtype)::Integer

# These alias for npolygon and getpolygon
GeoInterface.ngeom(::GeoInterface.MultiPolygon, geom::geomtype)::Integer
GeoInterface.getgeom(::GeoInterface.MultiPolygon, geom::geomtype, i)::"Polygon"
```


## Testing the interface
GeoInterface provides a Testsuite for a geom type to check whether all functions that have been implemented also work as expected.

```julia
GeoInterface.testgeometry(geom)
```
