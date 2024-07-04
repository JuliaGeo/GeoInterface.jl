```@meta
CurrentModule = GeoInterface
```

# Implementing GeoInterface
GeoInterface requires six functions to be defined for a custom geometry. On top of that
it could be useful to also implement some optional methods if they apply or are faster than the [Fallbacks](@ref).

If your package also supports geospatial operations on geometries--such as intersections--, please
also implement those interfaces where applicable.

Last but not least, we also provide an interface for rasters and features--geometries with properties--if applicable.

## Required for Geometry

```julia
GeoInterface.isgeometry(geom::customgeom)::Bool = true
GeoInterface.geomtrait(geom::customgeom)::DataType = XTrait() # <: AbstractGeometryTrait
# for PointTraits
GeoInterface.ncoord(geomtrait(geom), geom::customgeom)::Integer
GeoInterface.getcoord(geomtrait(geom), geom::customgeom, i)::Real
# for non PointTraits
GeoInterface.ngeom(geomtrait(geom), geom::customgeom)::Integer
GeoInterface.getgeom(geomtrait(geom), geom::customgeom, i)
```
Where the `getgeom` and `getcoord` could be an iterator (without the `i`) as well. It will return a new geom with the correct `geomtrait`.
This means that a call to `getgeom` on a geometry that has a `LineStringTrait` should return something that implements the `PointTrait`. This hierarchy can be checked programmatically with [`subtrait`](@ref). You read more about the `geomtrait` in the [Type hierarchy](@ref).

The `ngeom` and `getgeom` are aliases for their geom specific counterparts, such as `npoints` and `getpoint` for `LineStringTrait`s.


## Optional for Geometry

There are also optional generic methods that could help with locating this geometry.
```julia
GeoInterface.crs(trait(geom), geom::customgeom)::GeoFormatTypes.CoordinateReferenceSystem
GeoInterface.extent(trait(geom), geom::customgeom)::Extents.Extent
```

For extents, `Extents.extent(geom::customgeom)` is the fallback method for GeoInterface.extent, 
and can be used instead here for wider interoperability. If neither is defined,
`GeoInterface.extent` will calculate the extent from the points of the geometry.

And lastly, there are many other optional functions for each specific geometry. GeoInterface provides fallback implementations based on the generic functions above, but these are not optimized. These are detailed in [Fallbacks](@ref).

### Conversion
It is useful if others can convert any custom geometry into your
geometry type, if their custom geometry supports GeoInterface as well.
This requires the following methods, where the implementation should be defined in terms
of GeoInterface methods like `ngeom`, `getgeom`, or just `coordinates` calls.

```julia
# This method will get called on GeoInterface.convert(::Type{T}, geom)
# if geomtrait(geom) == LineStringTrait()
GeoInterface.convert(::Type{CustomLineString}, ::LineStringTrait, geom) = ...
GeoInterface.convert(::Type{CustomPolygon}, ::PolygonTrait, geom) = ...
```

## Required for Rasters
A Raster is something that is an AbstractArray
```julia
GeoInterface.israster(raster::customraster)::Bool = true
GeoInterface.trait(::customraster) = RasterTrait()
GeoInterface.extent(::RasterTrait, raster::customraster)::Extents.Extent
GeoInterface.crs(::RasterTrait, raster::customraster)::GeoFormatTypes.CoordinateReferenceSystem
```

## Required for Feature(Collection)s
A Feature is a geometry with properties, and in modern parlance, a row in table.
A FeatureCollection is thus a Vector of Features, often represented as a table.

A Feature implements the following:
```julia
GeoInterface.isfeature(feat::customfeat)::Bool = true
GeoInterface.properties(feat::customfeat)
GeoInterface.geometry(feat::customfeat)
```

While a FeatureCollection implements the following:
```julia
GeoInterface.isfeaturecollection(::Type{customcollection}) = true
GeoInterface.getfeature(trait(::customcollection), ::customcollection, i)
GeoInterface.nfeature(trait(::customcollection), ::customcollection)
GeoInterface.geometrycolumns(::customcollection) = (:geometry,)  # can be multiple!
```

The `geometrycolumns` enables other packages to know which field in a row, or column in a table, contains the geometry or geometries.

