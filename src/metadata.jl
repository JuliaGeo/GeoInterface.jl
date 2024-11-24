# This file contains internal helper functions to get metadata from DataAPI objects.
# At some point, it may also contain methods to set metadata.

"""
    Internal function.

## Extended help

    _get_dataapi_metadata(geom, key, default)

Get metadata associated with key `key` from some object, `geom`, that has DataAPI.jl metadata support.

If the object does not have metadata support, or the key does not exist, return `default`.
"""
function _get_dataapi_metadata(geom, key, default)
    if DataAPI.metadatasupport(GeomType).read # check that the type has metadata, and supports reading it
        if key in DataAPI.metadatakeys(geom) # check that the key exists
            return DataAPI.metadata(geom, key; style = false) # read the metadata
        end
    end
    return default
end

