# Task 3.0: Phase 3.0: Literature Foundation and References

## Objectives

Collect and catalog primary literature references to establish the foundation for validating the precipitation code implementation of Fang et al. (2010) model and related atmospheric/magnetic physics.

## Element 3.0.0: Collect and catalog primary literature references

### Specific Literature References to Check

1. **Fang et al. (2010) paper**
   - Citation details: Full bibliographic information
   - Equations to capture:
     - Energy dissipation parameterization (y = (2/E)(ρ·H)^0.7(6×10⁻⁶)^(-0.7))
     - Ionization rate formula (q_tot = Qe/0.035 × f/H)
     - Precipitation loss calculation (q_to_mirror / q_top)
     - Boundary conditions and parameter ranges
   - Coefficient values and their sources
   - Valid energy ranges: 100 eV - 1 MeV
   - Assumptions and approximations stated in paper

2. **MSIS 2.0/2.1 documentation**
   - NRLMSIS-00 or MSIS-2 technical documentation
   - Atmospheric profiles: temperature, density (mass number), scale height
   - Validity domains: altitude (0-1000 km), latitude, longitude, time
   - Input parameters: F10.7 solar flux, Ap geomagnetic index
   - Output variables and units (kg/m³ for mass density, km for scale height)
   - Reference implementation notes

3. **Standard dipole bounce period references**
   - Roederer (1970) or similar magnetospheric physics text
   - Relativistic bounce period formula
   - Dipole field assumptions (B = B₀(R_E/r)³)
   - L-shell definition: L = r_eq / R_E (Earth radii)
   - Constants: mc² values (0.511 MeV for e⁻, 938 MeV for p⁺)
   - Correction factors from reference literature

4. **Particle loss cone theory references**
   - Pitch angle definitions: equatorial pitch angle α_eq vs local α
   - Loss cone angle formula: sin²(α_LC) = B_eq / B_m
   - Mirror point conditions: first adiabatic invariant conservation
   - Atmospheric boundary conditions (altitude < 1000 km triggers loss)
   - Particle lifetimes and precipitation rates

### Expected Values from Literature

- **Energy dissipation**: f(z,E) function should match Fang 2010 Equation X
- **Ionization constant**: 0.035 should be verified against Fang 2010 Table X
- **Bounce period**: Should match relativistic formula t_b = 4LR_E / (γv) × I(α_eq)
- **Mirror altitude**: r = L·R_E·cos²(λ) relationship from dipole theory

### Verification Criteria

- [ ] All equations from Fang 2010 are accurately identified (equation numbers, page numbers)
- [ ] Parameter ranges from literature are documented (min/max values for all inputs)
- [ ] Coefficient sources are traced to specific references (0.035, 6×10⁻⁶, etc.)
- [ ] MSIS validity boundaries match model documentation
- [ ] Dipole model assumptions are clearly stated and justified
- [ ] Loss cone theory aligns with established magnetospheric physics

### Deliverables

1. **Literature survey document**: Bibliographic database with:
   - Complete citations (DOI, journal, year, volume, pages, authors)
   - Key equations extracted with equation numbers
   - Parameter tables with reference sources
   - Validity ranges and assumptions documented

2. **Reference equation catalog**: LaTeX-formatted equations ready for comparison:
   - Energy dissipation equation with constants and units
   - Ionization rate formula with integration bounds
   - Bounce period formula in coordinate-independent form
   - Mirror altitude relationship with dipole assumptions

3. **Assumption log**: Document all simplifying assumptions:
   - Dipole vs full magnetic field model
   - Atmospheric model approximations
   - Particle beam assumptions vs distribution functions
   - Coordinate system choices

### Dependencies

- None (this is a foundational task)

### Files to Create

- `literature_survey_3.0.pdf` or `.md` - Complete literature review
- `reference_equations_3.0.tex` - Equation catalog in LaTeX format
- `assumption_log_3.0.md` - Assumption tracking document

### References

- Fang et al. (2010) - Primary precipitation model paper
- Hedin (1991) - MSIS-90 model documentation
- Picone et al. (2002) - NRLMSISE-00 model documentation
- Roederer (1970) - Dynamics of Geomagnetically Trapped Radiation
- Schulz and Lanzerotti (1974) - Particle Diffusion in the Radiation Belts