"""
    testgeometry(geom)

Test whether the required interface for your `geom` has been implemented correctly.
"""
function testgeometry(geom)
    @assert isgeometry(geom) "$geom doesn't implement `isgeometry`."
    type = geomtrait(geom)
    @assert !isnothing(type) "$geom doesn't implement `geomtrait`."

    if type == PointTrait()
        n = ncoord(geom)
        if n >= 1  # point could be empty
            getcoord(geom, 1)  # point always needs at least 2
        end
    else
        n = ngeom(geom)
        if n >= 1  # geometry could be empty
            g2 = getgeom(geom, 1)
            subtype = subtrait(type)
            if !isnothing(subtype)
                issub = geomtrait(g2) isa subtype
                !issub && error("Implemented hierarchy for $geom type is incorrect. Subgeometry should be a $subtype")
            end
            @assert testgeometry(g2) "Subgeometry implementation is not valid."
        end
    end
    return true
end

"""
    testfeature(feature)

Test whether the required interface for your `feature` has been implemented correctly.
"""
function testfeature(feature)
    @assert isfeature(feature) "$feature doesn't implement `isfeature`."
    @assert geomtrait(feature) isa AbstractFeatureTrait "$feature does not return an `AbstractFeatureTrait` for `geomtrait`."
    geom = geometry(feature)
    if !isnothing(geom)
        @assert isgeometry(geom) "geom $geom from $feature doesn't implement `isgeometry`."
        @assert coordinates(feature) == coordinates(geometry(feature))
    end

    props = properties(feature)
    if !isnothing(props)
        @assert first(propertynames(props)) isa Symbol "`propertynames` of $props does not return an iterable of `Symbol`"
        map(n -> getproperty(props, n), propertynames(props))  
    end
    ext = extent(feature)
    @assert ext isa Union{Nothing,Extent}
    return true
end

"""
    testfeaturecollection(featurecollection)

Test whether the required interface for your `featurecollection` has been implemented correctly.
"""
function testfeaturecollection(fc)
    @assert isfeaturecollection(fc) "$fc doesn't implement `isfeaturecollection`."
    @assert geomtrait(fc) isa AbstractFeatureCollectionTrait "$fc does not return an `AbstractFeatureCollectionTrait` for `geomtrait`."
    @assert isa(nfeature(fc), Integer) "feature collection $fc doesn't return an `Integer` from `nfeatures`."
    if nfeature(fc) > 0
        @assert isfeature(getfeature(fc, 1)) "For $fc `getfeature(featurecollection, 1)` does not return an object where `isfeature(obj) == true`."
        @assert isfeature(getfeature(fc, nfeature(fc))) "For $fc `getfeature(featurecollection, nfeatures(featurecollection))` does not return an object where `isfeature(obj) == true`."
    else
        @warn "`nfeatures == 0` for feature collection, cannot test some properties"
    end
    @assert coordinates(fc) == coordinates.(getfeature(fc))
    return true
end
