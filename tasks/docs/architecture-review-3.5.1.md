# Architecture Review: Task 3.5.1 - Validate Numerical Methods and Stability

**Review Date**: January 16, 2026
**Reviewer**: Architecture Planner
**Task Status**: reviewing-plan-architecture

---

## Executive Summary

**Recommendation: ✅ APPROVE with minor clarifications**

Task 3.5.1 is well-scoped as a focused numerical methods validation element. The scope addresses fundamental numerical methods used throughout the precipitation model that have not been systematically validated in previous tasks. The proposed scope is cohesive and tightly coupled, fitting within the element size guidelines.

---

## 1. Scope Appropriateness

### 1.1 Current Scope Assessment

The task proposes validating four core numerical methods:

| Component | Method | Code Location | Previous Coverage |
|-----------|--------|---------------|-------------------|
| Trapezoidal Integration | `cumtrapz` | `calc_ionization.m:38` | ❌ Not validated |
| Interpolation | `interp1` | `dipole_mirror_altitude.m:24` | ⚠️ Documented difference only |
| Time Stepping | Explicit Euler | `fang10_precip.m:116-120` | ⚠️ Partial in 3.5.0 |
| Negative Value Clamping | `Qe(Qe<0) = 0` | `fang10_precip.m:123` | ⚠️ Mentioned in 3.5.0 |

**Assessment**: ✅ **Appropriate Scope**

These methods form the numerical engine of the precipitation model and merit dedicated validation. Previous tasks validated physical correctness (equations, constants, formulas) but not numerical accuracy.

### 1.2 Relationship to Previous Validations

**Task 3.1.1** (ionization rate calculation):
- Validated: Equation correctness, constant traceability, integration direction
- **Did NOT validate**: Numerical accuracy of `cumtrapz`, error bounds, grid sensitivity

**Task 3.2.1** (mirror altitude calculation):
- Validated: Mirror altitude vs analytical dipole solution
- **Did NOT validate**: Interpolation error of `interp1`, boundary behavior

**Task 3.5.0** (precipitation loss calculation):
- Includes: "Tier 3: Numerical Stability" testing explicit Euler convergence
- **Overlap identified**: Time stepping stability tests may duplicate some 3.5.0 work

**Recommendation**: Clarify overlap with 3.5.0 and avoid duplication. Focus 3.5.1 on **fundamental method validation** (integration, interpolation) rather than system-level time evolution.

---

## 2. Grid Resolution Testing

### 2.1 Proposed Grid Tests

The task should test with multiple grid resolutions to quantify accuracy:

| Grid Type | Current | Test Range | Rationale |
|-----------|---------|------------|-----------|
| Altitude (dz) | 1 km (fixed) | 0.5, 1, 2, 5, 10 km | MSIS uses 1 km; verify error scaling |
| Energy (dE) | Variable | Validate existing grid | Not primary focus |
| Pitch angle (dα) | Variable | Validate existing grid | Not primary focus |
| Time (dt) | 1e-8 s | 1e-9, 1e-8, 1e-7 s | Covered in 3.5.0 |

### 2.2 Required Tests

**Trapezoidal Integration Grid Sensitivity**:
```matlab
% Test convergence with decreasing dz
for dz = [0.5, 1, 2, 5, 10]  % km
    z = 0:dz:1000;
    q_tot = 1e10 * exp(-z/100);  % Exponential profile
    q_cum = cumtrapz(z, q_tot);
    q_cum_exact = 1e10 * 100 * (1 - exp(-z/100));  % Analytical
    error(dz) = max(abs((q_cum - q_cum_exact) / q_cum_exact));
end
% Verify: error ∝ dz² (second-order accuracy)
```

**Interpolation Grid Sensitivity**:
```matlab
% Test accuracy with different lookup grid densities
for n_points = [100, 500, 1000, 5000]
    mirror_lat = linspace(90, 0, n_points);
    % ... generate B_ratio, alpha_eq ...
    alpha_test = deg2rad(45);
    mirror_interp = interp1(alpha_eq, mirror_lat, alpha_test);
    % Compare with analytical solution
end
```

**Recommendation**: ✅ **Include grid resolution tests** - critical for establishing error bounds and validating O(Δz²) convergence.

---

## 3. Floating Point Analysis Depth

### 3.1 Proposed Depth

**Level 1: Basic Validation** (REQUIRED)
- Verify no NaN propagation through operations
- Confirm negative value clamping works
- Check for overflow/underflow in extreme cases

**Level 2: Error Quantification** (REQUIRED)
- Measure integration error vs analytical solution
- Quantify interpolation error on known functions
- Establish error bounds for typical conditions

**Level 3: Precision Analysis** (OPTIONAL/FUTURE)
- Double vs single precision sensitivity
- Round-off error accumulation in long simulations
- Machine epsilon considerations

### 3.2 Recommended Approach

**Focus on Level 1 and Level 2** - practical validation that establishes confidence:

