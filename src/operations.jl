import Base: ==, hash

# Compare points by coordinate values.
==(x::P, y::P) where {P <: AbstractPoint} = coordinates(x) == coordinates(y)

# Hash the coordinates for consistency.
hash(x::P) where {P <: AbstractPoint} = hash(coordinates(x))
