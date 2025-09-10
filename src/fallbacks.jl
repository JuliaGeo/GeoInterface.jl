# Defaults for many of the interface functions are defined here as fallback.
# Methods here should take a trait instance as first argument and should already be defined
# in the `interface.jl` first as a generic f(geom) method.

## Coords
# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M)

coordnames(t::AbstractGeometryTrait, geom) = default_coord_names[1:ncoord(t, geom)]

@inline coordtype(::FeatureCollectionTrait, fc) = coordtype(getfeature(fc, 1))
@inline coordtype(::FeatureTrait, feature) = coordtype(geometry(feature))
@inline coordtype(::AbstractGeometryTrait, geom) = coordtype(getgeom(geom, 1))
@inline coordtype(::PointTrait, geom) = typeof(x(geom))

# Maybe hardcode dimension order? At least for X and Y?
x(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:X), coordnames(geom)))
y(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:Y), coordnames(geom)))
z(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:Z), coordnames(geom)))
m(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:M), coordnames(geom)))

is3d(::AbstractGeometryTrait, geom) = :Z in coordnames(geom)
ismeasured(::AbstractGeometryTrait, geom) = :M in coordnames(geom)
isempty(::AbstractGeometryTrait, geom) = false

## Points
ngeom(::AbstractPointTrait, geom) = 0
getgeom(::AbstractPointTrait, geom) = nothing
getgeom(::AbstractPointTrait, geom, i) = nothing

## LineStrings
npoint(t::AbstractCurveTrait, geom) = ngeom(t, geom)
getpoint(t::AbstractCurveTrait, geom) = getgeom(t, geom)
getpoint(t::AbstractCurveTrait, geom, i) = getgeom(t, geom, i)
startpoint(t::AbstractCurveTrait, geom) = getpoint(t, geom, 1)
endpoint(t::AbstractCurveTrait, geom) = getpoint(t, geom, npoint(geom))

## Polygons
nring(t::AbstractPolygonTrait, geom) = ngeom(t, geom)
getring(t::AbstractPolygonTrait, geom) = getgeom(t, geom)
getring(t::AbstractPolygonTrait, geom, i) = getgeom(t, geom, i)
getexterior(t::AbstractPolygonTrait, geom) = getring(t, geom, 1)
nhole(t::AbstractPolygonTrait, geom) = nring(t, geom) - 1
gethole(t::AbstractPolygonTrait, geom) = (getgeom(t, geom, i) for i in 2:ngeom(t, geom))
gethole(t::AbstractPolygonTrait, geom, i) = getring(t, geom, i + 1)
npoint(t::AbstractPolygonTrait, geom) = sum(npoint(p) for p in getring(t, geom))
getpoint(t::AbstractPolygonTrait, geom) = flatten((p for p in getpoint(r)) for r in getring(t, geom))

## MultiPoint
npoint(t::AbstractMultiPointTrait, geom) = ngeom(t, geom)
getpoint(t::AbstractMultiPointTrait, geom) = getgeom(t, geom)
getpoint(t::AbstractMultiPointTrait, geom, i) = getgeom(t, geom, i)

## MultiLineString
nlinestring(t::AbstractMultiCurveTrait, geom) = ngeom(t, geom)
getlinestring(t::AbstractMultiCurveTrait, geom) = getgeom(t, geom)
getlinestring(t::AbstractMultiCurveTrait, geom, i) = getgeom(t, geom, i)
npoint(t::AbstractMultiCurveTrait, geom) = sum(npoint(ls) for ls in getgeom(t, geom))
getpoint(t::AbstractMultiCurveTrait, geom) = flatten((p for p in getpoint(ls)) for ls in getgeom(t, geom))

## MultiPolygon
npolygon(t::AbstractMultiPolygonTrait, geom) = ngeom(t, geom)
getpolygon(t::AbstractMultiPolygonTrait, geom) = getgeom(t, geom)
getpolygon(t::AbstractMultiPolygonTrait, geom, i) = getgeom(t, geom, i)
nring(t::AbstractMultiPolygonTrait, geom) = sum(nring(p) for p in getpolygon(t, geom))
getring(t::AbstractMultiPolygonTrait, geom) = flatten((r for r in getring(p)) for p in getpolygon(t, geom))
npoint(t::AbstractMultiPolygonTrait, geom) = sum(npoint(r) for r in getring(t, geom))
getpoint(t::AbstractMultiPolygonTrait, geom) = flatten((p for p in getpoint(r)) for r in getring(t, geom))

## Surface
npatch(t::AbstractPolyhedralSurfaceTrait, geom)::Integer = ngeom(t, geom)
getpatch(t::AbstractPolyhedralSurfaceTrait, geom) = getgeom(t, geom)
getpatch(t::AbstractPolyhedralSurfaceTrait, geom, i::Integer) = getgeom(t, geom, i)
getpoint(t::AbstractPolyhedralSurfaceTrait, geom) = flatten((p for p in getpoint(g)) for g in getgeom(t, geom))

## Default iterator
getgeom(t::AbstractGeometryTrait, geom) = (getgeom(t, geom, i) for i in 1:ngeom(t, geom))
getcoord(t::AbstractPointTrait, geom) = (getcoord(t, geom, i) for i in 1:ncoord(t, geom))