| Test | Purpose | Acceptance |
|------|---------|------------|
| NaN propagation | Ensure numerical errors don't propagate | No NaN in outputs |
| Negative clamping | Verify Qe ≥ 0 constraint | All Qe ≥ 0 |
| Integration error | Validate cumtrapz accuracy | < 1% vs analytical |
| Interpolation error | Validate interp1 accuracy | < 1% vs analytical |
| Extreme cases | Overflow/underflow handling | No inf/nan |

**Level 3** (precision analysis) is **out of scope** for this task. This would require exhaustive parameter sweeps and is more appropriate for a dedicated numerical robustness phase (if needed later).

**Recommendation**: ✅ **Focus on Level 1-2** - practical validation without deep floating point analysis.

---

## 4. Overlap with Task 3.5.0

### 4.1 Overlap Analysis

**Task 3.5.0 Scope** (from task-3.5.0.md):
- "Tier 3: Numerical Stability"
  - Test explicit Euler convergence with varying time steps
  - Verify no oscillations in Qe(t)
  - Check stability criterion: dt < t_b / (2 × lossfactor)
  - Confirm negative value clamping

**Task 3.5.1 Proposed Scope**:
- Time stepping stability (explicit Euler)
- Negative value enforcement

**Overlap Identified**:
1. Time stepping stability tests
2. Negative value clamping verification

### 4.2 Recommended Separation

**Task 3.5.0** (System-Level):
- Test the **integrated time evolution** in `fang10_precip.m`
- Validate system stability with realistic parameters
- Verify energy conservation over full simulation
- Focus on **physics-level correctness** (stability, conservation)

**Task 3.5.1** (Method-Level):
- Validate the **fundamental numerical methods** independently
- Test integration accuracy with analytical solutions
- Test interpolation accuracy with known functions
- Focus on **numerical accuracy** (error bounds, convergence)

**Revised Task 3.5.1 Scope**:
- ✅ Trapezoidal integration accuracy (cumtrapz)
- ✅ Interpolation accuracy (interp1)
- ❌ **Remove**: Time stepping stability (covered in 3.5.0)
- ⚠️ **Clarify**: Negative value enforcement - keep as simple sanity check only

**Recommendation**: ✅ **Revise scope** to focus on integration and interpolation, avoid duplicating 3.5.0 time stepping tests.

---

## 5. Feature Completeness Check (Anti-Stub Validation)

### 5.1 Completeness Assessment

**Question**: If we only validate what's specified here, will it be complete?

| Component | Validation Specified | Completeness |
|-----------|---------------------|--------------|
| Trapezoidal Integration | Grid sensitivity, error quantification | ✅ Complete |
| Interpolation | Accuracy, boundary behavior | ✅ Complete |
| Time Stepping | **Remove** (3.5.0) | ✅ Complete |
| Negative Clamping | Basic sanity check | ✅ Complete |
| Floating Point | Level 1-2 (NaN, error bounds) | ✅ Complete |

**Assessment**: ✅ **Complete feature**

This is NOT a stub validation. The scope covers all four numerical methods with quantifiable tests and error bounds.

### 5.2 Missing Elements Check

**Potentially Missing**:
- [ ] Grid convergence formal convergence test (order verification)
- [ ] Edge case handling (empty arrays, single point, degenerate inputs)
- [ ] Performance characterization (optional for validation)

**Decision**: These are **nice-to-have** but not required for completeness. The scope as specified provides adequate validation coverage.

**Recommendation**: ✅ **Feature is complete** - no obvious missing pieces.

---

## 6. Element Size and Scope Analysis

### 6.1 Estimated Size

Based on element-scope-rules.md guidelines:

| Metric | Estimate | Soft Limit | Verdict |
|--------|----------|------------|---------|
| Lines of code (validation script) | 200-300 | 400 | ✅ Small-Medium |
| Files created | 1-2 | 5 | ✅ Small |
| Test cases | 6-10 | 15 | ✅ Small-Medium |
| Iterations | 4-6 | 10 | ✅ Small |

**Estimated Deliverables**:
- Validation script: `test_numerical_methods.m` (~200 LOC)
- Validation report: `validation_report_3.5.1.md`

### 6.2 Cohesion Assessment

**Tightly Coupled Components**:
- Trapezoidal integration and interpolation are both numerical methods
- Both serve the same purpose: ensure numerical accuracy of the model
- Tests share similar structure (compare numerical vs analytical)

**Cohesion Question**: "Would splitting this require passing significant state?"

**Answer**: **No** - but splitting would create:
- Two separate validation scripts
- Duplicate test infrastructure
- Inconsistent error reporting

**Tight Coupling Override Applies**: ✅ **Approve as single element**

### 6.3 Complexity Smells Check

