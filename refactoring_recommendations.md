# Refactoring Recommendations for IMPACT Physical Constants

**Task:** 3.4.0 Validate Physical Constants and Unit Conversions  
**Date:** January 16, 2026  
**Purpose:** Future work plan for improving physical constant handling

---

## Executive Summary

This document provides prioritized recommendations for refactoring the IMPACT precipitation model to improve physical constant management, reduce magic numbers, and enhance unit conversion safety. The recommendations are based on findings from the comprehensive validation audit (Task 3.4.0).

**Overall Priority:** 🟡 **MEDIUM-HIGH**  
**Estimated Effort:** 2-3 sprints  
**Expected Impact:** Improved code maintainability and reduced error risk

---

## 1. Immediate Actions (Next Sprint)

### 1.1 Fix Boltzmann Constant Documentation Error

**Priority:** 🔴 **HIGH**  
**Effort:** < 1 day  
**Files Affected:** `nrlmsis2.1/msis_constants.F90`

**Issue:** Line 42 contains incorrect unit in comment
```fortran
! Boltzmann constant (CODATA 2018) (J/kg)  % ← WRONG
real(kind=rp), parameter   :: kB = 1.380649e-23_rp
```

**Required Fix:**
```fortran
! Boltzmann constant (CODATA 2018) (J/K)  % ← CORRECT
real(kind=rp), parameter   :: kB = 1.380649e-23_rp
```

**Rationale:** The value is correct (1.380649×10⁻²³ J/K), but the comment says "J/kg" which is dimensionally incorrect. Fixing documentation prevents future confusion.

**Testing:**
- No code changes required
- Verify documentation build succeeds
- Update CONSTANT_TRACEABILITY.md if needed

---

### 1.2 Investigate T_pa Coefficients

**Priority:** 🔴 **HIGH**  
**Effort:** 1-2 weeks  
**Files Affected:** `IMPACT_MATLAB/bounce_time_arr.m`, documentation

**Issue:** 6 T_pa polynomial coefficients not traced to literature source

**Current Status:**
```
T_pa[1] = 1.38  → NOT TRACED
T_pa[2] = 0.055 → NOT TRACED  
T_pa[3] = -0.32 → NOT TRACED
T_pa[4] = -0.037 → NOT TRACED
T_pa[5] = -0.394 → NOT TRACED
T_pa[6] = 0.056 → NOT TRACED
```

**Required Actions:**
1. Search Roederer (1970) "Dynamics of Geomagnetically Trapped Radiation" for polynomial approximations
2. Check Schulz and Lanzerotti (1974) "Particle Diffusion in the Radiation Belts" for numerical coefficients
3. Search computational implementations (e.g., LANL geomagnetic modeling codes)
4. Contact code author for historical documentation
5. If no source found, document as "numerical approximation with unknown origin"

**Deliverables:**
- Updated CONSTANT_TRACEABILITY.md with findings
- Documentation in bounce_time_arr.m header
- Decision: Keep as-is (documented limitation) or replace with exact integral

---

## 2. Short-Term Improvements (Sprint 2-3)

### 2.1 Create Centralized Constants File

**Priority:** 🟡 **MEDIUM**  
**Effort:** 1 week  
**Files Affected:** All MATLAB code

**Proposal:** Create `IMPACT_MATLAB/physical_constants.m`

