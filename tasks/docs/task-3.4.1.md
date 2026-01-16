# Task 3.4.1: Validate coordinate systems and angular definitions

## Architecture Review Status: ⚠️ APPROVED WITH CONCERNS

**Date:** January 16, 2026
**Reviewed by:** Architecture Planner
**Decision:** Proceed with implementation, addressing documented concerns

---

## Executive Summary

The proposed validation approach is **comprehensive** for the stated scope (angular definitions, coordinate systems, transformations). However, **critical gaps** exist in the coordinate system boundary handling between the dipole physics model and the MSIS atmospheric model that must be addressed.

**Overall Assessment:**
- ✅ **Angular Definition Validation:** Well-scoped and comprehensive
- ✅ **Coordinate System Validation:** Comprehensive for dipole physics
- ⚠️ **Coordinate System Boundary (Physics ↔ Atmosphere):** **CRITICAL GAP**
- ✅ **Transformation Validation:** Well-planned

---

## Architecture Approval: YES (With Conditions)

### Conditions for Proceeding:

1. **Document Coordinate System Separation (MUST)**
   - Explicitly document that physics calculations use **pure dipole magnetic coordinates**
   - Explicitly document that atmospheric calculations use **geographic coordinates**
   - Document that the two systems are **NOT mixed** - they operate at different spatial scales

2. **Expand Validation Scope (MUST)**
   - Add validation of L-shell dimensionality consistency
   - Add validation of Earth radius unit consistency (km vs m)
   - Validate the symmetry mapping at 90° boundary

3. **Document Approximation Assumptions (SHOULD)**
   - Document that MSIS uses fixed geographic latitudes (60°, 70°, 80°)
   - Document that this represents high-latitude auroral regions
   - Document that magnetic field model is pure dipole (no MLT dependence)

---

## Detailed Review

### 1. Angular Definitions Validation ✅

**Proposed Approach:** Audit all files for `sin`, `cos`, `tan`, `deg2rad`, `rad2deg` usage; verify pitch angle symmetry handling; verify degrees vs radians consistency

**Assessment:** ✅ COMPREHENSIVE

**Key Findings from Code Review:**

| Location | Pitch Angle Range | Unit | Symmetry Handling |
|----------|------------------|------|-------------------|
| `fang10_precip.m:10` | 0-180° | Degrees | Converted to radians for `bounce_time_arr` |
| `dipole_mirror_altitude.m` | 0-90° | Degrees | Clips >90° to 180-α (line 19) |
| `bounce_time_arr.m` | Radians | Radians | Uses `sin(pa)` directly |
| `def_testdata.m` | 0-180° | Degrees | Uses `sind(pa)` (degree version) |
| `dip_losscone.m` | 0-90° | Radians (internal) | Returns degrees |

**Identified Issues to Validate:**

1. **Symmetry Boundary at 90°:** `dipole_mirror_altitude.m:19` maps α > 90° → 180-α
   - Need to verify: Does this correctly handle sin(α) = sin(180-α) symmetry?
   - Need to verify: Is the mapping correct for the B = B_eq / sin²(α_eq) relationship?

2. **Mixed Trig Functions:** `sind()` (degrees) vs `sin()` (radians)
   - `def_testdata.m:26` uses `sind(pa)` for degree input
   - `bounce_time_arr.m:45` uses `sin(pa)` for radian input
   - **Risk:** Confusion could lead to using wrong function

3. **Loss Cone Angle Definition:**
   - `dip_losscone.m` returns loss cone in **degrees**
   - Need to verify this is consistent with pitch angle definitions used elsewhere

**Validation Recommendations:**

```matlab
% Test 1: Verify sin(α) = sin(180-α) symmetry
alpha_test = [0, 30, 60, 90, 120, 150, 180];
assert(abs(sin(deg2rad(alpha_test)) - sin(deg2rad(180-alpha_test))) < 1e-10);

% Test 2: Verify symmetry mapping in dipole_mirror_altitude
alpha_in = [15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165];
alt = dipole_mirror_altitude(alpha_in, 4);
% Verify: alt(α) should equal alt(180-α) for α ≠ 90

% Test 3: Verify sind vs sin consistency
% sind(45°) should equal sin(π/4)
assert(abs(sind(45) - sin(pi/4)) < 1e-10);
```

