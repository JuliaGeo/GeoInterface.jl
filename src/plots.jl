# Stubs are extended in ext/RecipesBaseExt.jl
function geoplot(args...; kwargs...)
    ext = Base.get_extension(@__MODULE__, :RecipesBaseExt)
    if !isnothing(ext)
        return ext.geoplot(args...; kwargs...)
    else
        error("No plotting extension found.")
    end
end
function geoplot!(args...; kwargs...)
    ext = Base.get_extension(@__MODULE__, :RecipesBaseExt)
    if !isnothing(ext)
        return ext.geoplot!(args...; kwargs...)
    else
        error("No plotting extension found.")
    end
end

macro enable_plots end
