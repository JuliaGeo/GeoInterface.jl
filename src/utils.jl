"""Test whether the interface for your `geom` has been implemented correctly."""
function testgeometry(geom)
    try
        type = geomtype(geom)
        ncoord(geom)
        ngeom(geom)
        getgeom(geom, 1)
        if type == Point()
            getcoord(geom, 1)
        end
    catch e
        println("You're missing an implementation: $e")
        return false
    end
    return true
end

"""Test geomtype for `geom` has been implemented."""
function isgeometry(geom)
    try
        type = geomtype(geom)
    catch
        return false
    end
    return true
end
