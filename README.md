[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliageo.github.io/GeoInterface.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliageo.github.io/GeoInterface.jl/dev)
[![Build Status](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml?query=branch%3Amain)

# GeoInterface
An interface for geospatial vector data in Julia

This Package describe a set of traits based on the [Simple Features standard (SF)](https://www.opengeospatial.org/standards/sfa)
for geospatial vector data, including the SQL/MM extension with support for circular geometry. 
Using these traits, it should be easy to parse, serialize and use different geometries in the Julia ecosystem,
without knowing the specifics of each individual package. In that regard it is similar to Tables.jl, but for geometries instead of tables.

Packages which support the GeoInterface.jl interface can be found in [INTEGRATIONS.md](INTEGRATIONS.md).