**Contents:**
```matlab
classdef physical_constants
    %PHYSICAL_CONSTANTS Centralized constants for IMPACT model
    %   All physical constants, empirical parameters, and conversion factors
    %   should be defined here for consistency
    
    %% Fundamental Physical Constants (CODATA 2018)
    properties (Constant)
        % Speed of light (m/s)
        c = 2.99792458e8;
        
        % Boltzmann constant (J/K)
        kB = 1.380649e-23;
        
        % Electron charge (C)
        e = 1.602176634e-19;
        
        % Atomic mass unit (kg)
        amu = 1.66053906660e-27;
        
        % Avogadro constant (mol^-1)
        NA = 6.02214076e23;
    end
    
    properties (Constant)
        % Electron rest mass energy (MeV)
        mc2_electron = 0.5109989461;
        
        % Proton rest mass energy (MeV)
        mc2_proton = 938.27208816;
        
        % Earth mean radius (m)
        Re = 6371e3;
        
        % Standard gravity (m/s^2)
        g0 = 9.80665;
    end
    
    %% Fang 2010 Model Constants
    properties (Constant)
        % Ionization energy per ion pair (keV)
        D_star = 0.035;
        
        % Reference density for column mass (g/cm³)
        rho_ref = 6e-6;
        
        % Energy dissipation exponent
        alpha = 0.7;
    end
    
    %% Unit Conversion Factors
    properties (Constant)
        % Energy conversions
        keV_to_MeV = 1e-3;
        MeV_to_keV = 1e3;
        eV_to_keV = 1e-3;
        keV_to_eV = 1e3;
        
        % Distance conversions
        km_to_m = 1e3;
        m_to_km = 1e-3;
        cm_to_m = 1e-2;
        m_to_cm = 1e2;
        
        % Density conversions
        g_cm3_to_kg_m3 = 1e3;
        kg_m3_to_g_cm3 = 1e-3;
        
        % Time conversions
        s_to_min = 1/60;
        min_to_s = 60;
        s_to_hour = 1/3600;
        hour_to_s = 3600;
        s_to_day = 1/86400;
        day_to_s = 86400;
    end
    
    methods (Static)
        function y = compute_T_pa(pa)
            %COMPUTE_T_PA Pitch angle factor for bounce period
            %   T_pa polynomial approximation for dipole bounce period
            %   Coefficients require literature verification (see CONSTANT_TRACEABILITY.md)
            
            y = sin(pa);
            T_pa = 1.38 + 0.055 .* y.^(1/3) - 0.32 .* y.^(1/2) ...
                   - 0.037 .* y.^(2/3) - 0.394 .* y + 0.056 .* y.^(4/3);
        end
        
        function rho_SI = rho_cgs_to_SI(rho_cgs)
            %RHO_CGS_TO_SI Convert density from g/cm³ to kg/m³
            rho_SI = rho_cgs * physical_constants.g_cm3_to_kg_m3;
        end
        
        function rho_cgs = rho_SI_to_cgs(rho_SI)
            %RHO_SI_TO_CGS Convert density from kg/m³ to g/cm³
            rho_cgs = rho_SI * physical_constants.kg_m3_to_g_cm3;
        end
    end
end
```

**Migration Plan:**
1. Create `physical_constants.m` with all constants
2. Update `bounce_time_arr.m` to use constants
3. Update `calc_Edissipation.m` to use constants  
4. Update `calc_ionization.m` to use constants
5. Update `get_msis_dat.m` to use constants
6. Update test files to use constants
7. Remove old hardcoded constants

**Testing:**
- Verify all existing tests still pass
- Add unit tests for constant values
- Add tests for conversion functions

---

### 2.2 Create Unit Conversion Module

**Priority:** 🟡 **MEDIUM**  
**Effort:** 3-4 days  
**Files Affected:** `IMPACT_MATLAB/unit_conversions.m`

**Proposal:** Create utility functions for safe unit conversions

**Contents:**
```matlab
function [energy_keV] = MeV_to_keV(energy_MeV)
    %MEV_TO_KEV Convert energy from MeV to keV
    energy_keV = energy_MeV * 1e3;
end

function [energy_MeV] = keV_to_MeV(energy_keV)  
    %KEV_TO_MEV Convert energy from keV to MeV
    energy_MeV = energy_keV * 1e-3;
end

function [density_SI] = g_cm3_to_kg_m3(density_cgs)
    %G_CM3_TO_KG_M3 Convert density from g/cm³ to kg/m³
    %   1 g/cm³ = 1000 kg/m³
    density_SI = density_cgs * 1000;
end

function [density_cgs] = kg_m3_to_g_cm3(density_SI)
    %KG_M3_TO_G_CM3 Convert density from kg/m³ to g/cm³
    %   1 kg/m³ = 0.001 g/cm³
    density_cgs = density_SI * 0.001;
end

function [altitude_km] = m_to_km(altitude_m)
    %M_TO_KM Convert altitude from meters to kilometers
    altitude_km = altitude_m * 1e-3;
end

function [altitude_m] = km_to_m(altitude_km)
    %KM_TO_M Convert altitude from kilometers to meters
    altitude_m = altitude_km * 1e3;
end

function [time_days] = s_to_days(time_s)
    %S_TO_DAYS Convert time from seconds to days
    time_days = time_s / 86400;
end

function [time_s] = days_to_s(time_days)
    %DAYS_TO_S Convert time from days to seconds
    time_s = time_days * 86400;
end
```

