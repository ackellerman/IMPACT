# Task 3.3.0: Validate MSIS data retrieval (get_msis_dat.m)

## Architecture Status: ✅ **APPROVED WITH CONDITIONS**

**Review Date**: January 16, 2026
**Architecture Document**: See `task-3.3.0-architecture-review.md`

### Key Decisions

1. **Validation Approach**: Four-tier strategy (static → file format → numerical → spatial averaging)
2. **Fixed Parameters**: ACCEPTED as test baseline (document limitations)
3. **Fortran Execution**: REQUIRED for end-to-end validation (Tier 3)
4. **External Dependencies**: ACCEPTED (msis21.parm, MSIS Fortran code)

### Conditions for Completion

1. ✅ Complete all 4 validation tiers
2. ⚠️ Document N (atomic nitrogen) exclusion rationale
3. ⚠️ Clarify O* (anomalous oxygen) definition
4. ⚠️ Update acceptance criteria per tier
5. ✅ Document all known limitations

### Architecture Strengths
- Clear separation of validation concerns
- Incremental risk management (each tier independent)
- Strong foundation from task 3.0.0
- Existing reference data available

### Key Risks & Mitigations
- **Fortran execution failure**: Use pre-compiled executable or pre-generated outputs
- **Numerical precision errors**: Document acceptable tolerances (<1-2%)
- **External dependencies**: Document msis21.parm and license requirements

---

## Task

Validate the MSIS 2.1 atmospheric data retrieval implemented in `get_msis_dat.m`, which provides density (ρ) and scale height (H) inputs to the Fang et al. (2010) electron precipitation ionization model.

## Scope

### Included
- Validation of physical constants and formulas in `get_msis_dat.m`
- Verification of MSIS input/output file formats
- Execution and validation of Fortran MSIS model
- Validation of spatial averaging logic (lat/lon/date averaging)
- Documentation of validation results and known limitations

### Excluded
- Parameter sweep validation (different F10.7, Ap values) - **Future task**
- Seasonal/latitudinal coverage validation beyond test points - **Future task**
- Storm-time validation (high F10.7, Ap conditions) - **Future task**
- MSIS accuracy validation (comparison to satellite data) - **Out of scope**
- MSIS 2.0 vs 2.1 comparison - **Out of scope**

## Validation Requirements

### Tier 1: Static Validation (Physical Constants & Formulas)
- [ ] **Atomic masses verified**: He=4, O=16, N₂=28.02, O₂=32, Ar=39.95, H=1, O*=16, NO=30
- [ ] **AMU conversion factor**: 1.66e-27 kg/AMU (verify against CODATA 1.660539e-27 kg)
- [ ] **Boltzmann constant**: 1.38e-23 J/K (verify against CODATA 1.380649e-23 J/K)
- [ ] **Gravitational parameters**: g₀=9.80665 m/s², R_E=6371 km
- [ ] **Scale height formula**: H = kT/(Mg) (derive from hydrostatic equilibrium)
- [ ] **Gravitational altitude correction**: g = g₀ × (R_E/(R_E + alt))²

**Acceptance Criterion**: All constants within < 0.1% of reference values

### Tier 2: File Format Validation (I/O Structure)
- [ ] **Input file format**: `msisinputs.txt` structure matches MSIS test format
  - Fields: iyd, sec, alt, glat, glong, stl, f107a, f107, Ap
- [ ] **Output file parsing**: `textscan` format matches MSIS output
  - Fields: 20 columns, species densities, ρ, T
- [ ] **Data extraction**: Verify column indices for nHe, nO, nN₂, nO₂, nAr, nH, nO*, nNO, T

**Acceptance Criterion**: All fields correctly mapped, no parsing errors

### Tier 3: Numerical Validation (MSIS Execution)
- [ ] **Fortran executable runs**: `./msis2.1_test.exe` executes successfully
- [ ] **Output densities**: ρ > 0, decreases with altitude, magnitude ~10⁻¹² to 10⁻⁶ g/cm³
- [ ] **Output temperatures**: T > 0, ~200-1000 K, physically reasonable
- [ ] **Scale height**: H > 0, increases with altitude, ~10⁴-10⁶ cm

