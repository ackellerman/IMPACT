# Phase 2.4: MATLAB Testing

## Overview
Create comprehensive test suite for MATLAB analysis scripts ensuring correctness of calculations, proper error handling, and numerical accuracy for space weather analysis tasks.

## Scope

### MATLAB Scripts Under Test
- **Data I/O**: get_msis_dat.m (201 lines), makeMSISinputs.m, def_testdata.m
- **Core Analysis**: calc_Edissipation.m (52 lines), calc_ionization.m (41 lines), fang10_precip.m (167 lines), sav_fang10_coeff.m (27 lines)
- **Magnetic Field**: dip_losscone.m (16 lines), dipole_mirror_altitude.m (31 lines), mirror_altitude.m (29 lines), bounce_time_arr.m (53 lines)

## Element 2.4.0: Test MATLAB data I/O utilities

### Objective
Create comprehensive tests for data input/output functions verifying file handling, data parsing, and test data generation.

### Deliverables
1. **Test Suite for get_msis_dat.m**
   - File parsing tests
   - Data structure validation tests
   - Error handling tests

2. **Test Suite for makeMSISinputs.m and def_testdata.m**
   - Input generation tests
   - Test data validation tests
   - Format verification tests

### Test Requirements

#### get_msis_dat.m Tests
- [ ] Test reading standard MSIS output files
- [ ] Test reading custom format files
- [ ] Test error handling for missing files
- [ ] Test error handling for malformed data
- [ ] Verify data structure completeness
- [ ] Test altitude array handling
- [ ] Test species data arrays
- [ ] Test temperature data arrays

#### makeMSISinputs.m Tests
- [ ] Test generating standard input format
- [ ] Test with various altitude ranges
- [ ] Test with different geographic locations
- [ ] Test with different times
- [ ] Verify output file format matches specification
- [ ] Test parameter validation
- [ ] Test date/time conversion

#### def_testdata.m Tests
- [ ] Verify test data covers expected ranges
- [ ] Test edge cases (min/max values)
- [ ] Verify data type consistency
- [ ] Test with different test scenarios
- [ ] Validate test data physical realism

### Verification Command
```bash
# Run MATLAB tests
cd /work/projects/IMPACT/IMPACT_MATLAB
matlab -batch "runtests('test_data_io.m'); exit"

# Expected: All tests pass, no errors
```

### Success Criteria
- All data I/O tests pass
- Error handling verified for invalid inputs
- Data structures validated
- Coverage >70% for data I/O functions

## Element 2.4.1: Test MATLAB core analysis scripts

### Objective
Create tests for energy dissipation, ionization, and precipitation analysis scripts verifying physical accuracy and numerical precision.

### Deliverables
1. **Test Suite for calc_Edissipation.m**
   - Energy calculation accuracy tests
   - Boundary condition tests
   - Unit validation tests

2. **Test Suite for calc_ionization.m**
   - Ionization rate tests
   - Species-dependent tests
   - Altitude profile tests

3. **Test Suite for fang10_precip.m and sav_fang10_coeff.m**
   - Precipitation model tests
   - Coefficient loading/saving tests
   - Integration with calc_Edissipation tests

### Test Requirements

#### calc_Edissipation.m Tests
- [ ] Test energy dissipation calculation accuracy
- [ ] Test with various precipitation energies
- [ ] Test with different pitch angles
- [ ] Test altitude range (0-1000 km)
- [ ] Verify physical units consistency
- [ ] Test boundary conditions (min/max energy)
- [ ] Compare with published results if available
- [ ] Test numerical stability

#### calc_ionization.m Tests
- [ ] Test ionization rate calculations
- [ ] Test for different species (O, N2, O2)
- [ ] Test cross-section calculations
- [ ] Test altitude dependence
- [ ] Verify ionization efficiency
- [ ] Test extreme energy depositions
- [ ] Validate against literature values

#### fang10_precip.m Tests
- [ ] Test Fang 2010 precipitation model
- [ ] Test with various precipitation fluxes
- [ ] Test energy spectrum integration
- [ ] Test angular dependence
- [ ] Verify output format
- [ ] Test numerical integration accuracy
- [ ] Compare with reference implementations

#### sav_fang10_coeff.m Tests
- [ ] Test coefficient file format
- [ ] Test saving/loading round-trip
- [ ] Verify coefficient values
- [ ] Test file I/O error handling
- [ ] Test with different coefficient sets

### Verification Command
```bash
# Run core analysis tests
cd /work/projects/IMPACT/IMPACT_MATLAB
matlab -batch "runtests('test_core_analysis.m'); exit"

# Expected: All physics calculations accurate to within tolerance (1e-4)
```

### Success Criteria
- All core analysis tests pass
- Numerical accuracy within tolerance (1e-4 relative)
- Physical units validated
- No numerical instabilities
- Coverage >75% for analytical scripts

