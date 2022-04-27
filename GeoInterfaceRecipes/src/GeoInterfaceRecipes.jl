module GeoInterfaceRecipes

using GeoInterface, RecipesBase

const GI = GeoInterface

"""
     GeoInterfaceRecipes.@enable_geo_plots(typ)

Macro to add plot recipes to a geometry type.
"""
macro enable_geo_plots(typ)
    quote
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
    _plotvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.LineStringTrait,GI.MultiLineStringTrait}, geom)
    seriestype --> :path
    _plotvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.PolygonTrait,GI.MultiPolygonTrait}, geom)
    seriestype --> :shape
    _plotvecs(t, geom)
end

RecipesBase.@recipe f(::GI.GeometryCollectionTrait, collection) = geometries(collection)

# Convert coordinates to the form used by Plots.jl
_plotvecs(::GI.PointTrait, geom) = [tuple(GI.coordinates(geom)...)]
function _plotvecs(::GI.MultiPointTrait, geom)
    n = GI.npoint(geom)
    if GI.is3d(geom)
        _geom2plotvec!(ntuple(_ -> Array{Float64}(undef, n), 3)..., geom)
    else
        _geom2plotvec!(ntuple(_ -> Array{Float64}(undef, n), 2)..., geom)
    end
end
function _plotvecs(::GI.LineStringTrait, geom)
    if GI.is3d(geom)
        vecs = ntuple(_ -> Array{Float64}(undef, n), 3)
        return _geom2plotvec!(vecs..., GI.getgeom(geom))
    else
        vecs = ntuple(_ -> Array{Float64}(undef, n), 2)
        return _geom2plotvec!(vecs..., GI.getgeom(geom))
    end
end
function _plotvecs(::GI.MultiLineStringTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for line in GI.getgeom(geom)
            i2 = i1 + GI.npoint(line) - 1
            vvecs = map(v -> view(v, i1:i2), vecs)
            _geom2plotvec!(vvecs..., line)
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
function _plotvecs(::GI.PolygonTrait, geom)
    ring = first(GI.getgeom(geom)) # currently doesn't plot holes
    if GI.is3d(geom)
        return getindex.(ring, 1), getindex.(ring, 2), getindex.(ring, 3)
    else
        return first.(ring), last.(ring)
    end
end
function _plotvecs(::GI.MultiPolygonTrait, geom)
    function loop!(vecs, geom)
        i1 = 1
        for ring in GI.getring(geom)
            i2 = i1 + GI.npoint(ring) - 1
            range = i1:i2
            vvecs = map(v -> view(v, range), vecs)
            _geom2plotvec!(vvecs..., ring)
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

_plotvec(n) = Array{Float64}(undef, n)

function _geom2plotvec!(xs, ys, geom)
    for (i, p) in enumerate(GI.getpoint(geom))
        xs[i] = GI.x(p)
        ys[i] = GI.y(p)
    end
    return xs, ys
end
function _geom2plotvec!(xs, ys, zs, geom)
    for (i, p) in enumerate(GI.getpoint(geom))
        xs[i] = GI.x(p)
        ys[i] = GI.y(p)
        zs[i] = GI.z(p)
    end
    return xs, ys, zs
end

end
