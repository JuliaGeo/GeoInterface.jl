module GeoInterface

using Base.Iterators: flatten

export testgeometry, isgeometry, geomtype, ncoord, getcoord, ngeom, getgeom

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
    MultiPolygonTrait

include("types.jl")
include("interface.jl")
include("fallbacks.jl")
include("utils.jl")

end # module