---

### 2. Coordinate Systems Validation ⚠️

**Proposed Approach:** Verify L-shell definition, check for mixed coordinate systems, validate altitude definitions

**Assessment:** ⚠️ INCOMPLETE - Missing critical boundary validation

**Coordinate Systems Identified:**

#### 2.1 Dipole Magnetic Coordinates (Physics Layer)

| Variable | Definition | Unit | Consistency Status |
|----------|------------|------|-------------------|
| L-shell | Distance in Earth radii at equator | Dimensionless (R_E) | ✅ Consistent |
| Re | Earth radius | 6371 km (dipole_mirror_altitude.m), 6.371e6 m (bounce_time_arr.m) | ⚠️ **UNITS DIFFER** |
| Equatorial Pitch Angle (α_eq) | Angle between v and B at equator | Degrees | ✅ Consistent |
| Mirror Latitude | Latitude of mirror point | Radians (internal), Degrees (conceptual) | ✅ Consistent |
| Mirror Altitude | Altitude above Earth's surface | km | ✅ Consistent |

**Critical Finding - Earth Radius Unit Inconsistency:**

```matlab
% dipole_mirror_altitude.m:27
r = Lshell.*6371.* cos(mirror_lat_query).^2;  % Re = 6371 km

% bounce_time_arr.m:41
Re = 6.371e6;  % Re = 6.371e6 m (6371 km)
```

**Assessment:** Both are correct (6371 km = 6.371e6 m), but this inconsistency creates:
- Confusion during debugging
- Risk of using wrong value in copy-paste code
- Documentation burden

**Recommendation:** Use consistent units across all files (prefer km, consistent with altitude)

#### 2.2 Geographic Coordinates (Atmospheric Layer - MSIS)

| Variable | Definition | Unit | Values Used |
|----------|------------|------|-------------|
| Geographic Latitude | Standard geographic latitude | Degrees | 60°, 70°, 80° (fixed) |
| Geographic Longitude | Standard geographic longitude | Degrees | 0°, 90°, 180°, 270° (fixed) |
| Altitude | Height above Earth's surface | km | 0-1000 km |

**Source:** `get_msis_dat.m:75-77`

**Critical Observation:** Geographic coordinates are **fixed** and do not relate to magnetic L-shell coordinates. This is an **acceptable approximation** for the current scope, but must be **explicitly documented**.

#### 2.3 Coordinate System Boundary (Physics ↔ Atmosphere)

**How Physics and Atmosphere Connect:**

1. **Physics Layer:** Calculates mirror altitude (km) from dipole geometry:
   ```matlab
   mirr_alt = dipole_mirror_altitude(pa, Lshell);  % Returns altitude in km
   ```

2. **Atmosphere Layer:** Provides atmospheric properties at all altitudes (0-1000 km):
   ```matlab
   [rho, H] = get_msis_dat(alt, f107a, f107, Ap, false);  % alt = 0:1:1000 km
   ```

3. **Connection:** Index into atmospheric array at mirror altitude:
   ```matlab
   [~, idx] = min(abs(alt - mirr_alt(a)));  % fang10_precip.m:93
   ```

**Critical Analysis:**

✅ **What Works:**
- The coordinate systems are **separate but compatible** at the interface
- Both use altitude in km as the common interface variable
- No explicit transformation from magnetic to geographic coordinates is required

⚠️ **What's Problematic:**
- **Implicit Assumption:** Mirror altitude from dipole physics is assumed to be equivalent to geographic altitude
- **Geometric Reality:** Magnetic field lines are NOT vertical, so "altitude along field line" ≠ "geometric altitude"
- **Dipole Approximation:** The pure dipole model ignores magnetic declination and non-dipole components

**Validation Requirement (MUST ADD):**

