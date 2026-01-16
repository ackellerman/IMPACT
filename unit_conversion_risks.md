# Unit Conversion Risk Assessment

**Task:** 3.4.0 Validate Physical Constants and Unit Conversions  
**Date:** January 16, 2026  
**Purpose:** Identify and document risks in unit conversion logic

---

## Executive Summary

This risk assessment evaluates the unit conversion logic across the IMPACT precipitation model. The audit examined energy, distance, density, and time conversions used in both MATLAB and Fortran 90 code.

**Overall Risk Level:** 🟡 **LOW-MEDIUM**

**Risk Summary:**
- **High Priority Risks:** 0 identified
- **Medium Priority Risks:** 2 identified  
- **Low Priority Risks:** 3 identified
- **No Critical Issues Found**

---

## 1. Risk Assessment Framework

### 1.1 Risk Categories

| Risk Level | Definition | Action Required |
|------------|------------|-----------------|
| 🔴 **HIGH** | Could cause incorrect scientific results | Immediate investigation and fix |
| 🟡 **MEDIUM** | Could cause numerical issues or confusion | Document and monitor |
| 🟢 **LOW** | Well-handled or minor documentation issues | Note for improvement |

### 1.2 Risk Criteria

- **Numerical Impact:** Does the risk affect calculation accuracy?
- **Frequency:** How often is the conversion used?
- **Detectability:** Would errors be caught by existing tests?
- **Scope:** How many files/functions are affected?

---

## 2. Energy Conversion Risks

### 2.1 keV ↔ MeV Conversion

**Risk Level:** 🟢 **LOW**

**Description:** Energy unit conversions between keV and MeV

**Current Implementation:**
```matlab
% calc_ionization.m - Energy flux in keV
q_tot = (Qe_grid / 0.035) .* f ./ H_grid;

% bounce_time_arr.m - Energy in MeV  
mc2 = 0.511; % MeV
pc = sqrt((E ./ mc2 + 1).^2 - 1) .* mc2;
```

**Risk Analysis:**
- ✅ **Proper Handling:** Units are clearly documented in function headers
- ✅ **No Implicit Conversions:** No hidden unit transformations detected
- ✅ **Test Coverage:** Unit conversions tested in validation suites

**Potential Issues:**
- Future developers might mix keV and MeV without proper conversion
- No centralized conversion utility exists

**Mitigation:**
```matlab
% RECOMMENDED: Create conversion utilities
function MeV = keV_to_MeV(keV)
    MeV = keV * 1e-3;
end

function keV = MeV_to_keV(MeV)
    keV = MeV * 1e3;
end
```

**Current Risk:** LOW  
**Recommendation:** Create utility functions for energy conversions

---

### 2.2 eV ↔ keV Conversion

**Risk Level:** 🟢 **LOW**

**Description:** Conversion between electron-volts and kiloelectron-volts (0.035 keV = 35 eV)

**Current Implementation:**
```matlab
% calc_ionization.m line 35
q_tot = (Qe_grid / 0.035) .* f ./ H_grid;
% 0.035 keV = 35 eV (exact conversion)
```

**Risk Analysis:**
- ✅ **Exact Conversion:** 0.035 keV = 35 eV (no rounding error)
- ✅ **Well Documented:** Constant 0.035 documented as keV in code comments
- ✅ **Validated:** Test file explicitly verifies this conversion

**Evidence:**
```matlab
% test_calc_ionization_validation.m lines 78-83
% Verify 0.035 keV = 35 eV (ionization energy per ion pair)
constant_keV = 0.035;
calculated_eV = constant_keV * 1000;  % = 35 eV
```

**Current Risk:** LOW  
**Status:** ✅ **WELL HANDLED**

---

## 3. Distance Conversion Risks

### 3.1 km ↔ m Conversion

**Risk Level:** 🟢 **LOW**

**Description:** Conversion between kilometers and meters for Earth radius

**Current Implementation:**
```matlab
% bounce_time_arr.m line 41 (meters)
Re = 6.371e6;  % Earth radius in meters

% get_msis_dat.m line 172 (kilometers)  
Re = 6371;     % Earth radius in kilometers
```

**Risk Analysis:**
- ✅ **Consistent Values:** Both represent 6371 km = 6.371×10⁶ m
- ✅ **Clear Documentation:** Units specified in variable names and comments
- ✅ **Unit Awareness:** Code clearly tracks which unit is being used

**Potential Issues:**
- Mix of km and m in different functions requires careful tracking
- No automatic conversion between the two representations

**Current Risk:** LOW  
**Recommendation:** Consider using consistent units throughout (meters recommended for SI compliance)

---

### 3.2 L-Shell Unit Consistency

**Risk Level:** 🟢 **LOW**

**Description:** L-shell parameter unit handling (dimensionless, in Earth radii)

