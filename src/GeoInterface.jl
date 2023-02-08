module GeoInterface

using Extents
using Base.Iterators: flatten

export testgeometry, isgeometry, trait, geomtrait, ncoord, getcoord, ngeom, getgeom

# traits
export AbstractGeometryTrait,
    AbstractGeometryCollectionTrait,
    GeometryCollectionTrait,
    AbstractPointTrait,
    PointTrait,
    AbstractCurveTrait,
    AbstractLineStringTrait,
    LineStringTrait,
    LineTrait,
    LinearRingTrait,
    CircularStringTrait,
    CompoundCurveTrait,
    AbstractSurfaceTrait,
    AbstractCurvePolygonTrait,
    CurvePolygonTrait,
    AbstractPolygonTrait,
    PolygonTrait,
    TriangleTrait,
    RectangleTrait,
    QuadTrait,
    PentagonTrait,
    HexagonTrait,
    AbstractPolyhedralSurfaceTrait,
    PolyhedralSurfaceTrait,
    TINTrait,
    AbstractMultiPointTrait,
    MultiPointTrait,
    AbstractMultiCurveTrait,
    MultiCurveTrait,
    AbstractMultiLineStringTrait,
    MultiLineStringTrait,
    AbstractMultiSurfaceTrait,
    MultiSurfaceTrait,
    AbstractMultiPolygonTrait,
    MultiPolygonTrait,
    AbstractFeatureTrait,
    FeatureTrait,
    AbstractFeatureCollectionTrait,
    FeatureCollectionTrait


include("types.jl")
include("interface.jl")
include("fallbacks.jl")
include("utils.jl")
include("base.jl")
include("wrappers.jl")

using .Wrappers
using .Wrappers: geointerface_geomtype

end # module