**Acceptance Criterion**: All outputs physically reasonable, no execution errors

### Tier 4: Spatial Averaging Validation
- [ ] **Reshape logic**: Array dimensions [nalt, nglong, nglat, ndate] correct
- [ ] **Mean calculation**: Mean over dimensions [2,3,4] (longitudes, latitudes, dates)
- [ ] **Output size**: Column vector [nalt, 1]

**Acceptance Criterion**: Averaging preserves altitude profile, correct output shape

## Fixed Test Parameters

The validation uses fixed parameters as a deterministic test baseline:

| Parameter | Value | Physical Meaning | Coverage |
|-----------|-------|-----------------|----------|
| iyds | [99079, 99172, 99266, 99356] | March 20, June 21, Sept 23, Dec 27, 1999 | ~equinox/solstice |
| glats | [60, 70, 80] | 60°, 70°, 80° N | High-latitude auroral |
| glongs | [0, 90, 180, 270] | 0°, 90°, 180°, 270° | Global longitudinal |
| sec | 64800 | 18:00 UT | Afternoon local time |
| f107a, f107 | 50, 50 | Quiet solar minimum | Solar baseline |
| Ap | 5 | Quiet geomagnetic | Magnetic baseline |

**Note**: This validates core physics with a reproducible baseline. Comprehensive parameter sweeps are future work.

## Deliverables

1. **test_msis_integration.m** - Comprehensive test script covering all 4 tiers
2. **validation_report_3.3.0.md** - Validation results for each tier
3. **Updated task documentation** - Documented acceptance criteria and known limitations

## Verification

### Tier 1 Verification
```matlab
% Test physical constants
assert(abs(1.66e-27 - 1.660539e-27)/1.660539e-27 < 0.001);  % AMU
assert(abs(1.38e-23 - 1.380649e-23)/1.380649e-23 < 0.001);  % Boltzmann
```

### Tier 2 Verification
```bash
# Check file structure
head -1 /work/projects/IMPACT/nrlmsis2.1/msisinputs.txt | grep "iyd.*sec.*alt.*glat"
awk 'NR==2 {print NF}' /work/projects/IMPACT/nrlmsis2.1/msisoutputs.txt  # Should be 20
```

### Tier 3 Verification
```matlab
% Run MSIS and check outputs
[rho_out, H_out] = get_msis_dat([100:100:1000], 50, 50, 5, false);
assert(all(rho_out > 0) && all(H_out > 0));
assert(all(diff(log(rho_out)) < 0));  % Density decreases
```

### Tier 4 Verification
```matlab
% Test spatial averaging
test_data = reshape(1:48, [6, 4, 3]);
averaged = mean(test_data, [2 3]);
assert(all(size(averaged) == [6, 1]));
```

## Completion Criteria

ALL of the following must be true:
- [ ] All 4 validation tiers completed (Tiers 1-4)
- [ ] All acceptance criteria met for each tier
- [ ] N (atomic nitrogen) exclusion documented with rationale
- [ ] O* (anomalous oxygen) definition clarified
- [ ] Test script `test_msis_integration.m` created and passes
- [ ] Validation report documents results and known limitations
- [ ] Fortran MSIS execution successful (or fallback documented)

When complete, output: TASK_COMPLETE

## Dependencies

- **Task 3.0.0**: MSIS 2.0/2.1 documentation collected (COMPLETED)
- **MSIS source code**: Available in `/work/projects/IMPACT/nrlmsis2.1/`
- **msis21.parm**: Binary parameter file (536 KB, required)
- **Fortran compiler**: gfortran 7.5.0+ (for recompilation if needed)

## Notes

- Fixed parameters provide deterministic baseline for validation
- Extensive parameter sweeps are future work
- MSIS 2.1 is external NRL software (Academic Research License)
- Tiered approach allows partial completion if Fortran execution fails

## References

1. Picone et al. (2002), NRLMSISE-00 empirical model of the atmosphere
2. Emmert et al. (2021), NRLMSIS 2.0: A Whole-Atmosphere Empirical Model
3. Fang et al. (2010), Parameterization of monoenergetic electron impact ionization
4. MSIS 2.1 documentation and source code