## Geospatial Operations
```julia
distance(geomtrait(a), geomtrait(b), a, b)
buffer(geomtrait(geom), geom, distance)
convexhull(geomtrait(geom), geom)
```

## Geospatial Relations
These functions are used to describe the relations between geometries as defined in the Dimensionally Extended 9-Intersection Model ([DE-9IM](https://en.wikipedia.org/wiki/DE-9IM)).

```julia
equals(geomtrait(a), geomtrait(b), a, b)
disjoint(geomtrait(a), geomtrait(b), a, b)
intersects(geomtrait(a), geomtrait(b), a, b)
touches(geomtrait(a), geomtrait(b), a, b)
within(geomtrait(a), geomtrait(b), a, b)
contains(geomtrait(a), geomtrait(b), a, b)
overlaps(geomtrait(a), geomtrait(b), a, b)
crosses(geomtrait(a), geomtrait(b), a, b)
relate(geomtrait(a), geomtrait(b), a, b, relationmatrix)
```

## Geospatial Sets
```julia
symdifference(geomtrait(a), geomtrait(b), a, b)
difference(geomtrait(a), geomtrait(b), a, b)
intersection(geomtrait(a), geomtrait(b), a, b)
union(geomtrait(a), geomtrait(b), a, b)
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
GeoInterface.geomtrait(geom::customgeom)::DataType = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::customgeom)::Integer
GeoInterface.getcoord(::PointTrait, geom::customgeom, i)::Real

# Defaults
GeoInterface.ngeom(::PointTrait, geom)::Integer = 0
GeoInterface.getgeom(::PointTrait, geom::customgeom, i) = nothing
```

A `geom::customgeom` with "LineString"-like traits implements the following methods:
```julia
GeoInterface.geomtrait(geom::customgeom)::DataType = LineStringTrait()
GeoInterface.ncoord(::LineStringTrait, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::LineStringTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::LineStringTrait, geom::customgeom, i) # of geomtrait Point

# Optional
GeoInterface.isclosed(::LineStringTrait, geom::customgeom)::Bool
GeoInterface.issimple(::LineStringTrait, geom::customgeom)::Bool
GeoInterface.length(::LineStringTrait, geom::customgeom)::Real
```
A `geom::customgeom` with "Polygon"-like traits can implement the following methods:
```julia
GeoInterface.geomtrait(geom::customgeom)::DataType = PolygonTrait()
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
GeoInterface.geomtrait(geom::customgeom) = GeometryCollectionTrait()
GeoInterface.ncoord(::GeometryCollectionTrait, geom::customgeom)::Integer
GeoInterface.ngeom(::GeometryCollectionTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::GeometryCollectionTrait,geom::customgeomm, i)::"GeometryTrait"
```

A `geom::customgeom` with "MultiPoint"-like traits has to implement the following methods:
```julia
GeoInterface.geomtrait(geom::customgeom) = MultiPointTrait()
GeoInterface.ncoord(::MultiPointTrait, geom::customgeom)::Integer

# These alias for npoint and getpoint
GeoInterface.ngeom(::MultiPointTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiPointTrait, geom::customgeom, i)::"PointTrait"
```

A `geom::customgeom` with "MultiLineString"-like traits has to implement the following methods:
```julia
GeoInterface.geomtrait(geom::customgeom) = MultiLineStringTrait()
GeoInterface.ncoord(::MultiLineStringTrait, geom::customgeom)::Integer

# These alias for nlinestring and getlinestring
GeoInterface.ngeom(::MultiLineStringTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiLineStringTrait,geom::customgeomm, i)::"LineStringTrait"
```

A `geom::customgeom` with "MultiPolygon"-like traits has to implement the following methods:
```julia
GeoInterface.geomtrait(geom::customgeom) = MultiPolygonTrait()
GeoInterface.ncoord(::MultiPolygonTrait, geom::customgeom)::Integer

# These alias for npolygon and getpolygon
GeoInterface.ngeom(::MultiPolygonTrait, geom::customgeom)::Integer
GeoInterface.getgeom(::MultiPolygonTrait, geom::customgeom, i)::"PolygonTrait"
```
