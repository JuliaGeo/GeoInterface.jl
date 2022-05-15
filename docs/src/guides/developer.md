```@meta
CurrentModule = GeoInterface
```

# Implementing GeoInterface
GeoInterface requires six functions to be defined for a custom geometry. On top of that
it could be useful to also implement some optional methods if they apply or are faster than the [Fallbacks](@ref).

If your package also supports geospatial operations on geometries--such as intersections--, please
also implement those interfaces where applicable.

Last but not least, we also provide an interface for features--geometries with properties--if applicable.

## Required for Geometry

```julia
GeoInterface.isgeometry(geom::customgeom)::Bool = true
GeoInterface.geomtype(geom::customgeom)::DataType = XTrait() # <: AbstractGeometryTrait
# for PointTraits
GeoInterface.ncoord(geomtype(geom), geom::customgeom)::Integer
GeoInterface.getcoord(geomtype(geom), geom::customgeom, i)::Real
# for non PointTraits
GeoInterface.ngeom(geomtype(geom), geom::customgeom)::Integer
GeoInterface.getgeom(geomtype(geom), geom::customgeom, i)
```
Where the `getgeom` and `getcoord` could be an iterator (without the `i`) as well. It will return a new geom with the correct `geomtype`.
This means that a call to `getgeom` on a geometry that has a `LineStringTrait` should return something that implements the `PointTrait`. This hierarchy can be checked programmatically with [`subtrait`](@ref). You read more about the `geomtype` in the [Type hierarchy](@ref).

The `ngeom` and `getgeom` are aliases for their geom specific counterparts, such as `npoints` and `getpoint` for `LineStringTrait`s.


## Optional for Geometry

There are also optional generic methods that could help with locating this geometry.
```julia
GeoInterface.crs(geomtype(geom), geom::customgeom)::GeoFormatTypes.GeoFormat}
GeoInterface.extent(geomtype(geom), geom::customgeom)::Extents.Extent
```

And lastly, there are many other optional functions for each specific geometry. GeoInterface provides fallback implementations based on the generic functions above, but these are not optimized. These are detailed in [Fallbacks](@ref).

## Required for Feature
```julia
GeoInterface.isfeature(feat::customfeat)::Bool = true
GeoInterface.properties(feat::customfeat)
GeoInterface.geometry(feat::customfeat)
```

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
GeoInterface provides a Testsuite for a geom type to check whether the required functions that have been correctly implemented and work as expected.

```julia
GeoInterface.testgeometry(geom)
GeoInterface.testfeature(geom)
```

## Examples

All custom geometries implement
```julia
GeoInterface.isgeometry(geom::customgeom)::Bool = true
```

A `geom::customgeom` with "Point"-like traits implements
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::customgeom)::Integer
GeoInterface.getcoord(::PointTrait, geom::customgeom, i)::Real

# Defaults
GeoInterface.ngeom(::PointTrait, geom)::Integer = 0
GeoInterface.getgeom(::PointTrait, geom::customgeom, i) = nothing
```

A `geom::customgeom` with "LineString"-like traits implements the following methods:
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = LineStringTrait()
GeoInterface.ncoord(::LineStringTrait, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::LineStringTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::LineStringTrait, geom::customgeom, i) # of geomtype Point

# Optional
GeoInterface.isclosed(::LineStringTrait, geom::customgeom)::Bool
GeoInterface.issimple(::LineStringTrait, geom::customgeom)::Bool
GeoInterface.length(::LineStringTrait, geom::customgeom)::Real
```
A `geom::customgeom` with "Polygon"-like traits can implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom)::DataType = PolygonTrait()
GeoInterface.ncoord(::PolygonTrait, geom::customgeom)::Integer

# These alias for nring and getring
GeoInterface.ngeom(::PolygonTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::PolygonTrait, geom::customgeom, i)::"LineStringTrait"

# Optional
GeoInterface.area(::PolygonTrait, geom::customgeom)::Real
GeoInterface.centroid(::PolygonTrait, geom::customgeom)::"PointTrait"
GeoInterface.pointonsurface(::PolygonTrait, geom::customgeom)::"PointTrait"
GeoInterface.boundary(::PolygonTrait, geom::customgeom)::"LineStringTrait"
```

A `geom::customgeom` with "GeometryCollection"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = GeometryCollectionTrait()
GeoInterface.ncoord(::GeometryCollectionTrait, geom::customgeom)::Integer
GeoInterface.ngeom(::GeometryCollectionTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::GeometryCollectionTrait,geom::customgeomm, i)::"GeometryTrait"
```

A `geom::customgeom` with "MultiPoint"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = MultiPointTrait()
GeoInterface.ncoord(::MultiPointTrait, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::MultiPointTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiPointTrait, geom::customgeom, i)::"PointTrait"
```

A `geom::customgeom` with "MultiLineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = MultiLineStringTrait()
GeoInterface.ncoord(::MultiLineStringTrait, geom::customgeom)::Integer

# These alias for nlinestring and getlinestring
GeoInterface.ngeom(::MultiLineStringTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiLineStringTrait,geom::customgeomm, i)::"LineStringTrait"
```

A `geom::customgeom` with "MultiPolygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtype(geom::customgeom) = MultiPolygonTrait()
GeoInterface.ncoord(::MultiPolygonTrait, geom::customgeom)::Integer

# These alias for npolygon and getpolygon
GeoInterface.ngeom(::MultiPolygonTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiPolygonTrait, geom::customgeom, i)::"PolygonTrait"
```