```matlab
% Test: Verify altitude compatibility between coordinate systems
% Question: Is mirror altitude from dipole geometry equivalent to
% geographic altitude at which atmosphere is sampled?

% For a dipole field line, the geometric altitude at latitude λ is:
% r(λ) = L * Re * cos²(λ)  (radial distance from Earth's center)
% h_geo(λ) = r(λ) - Re      (geometric altitude above surface)

% This is EXACTLY what dipole_mirror_altitude computes!
% Therefore: Mirror altitude IS geometric altitude

% CONCLUSION: The coordinate systems ARE compatible at the interface
% RECOMMENDATION: Document this clearly
```

---

### 3. Transformations Validation ✅

**Proposed Approach:** Verify `deg2rad`/`rad2deg` usage consistency, verify transformations between equatorial and local pitch angles

**Assessment:** ✅ COMPREHENSIVE

**Transformation Points Identified:**

| Location | Transformation | From | To |
|----------|---------------|------|-----|
| `fang10_precip.m:40` | `deg2rad(pa_arr)` | Degrees | Radians |
| `dipole_mirror_altitude.m:13` | `deg2rad(linspace(...))` | Degrees | Radians |
| `dipole_mirror_altitude.m:21` | `deg2rad(alpha_eq_in)` | Degrees | Radians |
| `dip_losscone.m:14` | `rad2deg(losscone)` | Radians | Degrees |
| `def_testdata.m:26` | `sind(pa)` (implicit) | Degrees | N/A |

**Local Pitch Angle Transformations:**

**Finding:** No explicit equatorial → local pitch angle transformations are currently implemented. The code uses **only equatorial pitch angles**.

**Assessment:** This is correct for the current scope:
- `fang10_precip.m:40` converts equatorial pitch angles to radians for bounce time
- `dipole_mirror_altitude.m` computes mirror altitude from equatorial pitch angles
- All calculations are at the equator, not at mirror points

**Validation Recommendations:**

```matlab
% Test 1: Verify all deg2rad/rad2deg conversions
test_angles_deg = [0, 30, 45, 60, 90, 180];
test_angles_rad = deg2rad(test_angles_deg);
assert(all(abs(rad2deg(test_angles_rad) - test_angles_deg) < 1e-10));

% Test 2: Verify no mixed-degree/radian inputs
% Search for all sin/cos/tan usage
% Ensure input to sin/cos/tan is ALWAYS in radians
% Ensure input to sind/cosd/tand is ALWAYS in degrees
```

---

## Additional Concerns & Recommendations

### Concern 1: Magnetic Field Model Assumptions ❗

**Question:** Should we validate the magnetic field model assumptions (pure dipole)?

**Answer:** ⚠️ **PARTIALLY - Document, Don't Validate**

**Rationale:**

✅ **Validate:**
- Verify that pure dipole formulas are correctly implemented
- Verify L-shell definition matches dipole theory
- Verify B_ratio formula matches Roederer (1970)

⏭️ **Document as Limitations:**
- Pure dipole ignores:
  - Non-dipole components (quadrupole, octupole, etc.)
  - Magnetic declination (difference between magnetic and geographic north)
  - Magnetic local time (MLT) dependence
  - Day/night variations
- MSIS uses fixed geographic latitudes (60°, 70°, 80°)
- These are approximations suitable for high-latitude auroral studies

**Recommendation:** Add "Magnetic Field Model Assumptions" section to task documentation

---

### Concern 2: Coordinate System Mismatches (MSIS vs Physics) ❗

**Question:** How should we handle potential coordinate system mismatches with MSIS (geographic) vs Physics (magnetic)?

**Answer:** ✅ **VALIDATE COMPATIBILITY, DON'T FIX (OUT OF SCOPE)**

**Detailed Assessment:**

**Current State:**
```matlab
% fang10_precip.m
Lshell = 3;                          % Magnetic coordinate
mirr_alt = dipole_mirror_altitude(pa, Lshell);  % Returns altitude in km
[~, idx] = min(abs(alt - mirr_alt));            % alt = 0:1:1000 km (MSIS grid)
[rho, H] = get_msis_dat(alt, f107a, f107, Ap, false);  % Returns atmospheric profiles
```