**Benefits:**
- Centralized unit conversion logic
- Easy to add validation and error checking
- Self-documenting function names
- Easier to maintain and test

---

### 2.3 Replace Magic Numbers with Named Constants

**Priority:** 🟡 **MEDIUM**  
**Effort:** 2-3 days  
**Files Affected:** `IMPACT_MATLAB/get_msis_dat.m`, `IMPACT_MATLAB/verify_mav.m`

**Issue:** Molecular masses hardcoded as magic numbers

**Current Code:**
```matlab
% get_msis_dat.m line 167
Mav = 1.66e-27*(nHe*4.0 + nO*16.0 + nN2*28.02 + nO2*32.0 + nAr*39.95 + nH*1.0 + nOa*16.0 + nNO*30);
```

**Refactored Code:**
```matlab
% Using centralized constants
Mav = physical_constants.amu * (nHe*physical_constants.mass.He + ...
                                nO*physical_constants.mass.O + ...
                                nN2*physical_constants.mass.N2 + ...
                                nO2*physical_constants.mass.O2 + ...
                                nAr*physical_constants.mass.Ar + ...
                                nH*physical_constants.mass.H + ...
                                nOa*physical_constants.mass.O + ...
                                nNO*physical_constants.mass.NO);
```

**Required Constants:**
```matlab
classdef (Abstract) molecular_masses
    properties (Constant)
        He = 4.0026;      % Helium (g/mol)
        O = 15.999;       % Atomic oxygen (g/mol)
        N2 = 28.0134;     % Molecular nitrogen (g/mol)
        O2 = 31.9988;     % Molecular oxygen (g/mol)
        Ar = 39.948;      % Argon (g/mol)
        H = 1.008;        % Atomic hydrogen (g/mol)
        N = 14.007;       % Atomic nitrogen (g/mol)
        NO = 30.006;      % Nitric oxide (g/mol)
    end
end
```

---

## 3. Medium-Term Enhancements (Sprint 4-5)

### 3.1 Add Unit Validation Framework

**Priority:** 🟡 **MEDIUM**  
**Effort:** 1 week  
**Files Affected:** All calculation functions

**Proposal:** Add input validation for units

**Implementation:**
```matlab
function [rho_out, H_out] = get_msis_dat(alt, f107a, f107, Ap, compile_msis)
    %GET_MSIS_DAT Retrieve atmospheric density and scale height from MSIS 2.1 model
    %
    % INPUT VALIDATION:
    %   alt     - Vector of geodetic altitudes (km), 0-1000 km
    %   f107a   - 81-day average F10.7 solar flux
    %   f107    - Daily F10.7 solar flux  
    %   Ap      - Daily geomagnetic Ap index
    
    % Validate input units
    validateattributes(alt, {'numeric'}, {'real', 'positive', '>=', 0, '<=', 1000, ...
        'vector'}, mfilename, 'alt');
    validateattributes(f107a, {'numeric'}, {'real', 'positive', '>=', 0}, ...
        mfilename, 'f107a');
    validateattributes(f107, {'numeric'}, {'real', 'positive', '>=', 0}, ...
        mfilename, 'f107');
    validateattributes(Ap, {'numeric'}, {'real', '>=', 0}, mfilename, 'Ap');
    
    % Rest of function...
end
```

**Benefits:**
- Catches unit errors early
- Provides clear error messages
- Self-documenting function interfaces
- Easier to debug unit issues

