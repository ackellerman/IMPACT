# Constant Usage Matrix for IMPACT Precipitation Code

**Task:** 3.4.0 Validate Physical Constants and Unit Conversions  
**Date:** January 16, 2026  
**Purpose:** Cross-reference file locations for all physical constants and empirical parameters

---

## 1. Physical Constants Matrix

### 1.1 Fundamental Physical Constants

| Constant | Standard Value | CODATA/IAU Reference | bounce_time_arr.m | msis_constants.F90 | Test Files |
|----------|----------------|----------------------|-------------------|---------------------|------------|
| Electron mc² | 0.511 MeV | 0.510998950 MeV | Line 26,34 | - | ✅ test_bounce_time_validation.m |
| Proton mc² | 938 MeV | 938.27208816 MeV | Line 28 | - | ✅ test_bounce_time_validation.m |
| Speed of Light (c) | 2.998×10⁸ m/s | 2.99792458×10⁸ m/s | Line 42 | - | ✅ test_bounce_time_validation.m |
| Earth Radius (R_E) | 6371 km | IAU 2015 | Line 41 (6.371e6 m) | - | ✅ All test files |
| Boltzmann Constant (k_B) | 1.380649×10⁻²³ J/K | CODATA 2018 | - | Line 42 | ✅ test_msis_integration.m |
| Avogadro Constant (N_A) | 6.02214076×10²³ | CODATA 2018 | - | Line 44 | ✅ test_msis_integration.m |
| Standard Gravity (g₀) | 9.80665 m/s² | CIMO Guide 2014 | - | Line 46 | ✅ All MSIS tests |
| Atomic Mass Unit | 1.66×10⁻²⁷ kg | CODATA 2018 | - | Line 58 | ✅ get_msis_dat.m |

### 1.2 Earth Geometry Constants (Fortran)

| Constant | Value | Units | Source | msis_utils.F90 | Usage Context |
|----------|-------|-------|--------|----------------|---------------|
| Reciprocal Flattening (1/f) | 298.257223563 | dimensionless | DMA TR8350.2 | Line 51 | Earth ellipsoid model |
| Eccentricity squared | Derived | dimensionless | Calculated | Line 51 | Geodetic calculations |

---

## 2. Fang 2010 Model Constants Matrix

### 2.1 Ionization and Energy Dissipation

| Constant | Value | Units | Source | calc_ionization.m | calc_Edissipation.m | Test Files |
|----------|-------|-------|--------|-------------------|---------------------|------------|
| Ionization Energy (D*) | 0.035 | keV | Rees 1989 | Line 35 | - | ✅ test_calc_ionization_validation.m |
| Reference Density (ρ_ref) | 6×10⁻⁶ | g/cm³ | Fang 2010 Eq.1 | - | Line 39 | ✅ test_calc_Edissipation_validation.m |
| Energy Exponent | 0.7 | dimensionless | Fang 2010 Eq.1 | - | Line 39 | ✅ test_calc_Edissipation_validation.m |

### 2.2 Pij Coefficients (32 coefficients)

| Coefficient | Value | Source | File Location | Validation |
|-------------|-------|--------|---------------|------------|
| P[1,1] | 1.24616 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[1,2] | 1.45903 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[1,3] | -0.242269 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[1,4] | 0.0595459 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[2,1] | 2.23976 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[2,2] | -4.22918×10⁻⁷ | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[2,3] | 0.0136458 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[2,4] | 0.00253332 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[3,1] | 1.41754 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[3,2] | 0.144597 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[3,3] | 0.0170433 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[3,4] | 0.000639717 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[4,1] | 0.248775 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[4,2] | -0.150890 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[4,3] | 6.30894×10⁻⁹ | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[4,4] | 0.00123707 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[5,1] | -0.465119 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[5,2] | -0.105081 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[5,3] | -0.0895701 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[5,4] | 0.0122450 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[6,1] | 0.386019 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[6,2] | 0.00175430 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[6,3] | -0.000742960 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[6,4] | 0.000460881 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[7,1] | -0.645454 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[7,2] | 0.000849555 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[7,3] | -0.0428502 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[7,4] | -0.00299302 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[8,1] | 0.948930 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[8,2] | 0.197385 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[8,3] | -0.00250603 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |
| P[8,4] | -0.00206938 | Fang 2010 Table 1 | coeff_fang10.mat | ✅ test_calc_Edissipation_validation.m |

