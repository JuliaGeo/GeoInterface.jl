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
    @assert isfeature(typeof(feature)) "$feature doesn't implement `isfeature`."
    @assert trait(feature) isa AbstractFeatureTrait "$feature does not return an `AbstractFeatureTrait` for `geomtrait`."
    @assert isnothing(geomtrait(feature))
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
    @assert isfeaturecollection(typeof(fc)) "$fc doesn't implement `isfeaturecollection`."
    @assert trait(fc) isa AbstractFeatureCollectionTrait "$fc does not return an `AbstractFeatureCollectionTrait` for `geomtrait`."
    @assert isnothing(geomtrait(fc))
    @assert isa(nfeature(fc), Integer) "feature collection $fc doesn't return an `Integer` from `nfeatures`."
    if nfeature(fc) > 0
        @assert isfeature(getfeature(fc, 1)) "For $fc `getfeature(featurecollection, 1)` does not return an object where `isfeature(obj) == true`."
        @assert isfeature(getfeature(fc, nfeature(fc))) "For $fc `getfeature(featurecollection, nfeatures(featurecollection))` does not return an object where `isfeature(obj) == true`."
    else
        @warn "`nfeatures == 0` for feature collection, cannot test some properties"
    end
    @assert coordinates(fc) == coordinates.(getfeature(fc))
    @assert geometrycolumns(fc) isa NTuple "feature collection $fc doesn't return a `NTuple` from `geometrycolumns`."
    return true
end

"""
    testraster(raster)

Test whether the required interface for your `raster` has been implemented correctly.
"""
function testraster(raster)
    @assert israster(typeof(raster)) "$raster doesn't implement `israster`."
    @assert trait(raster) isa AbstractRasterTrait "$raster does not return an `AbstractRasterTrait` for `trait`."

    am = affine(raster)
    if !isnothing(am)
        @assert Base.length(am) == 2 "Raster $raster doesn't return a Tuple of length 2 for `affine`"
        l, t = am
        @assert l isa AbstractMatrix{<:Real} "Raster $raster doesn't return an `AbstractMatrix{<:Real}` for `affine`"
        @assert t isa AbstractVector{<:Real} "Raster $raster doesn't return an `AbstractVector{<:Real}` for `affine`"
        @assert size(l)[1] == size(l)[2] "Raster $raster doesn't return a square matrix for `affine`"
        @assert size(l)[1] == Base.length(t) "Raster $raster doesn't return the same dimensions for the linear and translation part of `affine`"
    end

    @assert index(raster, 1.0, 1.0) isa NTuple{2,<:Integer} "Raster $raster doesn't return a `NTuple{2,<:Real}` for `index`."
    @assert coords(raster, 1, 1) isa NTuple{2,<:Real} "Raster $raster doesn't return a `NTuple{2,<:Integer}` for `coords`."

    @assert :CoordinateReferenceSystemFormat in Symbol.(supertypes(typeof(crs(raster)))) "Raster $raster doesn't return a CoordinateReferenceSystemFormat for `crs`."
    @assert extent(raster) isa Extent "Raster $raster doesn't return an `Extent` for `extent`"
    return true
end
