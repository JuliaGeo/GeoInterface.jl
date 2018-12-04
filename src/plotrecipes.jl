const AxesCoord = Tuple{Int8,Int8,Int8}
const global axescoord_default = AxesCoord([1,2,0])  #default to ignore the z axis


function pointcoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :Point
    axes[3]==0 ? [tuple(coordinates(geom)[[axes[1:2]...]]...)] :
                [tuple(coordinates(geom)[[axes...]]...)]
end

function multipointcoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :MultiPoint
    coords = coordinates(geom)
    if axes[3]==0 (getindex.(coords,axes[1]), getindex.(coords,axes[2]))
    else (getindex.(coords,axes[1]), getindex.(coords,axes[2]), getindex.(coords,axes[3])) end

end

function linestringcoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :LineString
    coords = coordinates(geom)
    if axes[3]==0 (getindex.(coords,axes[1]), getindex.(coords,axes[2]))
    else (getindex.(coords,axes[1]), getindex.(coords,axes[2]), getindex.(coords,axes[3])) end
end

function multilinestringcoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :MultiLineString
    x, y = Float64[], Float64[]
    for line in coordinates(geom)
        append!(x, getindex.(line,axes[1])); push!(x, NaN)
        append!(y, getindex.(line,axes[2])); push!(y, NaN)
        axes[3]==0 ? true : (append!(z, getindex.(line,axes[3])); push!(3, NaN))
    end
    axes[3]==0 ? (x, y) : (x,y,z)
end

function polygoncoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :Polygon
    ring = first(coordinates(geom)) # currently doesn't plot holes
    if axes[3]==0  (getindex.(ring,axes[1]), getindex.(ring,axes[2]))
    else (getindex.(ring,axes[1]), getindex.(ring,axes[2]), getindex.(ring,axes[3])) end
end

function multipolygoncoords(geom::AbstractGeometry,axes::AxesCoord)
    @assert geotype(geom) == :MultiPolygon
    x, y, z = Float64[], Float64[], Float64[]
    for poly in coordinates(geom)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        append!(x, getindex.(ring,axes[1])); push!(x, NaN)
        append!(y, getindex.(ring,axes[2])); push!(y, NaN)
        axes[3]==0 ? true : (append!(z, getindex.(ring,axes[3])); push!(3, NaN))
    end
    axes[3]==0 ? (x, y) : (x,y,z)
end
shapecoords(geom::AbstractGeometry,axes::Tuple) = shapecoords(geom,Int8.(axes))
shapecoords(geom::AbstractPoint,axes::AxesCoord) = pointcoords(geom,axes)
shapecoords(geom::AbstractMultiPoint,axes::AxesCoord) = multipointcoords(geom,axes)
shapecoords(geom::AbstractLineString,axes::AxesCoord) = linestringcoords(geom,axes)
shapecoords(geom::AbstractMultiLineString,axes::AxesCoord) = multilinestringcoords(geom,axes)
shapecoords(geom::AbstractPolygon,axes::AxesCoord) = polygoncoords(geom,axes)
shapecoords(geom::AbstractMultiPolygon,axes::AxesCoord) = multipolygoncoords(geom,axes)

function shapecoords(geom::AbstractGeometry,axes::AxesCoord)
    gtype = geotype(geom)
    if gtype == :Point
        return pointcoords(geom,axes)
    elseif gtype == :MultiPoint
        return multipointcoords(geom,axes)
    elseif gtype == :LineString
        return linestringcoords(geom,axes)
    elseif gtype == :MultiLineString
        return multilinestringcoords(geom,axes)
    elseif gtype == :Polygon
        return polygoncoords(geom,axes)
    elseif gtype == :MultiPolygon
        return multipolygoncoords(geom,axes)
    else
        warn("unknown geometry type: $gtype")
    end
end

RecipesBase.@recipe f(geom::AbstractPoint;axescoord::AxesCoord=axescoord_default) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom,axescoord)
)

RecipesBase.@recipe f(geom::AbstractMultiPoint;axescoord::AxesCoord=axescoord_default) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom,axescoord)
)

RecipesBase.@recipe f(geom::AbstractLineString;axescoord::AxesCoord=axescoord_default) =    (
    aspect_ratio := 1;
    seriestype --> :path;
    legend --> :false;
    shapecoords(geom,axescoord)
)
RecipesBase.@recipe f(geom::AbstractMultiLineString;axescoord::AxesCoord=axescoord_default) = (
    aspect_ratio := 1;
    seriestype --> :path;
    legend --> :false;
    shapecoords(geom,axescoord)
)

RecipesBase.@recipe f(geom::AbstractPolygon;axescoord::AxesCoord=axescoord_default) = (
    aspect_ratio := 1;
    seriestype --> :shape;
    legend --> :false;
    shapecoords(geom,axescoord)
)

RecipesBase.@recipe f(geom::AbstractMultiPolygon;axescoord::AxesCoord=axescoord_default) = (
    aspect_ratio := 1;
    seriestype --> :shape;
    legend --> :false;
    shapecoords(geom,axescoord)
)

RecipesBase.@recipe function f(geom::AbstractGeometry;axescoord::AxesCoord=axescoord_default)
    aspect_ratio := 1
    legend --> :false
    gtype = geotype(geom)
    if gtype == :Point || gtype == :MultiPoint
        seriestype := :scatter
    elseif gtype == :LineString || gtype == :MultiLineString
        seriestype := :path
    elseif gtype == :Polygon || gtype == :MultiPolygon
        seriestype := :shape
    else
        warn("unknown geometry type: $gtype")
    end
    shapecoords(geom,axescoord)
end

RecipesBase.@recipe function f(geom::Vector{<:AbstractGeometry};axescoord::AxesCoord=axescoord_default)
    aspect_ratio := 1
    legend --> :false
    for g in geom
        @series begin
            gtype = geotype(g)
            if gtype == :Point || gtype == :MultiPoint
                seriestype := :scatter
            elseif gtype == :LineString || gtype == :MultiLineString
                seriestype := :path
            elseif gtype == :Polygon || gtype == :MultiPolygon
                seriestype := :shape
            else
                warn("unknown geometry type: $gtype")
            end
            shapecoords(g,axescoord)
        end
    end
end





RecipesBase.@recipe f(feature::AbstractFeature) = geometry(feature)
RecipesBase.@recipe f(features::Vector{<:AbstractFeature}) = geometry.(features)
RecipesBase.@recipe f(collection::AbstractFeatureCollection) = features(collection)
RecipesBase.@recipe f(collection::AbstractGeometryCollection) = geometries(collection)