**Current Implementation:**
```matlab
% dipole_mirror_altitude.m lines 27-28
r = Lshell.*6371.* cos(mirror_lat_query).^2;  % r in km
mirror_altitude = r - 6371;  % altitude in km

% bounce_time_arr.m line 50
bt = 4.0 .* L .* Re .* mc2 ./ pc ./ c_si .* T_pa / 60 / 60 / 24;
% L is dimensionless, Re in meters
```

**Risk Analysis:**
- ✅ **Dimensionally Correct:** L-shell = r_eq / R_E (dimensionless)
- ✅ **Clear Units:** Function inputs/outputs clearly documented
- ✅ **Consistent with Theory:** Matches standard space physics definitions

**Current Risk:** LOW  
**Status:** ✅ **WELL HANDLED**

---

## 4. Density Conversion Risks

### 4.1 g/cm³ ↔ kg/m³ Conversion

**Risk Level:** 🟡 **MEDIUM**

**Description:** Potential confusion between g/cm³ and kg/m³ units for atmospheric density

**Current Implementation:**
```matlab
% calc_Edissipation.m expects g/cm³
rho_out - Atmospheric mass density (in g cm^-3)
H_out   - Atmospheric scale height (in cm)

% MSIS output matches this format
% Reference density uses same units
rho_ref = 6e-6;  % g/cm³
```

**Risk Analysis:**
- ✅ **Consistent Units:** All density calculations use g/cm³ consistently
- ✅ **No Conversion Needed:** MSIS output and reference density use same units
- ✅ **Well Documented:** Function inputs clearly specify units

**Potential Risk:**
- ⚠️ **Unit Confusion:** 6×10⁻⁶ g/cm³ = 6×10⁻³ kg/m³
- ⚠️ **Future Integration:** Other atmospheric models might use kg/m³
- ⚠️ **Scientific Literature:** Some papers use kg/m³, others use g/cm³

**Example of Potential Issue:**
```matlab
% If someone imports data from a model using kg/m³:
rho_wrong = 6e-6;  % Assumed kg/m³, but code expects g/cm³
% This would be 1000× too small!

% Correct conversion would be:
rho_correct = 6e-6 * 1000;  % Convert kg/m³ to g/cm³
```

**Current Risk:** MEDIUM  
**Recommendation:** Add explicit unit checking or conversion utilities

**Mitigation Strategy:**
```matlab
function rho_g_cm3 = kg_m3_to_g_cm3(rho_kg_m3)
    % Convert kg/m³ to g/cm³
    % 1 kg/m³ = 0.001 g/cm³
    rho_g_cm3 = rho_kg_m3 * 1e-3;
end

function rho_kg_m3 = g_cm3_to_kg_m3(rho_g_cm3)
    % Convert g/cm³ to kg/m³  
    % 1 g/cm³ = 1000 kg/m³
    rho_kg_m3 = rho_g_cm3 * 1e3;
end
```

---

### 4.2 Atomic Mass Unit Conversion

**Risk Level:** 🟢 **LOW**

**Description:** Conversion between atomic mass units and kilograms

**Current Implementation:**
```matlab
% get_msis_dat.m line 167
Mav = 1.66e-27*(nHe*4.0 + nO*16.0 + nN2*28.02 + ...);

% verify_mav.m line 17
M_matlab = amu_kg * (nHe*4.0 + nO*16.0 + ...);
```

**Risk Analysis:**
- ✅ **Correct Value:** 1.66×10⁻²⁷ kg (CODATA value: 1.66053906660×10⁻²⁷ kg)
- ✅ **Well Commented:** Purpose of conversion explained
- ✅ **Tested:** verify_mav.m validates the conversion

**Current Risk:** LOW  
**Status:** ✅ **WELL HANDLED**

---

## 5. Time Conversion Risks

### 5.1 Second ↔ Day Conversion

**Risk Level:** 🟢 **LOW**

**Description:** Conversion from seconds to days for bounce period output

**Current Implementation:**
```matlab
% bounce_time_arr.m line 50
bt = 4.0 .* L .* Re .* mc2 ./ pc ./ c_si .* T_pa / 60 / 60 / 24;
% Division by 60/60/24 converts seconds to days
```

**Risk Analysis:**
- ✅ **Correct Calculation:** 60 × 60 × 24 = 86400 seconds/day
- ✅ **Clear Intent:** Division factors clearly show unit conversion
- ✅ **Output Units:** Function header documents output as days

**Current Risk:** LOW  
**Status:** ✅ **WELL HANDLED**

---

## 6. MSIS Model Integration Risks

### 6.1 MSIS Output Unit Compatibility

**Risk Level:** 🟡 **MEDIUM**

**Description:** Ensuring MSIS model output units are compatible with IMPACT calculations

**Current Implementation:**
```matlab
% get_msis_dat.m function header
% OUTPUTS:
%   rho_out - Atmospheric mass density (in g cm^-3)
%   H_out   - Atmospheric scale height (in cm)

% calc_Edissipation.m function header
% INPUTS:
%   rho(z) - Vector of atmospheric mass densities (g cm^-3)
%   H(z)   - Vector of atmospheric scale heights (cm)
```

