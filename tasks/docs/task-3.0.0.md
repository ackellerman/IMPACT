# Task 3.0.0: Collect and catalog primary literature references

## Task
Collect and catalog primary literature references to establish the foundation for validating the precipitation code implementation of Fang et al. (2010) model and related atmospheric/magnetic physics.

## Scope

### Included
- Fang et al. (2010) paper: equations, coefficients, parameter ranges, assumptions
- MSIS 2.0/2.1 model documentation: atmospheric profiles, validity domains, input/output specifications
- Dipole bounce period theory: relativistic formulas, dipole field assumptions, constants
- Particle loss cone theory: pitch angle definitions, mirror point conditions, atmospheric boundaries

### Excluded
- Obtaining full-text papers (collect citation metadata and equation references only)
- Implementation of any physics models (pure literature collection)
- Code validation or testing (future tasks)

## Requirements

- [ ] **Fang et al. (2010) Collection**: Capture complete bibliographic information (DOI, journal, year, volume, pages, authors)
- [ ] **Equation Extraction**: Document 4 key equations with equation numbers and page numbers:
  - Energy dissipation parameterization: y = (2/E)(ρ·H)^0.7(6×10⁻⁶)^(-0.7)
  - Ionization rate formula: q_tot = Qe/0.035 × f/H
  - Precipitation loss calculation: q_to_mirror / q_top
  - All boundary conditions and parameter ranges
- [ ] **MSIS Documentation**: Catalog atmospheric model specifications including:
  - Validity domains: altitude (0-1000 km), latitude, longitude, time
  - Input parameters: F10.7 solar flux, Ap geomagnetic index
  - Output variables and units (kg/m³ for mass density, km for scale height)
- [ ] **Dipole Theory**: Document bounce period formulas and constants:
  - Relativistic bounce period formula with mc² values
  - Dipole field assumptions: B = B₀(R_E/r)³
  - L-shell definition: L = r_eq / R_E
- [ ] **Loss Cone Theory**: Catalog pitch angle and mirror point theory:
  - Equatorial pitch angle α_eq vs local α
  - Loss cone angle formula: sin²(α_LC) = B_eq / B_m
  - Atmospheric boundary conditions (altitude < 1000 km)

## Deliverables

1. **literature_survey_3.0.md** - Bibliographic database containing:
   - Complete citations with DOIs for Fang (2010), Hedin (1991), Picone (2002), Roederer (1970), Schulz (1974)
   - Extracted equations with equation numbers, page numbers, and context
   - Parameter tables with reference sources
   - Validity ranges and assumptions documented

2. **reference_equations_3.0.tex** - LaTeX-formatted equation catalog containing:
   - Energy dissipation equation with all constants and units
   - Ionization rate formula with integration bounds
   - Bounce period formula in coordinate-independent form
   - Mirror altitude relationship with dipole assumptions

3. **assumption_log_3.0.md** - Assumption tracking document containing:
   - Dipole vs full magnetic field model assumptions
   - Atmospheric model approximations
   - Particle beam assumptions vs distribution functions
   - Coordinate system choices

## Verification

This is a literature research task - verification is manual review:

1. **Completeness Check**: Reviewer verifies all 4 target papers are cited with complete bibliographic information
2. **Accuracy Check**: Reviewer verifies equations match original sources (equation numbers, page numbers, form)
3. **Format Check**: Verify LaTeX equations compile without errors
4. **Coverage Check**: Verify all 6 verification criteria from phase doc are addressed

```bash
# LaTeX compilation check (if LaTeX is available)
pdflatex reference_equations_3.0.tex

# Expected: 0 errors, 0 warnings
```

## Completion Criteria

ALL of the following must be true:
- [ ] Complete bibliographic information collected for all 5 primary references
- [ ] All 4 Fang et al. (2010) key equations documented with equation numbers and page numbers
- [ ] MSIS validity domains and parameter ranges fully documented
- [ ] Dipole bounce period and loss cone theory equations captured with proper citations
- [ ] All 3 deliverable files created with specified content
- [ ] Assumption log documents at least 4 major assumptions
- [ ] LaTeX equations compile without errors (if LaTeX available)

When complete, output: RALPH_COMPLETE

## If Stuck

If unable to complete after multiple attempts:
1. Document which specific references are unavailable or incomplete
2. Note which equations cannot be verified against primary sources
3. Output: RALPH_BLOCKED with specific blocker explanation

## Dependencies

- None (foundational task - no prerequisites)
- Requires: Internet access for obtaining citation metadata (DOIs, bibliographic info)
- Requires: Access to academic databases or institutional libraries for paper verification

## Notes

- This task focuses on **literature collection**, not implementation
- Prioritize citation accuracy over obtaining full-text papers
- Use DOI resolvers (doi.org) to verify bibliographic information
- If primary papers are inaccessible, cite secondary sources that accurately reference the equations

## References to Catalog

1. Fang et al. (2010) - Primary precipitation model paper
2. Hedin (1991) - MSIS-90 model documentation  
3. Picone et al. (2002) - NRLMSISE-00 model documentation
4. Roederer (1970) - Dynamics of Geomagnetically Trapped Radiation
5. Schulz and Lanzerotti (1974) - Particle Diffusion in the Radiation Belts
