# Task 3.5.1: Validate numerical methods and stability

**Status**: reviewing-plan-architecture
**Type**: Validation
**Component**: Numerical methods in `calc_ionization.m`, `dipole_mirror_altitude.m`, `fang10_precip.m`

## Scope

This task validates the **fundamental numerical methods** used throughout the precipitation model, focusing on integration and interpolation accuracy. These methods form the numerical engine that converts physical equations into computational results.

**Note**: System-level time stepping stability is validated in Task 3.5.0. This task focuses on method-level numerical accuracy.

## Objectives

1. Validate trapezoidal integration accuracy for ionization rate profiles
2. Validate linear interpolation accuracy for mirror altitude lookup
3. Quantify error bounds with grid resolution sensitivity
4. Verify negative value clamping and NaN handling
5. Establish acceptance criteria for operational conditions

## Validation Approach

### Component 1: Trapezoidal Integration (cumtrapz)

**Function**: `calc_ionization.m:38`
**Method**: `q_cum = -flip(cumtrapz(flip(z), flip(q_tot, 1), 1), 1);`

**Validation Strategy**:

**Tier 1: Analytical Test Cases**
- Test 1.1: Exponential profile (typical atmospheric decay)
  - q_tot(z) = A × exp(-z/H)
  - Analytical integral: q_cum(z) = A × H × (1 - exp(-z/H))
  - Verify: relative error < 1%

- Test 1.2: Linear profile (sanity check)
  - q_tot(z) = m × z + b
  - Analytical integral: q_cum(z) = 0.5 × m × z² + b × z
  - Verify: trapezoidal rule is exact for linear functions

- Test 1.3: Constant profile
  - q_tot(z) = C (constant)
  - Analytical integral: q_cum(z) = C × z
  - Verify: exact match (within machine precision)

**Tier 2: Grid Resolution Sensitivity**
- Test 2.1: Convergence test
  - Run integration with dz = [0.5, 1, 2, 5, 10] km
  - For each dz, compute error vs analytical solution
  - Verify: error ∝ dz² (second-order convergence)

- Test 2.2: Operational grid validation
  - Use MSIS grid: dz = 1 km (0-1000 km)
  - Verify: error < 1% for exponential profiles

- Test 2.3: Non-uniform grid handling
  - Test with variable dz (e.g., coarse at high altitudes, fine at low altitudes)
  - Verify: cumtrapz correctly handles non-uniform spacing

**Tier 3: Edge Case Handling**
- Test 3.1: Single point (z = 1 element)
  - Verify: q_cum = 0 (no integration possible)

- Test 3.2: Empty array
  - Verify: Error handling or graceful degradation

- Test 3.3: Negative altitude values
  - Verify: Integration handles edge cases correctly

### Component 2: Interpolation (interp1)

**Function**: `dipole_mirror_altitude.m:24`
**Method**: `mirror_lat_query = interp1(alpha_eq, mirror_latitude, alpha_eq_query);`

**Validation Strategy**:

**Tier 1: Analytical Test Cases**
- Test 1.1: Linear function (exact match expected)
  - Test interpolation on y = x
  - Verify: interp1 returns exact values (within machine precision)

- Test 1.2: Quadratic function (accuracy test)
  - Test interpolation on y = x²
  - Measure error vs analytical solution
  - Verify: error < 1% for reasonable grid density

- Test 1.3: Monotonic function (dipole B-ratio)
  - Test on actual dipole function: B_ratio ∝ cos⁶(λ)
  - Verify: interpolation preserves monotonicity

**Tier 2: Grid Resolution Sensitivity**
- Test 2.1: Lookup grid density
  - Test lookup grid sizes: n_points = [100, 500, 1000, 5000]
  - Current implementation: 500 points (line 13)
  - Verify: error decreases with n_points

- Test 2.2: Operational grid validation
  - Use current grid: 500 points (λ: 90° → 0°)
  - Verify: interpolation error < 1% for dipole functions

- Test 2.3: Boundary accuracy
  - Test near boundaries (α_eq ≈ 0°, α_eq ≈ 90°)
  - Verify: no extrapolation, clamps to boundary values

