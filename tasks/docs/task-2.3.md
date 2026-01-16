# Phase 2.3: Fortran Unit Testing

## Overview
Create comprehensive unit tests for Fortran NRLMSIS 2.1 modules to ensure correctness of calculations, numerical accuracy, and robustness across input ranges.

## Scope

### Module Testing Targets
- **Core Infrastructure**: msis_constants, msis_utils, msis_init
- **Computational Core**: msis_gfn, msis_tfn, msis_dfn, msis_calc
- **Coverage Target**: >80% line coverage for critical computational paths

## Element 2.3.0: Test core infrastructure modules

### Objective
Create unit tests for msis_constants, msis_utils, and msis_init modules with comprehensive coverage.

### Deliverables
1. **Test Suite for msis_constants**
   - Constants verification tests
   - Unit consistency checks
   - Reference value comparisons

2. **Test Suite for msis_utils**
   - All utility function tests
   - Boundary condition tests
   - Numerical accuracy tests

3. **Test Suite for msis_init**
   - Initialization sequence tests
   - Default value verification
   - Configuration validation tests

### Test Requirements

#### msis_constants Tests
- [ ] Verify all physical constant values match references
- [ ] Check conversion factor accuracy (within 1e-10)
- [ ] Validate unit consistency
- [ ] Test constant ranges and limits

#### msis_utils Tests
- [ ] Test all utility functions with valid inputs
- [ ] Test boundary conditions (min/max values)
- [ ] Test error handling for invalid inputs
- [ ] Verify numerical precision for calculations
- [ ] Test array operations edge cases

#### msis_init Tests
- [ ] Test successful initialization
- [ ] Test initialization with custom parameters
- [ ] Test error detection for invalid parameters
- [ ] Verify all arrays initialized
- [ ] Test re-initialization capability

### Verification Command
```bash
# Compile test suite
cd /work/projects/IMPACT/nrlmsis2.1
gfortran -O3 -cpp -DDBLE -o test_core_infrastructure utils_test.F90 constants_test.F90 init_test.F90

# Run tests
./test_core_infrastructure

# Expected: PASS for all tests, coverage report generated
```

### Success Criteria
- All tests pass without errors
- Coverage report shows >80% for modules tested
- No numerical precision violations
- All boundary conditions tested

## Element 2.3.1: Test computational core functions

### Objective
Create unit tests for msis_gfn, msis_tfn, msis_dfn, and msis_calc modules focusing on mathematical accuracy and edge case handling.

### Deliverables
1. **Test Suite for msis_gfn**
   - Geographic coordinate tests
   - Longitude dependence tests
   - Boundary condition tests (poles, dateline)

2. **Test Suite for msis_tfn**
   - Temperature profile accuracy tests
   - Gradient calculation tests
   - Altitude regime boundary tests

3. **Test Suite for msis_dfn**
   - Density profile tests for all species
   - Scale height calculation tests
   - Species coupling tests

4. **Test Suite for msis_calc**
   - Integration flow tests
   - Input validation tests
   - Output format tests

### Test Requirements

#### msis_gfn Tests
- [ ] Test latitude range (-90 to 90 degrees)
- [ ] Test longitude range (0 to 360 degrees)
- [ ] Test behavior at poles (lat = ±90)
- [ ] Test behavior at dateline (lon = 0, 180, 360)
- [ ] Verify numerical stability at boundaries
- [ ] Test with various altitudes
- [ ] Test with different geomagnetic conditions

#### msis_tfn Tests
- [ ] Test temperature at various altitudes (0-1000 km)
- [ ] Verify temperature continuity at regime boundaries
- [ ] Test gradient calculations
- [ ] Verify temperature never negative
- [ ] Test thermosphere profile (>85 km)
- [ ] Test mesosphere profile (~50-85 km)
- [ ] Test stratosphere profile (~12-50 km)

#### msis_dfn Tests
- [ ] Test density for all species (O, N2, O2, He, H, Ar, N, etc.)
- [ ] Verify density decreases with altitude (where physically correct)
- [ ] Test density at upper altitude limits
- [ ] Test density at surface pressure levels
- [ ] Verify no negative densities
- [ ] Test species sum = total density
- [ ] Test with different F10.7 and Ap indices

#### msis_calc Tests
- [ ] Test complete calculation flow
- [ ] Test all input parameter ranges
- [ ] Test error handling for out-of-range inputs
- [ ] Verify output format consistency
- [ ] Test with standard test inputs
- [ ] Compare outputs with reference data

### Verification Command
```bash
# Compile computational core tests
cd /work/projects/IMPACT/nrlmsis2.1
gfortran -O3 -cpp -DDBLE -o test_computational_core \
  gfn_test.F90 tfn_test.F90 dfn_test.F90 calc_test.F90 \
  msis_constants.F90 msis_utils.F90 msis_init.F90 \
  msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90

# Run tests
./test_computational_core

# Compare with reference outputs
diff test_computational_out.txt test_computational_ref.txt
```

### Success Criteria
- All computational tests pass
- Numerical accuracy within tolerance (1e-6 for double precision)
- No failures at boundary conditions
- Coverage >80% for computational modules

## Test Data

### Reference Data Sources
- `nrlmsis2.1/msis2.1_test_in.txt` - Standard test inputs
- `nrlmsis2.1/msis2.1_test_ref_dp.txt` - Reference outputs (double precision)
- `nrlmsis2.1/original_MSIScodes/` - Original reference implementation outputs

### Test Input Ranges
- **Altitude**: 0 to 1000 km
- **Latitude**: -90 to 90 degrees
- **Longitude**: 0 to 360 degrees
- **F10.7 (solar flux)**: 50 to 300 sfu
- **Ap (geomagnetic activity)**: 0 to 400
- **Day of year**: 1 to 365
- **Time (UT)**: 0 to 24 hours

## Test Infrastructure

### Build Scripts
```bash
# Single precision test build
gfortran -O3 -cpp -o test_suite_sp test_suite.F90 *.F90

# Double precision test build
gfortran -O3 -DDBLE -cpp -o test_suite_dp test_suite.F90 *.F90

# Debug build with bounds checking
gfortran -O0 -DDBLE -cpp -fcheck=all -o test_suite_debug test_suite.F90 *.F90
```

### Coverage Tools
- **gcov**: For code coverage analysis
- **gprof**: For performance profiling
- **valgrind**: For memory leak detection (if applicable)

## Dependencies
- gcc/gfortran compiler
- Make utility (if using Makefiles)
- Reference test data files

## Performance Tests
```bash
# Performance benchmarking
time ./test_computational_core

# Profile for hotspots
gprof ./test_computational_core gmon.out > analysis.txt
```

## Risks and Issues
- Floating-point precision differences across compilers
- Reference outputs tied to specific compiler version
- Numerical precision tolerances need calibration

## References
- NRLMSIS 2.1 Test Documentation
- Fortran 90 Testing Best Practices
- Numerical Accuracy in Scientific Computing