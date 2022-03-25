using GeoInterface
using Documenter

DocMeta.setdocmeta!(GeoInterface, :DocTestSetup, :(using GeoInterface); recursive=true)

makedocs(;
    modules=[GeoInterface],
    authors="JuliaGeo and contributors",
    repo="https://github.com/JuliaGeo/GeoInterface.jl/blob/{commit}{path}#{line}",
    sitename="GeoInterface.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliageo.github.io/GeoInterface.jl",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo="github.com/JuliaGeo/GeoInterface.jl",
    devbranch="main"
)
