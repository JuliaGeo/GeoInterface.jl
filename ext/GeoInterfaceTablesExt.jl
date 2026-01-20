module GeoInterfaceTablesExt

using GeoInterface
using GeoInterface.Wrappers
using Tables

# This module is meant to extend the Tables.jl interface to features and feature collections, such that they can be used with Tables.jl.
# This enables the use of the Tables.jl ecosystem with GeoInterface wrapper geometries.

# First, define the Tables interface

Tables.istable(::Type{<: Wrappers.FeatureCollection}) = true
Tables.isrowtable(::Type{<: Wrappers.FeatureCollection}) = true
Tables.rowaccess(::Type{<: Wrappers.FeatureCollection}) = true
Tables.rows(fc::Wrappers.FeatureCollection{P, C, E}) where {P <: Union{AbstractArray{<: Wrappers.Feature}, Tuple{Vararg{<: Wrappers.Feature}}}, C, E} = GeoInterface.getfeature(fc)
Tables.rows(fc::Wrappers.FeatureCollection) = Iterators.map(Wrappers.Feature, GeoInterface.getfeature(fc))
Tables.schema(fc::Wrappers.FeatureCollection) = property_schema(GeoInterface.getfeature(fc))

# Define the row access interface for feature wrappers
function Tables.getcolumn(row::Wrappers.Feature, i::Int)
    if i == 1
        return GeoInterface.geometry(row)
    else
        return GeoInterface.properties(row)[i-1]
    end
end
Tables.getcolumn(row::Wrappers.Feature, nm::Symbol) = nm === :geometry ? GeoInterface.geometry(row) : Tables.getcolumn(GeoInterface.properties(row), nm)
Tables.columnnames(row::Wrappers.Feature) = (:geometry, propertynames(GeoInterface.properties(row))...)

# Copied from GeoJSON.jl
# Credit to [Rafael Schouten](@rafaqz)
# Adapted from JSONTables.jl jsontable method
# We cannot simply use their method as we have concrete types and need the key/value pairs
# of the properties field, rather than the main object
# TODO: Is `missT` required?
# TODO: The `getfield` is probably required once
missT(::Type{Nothing}) = Missing
missT(::Type{T}) where {T} = T

function property_schema(features)
    # Otherwise find the shared names
    names = Set{Symbol}()
    types = Dict{Symbol,Type}()
    for feature in features
        props = GeoInterface.properties(feature)
        isnothing(props) && continue
        if isempty(names)
            for k in keys(props)
                k === :geometry && continue
                push!(names, k)
                types[k] = missT(typeof(props[k]))
            end
            push!(names, :geometry)
            types[:geometry] = missT(typeof(GeoInterface.geometry(feature)))
        else
            for nm in names
                T = types[nm]
                if haskey(props, nm)
                    v = props[nm]
                    if !(missT(typeof(v)) <: T)
                        types[nm] = Union{T,missT(typeof(v))}
                    end
                elseif hasfield(typeof(feature), nm)
                    v = getfield(feature, nm)
                    if !(missT(typeof(v)) <: T)
                        types[nm] = Union{T,missT(typeof(v))}
                    end
                elseif !(T isa Union && T.a === Missing)
                    types[nm] = Union{Missing,types[nm]}
                end
            end
            for (k, v) in pairs(props)
                k === :geometry && continue
                if !(k in names)
                    push!(names, k)
                    types[k] = Union{Missing,missT(typeof(v))}
                end
            end
        end
    end
    return collect(names), types
end



# Finally, define the metadata interface.  FeatureCollection wrappers have no metadata, so we simply specify geometry columns and CRS.

Tables.DataAPI.metadatasupport(::Type{<: Wrappers.FeatureCollection}) = (; read = true, write = false)
Tables.DataAPI.metadatakeys(::Wrappers.FeatureCollection) = ("GEOINTERFACE:geometrycolumns", "GEOINTERFACE:crs")
function Tables.DataAPI.metadata(fc::Wrappers.FeatureCollection, key::AbstractString; style = false)
    result = if key == "GEOINTERFACE:geometrycolumns"
        (:geometry,)
    elseif key == "GEOINTERFACE:crs"
        if isnothing(GeoInterface.crs(fc))
            nothing
            # or
            #=
            GeoFormatTypes.ESRIWellKnownText(
                """
                ENGCRS["Undefined Cartesian SRS with unknown unit",
                    EDATUM["Unknown engineering datum"],
                    CS[Cartesian,2],
                    AXIS["X",unspecified,
                        ORDER[1],
                        LENGTHUNIT["unknown",0]],
                    AXIS["Y",unspecified,
                        ORDER[2],
                        LENGTHUNIT["unknown",0]]]
                """
            )
            =#
        else
            GeoInterface.crs(fc)
        end
    else
        throw(KeyError(key))
    end

    if style
        return (result, :note)
    else
        return result
    end
end




end # module