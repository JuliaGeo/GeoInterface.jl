module WellKnownGeometryExt

using GeoInterface
using WellKnownGeometry

GeoInterface.astext(::AbstractGeometryTrait, geom) = WellKnownGeometry.getwkt(geom)
GeoInterface.asbinary(::AbstractGeometryTrait, geom) = WellKnownGeometry.getwkb(geom)

end