## Element 2.4.2: Test MATLAB magnetic field scripts

### Objective
Create tests for magnetic field calculations, particle motion, and field line analysis verifying physical correctness.

### Deliverables
1. **Test Suite for dip_losscone.m**
   - Loss cone angle calculation tests
   - Magnetic field strength tests
   - Boundary condition tests

2. **Test Suite for dipole_mirror_altitude.m and mirror_altitude.m**
   - Mirror point calculations
   - Equatorial crossing tests
   - Altitude profile tests

3. **Test Suite for bounce_time_arr.m**
   - Bounce time calculation tests
   - Field line length tests
   - Energy dependence tests

### Test Requirements

#### dip_losscone.m Tests
- [ ] Test loss cone angle calculation at various latitudes
- [ ] Test at equator (lat = 0)
- [ ] Test at high latitudes (lat = 60, 70, 80)
- [ ] Verify loss cone > 0 for trapped particles
- [ ] Test edge cases (no trapping)
- [ ] Validate dipole approximation assumptions
- [ ] Compare with complete magnetic field models if available

#### dipole_mirror_altitude.m and mirror_altitude.m Tests
- [ ] Test mirror point calculations
- [ ] Test with various pitch angles
- [ ] Test altitude ranges (100-1000 km)
- [ ] Verify mirror point > starting altitude
- [ ] Test equatorial pitch angle conversion
- [ ] Test numerical stability at small pitch angles
- [ ] Compare dipole vs. more accurate models

#### bounce_time_arr.m Tests
- [ ] Test bounce time calculation accuracy
- [ ] Test energy dependence (1 keV to 1 MeV)
- [ ] Test L-shell dependence (L = 1.2 to 6.0)
- [ ] Verify bounce time decreases with energy
- [ ] Verify bounce time increases with L-shell
- [ ] Test extreme values (very low/high energy)
- [ ] Compare with analytical approximations

### Verification Command
```bash
# Run magnetic field tests
cd /work/projects/IMPACT/IMPACT_MATLAB
matlab -batch "runtests('test_magnetic_field.m'); exit"

# Expected: All magnetic calculations physically reasonable
```

### Success Criteria
- All magnetic field tests pass
- Loss cone angles physically correct (0-90 degrees)
- Mirror altitudes within expected ranges
- Bounce times follow expected energy/L-shell dependence
- Coverage >70% for magnetic field scripts

## Test Infrastructure

### MATLAB Test Framework
```matlab
% Create test class
classdef TestMATLABScripts < matlab.unittest.TestCase
    methods (Test)
        function testGetMSISData(testCase)
            % Test implementation
            actual = get_msis_dat('test_input.txt');
            testCase.verifyClass(actual, 'struct');
            testCase.verifyEqual(actual.altitude(1), 0);
        end
    end
end
```

### Test Data Files
- `IMPACT_MATLAB/test_data/` - Directory for test inputs
- `IMPACT_MATLAB/test_expected/` - Directory for expected outputs
- Comparison tolerance: 1e-4 relative for physical calculations

### Running All Tests
```bash
# Run complete MATLAB test suite
cd /work/projects/IMPACT/IMPACT_MATLAB
matlab -batch "results = runtests('test_*.m'); disp(results); exit"

# Generate coverage report
matlab -batch "results = runtests('test_*.m'); coverage(results); exit"
```

## Test Coverage Goals

| Script Category | Coverage Target | Rationale |
|----------------|----------------|-----------|
| Data I/O | 70% | Standard file operations |
| Core Analysis | 75% | Complex physics |
| Magnetic Field | 70% | Well-understood theory |
| **Overall** | **>70%** | Practical minimum |

## Physical Validation Tests

### Energy Conservation
```matlab
% Verify energy conservation in precipitation calculations
Input Energy = Energy Dissipated + Energy Ionized + Energy Radiated
```

### Magnetic Invariants
```matlab
% Verify magnetic moment conservation
1st Invariant: J = ∮ v_|| ds = constant
2nd Invariant: I = ∮ B_m ds / B = constant
```

### Mass Continuity
```matlab
% Verify mass conservation in atmospheric model
∑(density_i) = total density (within numerical tolerance)
```

## Dependencies
- MATLAB R2019b or later
- MATLAB Unit Testing Framework
- Test data files in proper format
- Reference physics values for validation

## Risks and Issues
- Numerical precision differences in trigonometric functions
- Approximation errors in dipole magnetic model
- File format assumptions may not handle edge cases

## References
- Fang, X. et al. (2010) - Model of electron precipitation
- Roederer, J. G. (1970) - Dynamics of geomagnetically trapped radiation
- Lyons, L. R. and Williams, D. J. (1984) - Quantitative Aspects of Magnetospheric Physics