---

### 3.2 Create Unit-Aware Data Structures

**Priority:** 🟢 **LOW**  
**Effort:** 2 weeks  
**Files Affected:** All I/O functions

**Proposal:** Use MATLAB's unit system or create custom structures

**Implementation:**
```matlab
% Create unit-aware data structure
atmospheric_data = struct();
atmospheric_data.rho = AtmosphericQuantity(rho_values, 'g/cm3');
atmospheric_data.H = AtmosphericQuantity(H_values, 'cm');
atmospheric_data.alt = AtmosphericQuantity(alt_values, 'km');

classdef AtmosphericQuantity
    properties
        Value
        Unit
    end
    
    methods
        function obj = AtmosphericQuantity(value, unit)
            obj.Value = value;
            obj.Unit = unit;
        end
        
        function converted = convertTo(obj, targetUnit)
            % Convert to target unit
            switch [obj.Unit, '->', targetUnit]
                case 'g/cm3->kg/m3'
                    converted = obj.Value * 1000;
                case 'cm->km'
                    converted = obj.Value * 1e-5;
                % ... other conversions
            end
        end
        
        function validated = validateUnit(obj, expectedUnit)
            validated = strcmp(obj.Unit, expectedUnit);
            if ~validated
                error('Expected unit %s, got %s', expectedUnit, obj.Unit);
            end
        end
    end
end
```

---

## 4. Long-Term Architecture Improvements

### 4.1 Standardize on SI Units

**Priority:** 🟢 **LOW**  
**Effort:** 2-3 sprints  
**Files Affected:** All code

**Proposal:** Use SI units (kg, m, s) throughout codebase, convert only at I/O boundaries

**Rationale:**
- SI units are the international standard
- Reduces conversion errors
- Easier to interface with other models
- Better for scientific computing

**Implementation Plan:**
1. Use meters, kilograms, seconds internally
2. Convert to user-friendly units only for display/export
3. Create I/O functions that handle unit conversion
4. Document all unit assumptions

**Example:**
```matlab
% Internal calculations (SI units)
rho_SI = 1.225;           % kg/m³ (standard atmosphere)
alt_SI = 1000;            % m
H_SI = 8000;              % m (scale height in meters)

% Output (user-friendly units)
rho_display = rho_SI * 1e3;   % g/cm³
alt_display = alt_SI * 1e-3;  % km  
H_display = H_SI * 1e-2;      % cm
```

---

### 4.2 Create Unit Testing Framework

**Priority:** 🟢 **LOW**  
**Effort:** 1-2 sprints  
**Files Affected:** Test directory

**Proposal:** Implement comprehensive unit testing for all constants and conversions

**Test Categories:**
```matlab
classdef test_physical_constants < matlab.unittest.TestCase
    %TEST_PHYSICAL_CONSTANTS Unit tests for physical constants
    
    methods (Test)
        function test_fundamental_constants(test)
            % Test speed of light
            test.verifyEqual(physical_constants.c, 2.99792458e8, 'AbsTol', 1e-10);
            
            % Test Boltzmann constant
            test.verifyEqual(physical_constants.kB, 1.380649e-23, 'AbsTol', 1e-30);
            
            % Test Earth radius
            test.verifyEqual(physical_constants.Re, 6371e3, 'AbsTol', 1);
        end
        
        function test_energy_conversions(test)
            % Test keV to MeV
            test.verifyEqual(unit_conversions.keV_to_MeV(1000), 1, 'AbsTol', 1e-15);
            
            % Test MeV to keV
            test.verifyEqual(unit_conversions.MeV_to_keV(1), 1000, 'AbsTol', 1e-15);
        end
        
        function test_density_conversions(test)
            % Test g/cm³ to kg/m³
            test.verifyEqual(unit_conversions.g_cm3_to_kg_m3(1e-6), 1e-3, 'AbsTol', 1e-15);
            
            % Test kg/m³ to g/cm³
            test.verifyEqual(unit_conversions.kg_m3_to_g_cm3(1e-3), 1e-6, 'AbsTol', 1e-15);
        end
        
        function test_dimensional_homogeneity(test)
            % Test bounce period equation
            L = 4;
            E = 0.1;  % MeV
            pa = deg2rad(45);
            
            bt = bounce_time_arr(L, E, pa);
            test.verifyGreaterThan(bt, 0);  % Bounce period must be positive
            test.verifyLessThan(bt, 86400*2);  % Reasonable upper bound (2 days)
        end
    end
end
```

