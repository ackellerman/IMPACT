# Architecture Review: Task 3.2.1 - Validate Mirror Altitude Calculation

**Reviewer**: Architecture Planner
**Date**: January 16, 2026
**Task**: 3.2.1 - Validate mirror altitude calculation (dipole_mirror_altitude.m)
**Status**: APPROVED with clarifications

---

## Executive Summary

The architecture for validating mirror altitude calculations in `dipole_mirror_altitude.m` is **sound and follows established patterns** from task 3.2.0. However, there are important considerations around:

1. **Dual implementation discovery**: Two different mirror altitude algorithms exist in the codebase
2. **Interpolation vs analytical approach**: Need to validate both methods and reconcile differences
3. **Coordinate system consistency**: Verify equatorial pitch angle → mirror latitude → altitude transformation
4. **Loss cone boundary conditions**: Test edge cases with atmospheric boundaries

The approach is **approvable** but requires additional scope for comparing the two implementations.

---

## 1. Requirements Assessment

### Core Requirements (from task description)

| Requirement | Status | Notes |
|-------------|--------|-------|
| Validate B_ratio formula against Roederer (1970) | ✅ Clear | Equation (12) documented in reference_equations_3.0.tex |
| Validate r = L × R_E × cos²(λ) | ✅ Clear | Equation (13) documented |
| Validate interpolation accuracy | ✅ Clear | Need error tolerance specification |
| Verify coordinate system consistency | ✅ Clear | α_eq → λ_m → altitude transformation |
| Test edge cases (α=90°, loss cone) | ✅ Clear | Well-specified test cases |

### Feature Completeness Check ✅

**Required for this validation task:**
- [x] Equation validation (B_ratio formula)
- [x] Formula validation (mirror altitude)
- [x] Interpolation method verification
- [x] Edge case testing
- [x] Coordinate consistency check
- [x] Literature reference tracing

**Verdict**: This is a complete validation task. All components of mirror altitude calculation are addressed.

---

## 2. Current State Assessment

### Foundation Available

| Component | Status | Source |
|-----------|--------|--------|
| Roederer (1970) dipole theory | ✅ Available | Task 3.0.0 literature collection |
| Bounce period validation (3.2.0) | ✅ Complete | Provides validation methodology |
| Reference equations catalog | ✅ Available | reference_equations_3.0.tex, Sections 4 |
| Earth radius constant | ✅ Verified | R_E = 6371 km documented |

### Implementation Discovery (Critical Finding)

**TWO mirror altitude implementations exist:**

1. **`dipole_mirror_altitude.m`** (32 lines, interpolation approach)
   - Builds lookup table: B_ratio = cos⁶(λ)/√(1+3sin²(λ))
   - Interpolates mirror latitude from α_eq
   - Uses r = L × R_E × cos²(λ)

2. **`mirror_altitude.m`** (30 lines, analytical approach)
   - Direct formula: r_mirror = L × R_E × (1/sin²(α_eq))^(1/6)
   - No interpolation table
   - Single-line calculation

**Key Observation**: These two methods should produce identical results mathematically, as:
```
cos²(λ_m) = (1/sin²(α_eq))^(1/3)
```
where λ_m is the mirror latitude for equatorial pitch angle α_eq.

**Risk**: If the implementations diverge, it indicates a bug in one or both.

---

## 3. Architectural Analysis

### Equation Validation

#### B_ratio Formula (Line 14)

**Code**:
```matlab
B_ratio = (cos(mirror_latitude).^6)./sqrt(1 + 3*sin(mirror_latitude).^2);
```

**Literature Match**: Equation (12) in reference_equations_3.0.tex
```
B/B_eq = cos⁶(λ) / √(1 + 3 sin²(λ))
```

**Verification Strategy**:
- This is the standard dipole field latitude dependence
- Can derive from B ∝ 1/r³ with r = L·R_E·cos²(λ)
- Roederer (1970) Chapter 2 is the canonical source

**Decision**: ✅ APPROVE - Formula is correct and well-documented

#### Mirror Altitude Formula (Line 27)

**Code**:
```matlab
r = Lshell.*6371.* cos(mirror_lat_query).^2;
mirror_altitude = r - 6371;
```

**Literature Match**: Equations (13) and (14) in reference_equations_3.0.tex
```
r = L·R_E·cos²(λ)
h = r - R_E
```

**Verification Strategy**:
- Earth radius R_E = 6371 km is a standard IAU value
- Formula follows from dipole field line geometry
- Altitude subtraction is correct

**Decision**: ✅ APPROVE - Formula is correct

#### Interpolation Method (Line 24)

**Code**:
```matlab
mirror_lat_query = interp1(alpha_eq, mirror_latitude, alpha_eq_query);
```

**Architecture Concerns**:

