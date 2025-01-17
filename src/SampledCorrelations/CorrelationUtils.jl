"""
    all_exact_wave_vectors(sc::SampledCorrelations; bzsize=(1,1,1))

Returns all wave vectors for which `sc` contains exact values. `bsize` specifies
the number of Brillouin zones to be included.
"""
function all_exact_wave_vectors(sc::SampledCorrelations; bzsize=(1,1,1))
    Ls = size(sc.samplebuf)[2:4]  # If we had a sys, would use latsize
    offsets = map(L -> isodd(L) ? 1 : 0, Ls)
    up = Ls .* bzsize
    hi = map(L -> L - div(L, 2), up) .- offsets
    lo = map(L -> 1 - div(L, 2), up) .- offsets
    qs = zeros(Vec3, up...)
    for (k, lz) in enumerate(lo[3]:hi[3]), (j, ly) in enumerate(lo[2]:hi[2]), (i, lx) in enumerate(lo[1]:hi[1])
        qs[i,j,k] = Vec3(lx/Ls[1], ly/Ls[2], lz/Ls[3]) 
    end
    return qs
end

"""
    ωs(sc::SampledCorrelations; negative_energies=false)

Return the ω values for the energy index of a `SampledCorrelations`. By default,
only returns values for non-negative energies, which corresponds to the default
output of `intensities`. Set `negative_energies` to true to retrieve all ω
values.
"""
function ωs(sc::SampledCorrelations; negative_energies=false)
    Δω = sc.Δω
    isnan(Δω) && (return NaN)

    nω = size(sc.data, 7)
    hω = div(nω, 2) + 1
    ωvals = collect(0:(nω-1)) .* Δω
    for i ∈ hω+1:nω
        ωvals[i] -= 2ωvals[hω]
    end
    return negative_energies ? ωvals : ωvals[1:hω]
end


orig_crystal(sc::SampledCorrelations) = isnothing(sc.origin_crystal) ? sc.crystal : sc.origin_crystal
