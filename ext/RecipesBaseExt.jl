module RecipesBaseExt

using GeoInterface, RecipesBase
import GeoInterface: @enable_plots
const GI = GeoInterface

mutable struct GeoPlot
    args
end

function geoplot(args...; kw...)
    RecipesBase.plot(GeoPlot(args); kw...)
end
function geoplot!(args...; kw...)
    RecipesBase.plot!(GeoPlot(args); kw...)
end
function geoplot!(plt::RecipesBase.AbstractPlot, args...; kw...)
    RecipesBase.plot!(plt, GeoPlot(args); kw...)
end

RecipesBase.@recipe function f(gp::GeoPlot)
    if GI.isgeometry(gp.args[1])
        (trait(gp.args[1]), gp.args[1])
    elseif GI.isfeature(gp.args[1])
        (trait(gp.args[1]), gp.args[1])
    elseif GI.isfeaturecollection(gp.args[1])
        (trait(gp.args[1]), gp.args[1])
    elseif gp.args[1] isa AbstractVector
        x = [GeoPlot((arg,)) for arg in gp.args[1]]
    else
        error("No recipe found for $gp")
    end
end

function RecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol,Base.Any}, gps::AbstractVector{GeoPlot})
    series_list = RecipesBase.RecipeData[]
    RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
    for gp in Base.skipmissing(gps)
        Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (gp,)))
    end
    series_list
end

RecipesBase.@recipe function f(t::Union{GI.PointTrait,GI.MultiPointTrait}, geom)
    seriestype --> :scatter
    _coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.AbstractLineStringTrait,GI.MultiLineStringTrait}, geom)
    seriestype --> :path
    _coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.PolygonTrait,GI.MultiPolygonTrait,GI.LinearRingTrait}, geom)
    seriestype --> :shape
    _coordvecs(t, geom)
end

function RecipesBase.apply_recipe(plotattributes::AbstractDict{Symbol,Any}, ::GI.GeometryCollectionTrait, collection)
    series_list = RecipesBase.RecipeData[]
    RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
    for geom in GI.getgeom(collection)
        Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (trait(geom), geom)))
    end
    series_list
end

# Features
RecipesBase.@recipe function f(t::GI.FeatureTrait, feature)
    geom = GI.geometry(feature)
    (trait(geom), geom)
end

function RecipesBase.apply_recipe(plotattributes::AbstractDict{Symbol,Any}, ::GI.FeatureCollectionTrait, collection)
    series_list = RecipesBase.RecipeData[]
    RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
    for feat in GI.getfeature(collection)
        Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (trait(feat), feat)))
    end
    series_list
end

# Convert coordinates to the form used by Plots.jl
_coordvecs(::PointTrait, geom) = [tuple(GI.coordinates(geom)...)]
function _coordvecs(::MultiPointTrait, geom)
    n = GI.npoint(geom)
    # We use a fixed conditional instead of dispatch,
    # as `GI.is3d` may not be known at compile-time
    if GI.is3d(geom)
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 3)..., geom)
    else
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 2)..., geom)
    end
end
function _coordvecs(::AbstractLineStringTrait, geom)
    n = GI.npoint(geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return _geom2coordvecs!(vecs..., geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return _geom2coordvecs!(vecs..., geom)
    end
end
function _coordvecs(::MultiLineStringTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for line in GI.getgeom(geom)
            i2 = i1 + GI.npoint(line) - 1
            vvecs = map(v -> view(v, i1:i2), vecs)
            _geom2coordvecs!(vvecs..., line)
            map(v -> v[i2+1] = NaN, vecs)
            i1 = i2 + 2
        end
        return vecs
    end
    n = GI.npoint(geom) + ngeom(geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return loop!(vecs, geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return loop!(vecs, geom)
    end
end
function _coordvecs(::LinearRingTrait, geom)
    points = GI.getpoint(geom)
    if GI.is3d(geom)
        return GI.getcoord.(points, 1), GI.getcoord.(points, 2), GI.getcoord.(points, 3)
    else
        return GI.getcoord.(points, 1), GI.getcoord.(points, 2)
    end
end
function _coordvecs(::PolygonTrait, geom)
    ring = first(GI.getgeom(geom)) # currently doesn't plot holes
    points = GI.getpoint(ring)
    if GI.is3d(geom)
        return GI.getcoord.(points, 1), GI.getcoord.(points, 2), GI.getcoord.(points, 3)
    else
        return GI.getcoord.(points, 1), GI.getcoord.(points, 2)
    end
end
function _coordvecs(::MultiPolygonTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for ring in GI.getring(geom)
            i2 = i1 + GI.npoint(ring) - 1
            range = i1:i2
            vvecs = map(v -> view(v, range), vecs)
            _geom2coordvecs!(vvecs..., ring)
            map(v -> v[i2+1] = NaN, vecs)
            i1 = i2 + 2
        end
        return vecs
    end
    n = GI.npoint(geom) + GI.nring(geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return loop!(vecs, geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return loop!(vecs, geom)
    end
end


_coordvec(n) = Array{Float64}(undef, n)

function _geom2coordvecs!(xs, ys, geom)
    for (i, p) in enumerate(GI.getpoint(geom))
        xs[i] = GI.x(p)
        ys[i] = GI.y(p)
    end
    return xs, ys
end
function _geom2coordvecs!(xs, ys, zs, geom)
    for (i, p) in enumerate(GI.getpoint(geom))
        xs[i] = GI.x(p)
        ys[i] = GI.y(p)
        zs[i] = GI.z(p)
    end
    return xs, ys, zs
end

function expr_enable(typ)
    quote
        # We recreate the apply_recipe functions manually here
        # as nesting the @recipe macro doesn't work.
        function RecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol,Base.Any}, geom::$typ)
            @nospecialize
            series_list = RecipesBase.RecipeData[]
            RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
            Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (GeoInterface.trait(geom), geom)))
            return series_list
        end
        function RecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol,Base.Any}, geom::Base.AbstractVector{<:Base.Union{Base.Missing,<:($typ)}})
            @nospecialize
            series_list = RecipesBase.RecipeData[]
            RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
            for g in Base.skipmissing(geom)
                Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (GeoInterface.trait(g), g)))
            end
            return series_list
        end
    end
end

"""
     @enable_plots(GeometryType)

Macro to add plot recipes to a geometry type.

# Usage

```julia
struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

# Enable Plots.jl plotting
GeoInterfaceRecipes.@enable_plots MyGeometry
```
"""
macro enable_plots(typ)
    esc(expr_enable(typ))
end

# Enable Plots.jl for GeoInterface wrappers
@enable_plots GI.Wrappers.WrapperGeometry

end
