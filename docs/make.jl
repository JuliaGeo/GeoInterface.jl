using GeoInterface
using Documenter

DocMeta.setdocmeta!(GeoInterface, :DocTestSetup, :(using GeoInterface); recursive=true)
cp(joinpath(@__DIR__, "../INTEGRATIONS.md"), joinpath(@__DIR__, "src/reference/integrations.md"); force=true)

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
        "Background" => Any[
            "Simple Features"=>"background/sf.md",
        ],
        "Tutorials" => Any[
            "Installation"=>"tutorials/installation.md",
            "Usage"=>"tutorials/usage.md",
        ],
        "Guides" => Any[
            "For developers"=>"guides/developer.md",
            "Defaults"=>"guides/defaults.md",
        ],
        "Reference" => Any[
            "API" => "reference/api.md"
            "Implementations" => "reference/integrations.md"
        ],
    ]
)

deploydocs(;
    repo="github.com/JuliaGeo/GeoInterface.jl",
    devbranch="main"
)
