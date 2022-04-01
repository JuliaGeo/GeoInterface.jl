# Simple Features
Test

## Changes with respect to SF
While we try to adhere to SF, there are changes and extensions to make it more Julian.

### Function names
All function names are without the `ST_` prefix and are lowercased. In some cases the names have changed as well, to be inline with common Julia functions. `NumX` becomes `nx` and `Xn` becomes `getX`:
```julia
GeometryType -> geomtype
NumGeometries -> ngeom
GeometryN -> getgeom
NumPatches -> npatch
# etc
```

We also simplified the dimension functions. From the three original (`dimension`, `coordinateDimension`, `spatialDimension`) there's now only the coordinate dimension, so not to overlap with the Julia `ndims`.
```julia
coordinateDimension -> ncoords  # x, y, z, m
```

We've generalized the some functions:
```julia
SRID -> crs
envelope -> extent
```

And added a helper method to clarify the naming of coordinates.
```julia
coordnames = (:X, :Y, :Z, :M)
```

### Coverage
Not all SF functions are implemented, either as a possibly slower fallback or empty descriptor or not at all. The following SF functions are not (yet) available.

```julia
dimension
spatialDimension
asText
asBinary
boundary

locateAlong
locateBetween

distance
buffer
convexHull

```
While the following functions have no implementation:
```julia
equals
disjoint
touches
within
overlaps
crosses
intersects
contains
relate

intersection
union
difference
symdifference
```

## History
Test
