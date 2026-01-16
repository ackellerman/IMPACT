STATUS: APPROVED

## Improved Prompt

## Task 3.6.1: Validate atmospheric boundary integration

Implement comprehensive validation tests for electron precipitation model integration with atmospheric data across all altitude boundaries.

## Requirements

### Test Suite Implementation
- [ ] Implement `TestTopBoundary` class with 4 tests:
  - `test_500km_density()`: Verify MSIS density at 500 km is 10⁻¹³ to 10⁻¹¹ g/cm³
  - `test_top_boundary_dissipation()`: Verify energy dissipation ≤ 0.1% of total at 500 km
  - `test_top_boundary_cumulative()`: Verify cumulative ionization ≤ 0.1% of final value at 500 km
  - `test_grid_handling_top()`: Verify grid interpolation handles top boundary without errors

- [ ] Implement `TestBottomBoundary` class with 4 tests:
  - `test_density_gradient()`: Verify density follows exponential scale height model
  - `test_full_energy_deposition()`: Verify 99.9% energy deposition complete at boundary
  - `test_ionization_maximum()`: Verify ionization reaches physically reasonable maximum
  - `test_cutoff_handling()`: Verify lower cutoff altitude (80-100 km) handled correctly

- [ ] Implement `TestMSISIntegration` class with 4 tests:
  - `test_density_profile()`: Verify MSIS density matches reference within 10%
  - `test_species_consistency()`: Verify species densities sum within 1% of total
  - `test_interpolation_accuracy()`: Verify interpolation error < 0.1% for typical regions
  - `test_scale_height_consistency()`: Verify scale height consistent with density gradient

- [ ] Implement `TestDensityPhysicsCoupling` class with 4 tests:
  - `test_density_dissipation_relationship()`: Verify dissipation scales correctly with density
  - `test_density_ionization_relationship()`: Verify ionization scales correctly with density
  - `test_no_negative_values()`: Verify no unphysical negative values
  - `test_dynamic_range_handling()`: Verify 10-order magnitude density range handled

- [ ] Implement `TestColumnIntegration` class with 4 tests:
  - `test_column_ionization_units()`: Verify particles/cm²/s units
  - `test_column_energy_units()`: Verify erg/cm²/s units
  - `test_column_convergence()`: Verify grid refinement within 1% target
  - `test_column_magnitude()`: Verify column values 10⁸-10¹² particles/cm²/s

### Validation Criteria
All tests must pass with these tolerances:
- Top boundary: Density 10⁻¹³ to 10⁻¹¹ g/cm³, dissipation ≤ 0.1%
- Bottom boundary: Energy 99.9% complete, ionization maximum physical
- MSIS integration: Profile within 10%, species sum within 1%, interpolation < 0.1%
- Physics coupling: No negative values, 10-order dynamic range handled
- Column integration: Grid convergence < 1% error, magnitude within expected range

## Technical Context

- **Language**: Python 3
- **Test Framework**: pytest
- **Location**: `/work/projects/IMPACT/test_atmospheric_boundary_integration.py`
- **Test Pattern**: 5 test classes, 20 tests total, one assertion per test

## Dependencies

- **Requires**: Tasks 3.3.0, 3.5.1, 3.6.0 completed
- **Uses**: MSIS 2.1 reference data from Task 3.3.0
- **Uses**: Precipitation model integration from Task 3.6.0

## Verification

Run validation tests:
```bash
cd /work/projects/IMPACT
python3 -m pytest test_atmospheric_boundary_integration.py -v --tb=short
```

Expected: All 20 tests pass, 0 failures

## Completion Criteria

- [ ] All 20 tests implemented
- [ ] Test structure follows provided template exactly
- [ ] All tests pass with specified tolerances
- [ ] Grid convergence < 1% error
- [ ] Validation report generated
- [ ] No production code modified (tests only)

When complete, output: RALPH_COMPLETE

## If Stuck

If unable to complete after multiple attempts:
1. Document the specific test failing and error message
2. List what approaches were tried to fix it
3. Output: RALPH_BLOCKED

***

## Metadata
- Complexity: Simple (well-defined test structure)
- Recommended Max Iterations: 10
- Verification Method: pytest with 20 tests
