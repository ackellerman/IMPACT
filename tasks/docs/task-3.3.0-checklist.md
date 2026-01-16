# Implementation Checklist: Task 3.3.0

**For**: Developer/Tester implementing MSIS validation
**From**: Architecture Planner approval

---

## Architecture Summary

**Status**: ✅ **APPROVED WITH CONDITIONS**
**Approach**: Four-tier validation strategy
**Key Decision**: Fixed parameters acceptable as test baseline (document limitations)

---

## Pre-Implementation Checks

Before starting implementation:

- [ ] Read `task-3.3.0-architecture-review.md` for detailed guidance
- [ ] Verify MSIS directory exists: `/work/projects/IMPACT/nrlmsis2.1/`
- [ ] Verify `msis21.parm` file exists (should be ~536 KB)
- [ ] Verify `msis2.1_test.exe` exists (should be ~88 KB)
- [ ] Review `get_msis_dat.m` implementation (lines 74-81, 157-158, 170, 191-192)
- [ ] Check task 3.0.0 documentation for MSIS reference values

---

## Tier 1: Static Validation (Start Here)

**Goal**: Verify physical constants and formulas

**Implementation Steps**:
1. Create `test_constants.m` or add to main test script
2. Compare constants to reference values:
   - `amu_kg = 1.66e-27` → CODATA: `1.660539e-27` (tolerance: < 0.1%)
   - `kb = 1.38e-23` → CODATA: `1.380649e-23` (tolerance: < 0.1%)
   - `g0 = 9.80665` → IUGG standard
   - `Re = 6371` → IAU standard
3. Verify atomic masses:
   - He=4, O=16, N₂=28.02, O₂=32, Ar=39.95, H=1, O*=16, NO=30
4. Derive scale height formula from hydrostatic equilibrium
5. Verify gravitational altitude correction formula

**Acceptance Criterion**: All constants within < 0.1% of reference values

**Test Command**:
```matlab
assert(abs(1.66e-27 - 1.660539e-27)/1.660539e-27 < 0.001);
assert(abs(1.38e-23 - 1.380649e-23)/1.380649e-23 < 0.001);
% ... more tests
```

---

## Tier 2: File Format Validation

**Goal**: Verify MSIS input/output file formats

**Implementation Steps**:
1. Check `msisinputs.txt` format:
   - Header: `iyd sec alt glat glong stl f107a f107 Ap`
   - Verify 9 columns in data section
2. Check `msisoutputs.txt` format:
   - Header: 20 columns including species, ρ, T
   - Verify 20 columns in data section
3. Verify MATLAB parsing code (line 126):
   - `textscan` format matches actual columns
   - Column indices correct for species mapping:
     - nHe=col10, nO=col11, nN₂=col12, nO₂=col13, nAr=col14
     - ρ=col15, nH=col16, nO*=col18, nNO=col19, T=col20

**Acceptance Criterion**: All fields correctly mapped, no parsing errors

**Test Command**:
```bash
cd /work/projects/IMPACT/nrlmsis2.1
head -1 msisinputs.txt | grep "iyd.*sec.*alt.*glat.*glong.*stl.*f107a.*f107.*Ap"
awk 'NR==2 {print NF}' msisoutputs.txt  # Should be 20
```

---

## Tier 3: Numerical Validation

**Goal**: Verify Fortran MSIS execution and output physical reasonableness

**Implementation Steps**:
1. Test Fortran execution:
   ```bash
   cd /work/projects/IMPACT/nrlmsis2.1
   ./msis2.1_test.exe
   # Verify msisoutputs.txt is created
   ```

2. Test MATLAB function:
   ```matlab
   altitudes = 100:100:1000;
   [rho_out, H_out] = get_msis_dat(altitudes, 50, 50, 5, false);
   ```

3. Verify outputs physically reasonable:
   - `rho_out > 0` for all altitudes
   - `H_out > 0` for all altitudes
   - `diff(log(rho_out)) < 0` (density decreases)
   - Magnitude checks:
     - ρ: ~10⁻¹² to 10⁻⁶ g/cm³ for 100-1000 km
     - H: ~10⁴ to 10⁶ cm (10-10000 m)
     - T: ~200-1000 K

**Acceptance Criterion**: All outputs physically reasonable, no execution errors

**Test Command**:
```matlab
assert(all(rho_out > 0), 'Density must be positive');
assert(all(H_out > 0), 'Scale height must be positive');
assert(all(diff(log(rho_out)) < 0), 'Density should decrease');
assert(rho_out(1) < 1e-5 && rho_out(end) > 1e-15);
assert(H_out(1) > 1e4 && H_out(end) < 1e7);
```

**Fallback** (if Fortran execution fails):
- Use pre-generated `msisoutputs.txt` if available
- Document failure in validation report
- Create task 3.3.1 for MSIS compilation fix

---

## Tier 4: Spatial Averaging Validation

**Goal**: Verify reshape and mean logic

**Implementation Steps**:
1. Test reshape operation (line 187-188):
   - Input: `H` vector length = nalt × nglong × nglat × ndate
   - Reshape: `[nalt, nglong, nglat, ndate]`
   - Verify: nalt=length(alt), nglong=4, nglat=3, ndate=4

2. Test mean calculation (line 191-192):
   - Mean over dimensions [2,3,4] (longitudes, latitudes, dates)
   - Output size: `[nalt, 1]` (column vector)

3. Verify averaging preserves altitude profile:
   - Output vector length = nalt
   - Altitude dependence remains

**Acceptance Criterion**: Averaging preserves altitude profile, correct output shape

