# History
The previous pre-1.0 releases of GeoInterface.jl were smaller in scope, aligned to geointerface in Python [^sgillies]
which builds on GeoJSON [^geojson]. It provided abstract types and expected other geometries to be implemented as a subtype.
Recent Julia developments have shown that subtyping is difficult--you can only choose one supertype--and many packages moved to trait-based interfaces. Tables.jl is an excellent example of traits-based interface.

[^sgillies]: https://gist.github.com/sgillies/2217756
[^geojson]: https://geojson.org/

## Backwards compatibility
To keep function compatibility with pre-v1 releases--even while switching to traits--we keep the following methods.
```julia
# for Features
isfeature # new
geometry
properties

# for Geometries
coordinates
```

However, the `position` type is gone and merged with `PointTrait`.
