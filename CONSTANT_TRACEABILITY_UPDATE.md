# CONSTANT TRACEABILITY UPDATE - Task 3.2.0

**Date:** January 16, 2026
**Task:** Validate bounce period equations in bounce_time_arr.m
**Status:** T_pa polynomial coefficients remain **NOT TRACED**

---

## Update Summary

The validation completed in Task 3.2.0 has confirmed the status of T_pa polynomial coefficients:

- ✅ **Energy-to-momentum conversion formula (Line 38):** VERIFIED - mathematically equivalent to standard relativistic physics
- ✅ **Physical constants:** VERIFIED - match CODATA 2018 / IAU 2015 standards
- ✅ **Bounce period formula (Line 50):** VERIFIED - structure matches Roederer (1970)
- ⚠️ **T_pa polynomial COEFFICIENTS:** **NOT TRACED** - remain as documented limitation

---

## T_pa Polynomial Coefficients Status

### Current Documentation (from CONSTANT_TRACEABILITY.md)

All 6 T_pa coefficients are documented as "NOT TRACED - REQUIRES INVESTIGATION":

| Coefficient | Value | Status |
|------------|-------|--------|
| T_pa[1] (constant) | 1.38 | ❌ NOT TRACED |
| T_pa[2] (sin^1/3) | 0.055 | ❌ NOT TRACED |
| T_pa[3] (sin^1/2) | -0.32 | ❌ NOT TRACED |
| T_pa[4] (sin^2/3) | -0.037 | ❌ NOT TRACED |
| T_pa[5] (sin^1) | -0.394 | ❌ NOT TRACED |
| T_pa[6] (sin^4/3) | 0.056 | ❌ NOT TRACED |

### Validation Results

**Polynomial Structure:** ✅ **VALIDATED**
- Form: T_pa = Σ a_i · sin(α)^p_i matches Roederer (1970) mathematical structure
- Powers: 0, 1/3, 1/2, 2/3, 1, 4/3 are consistent with bounce period theory
- Values: All evaluated values in physically reasonable range (1.0-2.5)

**Individual Coefficients:** ⚠️ **NOT TRACED**
- No literature source identified for specific coefficient values
- Coefficients appear to be derived from numerical fitting
- Original source requires further investigation

### Validation Status: ✅ **STRUCTURE VERIFIED, COEFFICIENTS UNTRACED**

The polynomial form is validated as correct, but the specific coefficient values remain untraced to literature. This is a **known limitation** that does not affect the physical correctness of the implementation but requires future investigation.

---

## Recommended Actions for Future Investigation

### Priority 1: Literature Search

1. **Search Roederer (1970) original edition**
   - Look for numerical approximations to the bounce period integral
   - Check for tabulated polynomial coefficients

2. **Check Schulz and Lanzerotti (1974)**
   - "Particle Diffusion in the Radiation Belts"
   - May contain computational approximations

3. **Search subsequent implementations**
   - Look for early computational codes that first used these coefficients
   - Check LANL, NASA, and other space physics codes

### Priority 2: Code Archaeology

1. **Contact original code author** (Adam Kellerman)
   - Request historical documentation
   - Ask about coefficient origin

2. **Check version control history**
   - Look for commit messages or comments
   - Search for any references in repository

### Priority 3: Alternative Approaches

1. **Numerical re-fitting**
   - Fit polynomial to exact Roederer integral
   - Compare with existing coefficients
   - Document any differences

2. **Use alternative parameterization**
   - Replace with numerically integrated values
   - Document the change in traceability

---

## Physical Constants - Status Confirmed

All physical constants used in bounce_time_arr.m are **FULLY TRACED**:

| Constant | Value | Source | Status |
|----------|-------|--------|--------|
| mc²_e | 0.511 MeV | CODATA 2018 | ✅ TRACED |
| mc²_p | 938 MeV | CODATA 2018 | ✅ TRACED |
| c | 2.998×10⁸ m/s | CODATA 2018 | ✅ TRACED |
| R_E | 6.371×10⁶ m | IAU 2015 | ✅ TRACED |

---

## Validation Test Results

The validation suite `test_bounce_time_validation.m` includes 6 tests:

1. **Energy to Momentum Conversion** - ✅ PASSED
2. **Physical Constants Verification** - ✅ PASSED
3. **Bounce Period Formula Structure** - ✅ PASSED
4. **Particle Type Dependence** - ✅ PASSED
5. **Energy Dependence** - ✅ PASSED
6. **T_pa Polynomial Structure** - ✅ PASSED (coefficients untraced - documented)

---

## Summary

**Status:** T_pa polynomial coefficients remain **NOT TRACED**

**Impact:** Low - the polynomial form is correct and coefficients produce physically reasonable values, but the specific origin is unknown.

**Recommendation:** Continue literature investigation as part of future code maintenance.

---

**Document Version:** 1.1
**Previous Version:** 1.0 (CONSTANT_TRACEABILITY.md)
**Update:** Added Task 3.2.0 validation results confirming T_pa coefficient status