**Tier 3: Edge Case Handling**
- Test 3.1: Query outside domain
  - Test with α_eq_query < 0° or α_eq_query > 90°
  - Verify: Returns NaN or clamps to boundary (MATLAB interp1 default)

- Test 3.2: Coarse grid with steep gradients
  - Test interpolation on function with rapid changes
  - Verify: reasonable accuracy despite gradient

- Test 3.3: Multiple queries
  - Test with array of query points (vectorized)
  - Verify: consistent accuracy across all points

### Component 3: Negative Value Clamping

**Function**: `fang10_precip.m:123`
**Method**: `Qe(Qe<0) = 0;`

**Validation Strategy**:

**Tier 1: Basic Functionality**
- Test 1.1: Negative values clamped to zero
  - Create synthetic Qe with negative values
  - Verify: all Qe ≥ 0 after clamping

- Test 1.2: Non-negative values unchanged
  - Create Qe with all positive values
  - Verify: Qe unchanged after clamping

- Test 1.3: Zero values preserved
  - Create Qe with zero values
  - Verify: zero values remain zero

**Tier 2: Integration with Numerical Instability**
- Test 2.1: Explicit Euler overshoot
  - Run time stepping with large dt (causing overshoot)
  - Verify: negative values are clamped, not propagated

- Test 2.2: Small negative values (rounding error)
  - Create Qe with values like -1e-15 (near machine epsilon)
  - Verify: clamped to zero

**Tier 3: Physical Correctness**
- Test 3.1: Energy flux conservation
  - Verify: clamping does not violate energy conservation significantly
  - Measure: energy error from clamping < 0.1% of total energy

### Component 4: NaN Propagation

**Validation Strategy**:

**Tier 1: Input NaN Handling**
- Test 1.1: NaN in altitude array
  - Verify: NaN propagates to output (expected behavior)

- Test 1.2: NaN in input data
  - Verify: NaN propagates or is handled gracefully

**Tier 2: Output NaN Checks**
- Test 2.1: All validation tests check for NaN
  - Verify: no unexpected NaN in valid inputs

- Test 2.2: NaN in edge cases
  - Verify: NaN only occurs in documented edge cases

## Acceptance Criteria

**MUST** (all required for task completion):
- [ ] Trapezoidal integration error < 1% for exponential profiles at 1 km grid
- [ ] Trapezoidal integration exact for linear functions (within machine precision)
- [ ] Integration demonstrates O(dz²) convergence (error halves when dz halves)
- [ ] Linear interpolation exact for linear functions (within machine precision)
- [ ] Interpolation error < 1% for dipole functions at 500-point grid
- [ ] Negative value clamping verified with synthetic test cases
- [ ] No NaN/Inf outputs for any valid input in validation tests
- [ ] Grid resolution sensitivity documented with error tables

**SHOULD** (recommended for completeness):
- [ ] Non-uniform grid handling validated
- [ ] Boundary interpolation accuracy verified
- [ ] Energy conservation error from clamping quantified (< 0.1%)
- [ ] Error bounds documented for operational conditions

## Test Cases

### Test Suite Structure

```matlab
function [passed, failed] = test_numerical_methods()
    % Comprehensive numerical methods validation suite

    passed = 0;
    failed = 0;

    %% Component 1: Trapezoidal Integration
    fprintf('=== Component 1: Trapezoidal Integration ===\n');

    % Tier 1: Analytical Tests
    [p, f] = test_integration_exponential();
    passed = passed + p; failed = failed + f;

    [p, f] = test_integration_linear();
    passed = passed + p; failed = failed + f;

    [p, f] = test_integration_constant();
    passed = passed + p; failed = failed + f;

    % Tier 2: Grid Sensitivity
    [p, f] = test_integration_convergence();
    passed = passed + p; failed = failed + f;

    [p, f] = test_integration_operational_grid();
    passed = passed + p; failed = failed + f;

    % Tier 3: Edge Cases
    [p, f] = test_integration_edge_cases();
    passed = passed + p; failed = failed + f;

    %% Component 2: Interpolation
    fprintf('\n=== Component 2: Interpolation ===\n');

    % Tier 1: Analytical Tests
    [p, f] = test_interpolation_linear();
    passed = passed + p; failed = failed + f;

    [p, f] = test_interpolation_quadratic();
    passed = passed + p; failed = failed + f;

    % Tier 2: Grid Sensitivity
    [p, f] = test_interpolation_grid_density();
    passed = passed + p; failed = failed + f;

    [p, f] = test_interpolation_boundaries();
    passed = passed + p; failed = failed + f;

    %% Component 3: Negative Value Clamping
    fprintf('\n=== Component 3: Negative Value Clamping ===\n');

    [p, f] = test_clamp_negative();
    passed = passed + p; failed = failed + f;

    [p, f] = test_clamp_positive_unchanged();
    passed = passed + p; failed = failed + f;

    %% Component 4: NaN Handling
    fprintf('\n=== Component 4: NaN Handling ===\n');

    [p, f] = test_nan_propagation();
    passed = passed + p; failed = failed + f;

    %% Summary
    fprintf('\n=== Summary ===\n');
    fprintf('Passed: %d, Failed: %d\n', passed, failed);
end
```

