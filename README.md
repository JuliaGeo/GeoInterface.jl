[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliageo.github.io/GeoInterface.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliageo.github.io/GeoInterface.jl/dev)
[![CI](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/JuliaGeo/GeoInterface.jl/branch/master/graph/badge.svg?token=ccpOaPSi08)](https://codecov.io/gh/JuliaGeo/GeoInterface.jl)

# GeoInterface
An interface for geospatial vector data in [Julia](https://julialang.org/).

This Package describe a set of traits based on the [Simple Features standard
(SF)](https://www.opengeospatial.org/standards/sfa) for geospatial vector data, including
the SQL/MM extension with support for circular geometry. Using these traits, it should be
easy to parse, serialize and use different geometries in the Julia ecosystem, without
knowing the specifics of each individual package. In that regard it is similar to
[Tables.jl](https://github.com/JuliaData/Tables.jl), but for geometries instead of tables.

Packages which support the GeoInterface.jl interface can be found in
[INTEGRATIONS.md](INTEGRATIONS.md).

We thank Julia Computing for supporting contributions to this package.
