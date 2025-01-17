# Version 0.5.0

This version includes many **breaking changes**.

Added support for Dipole-mode Linear Spin Wave Theory. (Thanks Hao Zhang!)

Split `intensities` into calculation ([`intensity_formula`](@ref)) and
presentation ([`intensities_interpolated`](@ref), [`intensities_binned`](@ref)).
This is a **breaking change**, see the docs to migrate your code.

`StructureFactor` type renamed [`SampledCorrelations`](@ref). An appropriate
`SampledCorrelations` is created by calling either
[`dynamical_correlations`](@ref) or [`instant_correlations`](@ref) instead of
`DynamicStructureFactor` or `InstantStructureFactor`.

Broadened support for custom observables in `SampledCorrelations` for use in
`intensity_formula`.

Added function [`load_nxs`](@ref) to load experimental neutron scattering data
to compare with `intensities_binned`.

Replace `set_anisotropy!` with a new function [`set_onsite_coupling!`](@ref)
(and similarly [`set_onsite_coupling_at!`](@ref)). The latter expects an
explicit matrix representation for the local Hamiltonian. This can be
constructed, e.g., as a linear combination of [`stevens_operators`](@ref), or as
a polynomial of [`spin_operators`](@ref). To understand the mapping between
these two, the new function [`print_stevens_expansion`](@ref) acts on an
arbitrary local operator.

Replace `set_biquadratic!` with an optional keyword argument `biquad` to
[`set_exchange!`](@ref).

Symbolic representations of operators are now hidden unless the package
`DynamicPolynomials` is explicitly loaded by the user. The functionality of
`print_anisotropy_as_stevens` has been replaced with
[`print_classical_stevens_expansion`](@ref), while
`print_anisotropy_as_classical_spins` has become
[`print_classical_spin_polynomial`](@ref).


# Version 0.4.3

**Experimental** support for linear [`SpinWaveTheory`](@ref), implemented in
SU(_N_) mode. This module may evolve rapidly.

Implement renormalization of single-ion anisotropy and biquadratic interactions
when in `:dipole` mode. This makes the model more faithful to the quantum
mechanical Hamiltonian, but is also a **breaking change**.

Various improvements and bugfixes for [`to_inhomogeneous`](@ref). Setting
inhomogeneous interactions via [`set_exchange_at!`](@ref) should now infer the
correct bond offset direction, or will report an ambiguity error. Ambiguities
can be resolved by passing an explicit `offset`.

The function [`remove_periodicity!`](@ref) disables periodicity along specified
dimensions.

Rename `StaticStructureFactor` to `InstantStructureFactor`.


# Version 0.4.2

Introduce [`LocalSampler`](@ref), a framework for MCMC sampling with local spin
updates.

Rename `print_dominant_wavevectors` to [`print_wrapped_intensities`](@ref) to
reduce confusion with the physical instantaneous intensities.

The function [`spherical_shell`](@ref) now takes a radius in physical units of inverse Å.

New exported functions [`global_position`](@ref), [`magnetic_moment`](@ref), [`all_sites`](@ref).

Remove all uses of
[`Base.deepcopy`](https://docs.julialang.org/en/v1/base/base/#Base.deepcopy)
which [resolves crashes](https://github.com/SunnySuite/Sunny.jl/issues/65).

# Version 0.4.1

The function [`to_inhomogeneous`](@ref) creates a system that supports
inhomogeneous interactions, which can be set using [`set_exchange_at!`](@ref),
etc.

`set_biquadratic!` replaces `set_exchange_with_biquadratic!`.


# Version 0.4.0

This update includes many breaking changes, and is missing some features of
0.3.0.

### Creating a spin `System`

Rename `SpinSystem` to [`System`](@ref). Its constructor now has the form,

```julia
System(crystal, latsize, infos, mode)
```

The parameter `infos` is now a list of [`SpinInfo`](@ref) objects. Each defines
spin angular momentum $S = \frac{1}{2}, 1, \frac{3}{2}, …$, and an optional
$g$-factor or tensor.

The parameter `mode` is one of `:SUN` or `:dipole`.

### Setting interactions

Interactions are now added mutably to an existing `System` using the following
functions: [`set_external_field!`](@ref), [`set_exchange!`](@ref),
[`set_onsite_coupling!`](@ref), [`enable_dipole_dipole!`](@ref).

As a convenience, one can use [`dmvec(D)`](@ref) to convert a DM vector to a
$3×3$ antisymmetric exchange matrix.

Fully general single-ion anisotropy is now possible. The function
[`set_onsite_coupling!`](@ref) expects the single ion anisotropy to be expressed as a
polynomial in symbolic spin operators [`𝒮`](@ref), or as a linear combination
of symbolic Stevens operators [`𝒪`](@ref). For example, an easy axis anisotropy
in the direction `n` may be written `D*(𝒮⋅n)^2`.

Stevens operators `𝒪[k,q]` admit polynomial expression in spin operators
`𝒮[α]`. Conversely, a polynomial of spin operators can be expressed as a linear
combination of Stevens operators. To see this expansion use
`print_anisotropy_as_stevens`.


### Inhomogeneous field

An external field can be applied to a single site with
[`set_external_field_at!`](@ref). 


### Structure factor rewrite

The calculation of structure factors has been completely rewritten. For the new
interface, see the [Structure Factor Calculations](@ref) page.


### Various

* The "Sampler" interface is in flux. [`Langevin`](@ref) replaces both
  `LangevinHeunP` and `LangevinSampler`. Local spin-flip Monte Carlo sampling
  methods are temporarily broken.

* [`repeat_periodically`](@ref) replaces `extend_periodically`.

Additional related functions include [`resize_periodically`](@ref) and
[`reshape_geometry`](@ref), the latter being fundamental.

* [`print_symmetry_table`](@ref) replaces `print_bond_table()`.

The new function includes the list of symmetry-allowed single ion anisotropies
in addition to exchange interactions.

* When reading CIF files, the field `_atom_site_label` is now used in place of
  the field `_atom_site_type_symbol`.

This is required for correctness. The field `_atom_site_label` is guaranteed to
be present, and is guaranteed to be a distinct label for each
symmetry-inequivalent site. Code that explicitly referred to site labels (e.g.
in calls to [`subcrystal`](@ref)) will need to be updated to use the new label.
