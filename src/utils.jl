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
    geom = geometry(feature)
    if !isnothing(geom)
        @assert isgeometry(geom) "geom $geom from $feature doesn't implement `isgeometry`."
    end
    props = properties(feature)
    return true
end
