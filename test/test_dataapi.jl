using Test
using GeoInterface
using GeoFormatTypes: EPSG
using DataAPI

struct TestMetadata
    geometrycolumns
    crs
end

DataAPI.metadatasupport(::Type{TestMetadata}) = (; read = true, write = false)
DataAPI.metadatakeys(::TestMetadata) = ("GEOINTERFACE:geometrycolumns", "GEOINTERFACE:crs")
function DataAPI.metadata(x::TestMetadata, key::String; style::Bool=false)
    if key === "GEOINTERFACE:geometrycolumns"
        style ? (x.geometrycolumns, :note) : x.geometrycolumns
    elseif key === "GEOINTERFACE:crs"
        style ? (x.crs, :note) : x.crs
    else
        nothing
    end
end
DataAPI.metadata(x::TestMetadata, key::String, default; style::Bool=false) = something(DataAPI.metadata(x, key; style), style ? (default, :note) : default)





@testset "DataAPI" begin
    td = TestMetadata((:g,), nothing)
    @test GeoInterface.geometrycolumns(td) == (:g,)
    @test GeoInterface.crs(td) === nothing

    td = TestMetadata((:g,), EPSG(4326))
    @test GeoInterface.geometrycolumns(td) == (:g,)
    @test GeoInterface.crs(td) == EPSG(4326)

    td = TestMetadata("geometry1", EPSG(4326))
    @test GeoInterface.geometrycolumns(td) == (:geometry1,)
    @test GeoInterface.crs(td) == EPSG(4326)
end
