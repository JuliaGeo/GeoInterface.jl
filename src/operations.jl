import Base: ==, hash, isapprox

# Compare points by coordinate values.
==(x::P, y::P) where {P <: AbstractPoint} = coordinates(x) == coordinates(y)

# Hash the coordinates for consistency.
hash(x::P) where {P <: AbstractPoint} = hash(coordinates(x))

# Compare points approximately by coordinate values.
isapprox(x::P, y::P; kwargs...) where {P <: AbstractPoint} = isapprox(coordinates(x), coordinates(y); kwargs...)
