"""
    Logistic(μ,θ)

The *Logistic distribution* with location `μ` and scale `θ` has probability density function

```math
f(x; \\mu, \\theta) = \\frac{1}{4 \\theta} \\mathrm{sech}^2
\\left( \\frac{x - \\mu}{2 \\theta} \\right)
```

```julia
Logistic()       # Logistic distribution with zero location and unit scale, i.e. Logistic(0, 1)
Logistic(u)      # Logistic distribution with location u and unit scale, i.e. Logistic(u, 1)
Logistic(u, b)   # Logistic distribution with location u ans scale b

params(d)       # Get the parameters, i.e. (u, b)
location(d)     # Get the location parameter, i.e. u
scale(d)        # Get the scale parameter, i.e. b
```

External links

* [Logistic distribution on Wikipedia](http://en.wikipedia.org/wiki/Logistic_distribution)

"""
struct Logistic{T<:Real} <: ContinuousUnivariateDistribution
    μ::T
    θ::T

    Logistic{T}(μ::T, θ::T) where {T} = (@check_args(Logistic, θ > zero(θ)); new{T}(μ, θ))
end

Logistic(μ::T, θ::T) where {T<:Real} = Logistic{T}(μ, θ)
Logistic(μ::Real, θ::Real) = Logistic(promote(μ, θ)...)
Logistic(μ::Integer, θ::Integer) = Logistic(Float64(μ), Float64(θ))

@kwdispatch Logistic()

@kwmethod Logistic(;) = Logistic(0, 1)

@kwmethod Logistic(;μ) = Logistic(μ, 1)
@kwmethod Logistic(;mu) = Logistic(mu, 1)
@kwmethod Logistic(;location) = Logistic(location, 1)
@kwmethod Logistic(;mean) = Logistic(mean, 1)

@kwmethod Logistic(;σ) = Logistic(0, σ)
@kwmethod Logistic(;sigma) = Logistic(0, sigma)
@kwmethod Logistic(;scale) = Logistic(0, scale)

@kwmethod Logistic(;std) = Logistic(0, (sqrt3 * std) / π)
@kwmethod Logistic(;var) = Logistic(0, sqrt(3*var) / π)

@kwmethod Logistic(;μ,σ) = Logistic(μ, σ)
@kwmethod Logistic(;mu,sigma) = Logistic(mu, sigma)
@kwmethod Logistic(;location,scale) = Logistic(location, scale)

@kwmethod Logistic(;mean,std) = Logistic(mean, (sqrt3 * std) / π)
@kwmethod Logistic(;mean,var) = Logistic(mean, sqrt(3*var) / π)

@distr_support Logistic -Inf Inf

#### Conversions
function convert(::Type{Logistic{T}}, μ::S, θ::S) where {T <: Real, S <: Real}
    Logistic(T(μ), T(θ))
end
function convert(::Type{Logistic{T}}, d::Logistic{S}) where {T <: Real, S <: Real}
    Logistic(T(d.μ), T(d.θ))
end

#### Parameters

location(d::Logistic) = d.μ
scale(d::Logistic) = d.θ

params(d::Logistic) = (d.μ, d.θ)
@inline partype(d::Logistic{T}) where {T<:Real} = T


#### Statistics

mean(d::Logistic) = d.μ
median(d::Logistic) = d.μ
mode(d::Logistic) = d.μ

std(d::Logistic) = π * d.θ / sqrt3
var(d::Logistic) = (π * d.θ)^2 / 3
skewness(d::Logistic{T}) where {T<:Real} = zero(T)
kurtosis(d::Logistic{T}) where {T<:Real} = T(6)/5

entropy(d::Logistic) = log(d.θ) + 2


#### Evaluation

zval(d::Logistic, x::Real) = (x - d.μ) / d.θ
xval(d::Logistic, z::Real) = d.μ + z * d.θ

pdf(d::Logistic, x::Real) = (lz = logistic(-abs(zval(d, x))); lz*(1-lz)/d.θ)
logpdf(d::Logistic, x::Real) = (u = -abs(zval(d, x)); u - 2*log1pexp(u) - log(d.θ))

cdf(d::Logistic, x::Real) = logistic(zval(d, x))
ccdf(d::Logistic, x::Real) = logistic(-zval(d, x))
logcdf(d::Logistic, x::Real) = -log1pexp(-zval(d, x))
logccdf(d::Logistic, x::Real) = -log1pexp(zval(d, x))

quantile(d::Logistic, p::Real) = xval(d, logit(p))
cquantile(d::Logistic, p::Real) = xval(d, -logit(p))
invlogcdf(d::Logistic, lp::Real) = xval(d, -logexpm1(-lp))
invlogccdf(d::Logistic, lp::Real) = xval(d, logexpm1(-lp))

function gradlogpdf(d::Logistic, x::Real)
    e = exp(-zval(d, x))
    ((2e) / (1 + e) - 1) / d.θ
end

mgf(d::Logistic, t::Real) = exp(t * d.μ) / sinc(d.θ * t)

function cf(d::Logistic, t::Real)
    a = (π * t) * d.θ
    a == zero(a) ? complex(one(a)) : cis(t * d.μ) * (a / sinh(a))
end


#### Sampling

rand(d::Logistic) = rand(GLOBAL_RNG, d)
rand(rng::AbstractRNG, d::Logistic) = quantile(d, rand(rng))