### Expected Output Format

```
=== Component 1: Trapezoidal Integration ===
TEST 1.1: Exponential Profile
✓ PASS: Relative error = 0.0012% (< 1% threshold)

TEST 1.2: Linear Profile
✓ PASS: Exact match (within machine precision)

TEST 1.3: Constant Profile
✓ PASS: Exact match

TEST 2.1: Grid Convergence
dz = [0.5, 1, 2, 5, 10] km
error = [0.0003, 0.0012, 0.0048, 0.030, 0.12] %
✓ PASS: O(dz²) convergence verified

TEST 2.2: Operational Grid (dz = 1 km)
✓ PASS: Error = 0.0012% (< 1% threshold)

=== Component 2: Interpolation ===
TEST 1.1: Linear Function
✓ PASS: Exact match (within machine precision)

TEST 1.2: Quadratic Function
✓ PASS: Error = 0.15% (< 1% threshold)

TEST 2.1: Grid Density (n_points = [100, 500, 1000])
error = [0.89, 0.12, 0.03] %
✓ PASS: Error decreases with grid density

=== Component 3: Negative Value Clamping ===
TEST 1.1: Clamp Negative Values
✓ PASS: All negative values clamped to 0

TEST 1.2: Preserve Positive Values
✓ PASS: Positive values unchanged

=== Component 4: NaN Handling ===
TEST 1.1: NaN in Input
✓ PASS: NaN handled correctly (propagates to output)

=== Summary ===
Passed: 12, Failed: 0
✓ ALL TESTS PASSED
```

## Deliverables

1. **Validation Script** (`test_numerical_methods.m`)
   - Complete test suite (12+ tests)
   - Analytical test cases for integration and interpolation
   - Grid resolution sensitivity analysis
   - Negative clamping and NaN handling verification
   - Comprehensive error reporting

2. **Validation Report** (`validation_report_3.5.1.md`)
   - Integration error quantification (table of dz vs error)
   - Interpolation error quantification (table of n_points vs error)
   - Convergence analysis (O(dz²) verification)
   - Established error bounds for operational conditions
   - Known limitations (e.g., linear interpolation accuracy on steep gradients)

3. **Updated Task Documentation**
   - Clarified scope (focus on integration + interpolation)
   - Explicit separation from 3.5.0 time stepping
   - Acceptance criteria documented

## Dependencies

**Upstream**:
- Task 3.1.1: Ionization rate calculation (equations validated)
- Task 3.2.1: Mirror altitude calculation (method validated)

**Related**:
- Task 3.5.0: Precipitation loss calculation (system-level stability)

**Note**: Can proceed in parallel with 3.5.0 due to scope separation.

## Verification Command

```bash
cd /work/projects/IMPACT/IMPACT_MATLAB
matlab -batch "run('test_numerical_methods.m');"
```

**Expected Output**: All tests pass, error bounds < 1% thresholds

**Failure Detection**: Any test fails, error exceeds threshold, NaN/Inf present

## Risk and Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Integration error exceeds 1% threshold | High | Low | Document findings, recommend grid refinement |
| Interpolation accuracy insufficient | Medium | Low | Consider higher-order interpolation (future work) |
| Overlap with 3.5.0 causes confusion | Low | Medium | Clearly document scope separation |
| Analytical solutions not available | Low | Low | Use well-known test functions (exponential, polynomial) |