- [x] Element name is single purpose ("Validate numerical methods")
- [x] Single coherent domain (numerical accuracy)
- [x] Single architectural layer (numerical methods)
- [x] Estimated LOC < 300 (within limit)
- [x] Test cases ~8 (within limit)
- [ ] "Also needs X" - None identified

**No complexity smells detected.**

**Recommendation**: ✅ **Element size is appropriate** - well within small-medium range.

---

## 7. Recommendations

### 7.1 Required Changes

1. **Clarify Scope Separation from 3.5.0**:
   - Remove time stepping stability (covered in 3.5.0)
   - Focus on fundamental methods: integration + interpolation
   - Keep negative clamping as simple sanity check only

2. **Add Grid Convergence Tests**:
   - Test trapezoidal integration with dz = [0.5, 1, 2, 5, 10] km
   - Verify O(Δz²) convergence
   - Establish error bounds for operational grid (1 km)

3. **Define Acceptance Criteria**:
   - Integration error < 1% vs analytical for exponential profiles
   - Interpolation error < 1% for dipole functions
   - No NaN/Inf outputs for any valid input
   - All Qe ≥ 0 (negative clamping works)

### 7.2 Optional Enhancements (Future Work)

- [ ] Level 3 floating point analysis (double vs single precision)
- [ ] Performance benchmarking of numerical methods
- [ ] Adaptive grid resolution recommendations
- [ ] Comparison with higher-order methods (Simpson's rule, cubic spline)

### 7.3 Deliverables

**Required**:
1. `test_numerical_methods.m` - Validation script
   - Trapezoidal integration tests (grid sensitivity, analytical comparison)
   - Interpolation tests (accuracy, boundary behavior)
   - Negative value clamping test
   - NaN propagation check

2. `validation_report_3.5.1.md` - Documentation
   - Integration error quantification (table of dz vs error)
   - Interpolation error quantification (table of n_points vs error)
   - Established error bounds for operational conditions
   - Known limitations (e.g., linear interpolation accuracy)

3. Updated task-3.5.1.md with clarified scope

---

## 8. Architecture Approval

### 8.1 Approval Decision

**Status**: ✅ **APPROVE with modifications**

**Rationale**:
- Scope is cohesive and focused on numerical methods validation
- Element size is within guidelines (small-medium)
- No complexity smells
- Feature is complete (not a stub)
- Required modifications: clarify overlap with 3.5.0, add grid convergence tests

### 8.2 Verification Requirements

Every validation MUST have:

| Requirement | Specification |
|-------------|---------------|
| Specific command | `matlab -batch "run('test_numerical_methods.m');"` |
| Expected output | All tests pass, error bounds < 1% |
| Failure detection | Relative error > 1%, NaN/Inf present |

### 8.3 Guardrails for Implementation

**DO NOT**:
- ❌ Duplicate time stepping stability tests from 3.5.0
- ❌ Perform deep floating point analysis (Level 3)
- ❌ Test alternative integration/interpolation methods

**DO**:
- ✅ Quantify error vs analytical solutions
- ✅ Test grid resolution sensitivity
- ✅ Validate NaN handling and negative clamping
- ✅ Establish error bounds for operational conditions

**Acceptance Criteria**:
1. Trapezoidal integration error < 1% for exponential profiles at 1 km grid
2. Interpolation error < 1% for dipole functions at 500-point lookup
3. No NaN/Inf in any validation test
4. Negative value clamping verified with synthetic test
5. Grid convergence demonstrates O(Δz²) behavior

---

## 9. Risk and Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Analytical solutions not available for all test cases | Medium | Low | Use well-known functions (exponential, polynomial) |
| Grid convergence tests reveal accuracy issues in production | High | Low | This is a validation task - finding issues is the goal |
| Time stepping overlap with 3.5.0 causes confusion | Low | Medium | Clearly document separation in task docs |
| Error bounds exceed 1% threshold | High | Low | Document findings and recommend grid refinement |

---

## 10. Dependencies

**Upstream Dependencies**:
- Task 3.1.1: Ionization rate calculation (must validate equations first)
- Task 3.2.1: Mirror altitude calculation (must validate method first)
- Task 3.5.0: Precipitation loss calculation (system-level validation)

**Downstream Dependents**:
- Task 3.6.0+: Integration tests (will rely on validated numerical methods)

**Blocked**: None - can proceed in parallel with 3.5.0 if scope is clarified

---

## 11. Summary

**Architecture Review: ✅ APPROVE with minor clarifications**

**Key Points**:
1. Scope is appropriate and cohesive
2. Grid resolution testing is critical - include in validation
3. Floating point analysis should stay at Level 1-2 (practical, not exhaustive)
4. Remove time stepping overlap with 3.5.0 - focus on integration + interpolation
5. Feature is complete (not a stub validation)
6. Element size is within guidelines (small-medium)

**Required Action**: Update task-3.5.1.md with clarified scope before implementation begins.

**Next State**: Transition to `reviewing-plan-scope` after scope clarification.

---

*Architecture Review Complete*