## Special geometries
npoint(::LineTrait, geom) = 2
npoint(::TriangleTrait, geom) = 3
nring(::TriangleTrait, geom) = 1
npoint(::RectangleTrait, geom) = 4
nring(::RectangleTrait, geom) = 1
npoint(::QuadTrait, geom) = 4
nring(::QuadTrait, geom) = 1
npoint(::PentagonTrait, geom) = 5
nring(::PentagonTrait, geom) = 1
npoint(::HexagonTrait, geom) = 6
nring(::HexagonTrait, geom) = 1

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(t::AbstractCurveTrait, geom) = allunique((getpoint(t, geom, i) for i in 1:npoint(geom)-1)) && allunique((getpoint(t, geom, i) for i in 2:npoint(t, geom)))
isclosed(t::AbstractCurveTrait, geom) = getpoint(t, geom, 1) == getpoint(t, geom, npoint(t, geom))
isring(t::AbstractCurveTrait, geom) = issimple(t, geom) && isclosed(t, geom)

issimple(t::AbstractMultiPointTrait, geom) = allunique((getgeom(t, geom)))

issimple(t::AbstractMultiCurveTrait, geom) = all(issimple.(getgeom(t, geom)))
isclosed(t::AbstractMultiCurveTrait, geom) = all(isclosed.(getgeom(t, geom)))

"The key used to retrieve and store the CRS from DataAPI.jl metadata, if no other solution exists in that format."
const GEOINTERFACE_CRS_KEY = "GEOINTERFACE:crs"

crs(::Nothing, geom) = _get_dataapi_metadata(geom, GEOINTERFACE_CRS_KEY, nothing) # see `metadata.jl`
crs(::AbstractTrait, geom) = _get_dataapi_metadata(geom, GEOINTERFACE_CRS_KEY, nothing) # see `metadata.jl`

# FeatureCollection
getfeature(t::AbstractFeatureCollectionTrait, fc) = (getfeature(t, fc, i) for i in 1:nfeature(t, fc))

# Backwards compatibility
coordinates(t::AbstractPointTrait, geom) = collect(getcoord(t, geom))
coordinates(t::AbstractGeometryTrait, geom) = map(coordinates, getgeom(t, geom))
function coordinates(t::AbstractFeatureTrait, feature)
    geom = geometry(feature)
    isnothing(geom) ? [] : coordinates(geom)
end
coordinates(t::AbstractFeatureCollectionTrait, fc) = map(f -> coordinates(f), getfeature(t, fc))

extent(::Any, x) = Extents.extent(x)
function calc_extent(t::AbstractPointTrait, geom)
    x = GeoInterface.x(t, geom)
    y = GeoInterface.y(t, geom)
    if is3d(geom)
        z = GeoInterface.z(t, geom)
        return Extent(; X=(x, x), Y=(y, y), Z=(z, z))
    else
        return Extent(; X=(x, x), Y=(y, y))
    end
end
function calc_extent(t::AbstractGeometryTrait, geom)
    points = getpoint(t, geom)
    X = extrema(p -> x(p), points)
    Y = extrema(p -> y(p), points)
    if is3d(geom)
        Z = extrema(p -> z(p), points)
        Extent(; X, Y, Z)
    else
        Extent(; X, Y)
    end
end
calc_extent(t::GeometryCollectionTrait, geom) = reduce(Extents.union, (extent(f) for f in getgeom(t, geom)))
function calc_extent(::AbstractFeatureTrait, feature)
    geom = geometry(feature)
    isnothing(geom) ? nothing : extent(geom)
end
calc_extent(t::AbstractFeatureCollectionTrait, fc) = reduce(Extents.union, filter(!isnothing, collect(extent(f) for f in getfeature(t, fc))))

# Package level `GeoInterface.convert` method
# Packages must implement their own `traittype` method
# that accepts a GeoInterface.jl trait and returns the
# corresponding geometry type
function convert(package::Module, geom)
    t = trait(geom)
    convert(package, t, geom)
end
function convert(package::Module, t::AbstractTrait, geom)
    isdefined(package, :geointerface_geomtype) || throw(ArgumentError("$package does not implement `geointerface_geomtype`. Please request this be implemented in a github issue."))
    convert(package.geointerface_geomtype(t), t, geom)
end

# Subtraits

"""
    subtrait(t::AbstractGeometryTrait)

Gets the expected, possible abstract, (sub)trait for subgeometries (retrieved with
[`getgeom`](@ref)) of trait `t`. This follows the [Type hierarchy](@ref) of Simple Features.

# Examples
```jldoctest; setup = :(using GeoInterface)
julia> GeoInterface.subtrait(LineStringTrait())
AbstractPointTrait
julia> GeoInterface.subtrait(PolygonTrait())  # Any of LineStringTrait, LineTrait, LinearRingTrait
AbstractLineStringTrait
```
```jldoctest; setup = :(using GeoInterface)
# `nothing` is returned when there's no subtrait or when it's not known beforehand
julia> isnothing(GeoInterface.subtrait(PointTrait()))
true
julia> isnothing(GeoInterface.subtrait(GeometryCollectionTrait()))
true
```
"""
subtrait(::AbstractPointTrait) = nothing
subtrait(::AbstractCurveTrait) = AbstractPointTrait
subtrait(::AbstractCurvePolygonTrait) = AbstractCurveTrait
subtrait(::AbstractPolygonTrait) = AbstractLineStringTrait
subtrait(::AbstractPolyhedralSurfaceTrait) = AbstractPolygonTrait
subtrait(::TINTrait) = TriangleTrait
subtrait(::AbstractMultiPointTrait) = AbstractPointTrait
subtrait(::AbstractMultiLineStringTrait) = AbstractLineStringTrait
subtrait(::AbstractMultiPolygonTrait) = AbstractPolygonTrait
subtrait(::AbstractMultiSurfaceTrait) = AbstractSurfaceTrait
subtrait(::AbstractGeometryCollectionTrait) = nothing
subtrait(::AbstractGeometryTrait) = nothing  # fallback