| Issue | Severity | Recommendation |
|-------|----------|----------------|
| **No interpolation method specified** | Medium | Verify `interp1` default is linear; specify method explicitly |
| **No error tolerance documented** | Medium | Define acceptable error vs analytical solution |
| **Grid resolution (500 points)** | Low | Verify resolution is sufficient for 1% accuracy |
| **Monotonicity assumption** | Low | Verify α_eq vs λ_m relationship is monotonic |

**Verification Strategy**:
1. Compare interpolation results to analytical solution from `mirror_altitude.m`
2. Measure error across pitch angle range [1°, 90°]
3. Verify interpolation error < 1% (or define appropriate tolerance)
4. Check boundary behavior (α_eq → 0°, α_eq = 90°)

**Decision**: ⚠️ CONDITIONAL APPROVAL - Add interpolation error tolerance and method specification

### Coordinate System Consistency

**Transformation Chain**:
```
α_eq (equatorial pitch angle)
  → B_ratio = sin²(α_eq)
  → λ_m (mirror latitude) via inversion of B/B_eq = cos⁶(λ)/√(1+3sin²(λ))
  → r_m = L·R_E·cos²(λ_m)
  → h_m = r_m - R_E
```

**Critical Points**:
1. **Pitch angle clipping** (line 19): `alpha_eq_in(alpha_eq_in > 90) = 180 - alpha_eq_in(alpha_eq_in > 90)`
   - Handles α > 90° by using symmetry: sin(α) = sin(180°-α)
   - This is correct physical behavior

2. **Radian conversion**: Consistent use of `deg2rad()`

3. **Inverse problem**: α_eq → λ_m is mathematically inverse of λ → B/B_eq → α
   - Interpolation approach is numerically sound for this monotonic function

**Decision**: ✅ APPROVE - Coordinate transformation is correct

### Edge Case Testing

**Required Test Cases**:

| Case | α_eq | L | Expected Behavior | Risk |
|------|------|---|-------------------|------|
| Equatorial mirroring | 90° | 4 | h_m = 4×6371×cos²(90°) - 6371 | Low |
| Loss cone (small α) | 5° | 4 | h_m < 1000 km | Medium |
| Below surface | 1° | 4 | h_m < 0 | Low |
| High L-shell | 45° | 8 | Large altitude | Low |
| Low L-shell | 45° | 2 | Low altitude | Low |

**Loss Cone Boundary Condition**:
- From reference_equations_3.0.tex Equation (15):
  ```
  sin²(α_LC) = B_eq/B_m
  ```
- Mirror altitude < 1000 km indicates precipitation loss

**Decision**: ✅ APPROVE - Edge cases are well-specified

---

## 4. Architecture Concerns and Recommendations

### Concern 1: Dual Implementation Reconciliation ⚠️

**Issue**: Two implementations (`dipole_mirror_altitude.m` and `mirror_altitude.m`) use different approaches.

**Impact**: Medium - Potential for inconsistent results if one has bugs.

**Recommendation**:

1. **Add to task scope**: Compare outputs from both implementations
2. **Validate equivalence**: For α_eq ∈ [5°, 90°], verify:
   ```
   |h_interp - h_analytical| / h_analytical < 0.01 (1%)
   ```
3. **Document purpose**: Clarify why both exist:
   - `dipole_mirror_altitude.m`: Used in `fang10_precip.m` (line 44)
   - `mirror_altitude.m`: Alternative implementation, possibly for testing

**Architecture Decision**: Add "Cross-validation with analytical solution" as a validation criterion.

### Concern 2: Interpolation Error Tolerance ⚠️

**Issue**: No specified accuracy requirement for interpolation.

**Impact**: Low - Interpolation is likely accurate, but tolerance should be explicit.

**Recommendation**:
1. Define tolerance: Maximum 1% error vs analytical solution
2. Test at critical pitch angles (loss cone boundaries)
3. Verify monotonic error distribution (no spikes)

**Architecture Decision**: Specify interpolation error tolerance in task requirements.

### Concern 3: Literature Reference Completeness ℹ️

**Issue**: Reference equations cite Roederer (1970) but don't provide specific equation numbers.

**Impact**: Low - Formulas are standard dipole theory.

**Recommendation**:
1. Find exact equation numbers in Roederer (1970) if available
2. Document page numbers for future reference
3. Cite alternative sources (Walt 1994, Kivelson & Russell 1995) for redundancy

**Architecture Decision**: Optional enhancement for documentation quality.

---

## 5. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Interpolation error exceeds tolerance** | Low | Medium | Test across full pitch angle range |
| **Dual implementations diverge** | Low | High | Add cross-validation test |
| **Edge case handling incorrect** | Low | Medium | Explicit tests for α_eq → 0°, α_eq = 90° |
| **Coordinate unit mismatch** | Very Low | High | Verify all conversions (degrees ↔ radians, km ↔ m) |
| **Literature equation mismatch** | Very Low | Medium | Cross-check multiple sources |

---

## 6. Implementation Guardrails

### Acceptance Criteria

