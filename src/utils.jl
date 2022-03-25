"""Test whether the interface for your `geom` has been implemented correctly."""
function testgeometry(geom)
    try
        @assert isgeometry(geom)
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