**Risk Analysis:**
- ✅ **Unit Match:** MSIS output units match IMPACT input requirements
- ✅ **Documented:** Both functions clearly specify units
- ✅ **Validated:** test_msis_integration.m verifies unit compatibility

**Potential Risks:**
- ⚠️ **Future MSIS Updates:** New MSIS versions might change default output units
- ⚠️ **Alternative MSIS Interfaces:** Different interfaces might use different units
- ⚠️ **Configuration Settings:** MSIS might have unit options that could be changed

**Current Risk:** MEDIUM  
**Recommendation:** Add unit validation at MSIS-IMPACT interface

---

## 7. Risk Summary Matrix

| Conversion Type | Risk Level | Frequency | Impact | Detectability | Overall |
|-----------------|------------|-----------|--------|---------------|---------|
| Energy: keV ↔ MeV | 🟢 LOW | High | Medium | High | LOW |
| Energy: eV ↔ keV | 🟢 LOW | Low | High | High | LOW |
| Distance: km ↔ m | 🟢 LOW | High | Medium | High | LOW |
| Distance: L-shell | 🟢 LOW | Medium | Medium | High | LOW |
| Density: g/cm³ ↔ kg/m³ | 🟡 MEDIUM | Low | High | Medium | MEDIUM |
| Density: AMU conversion | 🟢 LOW | Low | Low | High | LOW |
| Time: s ↔ day | 🟢 LOW | Medium | Low | High | LOW |
| MSIS integration | 🟡 MEDIUM | Medium | High | Medium | MEDIUM |

---

## 8. Recommended Risk Mitigations

### 8.1 High Priority Actions

1. **Create Unit Conversion Utilities:**
   ```matlab
   % energy_conversions.m
   function MeV = keV_to_MeV(keV)
       MeV = keV * 1e-3;
   end
   
   function kg_m3 = g_cm3_to_kg_m3(g_cm3)
       kg_m3 = g_cm3 * 1e3;
   end
   
   function g_cm3 = kg_m3_to_g_cm3(kg_m3)
       g_cm3 = kg_m3 * 1e-3;
   end
   ```

2. **Add Unit Validation:**
   ```matlab
   function validate_density_units(rho, expected_unit)
       if expected_unit == "g/cm3" && max(rho) > 1e-3
           error('Density values suggest wrong units (kg/m³ instead of g/cm³?)');
       end
   end
   ```

### 8.2 Medium Priority Actions

3. **Document Unit Assumptions:**
   - Add explicit unit specifications to all function interfaces
   - Create a units.md documentation file
   - Add unit tests for all conversion functions

4. **Create Unit Constants:**
   ```matlab
   % physical_constants.m
   const.amu_kg = 1.66053906660e-27;  % kg
   const.km_to_m = 1e3;                % dimensionless
   const.s_to_day = 1/86400;           % dimensionless
   ```

### 8.3 Low Priority Actions

5. **Standardize Units:**
   - Consider using SI units (kg, m, s) throughout the codebase
   - Convert to user-friendly units only at I/O boundaries
   - Create consistent unit conventions across MATLAB and Fortran

---

## 9. Testing Recommendations

### 9.1 Unit Conversion Tests

| Test | Purpose | Expected Result |
|------|---------|-----------------|
| Test energy conversions | Verify keV ↔ MeV accuracy | All conversions within 1e-15 relative error |
| Test density conversions | Verify g/cm³ ↔ kg/m³ accuracy | All conversions within 1e-15 relative error |
| Test MSIS integration | Verify unit compatibility | MSIS output matches expected units |
| Test dimensional analysis | Verify equation homogeneity | All equations dimensionally consistent |

### 9.2 Regression Tests

| Test | Purpose | Trigger |
|------|---------|---------|
| Unit mismatch detection | Catch unit errors early | All validation runs |
| Constant value check | Detect constant drift | Monthly validation |
| Cross-file consistency | Ensure uniform constant usage | Release validation |

---

## 10. Conclusion

**Overall Assessment:** The unit conversion logic in the IMPACT precipitation model is **well-implemented and low-risk**. No critical issues were identified that would cause incorrect scientific results.

**Key Strengths:**
- ✅ Consistent use of documented units throughout the codebase
- ✅ Clear unit specifications in function interfaces
- ✅ Good test coverage for unit-related functionality
- ✅ No hidden or implicit unit conversions detected

**Areas for Improvement:**
- ⚠️ Create centralized unit conversion utilities
- ⚠️ Add unit validation at MSIS-IMPACT interface
- ⚠️ Consider standardizing on SI units throughout

**Final Risk Rating:** 🟡 **LOW-MEDIUM** (No critical issues, minor improvements recommended)

---

**Risk Assessor:** Implementation Specialist  
**Assessment Date:** January 16, 2026  
**Next Review:** Task 3.4.1 (Refactoring Implementation)