**Coordinate Flow:**
1. Physics: Compute mirror altitude using magnetic L-shell (dipole geometry)
2. Atmosphere: Sample atmosphere at that geometric altitude (MSIS, fixed geographic latitudes)
3. Connection: Altitude is the common variable

**Geometric Reality:**
- For a dipole field line at L=3:
  - At equator (λ=0°): r = 3 × 6371 km = 19113 km, h = 12742 km
  - At mirror point (λ=λ_m): r = 3 × 6371 × cos²(λ_m), h = r - 6371
- The altitude computed from dipole geometry IS the geometric altitude
- MSIS assumes fixed geographic latitudes (60°, 70°, 80°), but the actual magnetic latitude varies

**Approximation:**
- The code effectively assumes: "Atmosphere at 100 km geometric altitude (high latitude) is the same as atmosphere at magnetic mirror altitude 100 km"
- This is **acceptable for L=3** (mirror altitudes typically < 1000 km, within MSIS range)
- This is **not physically accurate** (magnetic latitude ≠ geographic latitude), but is a **reasonable simplification**

**Validation Approach:**

```matlab
% Test: Verify coordinate system compatibility

% 1. For given L-shell and pitch angle, compute mirror altitude
L = 4;
pa = 45;  % degrees
mirr_alt = dipole_mirror_altitude(pa, L);  % Returns altitude in km

% 2. Compute mirror latitude from dipole geometry
% From dipole_mirror_altitude.m: r = L * Re * cos²(λ)
% Therefore: cos(λ) = sqrt(r / (L * Re))
r_mirror = mirr_alt + 6371;  % Convert altitude to radial distance
lambda_m = acosd(sqrt(r_mirror / (L * 6371)));  % Mirror latitude in degrees

% 3. Compare to MSIS geographic latitudes
msis_lats = [60, 70, 80];  % From get_msis_dat.m:75

% 4. Document the approximation
fprintf('Mirror altitude: %.1f km\n', mirr_alt);
fprintf('Mirror latitude: %.1f° (magnetic)\n', lambda_m);
fprintf('MSIS latitudes: %.1f°, %.1f°, %.1f° (geographic)\n', msis_lats);
fprintf('\nApproximation: Atmosphere sampled at geographic latitudes\n');
fprintf('does not match actual magnetic latitude of mirror point.\n');
fprintf('This is acceptable for high-latitude auroral studies.\n');
```

**Recommendation:** Add this validation to the test suite and document the approximation

---

## Expanded Validation Plan

### Additional Test Cases Required:

#### Test Case 1: Earth Radius Unit Consistency
```matlab
% Verify all uses of Re are correct (6371 km or 6.371e6 m)
Re_km = 6371;
Re_m = 6.371e6;
assert(abs(Re_km * 1000 - Re_m) < 1e-6);
```

#### Test Case 2: L-Shell Dimensionality
```matlab
% Verify L-shell is used correctly as dimensionless quantity
L_test = 4;  % Dimensionless
r_eq = L_test * 6371;  % Should be 4 × 6371 km at equator
assert(r_eq == 4 * 6371);
```

#### Test Case 3: Pitch Angle Symmetry
```matlab
% Verify sin(α) = sin(180-α) symmetry in dipole_mirror_altitude
alpha_test = [15, 30, 45, 60, 75];
alt_1 = dipole_mirror_altitude(alpha_test, 4);
alt_2 = dipole_mirror_altitude(180 - alpha_test, 4);
assert(all(abs(alt_1 - alt_2) < 1e-6));
```

#### Test Case 4: Coordinate System Compatibility
```matlab
% Verify that mirror altitude from dipole geometry is compatible
% with MSIS altitude grid
L = 4;
pa = [10, 30, 60, 90];
mirr_alt = dipole_mirror_altitude(pa, L);

% Check that all mirror altitudes are within MSIS range
msis_alt_range = [0, 1000];  % From get_msis_dat.m:23
assert(all(mirr_alt >= msis_alt_range(1)));
assert(all(mirr_alt <= msis_alt_range(2)));
```

