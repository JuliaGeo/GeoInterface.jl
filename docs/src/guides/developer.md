# Implementing GeoInterface
GeoInterface requires six functions to be defined for a custom geometry. On top of that
it could be useful to also implement some optional methods if they apply or are faster than the fallbacks.

If your package also supports geospatial operations on geometries--such as intersections--, please
also implement those interfaces where applicable.

## Required for Geometry

```julia
GeoInterface.isgeometry(geom::customgeom)::Bool = true
GeoInterface.geomtype(geom::customgeom)::DataType = GeoInterface.X()
GeoInterface.ncoord(geomtype(geom), geom::customgeom)::Integer
GeoInterface.getcoord(geomtype(geom), geom::customgeom, i)::Real  # only for Points
GeoInterface.ngeom(geomtype(geom), geom::customgeom)::Integer
GeoInterface.getgeom(geomtype(geom), geom::customgeom, i)  # geomtype -> GeoInterface.Y
```
Where the `getgeom` could be an iterator (without the i) as well. It will return a new geom with the correct `geomtype`. The `ngeom` and `getgeom` are aliases for their geom specific counterparts, such as `npoints` and `getpoint` for LineStrings.

You read more about the `geomtype` in the [Type hierarchy](@ref).

## Optional for Geometry

There are also optional generic methods that could help with locating this geometry.
```julia
GeoInterface.crs(geomtype(geom), geom::customgeom)::GeoFormatTypes.GeoFormat}
GeoInterface.extent(geomtype(geom), geom::customgeom)::Extents.Extent
```

And lastly, there are many other optional functions for each specific geometry. GeoInterface provides fallback implementations based on the generic functions above, but these are not optimized. These are detailed in [Fallbacks](@ref).

## GeoSpatial Operations
```julia
distance(geomtype(a), geomtype(b), a, b)
buffer(geomtype(geom), geom, distance)
convexhull(geomtype(geom), geom)
```

## GeoSpatial Relations
These functions are used to describe the relations between geometries as defined in the Dimensionally Extended 9-Intersection Model ([DE-9IM](https://en.wikipedia.org/wiki/DE-9IM)).

```julia
equals(geomtype(a), geomtype(b), a, b)
disjoint(geomtype(a), geomtype(b), a, b)
intersects(geomtype(a), geomtype(b), a, b)
touches(geomtype(a), geomtype(b), a, b)
within(geomtype(a), geomtype(b), a, b)
contains(geomtype(a), geomtype(b), a, b)
overlaps(geomtype(a), geomtype(b), a, b)
crosses(geomtype(a), geomtype(b), a, b)
relate(geomtype(a), geomtype(b), a, b, relationmatrix)
```

## Geospatial Sets
```julia
symdifference(geomtype(a), geomtype(b), a, b)
difference(geomtype(a), geomtype(b), a, b)
intersection(geomtype(a), geomtype(b), a, b)
union(geomtype(a), geomtype(b), a, b)
```

## Testing the interface
GeoInterface provides a Testsuite for a geom type to check whether all functions that have been implemented also work as expected.

```julia
GeoInterface.testgeometry(geom)
```

## Examples

All custom geometies implement
```julia
GeoInterface.isgeometry(geom::customgeom)::Bool = true
```

A `geom::customgeom` with "Point"-like traits implements
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = GeoInterface.Point()
GeoInterface.ncoord(::GeoInterface.Point, geom::customgeom)::Integer
GeoInterface.getcoord(::GeoInterface.Point, geom::customgeom, i)::Real

# Defaults
GeoInterface.ngeom(::GeoInterface.Point, geom)::Integer = 0
GeoInterface.getgeom(::GeoInterface.Point, geom::customgeom, i) = nothing
```

A `geom::customgeom` with "LineString"-like traits implements the following methods:
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = GeoInterface.LineString()
GeoInterface.ncoord(::GeoInterface.LineString, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::GeoInterface.LineString, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.LineString, geom::customgeom, i) # of geomtype Point

# Optional
GeoInterface.isclosed(::GeoInterface.LineString, geom::customgeom)::Bool
GeoInterface.issimple(::GeoInterface.LineString, geom::customgeom)::Bool
GeoInterface.length(::GeoInterface.LineString, geom::customgeom)::Real
```
A `geom::customgeom` with "Polygon"-like traits can implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = GeoInterface.Polygon()
GeoInterface.ncoord(::GeoInterface.Polygon, geom::customgeom)::Integer

# These alias for nring and getring
GeoInterface.ngeom(::GeoInterface.Polygon, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.Polygon, geom::customgeom, i)::"LineString"

# Optional
GeoInterface.area(::GeoInterface.Polygon, geom::customgeom)::Real
GeoInterface.centroid(::GeoInterface.Polygon, geom::customgeom)::"Point"
GeoInterface.pointonsurface(::GeoInterface.Polygon, geom::customgeom)::"Point"
GeoInterface.boundary(::GeoInterface.Polygon, geom::customgeom)::"LineString"
```

A `geom::customgeom` with "GeometryCollection"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = GeoInterface.GeometryCollection()
GeoInterface.ncoord(::GeoInterface.GeometryCollection, geom::customgeom)::Integer
GeoInterface.ngeom(::GeoInterface.GeometryCollection, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.GeometryCollection,geom::customgeomm, i)::"Geometry"
```

A `geom::customgeom` with "MultiPoint"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = GeoInterface.MultiPoint()
GeoInterface.ncoord(::GeoInterface.MultiPoint, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::GeoInterface.MultiPoint, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.MultiPoint, geom::customgeom, i)::"Point"
```

A `geom::customgeom` with "MultiLineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = GeoInterface.MultiLineString()
GeoInterface.ncoord(::GeoInterface.MultiLineString, geom::customgeom)::Integer

# These alias for nlinestring and getlinestring
GeoInterface.ngeom(::GeoInterface.MultiLineString, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.MultiLineString,geom::customgeomm, i)::"LineString"
```

A `geom::customgeom` with "MultiPolygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = GeoInterface.MultiPolygon()
GeoInterface.ncoord(::GeoInterface.MultiPolygon, geom::customgeom)::Integer

# These alias for npolygon and getpolygon
GeoInterface.ngeom(::GeoInterface.MultiPolygon, geom::customgeom)::Integer
GeoInterface.getgeom(::GeoInterface.MultiPolygon, geom::customgeom, i)::"Polygon"
```