---

## 5. Prioritized Action Items Summary

### 5.1 Immediate Actions (This Sprint)

| Priority | Action | Effort | Owner | Due Date |
|----------|--------|--------|-------|----------|
| 🔴 HIGH | Fix Boltzmann constant comment | <1 day | Implementation | Immediate |
| 🔴 HIGH | Investigate T_pa coefficients | 1-2 weeks | Code Owner | Next milestone |

### 5.2 Short-Term Actions (Next 2-3 Sprints)

| Priority | Action | Effort | Owner | Due Date |
|----------|--------|--------|-------|----------|
| 🟡 MEDIUM | Create centralized constants file | 1 week | Implementation | Sprint 2 |
| 🟡 MEDIUM | Create unit conversion module | 3-4 days | Implementation | Sprint 2 |
| 🟡 MEDIUM | Replace magic numbers | 2-3 days | Implementation | Sprint 3 |

### 5.3 Medium-Term Actions (Sprint 4-5)

| Priority | Action | Effort | Owner | Due Date |
|----------|--------|--------|-------|----------|
| 🟡 MEDIUM | Add unit validation framework | 1 week | Implementation | Sprint 4 |
| 🟢 LOW | Create unit-aware data structures | 2 weeks | Architecture | Sprint 5 |

### 5.4 Long-Term Actions (Future Releases)

| Priority | Action | Effort | Owner | Due Date |
|----------|--------|--------|-------|----------|
| 🟢 LOW | Standardize on SI units | 2-3 sprints | Architecture | Release 2.0 |
| 🟢 LOW | Create unit testing framework | 1-2 sprints | QA | Release 2.0 |

---

## 6. Success Metrics

### 6.1 Code Quality Metrics

| Metric | Current State | Target State | Measurement |
|--------|---------------|--------------|-------------|
| Magic numbers | 15+ identified | <5 | Static analysis |
| Centralized constants | 0% | 100% | File count |
| Unit conversion functions | 0 | 10+ | Function count |
| Unit validation coverage | 0% | 100% | Function coverage |

### 6.2 Maintainability Metrics

| Metric | Current State | Target State | Measurement |
|--------|---------------|--------------|-------------|
| Constant duplication | High (scattered) | Low (centralized) | LOC analysis |
| Unit conversion errors | Unknown | 0 | Testing |
| Documentation completeness | 87% traced | 100% traced | CONSTANT_TRACEABILITY.md |
| Test coverage for constants | Partial | Complete | Coverage report |

---

## 7. Dependencies and Risks

### 7.1 Dependencies

- Task 3.4.0 validation complete ✅
- CONSTANT_TRACEABILITY.md up to date
- Test infrastructure in place
- Code owner review and approval

### 7.2 Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking existing functionality | Low | High | Comprehensive testing |
| Developer resistance to change | Medium | Medium | Training and documentation |
| Performance impact | Low | Low | Benchmark before/after |
| Scope creep | Medium | Medium | Strict prioritization |

---

## 8. References

1. CONSTANT_TRACEABILITY.md (87% traced, 13% requires investigation)
2. validation_report_3.4.0.md (comprehensive audit findings)
3. unit_conversion_risks.md (risk assessment)
4. CODATA 2018: https://pml.nist.gov/cuu/Constants/
5. IAU 2015 Resolution B1: https://www.iau.org/administration/resolutions/general_assemblies/

---

**Document Prepared By:** Implementation Specialist  
**Review Status:** Ready for Architecture Review  
**Approval Required:** Phase Lead, Architecture Board  
**Next Review Date:** Task 3.4.1 Planning Session