#### Test Case 5: Loss Cone Angle Consistency
```matlab
% Verify loss cone angle is consistent with mirror altitude
L = 4;
h_loss = 100;  % km (typical ionization altitude)
losscone_deg = dip_losscone(L, h_loss);

% Compute mirror altitude at loss cone angle
mirr_at_losscone = dipole_mirror_altitude(losscone_deg, L);

% Should equal h_loss (within tolerance)
assert(abs(mirr_at_losscone - h_loss) < 1e-3);
```

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Earth radius unit confusion** | Calculation errors in bounce time | Medium | Use consistent units across all files; document values |
| **Pitch angle symmetry error** | Incorrect loss cone calculation | Low | Test symmetry at 90° boundary |
| **Coordinate system incompatibility** | Physical mismatch between physics and atmosphere | Low | Document approximation; add validation test |
| **Mixed degree/radian usage** | Silent numerical errors | Medium | Audit all trig function calls; add lint rules |
| **Undocumented dipole approximation** | Misunderstanding of model limitations | Low | Add "Model Assumptions" section to documentation |

---

## Implementation Guardrails

### Acceptance Criteria:

1. ✅ **Angular Definitions:**
   - [ ] All pitch angle uses are documented as degrees or radians
   - [ ] Symmetry at 90° boundary is validated
   - [ ] Loss cone angle is consistent with mirror altitude

2. ✅ **Coordinate Systems:**
   - [ ] L-shell is dimensionless and consistently used
   - [ ] Earth radius units are consistent (or explicitly documented if different)
   - [ ] Coordinate system boundary (physics ↔ atmosphere) is documented

3. ✅ **Transformations:**
   - [ ] All `deg2rad`/`rad2deg` conversions are correct
   - [ ] No mixed-degree/radian inputs to trig functions
   - [ ] Coordinate system compatibility is validated

### Documentation Requirements:

1. Create coordinate system diagram showing:
   - Dipole magnetic coordinates (L, α_eq, λ_m)
   - Geographic coordinates (lat, lon, altitude)
   - Interface variable (altitude in km)

2. Add "Model Assumptions" section documenting:
   - Pure dipole field (no non-dipole components)
   - Fixed geographic latitudes for MSIS (high-latitude approximation)
   - No magnetic local time dependence
   - Geometric altitude equivalence between coordinate systems

3. Update function headers for:
   - `dipole_mirror_altitude.m`: Clarify input/output units and coordinate system
   - `dip_losscone.m`: Clarify coordinate system
   - `bounce_time_arr.m`: Clarify input units

### Testing Requirements:

1. Add MATLAB test function: `test_coordinate_systems_validation.m`
2. Run all tests and verify 100% pass rate
3. Document any edge cases or limitations found

---

## Summary

**Architecture Decision:** ✅ **APPROVED WITH CONDITIONS**

The proposed validation approach is **comprehensive** and **well-scoped** for the coordinate systems and angular definitions in the IMPACT precipitation model. The main concern is the **coordinate system boundary** between the dipole physics model and the MSIS atmospheric model, which must be **explicitly documented** as an acceptable approximation.

**Key Takeaways:**
1. Angular definition validation is well-planned and comprehensive
2. Coordinate system validation needs to expand scope to include Earth radius unit consistency and coordinate system boundary documentation
3. Coordinate system boundary (physics ↔ atmosphere) is a critical gap that must be addressed through documentation, not code changes
4. Magnetic field model assumptions should be documented as limitations, not validated
5. Multiple additional test cases are required to ensure robust validation

**Next Steps:**
1. Implement validation tests as outlined above
2. Create coordinate system documentation
3. Add model assumptions documentation
4. Verify all tests pass
5. Advance to scope review

---

**Reviewer:** Architecture Planner
**Date:** January 16, 2026
**Decision:** Proceed with implementation, addressing documented concerns
