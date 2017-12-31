shapecoords(geom::AbstractPoint) = [tuple(coordinates(geom)...)]
RecipesBase.@recipe f(geom::AbstractPoint) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiPoint)
    x, y = [], []
    for (xi,yi) in coordinates(geom)
        push!(x, xi); push!(y, yi)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiPoint) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractLineString)
    x, y = [], []
    for (xi,yi) in coordinates(geom)
        push!(x, xi); push!(y, yi)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractLineString) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiLineString)
    x, y = [], []
    for line in coordinates(geom)
        linex, liney = [], []
        for (xi,yi) in line
            push!(linex, xi); push!(liney, yi)
        end
        push!(x, linex); push!(y, liney)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiLineString) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractPolygon)
    x, y = [], []
    for (xi,yi) in first(coordinates(geom))
        push!(x, xi); push!(y, yi)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractPolygon) = (seriestype --> :shape; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiPolygon)
    x, y = [], []
    for poly in coordinates(geom)
        ringx, ringy = [], []
        for (xi,yi) in first(poly)
            push!(ringx, xi); push!(ringy, yi)
        end
        push!(x, ringx); push!(y, ringy)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiPolygon) = (seriestype --> :shape; legend --> :false; shapecoords(geom))