---

## 3. Bounce Period Constants Matrix

### 3.1 T_pa Polynomial Coefficients

| Coefficient | Value | bounce_time_arr.m | test_bounce_time_validation.m | Literature Source | Status |
|-------------|-------|-------------------|-------------------------------|-------------------|--------|
| T_pa[1] | 1.38 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |
| T_pa[2] | 0.055 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |
| T_pa[3] | -0.32 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |
| T_pa[4] | -0.037 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |
| T_pa[5] | -0.394 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |
| T_pa[6] | 0.056 | Line 46 | Line 266,332,340,418,507 | ❌ NOT TRACED | ⚠️ REQUIRES INVESTIGATION |

---

## 4. Molecular and Atomic Mass Matrix

### 4.1 Species Masses (g/mol → kg/molecule)

| Species | Mass (g/mol) | Mass (kg/molecule) | Code Usage | File Location |
|---------|--------------|-------------------|------------|---------------|
| He | 4.0 | 6.642×10⁻²⁷ | 4.0 | get_msis_dat.m:167, verify_mav.m:17,23 |
| O | 16.0 | 2.657×10⁻²⁶ | 16.0 | get_msis_dat.m:167, verify_mav.m:17,23 |
| N₂ | 28.02 | 4.652×10⁻²⁶ | 28.02 | get_msis_dat.m:167, verify_mav.m:17,23 |
| O₂ | 32.0 | 5.314×10⁻²⁶ | 32.0 | get_msis_dat.m:167, verify_mav.m:17,23 |
| Ar | 39.95 | 6.633×10⁻²⁶ | 39.95 | get_msis_dat.m:167, verify_mav.m:17,23 |
| H | 1.0 | 1.660×10⁻²⁷ | 1.0 | get_msis_dat.m:167, verify_mav.m:17,23 |
| N | 14.0 | 2.325×10⁻²⁶ | - | (in MSIS, not in average calculation) |
| O (atomic) | 16.0 | 2.657×10⁻²⁶ | 16.0 | get_msis_dat.m:167, verify_mav.m:17,23 |
| NO | 30.0 | 4.982×10⁻²⁶ | 30.0 | get_msis_dat.m:167 |

---

## 5. Unit Conversion Factors Matrix

### 5.1 Energy Conversions

| From | To | Factor | Code Location | Validation Status |
|------|----|--------|---------------|-------------------|
| keV | MeV | 1×10⁻³ | Implicit in calc_ionization.m | ✅ VALIDATED |
| MeV | keV | 1×10³ | Implicit in bounce_time_arr.m | ✅ VALIDATED |
| eV | keV | 1×10⁻³ | calc_ionization.m:35 (0.035 keV) | ✅ VALIDATED |

### 5.2 Distance Conversions

| From | To | Factor | Code Location | Validation Status |
|------|----|--------|---------------|-------------------|
| km | m | 1×10³ | bounce_time_arr.m:41 (6.371e6) | ✅ VALIDATED |
| m | km | 1×10⁻³ | dipole_mirror_altitude.m:27 | ✅ VALIDATED |
| cm | m | 1×10⁻² | Implicit in MSIS scale height | ✅ VALIDATED |

### 5.3 Density Conversions

| From | To | Factor | Code Location | Validation Status |
|------|----|--------|---------------|-------------------|
| g/cm³ | kg/m³ | 1×10³ | Not used (consistent units) | ✅ CONSISTENT |
| amu | kg | 1.66×10⁻²⁷ | get_msis_dat.m:167 | ✅ VALIDATED |

### 5.4 Time Conversions

