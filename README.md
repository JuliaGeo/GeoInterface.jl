# GeoInterface.jl

A Julia Protocol for Geospatial Data

## Motivation
To support operations or visualization of multiple (but similar) implementations of vector data (across `GeoJSON.jl`, `LibGEOS.jl`, etc). As a starting point, it will follow the [GEO interface](https://gist.github.com/sgillies/2217756) [1] in Python (which in turn borrows its design from the [GeoJSON specification](http://geojson.org/) [2]).

## GEO Interface

### AbstractPosition
A position can be thought of as a tuple of numbers. There must be at least two elements, and may be more. The order of elements must follow `x`, `y`, `z` order (e.g. easting, northing, altitude for coordinates in a projected coordinate reference system, or longitude, latitude, altitude for coordinates in a geographic coordinate reference system). It requires the following methods:

- `xcoord(::AbstractPosition)::Float64`
- `ycoord(::AbstractPosition)::Float64`
- `zcoord(::AbstractPosition)::Float64`
- `hasz(::AbstractPosition)::Bool` (`false` by default)

Remark: Although the specification allows the representation of up to 3 dimensions, not all algorithms support require all 3 dimensions. Also, if you are working with an arbitrary `obj::AbstractPosition`, you should call `hasz(obj)` before calling `zcoord(obj)`.

### AbstractGeometry
Represents vector geometry, and encompasses the following abstract types: `AbstractPoint, AbstractMultiPoint, AbstractLineString, AbstractMultiLineString, AbstractMultiPolygon, AbstractPolygon`. It requires the `coordinates` method, where

- `coordinates(::AbstractPoint)` returns a single position.
- `coordinates(::AbstractMultiPoint)` returns a vector of positions.
- `coordinates(::AbstractLineString)` returns a vector of positions.
- `coordinates(::AbstractMultiLineString)` returns a vector of linestrings.
- `coordinates(::AbstractPolygon)` returns a vector of linestrings.
- `coordinates(::AbstractMultiPolygon)` returns a vector of polygons.

### AbstractGeometryCollection
Represents a collection of geometries, and requires the `geometries` method, which returns a vector of geometries. Is also a subtype of `AbstractGeometry`.

### AbstractFeature
Represents a geometry with additional attributes, and requires the following methods

- `geometry(::AbstractFeature)::AbstractGeometry` returns the corresponding geometry
- `properties(::AbstractFeature)::Dict{AbstractString,Any}` returns a dictionary of the properties

Optionally, you can also provide the following methods

- `bbox(::AbstractFeature)::AbstractGeometry` returns the bounding box for that feature
- `crs(::AbstractFeature)::Dict{AbstractString,Any}` returns the coordinate reference system

## Geospatial Geometries
If you don't need to provide your own user types, GeoInterface also provides a set of geometries (below), which implements the GEO Interface:

- `CRS`
- `Position`
- `Geometry <: AbstractGeometry`
  - `Point <: AbstractPoint <: AbstractGeometry`
  - `MultiPoint <: AbstractMultiPoint <: AbstractGeometry`
  - `LineString <: AbstractLineString <: AbstractGeometry`
  - `MultiLineString <: AbstractMultiLineString <: AbstractGeometry`
  - `Polygon <: AbstractPolygon <: AbstractGeometry`
  - `MultiPolygon <: AbstractMultiPolygon <: AbstractGeometry`
  - `GeometryCollection <: AbstractGeometryCollection <: AbstractGeometry`
- `Feature <: AbstractFeature`
- `FeatureCollection <: AbstractFeatureCollection`

## Remarks

Conceptually,

- an `::AbstractGeometryCollection` maps to a `DataArray{::AbstractGeometry}`, and
- an `::AbstractFeatureCollection` maps to a `DataFrame`, where each row is an `AbstractFeature`

The design of the types in GeoInterface differs from the GeoJSON specification in the following ways:

- Julia Geometries do not provide a `bbox` and `crs` method. If you wish to provide a `bbox` or `crs` attribute, wrap the geometry into a `Feature` or `FeatureCollection`.
- Features do not have special fields for `id`, `bbox`, and `crs`. These are to be provided (or found) in the `properties` field, under the keys `featureid`, `bbox`, and `crs` respectively (if they exist).

## References

[1]: A Python Protocol for Geospatial Data ([gist](https://gist.github.com/sgillies/2217756))

[2]: GeoJSON Specification ([website](http://geojson.org/))
