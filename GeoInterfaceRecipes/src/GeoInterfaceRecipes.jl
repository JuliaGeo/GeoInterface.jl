module GeoInterfaceRecipes

using GeoInterface, RecipesBase

const GI = GeoInterface

export @enable_geo_plots

"""
     GeoInterfaceRecipes.@enable_geo_plots(typ)

Macro to add plot recipes to a geometry type.
"""
macro enable_geo_plots(typ)
    quote
        # We recreate the apply_recipe functions manually here
        # as nesting the @recipe macro doesn't work.
        function RecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol, Base.Any}, geom::$(esc(typ)))
              @nospecialize
              series_list = RecipesBase.RecipeData[]
              RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
              Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (GeoInterface.geomtype(geom), geom)))
              return series_list
        end
        function RecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol, Base.Any}, geom::Base.AbstractVector{<:Base.Union{Base.Missing,<:($(esc(typ)))}})
              @nospecialize
              series_list = RecipesBase.RecipeData[]
              RecipesBase.is_explicit(plotattributes, :label) || (plotattributes[:label] = :none)
              for g in Base.skipmissing(geom)
                  Base.push!(series_list, RecipesBase.RecipeData(plotattributes, (GeoInterface.geomtype(g), g)))
              end
              return series_list
        end
    end
end

RecipesBase.@recipe function f(t::Union{GI.PointTrait,GI.MultiPointTrait}, geom)
    seriestype --> :scatter
    _coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.LineStringTrait,GI.MultiLineStringTrait}, geom)
    seriestype --> :path
    _coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.PolygonTrait,GI.MultiPolygonTrait}, geom)
    seriestype --> :shape
    _coordvecs(t, geom)
end

RecipesBase.@recipe f(::GI.GeometryCollectionTrait, collection) = collect(getgeom(collection))

# Convert coordinates to the form used by Plots.jl
_coordvecs(::GI.PointTrait, geom) = [tuple(GI.coordinates(geom)...)]
function _coordvecs(::GI.MultiPointTrait, geom)
    n = GI.npoint(geom)
    # We use a fixed conditional instead of dispatch,
    # as `is3d` may not be known at compile-time
    if GI.is3d(geom)
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 3)..., geom)
    else
        _geom2coordvecs!(ntuple(_ -> Array{Float64}(undef, n), 2)..., geom)
    end
end
function _coordvecs(::GI.LineStringTrait, geom)
    n = GI.npoint(geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return _geom2coordvecs!(vecs..., geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return _geom2coordvecs!(vecs..., geom)
    end
end
function _coordvecs(::GI.MultiLineStringTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for line in GI.getgeom(geom)
            i2 = i1 + GI.npoint(line) - 1
            vvecs = map(v -> view(v, i1:i2), vecs)
            _geom2coordvecs!(vvecs..., line)
            map(v -> v[i2 + 1] = NaN, vecs)
            i1 = i2 + 2
        end
        return vecs
    end
    n = GI.npoint(geom) + GI.ngeom(geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return loop!(vecs, geom)
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return loop!(vecs, geom)
    end
end
function _coordvecs(::GI.PolygonTrait, geom)
    ring = first(GI.getgeom(geom)) # currently doesn't plot holes
    points = GI.getpoint(ring)
    if GI.is3d(geom)
        return getcoord.(points, 1), getcoord.(points, 2), getcoord.(points, 3)
    else
        return getcoord.(points, 1), getcoord.(points, 2)
    end
end
function _coordvecs(::GI.MultiPolygonTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for ring in GI.getring(geom)
            i2 = i1 + GI.npoint(ring) - 1
            range = i1:i2
            vvecs = map(v -> view(v, range), vecs)
            _geom2coordvecs!(vvecs..., ring)
            map(v -> v[i2 + 1] = NaN, vecs)
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

end
