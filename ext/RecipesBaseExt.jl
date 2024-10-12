module RecipesBaseExt

using GeoInterface, RecipesBase

const GI = GeoInterface

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

RecipesBase.@recipe f(::GI.GeometryCollectionTrait, collection) = collect(getgeom(collection))

# Features
RecipesBase.@recipe f(t::GI.FeatureTrait, feature) = GI.geometry(feature)

RecipesBase.@recipe f(t::GI.FeatureCollectionTrait, fc) = collect(GI.getfeature(fc))


# Convert coordinates to the form used by Plots.jl
_coordvecs(::PointTrait, geom) = [tuple(GI.coordinates(geom)...)]
function _coordvecs(::MultiPointTrait, geom)
    n = npoint(geom)
    # We use a fixed conditional instead of dispatch,
    # as `is3d` may not be known at compile-time
    if is3d(geom)
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 3)..., geom)
    else
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 2)..., geom)
    end
end
function _coordvecs(::AbstractLineStringTrait, geom)
    n = npoint(geom)
    if is3d(geom)
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
        for line in getgeom(geom)
            i2 = i1 + npoint(line) - 1
            vvecs = map(v -> view(v, i1:i2), vecs)
            _geom2coordvecs!(vvecs..., line)
            map(v -> v[i2+1] = NaN, vecs)
            i1 = i2 + 2
        end
        return vecs
    end
    n = npoint(geom) + ngeom(geom)
    if is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return loop!(vecs, geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return loop!(vecs, geom)
    end
end
function _coordvecs(::LinearRingTrait, geom)
    points = getpoint(geom)
    if is3d(geom)
        return getcoord.(points, 1), getcoord.(points, 2), getcoord.(points, 3)
    else
        return getcoord.(points, 1), getcoord.(points, 2)
    end
end
function _coordvecs(::PolygonTrait, geom)
    ring = first(getgeom(geom)) # currently doesn't plot holes
    points = getpoint(ring)
    if is3d(geom)
        return getcoord.(points, 1), getcoord.(points, 2), getcoord.(points, 3)
    else
        return getcoord.(points, 1), getcoord.(points, 2)
    end
end
function _coordvecs(::MultiPolygonTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for ring in getring(geom)
            i2 = i1 + npoint(ring) - 1
            range = i1:i2
            vvecs = map(v -> view(v, range), vecs)
            _geom2coordvecs!(vvecs..., ring)
            map(v -> v[i2+1] = NaN, vecs)
            i1 = i2 + 2
        end
        return vecs
    end
    n = npoint(geom) + nring(geom)
    if is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return loop!(vecs, geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return loop!(vecs, geom)
    end
end


_coordvec(n) = Array{Float64}(undef, n)

function _geom2coordvecs!(xs, ys, geom)
    for (i, p) in enumerate(getpoint(geom))
        xs[i] = x(p)
        ys[i] = y(p)
    end
    return xs, ys
end
function _geom2coordvecs!(xs, ys, zs, geom)
    for (i, p) in enumerate(getpoint(geom))
        xs[i] = x(p)
        ys[i] = y(p)
        zs[i] = z(p)
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
     GeoInterfaceRecipes.@enable(GeometryType)

Macro to add plot recipes to a geometry type.

# Usage

```julia
struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

# Enable Plots.jl plotting
GeoInterfaceRecipes.@enable_geo_plots MyGeometry
```
"""
macro enable(typ)
    esc(expr_enable(typ))
end

# Compat
macro enable_geo_plots(typ)
    esc(expr_enable(typ))
end

# Enable Plots.jl for GeoInterface wrappers
@enable GeoInterface.Wrappers.WrapperGeometry

end