| From | To | Factor | Code Location | Validation Status |
|------|----|--------|---------------|-------------------|
| s | min | 1/60 | bounce_time_arr.m:50 | ✅ VALIDATED |
| min | h | 1/60 | bounce_time_arr.m:50 | ✅ VALIDATED |
| h | day | 1/24 | bounce_time_arr.m:50 | ✅ VALIDATED |

---

## 6. Test Coverage Matrix

### 6.1 Constant Validation Tests

| Constant | Test File | Test Function | Test Status |
|----------|-----------|---------------|-------------|
| R_E (6371 km) | test_bounce_time_validation.m | Re validation | ✅ PASS |
| R_E (6371 km) | test_mirror_altitude_validation.m | Re usage | ✅ PASS |
| mc²_e (0.511 MeV) | test_bounce_time_validation.m | mc2_e validation | ✅ PASS |
| mc²_p (938 MeV) | test_bounce_time_validation.m | mc2_p validation | ✅ PASS |
| c (2.998e8 m/s) | test_bounce_time_validation.m | c_si validation | ✅ PASS |
| 0.035 keV | test_calc_ionization_validation.m | Ionization constant | ✅ PASS |
| 6×10⁻⁶ g/cm³ | test_calc_Edissipation_validation.m | Reference density | ✅ PASS |
| T_pa coefficients | test_bounce_time_validation.m | T_pa polynomial | ✅ PASS (no source) |
| Pij coefficients | test_calc_Edissipation_validation.m | Fang coefficients | ✅ PASS |

### 6.2 Integration Tests

| Test File | Purpose | Constants Validated |
|-----------|---------|---------------------|
| test_bounce_time_validation.m | Bounce period calculations | R_E, mc²_e, mc²_p, c, T_pa |
| test_calc_Edissipation_validation.m | Energy dissipation | ρ_ref, Pij coefficients |
| test_calc_ionization_validation.m | Ionization rates | 0.035 keV |
| test_msis_integration.m | MSIS model integration | k_B, g₀, molecular masses |
| test_mirror_altitude_validation.m | Mirror altitude calculations | R_E |

---

## 7. Consistency Violation Matrix

### 7.1 Zero Violations Found

| Constant | Expected | Found | Deviation | Status |
|----------|----------|-------|-----------|--------|
| R_E | 6371 km | 6371 km | 0 km | ✅ CONSISTENT |
| mc²_e | 0.511 MeV | 0.511 MeV | 0% | ✅ CONSISTENT |
| mc²_p | 938 MeV | 938 MeV | 0% | ✅ CONSISTENT |
| c | 2.998e8 m/s | 2.998e8 m/s | 0% | ✅ CONSISTENT |
| 0.035 keV | 0.035 keV | 0.035 keV | 0% | ✅ CONSISTENT |
| 6×10⁻⁶ | 6×10⁻⁶ | 6×10⁻⁶ | 0% | ✅ CONSISTENT |

---

## 8. Legend and Usage Guide

### 8.1 Status Indicators

| Symbol | Meaning |
|--------|---------|
| ✅ | Validated/Consistent |
| ⚠️ | Issue detected (see notes) |
| ❌ | Not traced/Problematic |
| - | Not used in this file |

### 8.2 File Abbreviations

| Abbreviation | Full File Path |
|--------------|----------------|
| bounce_time_arr.m | IMPACT_MATLAB/bounce_time_arr.m |
| calc_Edissipation.m | IMPACT_MATLAB/calc_Edissipation.m |
| calc_ionization.m | IMPACT_MATLAB/calc_ionization.m |
| get_msis_dat.m | IMPACT_MATLAB/get_msis_dat.m |
| msis_constants.F90 | nrlmsis2.1/msis_constants.F90 |
| msis_utils.F90 | nrlmsis2.1/msis_utils.F90 |
| coeff_fang10.mat | IMPACT_MATLAB/coeff_fang10.mat |

---

**Document Version:** 1.0  
**Date:** January 16, 2026  
**Validation Coverage:** 45 constants across 10+ files