"""Test whether the interface for your `geom` has been implemented correctly."""
function test_interface_for_geom(geom)
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