**MUST (all required)**:
- [ ] B_ratio formula matches Equation (12) from Roederer (1970) theory
- [ ] Mirror altitude formula r = L·R_E·cos²(λ) is verified
- [ ] Interpolation error < 1% compared to analytical solution
- [ ] Coordinate transformations (degrees ↔ radians) are correct
- [ ] Edge cases tested: α_eq = 90°, α_eq < α_LC, h_m < 0

**SHOULD (recommended)**:
- [ ] Cross-validation with `mirror_altitude.m` analytical solution
- [ ] Error distribution plotted across α_eq ∈ [1°, 90°]
- [ ] Performance benchmark: interpolation vs analytical approach

**COULD (optional)**:
- [ ] Higher precision interpolation (spline vs linear)
- [ ] Reference to exact Roederer (1970) equation numbers

### Testing Strategy

```matlab
% Test case 1: Analytical vs interpolation comparison
L_test = 4;
alpha_eq_range = deg2rad(linspace(5, 90, 100));

h_interp = dipole_mirror_altitude(rad2deg(alpha_eq_range), L_test);
h_analytical = mirror_altitude(rad2deg(alpha_eq_range), L_test);

max_rel_error = max(abs(h_interp - h_analytical) ./ h_analytical);
assert(max_rel_error < 0.01, 'Interpolation error exceeds 1%');

% Test case 2: Equatorial mirroring (α_eq = 90°)
h_90 = dipole_mirror_altitude(90, 4);
expected_h_90 = 4 * 6371 * cosd(90)^2 - 6371;
assert(abs(h_90 - expected_h_90) < 1, 'Equatorial mirroring incorrect');

% Test case 3: Loss cone check (α_eq = 5° at L=4)
h_loss_cone = dipole_mirror_altitude(5, 4);
assert(h_loss_cone < 1000, 'Loss cone altitude > 1000 km');
```

### Dependencies

| Dependency | Status | Notes |
|-----------|--------|-------|
| Task 3.0.0 (Literature) | ✅ Complete | Roederer (1970) references available |
| Task 3.2.0 (Bounce period) | ✅ Complete | Provides validation methodology |
| `mirror_altitude.m` | ✅ Available | Required for cross-validation |
| Reference equations (Section 4) | ✅ Available | Equations (12)-(15) documented |

---

## 7. Deliverables

1. **Validation Report** (`validation_report_3.2.1.md`):
   - Equation-by-equation verification
   - Interpolation error analysis
   - Comparison with analytical solution
   - Edge case test results

2. **Test Script** (`test_dipole_mirror_altitude.m`):
   - Reproducible test cases
   - Error tolerance checks
   - Cross-validation with `mirror_altitude.m`

3. **Architectural Notes** (if needed):
   - Clarification of dual implementation purpose
   - Recommendations for future refactoring

---

## 8. Sequence of Work

1. **Literature Verification** (Day 1):
   - Confirm B_ratio formula matches Roederer (1970)
   - Verify mirror altitude formula derivation

2. **Equation Validation** (Day 1):
   - Check mathematical correctness of each line
   - Verify coordinate transformations

3. **Interpolation Analysis** (Day 2):
   - Compare interpolation vs analytical solution
   - Measure error across pitch angle range
   - Verify error < 1%

4. **Edge Case Testing** (Day 2):
   - Test α_eq = 90° (equatorial)
   - Test α_eq < α_LC (loss cone)
   - Test h_m < 0 (below surface)

5. **Documentation** (Day 3):
   - Write validation report
   - Create test script
   - Document findings

---

## 9. Final Decision

### Architecture Verdict: **APPROVED with Conditions**

**Approvals**:
- ✅ Equation validation approach is sound
- ✅ Coordinate system consistency is correct
- ✅ Edge case testing is comprehensive

**Conditions**:
1. ⚠️ Add cross-validation with `mirror_altitude.m` analytical solution
2. ⚠️ Specify interpolation error tolerance (1% recommended)
3. ⚠️ Document the relationship between the two implementations

**Rationale**:
The validation approach is scientifically sound and follows established patterns from task 3.2.0. The primary concern is the discovery of two implementations, which requires cross-validation to ensure consistency. Once this is addressed, the architecture is solid.

### Recommended Task Scope Addition

Add to task requirements:

> **Cross-Validation**: Compare interpolation-based results (`dipole_mirror_altitude.m`) with analytical solution (`mirror_altitude.m`) across the pitch angle range [5°, 90°]. Verify relative error < 1%. Document any discrepancies and explain why both implementations exist.

---

## 10. Transition to Scope Review

This architecture review is **complete**. The task is ready for scope review with the following notes:

- **Scope size**: Appropriate (~100 lines of test code, ~200 lines documentation)
- **Complexity**: Low-medium (well-defined equations, clear test cases)
- **Dependencies**: All required foundation available
- **Risks**: Mitigated with cross-validation requirement

**Next Step**: Advance to `reviewing-plan-scope` state.

---

**Signature**: Architecture Planner
**Date**: January 16, 2026