**Test Command**:
```matlab
% Test with known data
test_data = reshape(1:48, [6, 4, 3]);  % nalt=6, nglong=4, nglat=3
averaged = mean(test_data, [2 3]);
assert(all(size(averaged) == [6, 1]), 'Mean output shape incorrect');

% Verify numerical averaging
assert(abs(averaged(1) - mean([1,7,13,19,25,31,37,43])) < 1e-10);
```

---

## Required Documentation

### Open Questions to Address

1. **N (atomic nitrogen) exclusion**:
   - [ ] Verify N density magnitude in MSIS outputs (should be < 10⁸ cm⁻³)
   - [ ] Calculate mass contribution of N (should be < 1% of total)
   - [ ] Document rationale for excluding N from Mav calculation

2. **O* (anomalous oxygen) definition**:
   - [ ] Verify MSIS documentation for nOa (anomalous oxygen)
   - [ ] Confirm O* in Fang model refers to MSIS nOa
   - [ ] Confirm mass assumption (O* = 16 AMU, same as O)

### Code Documentation to Add

Update `get_msis_dat.m` comments with:

1. **Line 157**: Add comment explaining N exclusion:
   ```matlab
   % Note: N (atomic nitrogen) excluded because nN < 1% of total neutral mass
   ```

2. **Line 161-162**: Add references for constants:
   ```matlab
   g0 = 9.80665;    % m/s^2, IUGG standard sea-level gravity
   Re = 6371;       % km, IAU standard Earth radius
   ```

3. **Line 170**: Add derivation reference:
   ```matlab
   H = kb * T ./ (Mav .* g); % scale height from hydrostatic equilibrium: H = kT/(Mg)
   ```

4. **Line 174**: Add unit conversion note:
   ```matlab
   H = H' * 100;  % Convert m to cm (Fang equations require H in cm)
   ```

---

## Validation Report Template

Create `validation_report_3.3.0.md` with:

```markdown
# MSIS Data Retrieval Validation Report

## Summary
- Date: [DATE]
- Tiers completed: [X/4]
- Overall status: [PASS/FAIL/PARTIAL]

## Tier 1: Static Validation
- Constants verified: [PASS/FAIL]
  - AMU conversion: [error %]
  - Boltzmann constant: [error %]
  - Gravitational parameters: [PASS/FAIL]
- Atomic masses: [PASS/FAIL]
- Formulas derived: [PASS/FAIL]

## Tier 2: File Format Validation
- Input file format: [PASS/FAIL]
- Output file parsing: [PASS/FAIL]
- Column mapping: [PASS/FAIL]

## Tier 3: Numerical Validation
- Fortran execution: [PASS/FAIL]
- Output densities: [PASS/FAIL] (min: [val], max: [val])
- Output temperatures: [PASS/FAIL] (min: [val], max: [val])
- Scale heights: [PASS/FAIL] (min: [val], max: [val])

## Tier 4: Spatial Averaging Validation
- Reshape logic: [PASS/FAIL]
- Mean calculation: [PASS/FAIL]
- Output shape: [PASS/FAIL] ([nalt, 1])

## Known Limitations
1. Fixed parameters used (F10.7=50, Ap=5, 4 dates)
2. N (atomic nitrogen) excluded from Mav calculation
3. Validation limited to quiet solar/geomagnetic conditions

## Open Questions
1. [Document N exclusion rationale]
2. [Clarify O* definition]

## Recommendations
- [List follow-up tasks for extended validation]
```

---

## Success Criteria

**Task Complete When**:

- [ ] **Tier 1**: All constants verified (< 0.1% error), formulas derived
- [ ] **Tier 2**: File formats validated, columns mapped correctly
- [ ] **Tier 3**: Fortran MSIS executes successfully, outputs physically reasonable
- [ ] **Tier 4**: Spatial averaging logic validated, output shape correct
- [ ] **Documentation**: N exclusion and O* definition clarified
- [ ] **Test script**: `test_msis_integration.m` created and passes all tests
- [ ] **Report**: `validation_report_3.3.0.md` completed with results

**Final Output**: `TASK_COMPLETE`

---

## Troubleshooting

### Fortran Execution Fails

**Symptom**: `msis2.1_test.exe` not found or fails to run

**Solutions**:
1. Check if executable exists: `ls -lh /work/projects/IMPACT/nrlmsis2.1/msis2.1_test.exe`
2. Try recompiling: `cd /work/projects/IMPACT/nrlmsis2.1 && ./compile_msis.sh`
3. Check if `msis21.parm` exists: `ls -lh /work/projects/IMPACT/nrlmsis2.1/msis21.parm`
4. Check file permissions: `chmod +x /work/projects/IMPACT/nrlmsis2.1/msis2.1_test.exe`
5. Use fallback: Pre-generated `msisoutputs.txt` (if available)

### Path Resolution Fails

**Symptom**: MATLAB function can't find MSIS directory

**Solutions**:
1. Test path resolution:
   ```matlab
   cd /tmp
   [rho, H] = get_msis_dat([100, 200], 50, 50, 5);
   ```
2. Check MSIS directory existence verification (line 53-55)
3. Verify `msisDIR` path is correct

### Numerical Errors

**Symptom**: Outputs unrealistic or NaN values

**Solutions**:
1. Check MSIS output file for corruption
2. Verify input file format is correct
3. Check for division by zero (Mav or g)
4. Compare to reference file: `msis2.1_test_ref_dp.txt`

---

## References

- Architecture review: `task-3.3.0-architecture-review.md`
- Task documentation: `task-3.3.0.md`
- Literature survey: `literature_survey_3.0.md`
- MSIS source: `/work/projects/IMPACT/nrlmsis2.1/`

---

**End of Checklist**
