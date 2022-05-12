"""Test whether the required interface for your `geom` has been implemented correctly."""
function testgeometry(geom)
    try
        @assert isgeometry(geom)
        type = geomtype(geom)

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
                    @assert geomtype(g2) isa subtype
                end
                @assert testgeometry(g2)  # recursive testing of subgeometries
            end
        end
    catch e
        println("You're missing an implementation: $e")
        return false
    end
    return true
end

"""Test whether the required interface for your `feature` has been implemented correctly."""
function testfeature(feature)
    try
        @assert isfeature(feature)
        geom = geometry(feature)
        @assert isgeometry(geom)
        props = properties(feature)
    catch e
        println("You're missing an implementation: $e")
        return false
    end
    return true
end
