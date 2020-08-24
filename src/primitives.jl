const Indexable = Union{AbstractVector,Tuple}

# Point
geomtype(::AbstractVector{T}) where {T <: Real} = Point()
geomtype(::Tuple{T,U}) where {T,U <: Real} = Point()
geomtype(::Tuple{T,U,V}) where {T,U,V <: Real} = Point()
ncoord(::AbstractPoint, geom::Indexable) = length(geom)
getcoord(::AbstractPoint, geom::Indexable, i::Integer) = geom[i]

# LineString
ncoord(::AbstractLineString, geom::Indexable) =
    ncoord(Point, getpoint(geom, 1))
npoint(::AbstractLineString, geom::Indexable) = length(geom)
getpoint(::AbstractLineString, geom::Indexable, i::Integer) = geom[i]

# Polygon
ncoord(::AbstractPolygon, geom::Indexable) =
    ncoord(LineString, getexterior(geom))
getexterior(::AbstractPolygon, geom::Indexable) = geom[1]
nhole(::AbstractPolygon, geom::Indexable) = length(geom) - 1
gethole(::AbstractPolygon, geom::Indexable, i::Integer) = geom[i + 1]

# MultiPoint
ncoord(::AbstractMultiPoint, geom::Indexable) =
    ncoord(Point, getpoint(geom, 1))
npoint(::AbstractMultiPoint, geom::Indexable) = length(geom)
getpoint(::AbstractMultiPoint, geom::Indexable, i::Integer) = geom[i]

# MultiLineString
ncoord(::AbstractMultiLineString, geom::Indexable) =
    ncoord(LineString, getlinestring(geom, 1))
nlinestring(::AbstractMultiLineString, geom::Indexable) = length(geom)
getlinestring(::AbstractMultiLineString, geom::Indexable, i::Integer) =
    geom[i]

# MultiPolygon
ncoord(::AbstractMultiPolygon, geom::Indexable) =
    ncoord(Polygon, getpolygon(geom, 1))
npolygon(::AbstractMultiPolygon, geom::Indexable) = length(geom)
getpolygon(::AbstractMultiPolygon, geom::Indexable, i::Integer) = geom[i]

# GeometryCollection
ncoord(::AbstractGeometryCollection, geom::Indexable) =
    ncoord(geomtype(geom), getgeom(geom, 1))
ngeom(::AbstractGeometryCollection, collection::Indexable) =
    length(collection)
getgeom(::AbstractGeometryCollection, collection::Indexable, i::Integer) =
    collection[i]
