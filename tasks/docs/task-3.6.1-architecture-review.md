# Architecture Review: Task 3.6.1 - Validate Atmospheric Boundary Integration

## Status: **APPROVED WITH CLARIFICATIONS**

---

## 1. Architecture Brief

### Context
Task 3.6.1 validates the atmospheric boundary integration for the IMPACT electron precipitation model, ensuring physical correctness at the magnetosphere-atmosphere interface (500 km) and the lower atmospheric boundary (ground or 80-100 km cutoff). This task complements Task 3.6.0 (energy/flux consistency) by focusing specifically on how atmospheric data from MSIS 2.1 integrates with precipitation physics across the altitude column.

### Integration Points Validated
1. **Top Boundary (500 km)**: MSIS density at exospheric altitudes, minimal energy dissipation, cumulative ionization start
2. **Bottom Boundary (80 km/ground)**: Maximum atmospheric density, complete energy deposition, ionization maximum
3. **MSIS 2.1 Data Integration**: Density profiles, scale heights, species densities, interpolation accuracy
4. **Density-Physics Coupling**: Energy dissipation ∝ density, ionization ∝ density × energy deposition
5. **Column Integration**: Vertical integration of ionization and energy deposition from 500 km to ground

### Foundation Available
- **Task 3.3.0**: MSIS 2.1 data retrieval validated (4-tier validation complete)
- **Task 3.5.1**: Numerical methods validated (trapezoidal integration, interpolation accuracy)
- **Task 3.6.0**: Energy and flux consistency validated (0.000000% error, boundaries already tested)
- **Existing Test Patterns**: Python validation scripts with 5-class structure (`test_energy_flux_consistency.py`)
- **MATLAB Code**: `calc_Edissipation.m`, `calc_ionization.m`, `fang10_precip.m`, `get_msis_dat.m`

### Validation Scope
1. **Boundary Physical Behavior**: Verify MSIS density, energy dissipation, and cumulative quantities at 500 km and ground/80 km
2. **MSIS Data Integration**: Validate density profiles, species consistency, interpolation accuracy, scale heights
3. **Density-Physics Coupling**: Verify energy dissipation and ionization scale correctly with atmospheric density
4. **Column Integration**: Validate vertical integration of ionization and energy deposition
5. **Dynamic Range**: Verify 10-order magnitude density range is handled without numerical issues

---

## 2. Architecture Decision Record

### Decision ADR-3.6.1-1: Test Structure Alignment with Previous Tasks
**Context**: Task 3.6.1 proposes a 5-class test structure (`TestTopBoundary`, `TestBottomBoundary`, `TestMSISIntegration`, `TestDensityPhysicsCoupling`, `TestColumnIntegration`). This aligns with the 3-class structure from Task 3.6.0 but is more granular.

**Decision**: **APPROVE** the 5-class structure.

**Rationale**:
- **Logical grouping**: Each class corresponds to a distinct physical domain (boundaries, MSIS data, physics coupling, column integration)
- **Incremental validation**: Allows partial completion if one domain fails without blocking others
- **Traceability**: Clear mapping to validation requirements (3.6.1.1 - 3.6.1.5)
- **Cohesion**: Each class tests a coherent set of related behaviors

**Consequences**:
- ✅ Clear separation of concerns across physical domains
- ✅ Enables targeted debugging if specific boundaries or couplings fail
- ✅ Consistent with existing test patterns (just more granular)
- ⚠️ More test classes to maintain than 3.6.0 (5 vs 3)
- ⚠️ Requires careful test fixture setup to avoid duplication

---

### Decision ADR-3.6.1-2: Boundary Condition Overlap with Task 3.6.0
**Context**: Task 3.6.0 already validated top (500 km) and bottom (80 km) boundary conditions. Task 3.6.1 proposes additional boundary validation tests.

**Analysis of Overlap**:

| Boundary | Task 3.6.0 Tests | Task 3.6.1 Tests | Focus Difference |
|----------|------------------|------------------|------------------|
| Top (500 km) | q_cum ≈ 0, q_tot > 0 | Density magnitude, grid handling, energy dissipation | 3.6.1 focuses on atmospheric behavior, 3.6.0 on flux values |
| Bottom (80 km) | q_cum = total, q_tot ≈ peak | Density gradient, cutoff handling, full energy deposition | 3.6.1 focuses on atmospheric profile, 3.6.0 on cumulative integration |

**Decision**: **APPROVE** additional boundary validation tests.

**Rationale**:
- **Different focus**: 3.6.0 validates flux consistency at boundaries; 3.6.1 validates atmospheric physics
- **Complementary validation**: 3.6.1 adds density profile validation, gradient checking, cutoff handling
- **No duplication**: The tests are distinct (MSIS data vs ionization rates)
- **Increased confidence**: Multiple validation angles improve coverage

**Consequences**:
- ✅ Comprehensive boundary validation (both flux and atmospheric physics)
- ✅ Validates MSIS data availability and interpolation at boundaries
- ✅ Catches different failure modes (density errors vs flux errors)
- ⚠️ Requires careful test documentation to avoid confusion about test purpose
- ⚠️ May need to coordinate with 3.6.0 results to avoid redundant testing

**Mitigation**: Document in test code which task validates which aspect:
```python
# TestTopBoundary: MSIS density and atmospheric physics (Task 3.6.1)
# TestEnergyConservation: Flux consistency at boundaries (Task 3.6.0)
```

---

### Decision ADR-3.6.1-3: Density-Physics Coupling Validation Strategy
**Context**: Task 3.6.1 validates that energy dissipation and ionization scale correctly with atmospheric density. This requires understanding the coupling equations.

**Coupling Equations**:
```
1. Energy dissipation: dE/dz = -n(z) × σ(E) × E
2. Ionization rate: q(z) = (dE/dz) / ε_ion × n(z)
```

Where:
- `n(z)` is atmospheric density from MSIS (g/cm³ or number density)
- `σ(E)` is energy-dependent cross-section (embedded in Fang 2010 parameterization)
- `E` is electron energy (keV)
- `ε_ion = 0.035 keV` is ionization energy

**Decision**: **APPROVE** coupling validation approach with specific test cases.

**Required Validation Tests**:

1. **Density-Dissipation Test**:
   ```python
   # Test 8: Verify dissipation scales with density
   # High density → rapid energy deposition
   # Low density → slow energy deposition
   # Validate: dissipation/ρ is monotonic with energy (Fang 2010 shape)
   ```

2. **Density-Ionization Test**:
   ```python
   # Test 9: Verify ionization scales with density
   # q_tot = (Qe/0.035) × f / H
   # Validate: ionization/ρ is proportional to f/H (Fang 2010)
   ```

3. **No Negative Values Test**:
   ```python
   # Test 10: Verify no unphysical negative values
   # Check: dE/dz < 0 (energy always decreases)
   # Check: q_tot > 0 (ionization always positive)
   # Check: H > 0 (scale height always positive)
   ```

4. **Dynamic Range Test**:
   ```python
   # Test 11: Verify 10-order magnitude density range handled
   # Check: No numerical overflow/underflow
   # Check: Consistent accuracy across altitude range (0-1000 km)
   ```

**Consequences**:
- ✅ Validates fundamental physics of energy-atmosphere interaction
- ✅ Catches unit conversion errors (density units in Fang equations)
- ✅ Ensures numerical stability across 10-order magnitude density range
- ⚠️ Requires understanding Fang 2010 parameterization details
- ⚠️ May expose numerical issues at very low densities (exosphere)

---

### Decision ADR-3.6.1-4: Column Integration Validation
**Context**: Task 3.6.1 validates vertical integration of ionization and energy deposition from 500 km to ground. This is distinct from the cumulative integration validated in Task 3.6.0.

**Difference Between Tasks**:

| Aspect | Task 3.6.0 | Task 3.6.1 |
|--------|------------|------------|
| Integration type | Cumulative ionization (`q_cum`) | Column totals (∫ q(z) dz) |
| Integration variable | Altitude z (cumulative) | Altitude z (integrated) |
| Physical meaning | Ionization above altitude z | Total ionization in column |
| Validation focus | Derivative relationship (dq_cum/dz = q_tot) | Units, convergence, magnitude |

**Column Integration Equations**:
```
1. Column ionization: N_col = ∫[500km to ground] q(z) dz  [particles/cm²/s]
2. Column energy deposition: E_col = ∫[500km to ground] dE/dz dz  [erg/cm²/s]
```

**Decision**: **APPROVE** column integration validation with convergence testing.

**Required Validation Tests**:

1. **Units Test**:
   ```python
   # Test 12: Verify column ionization units
   # q(z): [cm⁻³ s⁻¹]
   # dz: [cm]
   # ∫ q(z) dz: [cm⁻² s⁻¹] (particles per column area per second)
   ```

2. **Convergence Test**:
   ```python
   # Test 13: Verify grid convergence
   # Integrate with dz = [0.5, 1, 2, 5] km
   # Verify: Column values converge within 1% as dz → 0
   ```

3. **Magnitude Test**:
   ```python
   # Test 14: Verify physical magnitude
   # Column ionization: 10⁸-10¹² particles/cm²/s (typical precipitation)
   # Column energy deposition: Input energy flux (conservation check)
   ```

4. **Energy Conservation Test**:
   ```python
   # Test 15: Verify energy conservation in column
   # E_col should equal input energy flux for full absorption
   # Partial absorption: E_col < input (electrons pass through or mirror above)
   ```

**Consequences**:
- ✅ Validates total energy/flux balance in atmospheric column
- ✅ Complements cumulative integration validation (3.6.0)
- ✅ Provides physical magnitude sanity checks
- ⚠️ Requires careful interpretation of "full absorption" vs partial absorption
- ⚠️ May depend on pitch angle and mirror altitude (test with fixed conditions)

---

### Decision ADR-3.6.1-5: MATLAB-Python Integration Approach
**Context**: Task 3.6.1 proposes a Python validation script (`test_atmospheric_boundary_integration.py`) that tests MATLAB code. This follows the pattern from Task 3.6.0.

**Decision**: **APPROVE** Python test + MATLAB data files approach.

**Rationale**:
- **Consistent with 3.6.0**: Same integration approach as previous validation task
- **Proven pattern**: `test_energy_flux_consistency.py` successfully validates MATLAB code
- **Clear separation**: MATLAB generates test data, Python validates it
- **No MATLAB Engine dependency**: Avoids complex integration issues

**Integration Pattern**:
```python
# Step 1: Generate MATLAB test data
# MATLAB script: generate_boundary_test_data.m
# - Calls get_msis_dat for density profiles
# - Calls calc_Edissipation for energy dissipation
# - Calls calc_ionization for ionization rates
# - Saves to test_data_boundary_3.6.1.mat

# Step 2: Python validation
# Python script: test_atmospheric_boundary_integration.py
# - Loads test_data_boundary_3.6.1.mat
# - Validates boundary conditions, MSIS integration, coupling, column integration
# - Generates report
```

**Consequences**:
- ✅ Consistent with existing validation patterns
- ✅ Avoids MATLAB Engine for Python dependency
- ✅ Clear separation of concerns (MATLAB for physics, Python for validation)
- ⚠️ Requires MATLAB test data generation script
- ⚠️ Test data file version control needed

**File Structure**:
```
IMPACT_MATLAB/
├── generate_boundary_test_data.m      # Generate test data
├── test_data_boundary_3.6.1.mat      # Test data file (tracked)
├── test_atmospheric_boundary_integration.py  # Validation script
└── atmospheric_boundary_report.md     # Validation report
```

---

## 3. Feature Completeness Check

### Is This Task a Stub or Complete Feature?

**Assessment**: **COMPLETE VALIDATION TASK**

**What IS included**:
- ✅ Top boundary (500 km) validation: Density, energy dissipation, cumulative quantities, grid handling
- ✅ Bottom boundary (80 km/ground) validation: Density gradient, full energy deposition, ionization maximum, cutoff handling
- ✅ MSIS 2.1 data integration validation: Density profiles, species consistency, interpolation accuracy, scale heights
- ✅ Density-physics coupling validation: Energy dissipation scaling, ionization scaling, no negative values, dynamic range
- ✅ Column integration validation: Units, convergence, magnitude, energy conservation

**What is NOT included** (intentional exclusions):
- ❌ Altitude sweep beyond test points (0-1000 km is full range already)
- ❌ Solar/geomagnetic condition variations (fixed F107=50, Ap=5 per 3.3.0 baseline)
- ❌ Seasonal/diurnal variations (fixed dates/times per 3.3.0 baseline)
- ❌ Energy sweep beyond test energies (depends on 3.6.0 results)
- ❌ Pitch angle variations (fixed per 3.6.0 baseline)
- ❌ Comparison to observational data (satellite measurements)
- ❌ Performance testing (execution time, memory usage)
- ❌ MSIS accuracy validation (already done in 3.3.0)

**Rationale for Exclusions**:
- **Scope**: Task focuses on "atmospheric boundary integration," not comprehensive parameter sweeps
- **Focus**: Validates MSIS-physics coupling across altitude boundaries with fixed baseline conditions
- **Efficiency**: Uses validated MSIS baseline (3.3.0) without re-validating all parameter space
- **Traceability**: Validates specific integration paths (MSIS → precipitation physics)
- **Future work**: Parameter sweeps would be separate tasks (not boundary integration)

**Verdict**: This is a **complete validation task** within its stated scope. The exclusions are appropriate and should be documented as future work, not missing features.

---

## 4. Scope Validation (Element Scope Rules)

### Element Size Analysis

| Metric | Estimated Value | Soft Limit | Status |
|--------|-----------------|------------|--------|
| Lines of code | 250-350 (test code only) | 400 | ✅ APPROVED |
| Files modified | 1-2 (test scripts only) | 5 | ✅ APPROVED |
| Test cases | 12-16 validation tests | 15 | ⚠️ APPROVED (slightly over) |
| Iterations | 3-4 | 10 | ✅ APPROVED |

**Note**: Test cases (12-16) slightly exceed soft limit (15), but this is acceptable for integration validation (see Element Scope Rules: "Integration tests may need more").

### Cohesion Check
**Question**: "Would splitting this require passing significant state between elements?"

**Analysis**:
- ✅ This is a **single coherent validation task** (atmospheric boundary integration)
- ✅ Splitting into multiple elements would require:
  - Passing MSIS density profiles and scale heights between elements
  - Duplicating MATLAB execution and data file generation
  - Creating multiple test reports instead of one comprehensive report
  - Increased coordination overhead for boundary coupling validation
- ✅ All test classes are tightly coupled (boundaries, MSIS data, physics coupling, column integration are interrelated)
- ✅ The physical processes are interdependent (density affects dissipation, which affects ionization, which affects column totals)

**Verdict**: **APPROVED** - The element is cohesive and tightly coupled. Splitting would create unnecessary overhead.

### Complexity Smells Check
- [x] Element name contains "and" or multiple verbs: ❌ "Validate atmospheric boundary integration" (single verb)
- [x] Multiple distinct algorithms in one element: ❌ Single validation logic
- [x] Element spans multiple architectural layers: ⚠️ Tests validation layer only (acceptable)
- [x] Estimated >150 lines of production code: ⚠️ 250-350 lines of test code (acceptable for validation)
- [x] Element has sub-bullets that could be separate elements: ❌ All sub-bullets are validation tests
- [x] "Also needs X" appears in requirements: ❌ All requirements are part of core scope
- [x] Testing strategy has >8 distinct test cases: ⚠️ 12-16 tests (slightly over 15 limit, but acceptable)

**Verdict**: **APPROVED** - Minor complexity smells are acceptable for a validation task. No major concerns.

---

## 5. Risks & Mitigation

### Risk 1: Boundary Condition Validation Overlap with Task 3.6.0
**Probability**: High | **Impact**: Low

**Description**:
- Task 3.6.0 already validated top (500 km) and bottom (80 km) boundary conditions
- Task 3.6.1 proposes additional boundary tests (MSIS density, grid handling, energy dissipation)
- Potential for confusion about which task validates which aspect

**Mitigation**:
1. **Primary**: Document clear distinction (ADR-3.6.1-2)
   - 3.6.0: Flux consistency at boundaries (q_cum, q_tot values)
   - 3.6.1: Atmospheric physics at boundaries (MSIS density, energy dissipation)
2. **Secondary**: Add comments in test code referencing task responsibilities
3. **Testing**: Review test cases to ensure no duplication
4. **Documentation**: Document in both task docs and validation reports

**Documentation Example**:
```python
class TestTopBoundary:
    """
    Validate atmospheric physics at 500 km top boundary.

    Note: This validates MSIS density and energy dissipation at 500 km.
    Flux consistency at 500 km is validated in Task 3.6.0
    (test_energy_flux_consistency.py).
    """
```

**Success Criteria**:
- Clear documentation of test responsibilities
- No duplicate test cases
- Complementary validation (not redundant)

---

### Risk 2: MSIS Reference Data Availability for All Conditions
**Probability**: Medium | **Impact**: Medium

**Description**:
- Task 3.6.1 requires MSIS reference data for validation
- MSIS data may not be available for all test conditions (solar/geomagnetic variations)
- Task 3.3.0 used fixed parameters (F107=50, Ap=5) as baseline

**Mitigation**:
1. **Primary**: Use same fixed parameters as Task 3.3.0 (validated baseline)
   - F107a = 50, F107 = 50, Ap = 5
   - Dates: March 20, June 21, Sept 23, Dec 27, 1999
   - Latitudes: 60°, 70°, 80° N (auroral region)
   - Longitudes: 0°, 90°, 180°, 270°
2. **Secondary**: Use MSIS output from Task 3.3.0 as reference data
3. **Testing**: Validate with fixed baseline conditions (not parameter sweeps)
4. **Documentation**: Document sensitivity to geophysical conditions (future work)

**Baseline Parameters (from Task 3.3.0)**:
```matlab
% MSIS fixed parameters (validated in Task 3.3.0)
iyds = [99079, 99172, 99266, 99356];  % Equinox/solstice dates
glats = [60, 70, 80];                 % High-latitude auroral
glongs = [0, 90, 180, 270];           % Global longitudinal
sec = 64800;                          % 18:00 UT
f107a = 50; f107 = 50; Ap = 5;        % Quiet solar/geomagnetic
```

**Success Criteria**:
- All validation tests use same MSIS baseline as Task 3.3.0
- MSIS reference data available for all test conditions
- Documentation states that parameter sweeps are future work

---

### Risk 3: Dynamic Range Numerical Issues (10 Orders of Magnitude)
**Probability**: Low | **Impact**: Medium

**Description**:
- Atmospheric density varies by ~10 orders of magnitude from 500 km to ground
- Numerical integration may have precision issues at very low densities (exosphere)
- Scale height calculation may be unstable at very high altitudes

**Density Range**:
- 500 km (exosphere): ~10⁻¹² g/cm³
- 100 km (thermosphere): ~10⁻⁹ g/cm³
- Ground (troposphere): ~10⁻³ g/cm³
- **Total range**: ~10⁹ orders of magnitude

**Mitigation**:
1. **Primary**: Test dynamic range with relative error (not absolute)
   ```python
   # Use relative error for dynamic range test
   relative_error = abs(computed - reference) / reference
   assert(relative_error < 0.01, 'Dynamic range test failed')
   ```
2. **Secondary**: Validate with double-precision floats (already used in MSIS)
3. **Testing**: Test multiple altitude ranges to identify numerical issues
   - Exosphere (300-500 km): Low density, large scale height
   - Thermosphere (100-300 km): Medium density, moderate scale height
   - Lower atmosphere (0-100 km): High density, small scale height
4. **Documentation**: Document any altitude-specific numerical issues discovered

**Success Criteria**:
- No numerical overflow/underflow errors
- Relative error < 1% across full altitude range (0-1000 km)
- Consistent accuracy for different density regimes

---

### Risk 4: Column Integration Convergence Issues
**Probability**: Low | **Impact**: Low

**Description**:
- Column integration requires accurate numerical integration over 0-1000 km
- Trapezoidal rule may have convergence issues for sharp gradients
- Grid resolution affects integration accuracy

**Mitigation**:
1. **Primary**: Use convergence test (ADR-3.6.1-4)
   ```python
   # Test column integration convergence
   dz_values = [0.5, 1.0, 2.0, 5.0]  # km
   column_values = []
   for dz in dz_values:
       col_value = integrate_column(dz)
       column_values.append(col_value)

   # Verify convergence
   convergence_error = abs(column_values[0] - column_values[1]) / column_values[0]
   assert(convergence_error < 0.01, 'Column integration does not converge')
   ```
2. **Secondary**: Use validated numerical methods from Task 3.5.1 (cumtrapz accuracy)
3. **Testing**: Test with operational grid (dz = 1 km, same as MSIS)
4. **Documentation**: Document convergence behavior and grid sensitivity

**Success Criteria**:
- Column values converge within 1% as dz → 0
- Operational grid (dz = 1 km) meets accuracy requirements
- No unexpected convergence issues

---

### Risk 5: Density-Physics Coupling Unit Conversion Errors
**Probability**: Low | **Impact**: High

**Description**:
- Energy dissipation depends on density with specific unit requirements
- Ionization depends on density and energy deposition with mixed units
- Unit conversion errors could cause wrong coupling behavior

**Unit Mappings**:
```python
# calc_Edissipation.m
# Inputs: ρ [g/cm³], H [cm], E [keV]
# Output: f [dimensionless] - energy dissipation fraction

# calc_ionization.m
# Inputs: Qe [keV cm⁻² s⁻¹], f [dimensionless], H [cm]
# Output: q_tot [cm⁻³ s⁻¹], q_cum [cm⁻² s⁻¹]
# Formula: q_tot = (Qe/0.035) × f / H

# Unit analysis:
# Qe [keV cm⁻² s⁻¹] / ε_ion [keV] = [cm⁻² s⁻¹]
# [cm⁻² s⁻¹] × f [dimensionless] / H [cm] = [cm⁻³ s⁻¹] ✓ Correct
```

**Mitigation**:
1. **Primary**: Verify unit consistency with dimensional analysis
2. **Secondary**: Document unit mapping table (same as ADR-3.6.0-3)
3. **Testing**: Create unit validation test cases
4. **Documentation**: Document all units in code comments

**Unit Mapping Table**:
| Component | Input Units | Output Units | Next Component |
|-----------|-------------|--------------|-----------------|
| `get_msis_dat` | alt [km], F107 [sfu], Ap [index] | ρ [g/cm³], H [cm] | `calc_Edissipation` |
| `calc_Edissipation` | ρ [g/cm³], H [cm], E [keV] | f [dimensionless] | `calc_ionization` |
| `calc_ionization` | Qe [keV cm⁻² s⁻¹], f [dimensionless], H [cm] | q_tot [cm⁻³ s⁻¹], q_cum [cm⁻² s⁻¹] | `fang10_precip` |

**Success Criteria**:
- All unit conversions verified with dimensional analysis
- Unit mapping table documented and validated
- No unit mismatches detected in coupling tests

---

## 6. Dependencies

### Hard Dependencies (Required for Completion)
1. ✅ **Task 3.3.0 completed**: MSIS 2.1 data retrieval validated (4-tier validation complete)
2. ✅ **Task 3.5.1 completed**: Numerical methods validated (cumtrapz accuracy, interpolation)
3. ✅ **Task 3.6.0 completed**: Energy and flux consistency validated (0.000000% error, boundaries tested)
4. ✅ **MATLAB installation**: R2019b+ or compatible
5. ✅ **Python 3.x**: For validation script execution
6. ✅ **MSIS baseline data**: Available from Task 3.3.0 (fixed parameters validated)

### Soft Dependencies (Optional but Recommended)
1. ⚠️ **Task 3.6.0 validation report**: Reference for boundary condition behavior
2. ⚠️ **Test data from Task 3.6.0**: Can reuse for boundary overlap clarification
3. ⚠️ **MSIS reference profiles**: From Task 3.3.0 for density profile validation

### External Dependencies (Out of Scope)
1. ❌ **Satellite observation data**: Not validating against real measurements
2. ❌ **Literature data beyond Fang 2010**: Not comparing to other studies
3. ❌ **Fang et al. (2010) authors**: Not contacting authors for clarification
4. ❌ **Additional MSIS test conditions**: Solar/geomagnetic variations (future work)

---

## 7. Implementation Guardrails

### Acceptance Criteria Summary

**Task Complete When**:
- [ ] **Top Boundary**: All 4 top boundary tests pass (density, dissipation, cumulative, grid handling)
- [ ] **Bottom Boundary**: All 4 bottom boundary tests pass (gradient, energy deposition, ionization maximum, cutoff)
- [ ] **MSIS Integration**: All 4 MSIS integration tests pass (density profile, species consistency, interpolation, scale height)
- [ ] **Density-Physics Coupling**: All 4 coupling tests pass (dissipation scaling, ionization scaling, no negative values, dynamic range)
- [ ] **Column Integration**: All 4 column integration tests pass (units, convergence, magnitude, energy conservation)
- [ ] **Documentation**: Validation results documented in `atmospheric_boundary_report.md`
- [ ] **Unit Mapping**: Unit mapping table verified (same as ADR-3.6.0-3)
- [ ] **Verification**: At least 12 test cases pass (minimum coverage)

### Sequencing
1. **Start**: Review Task 3.6.0 results and clarify boundary overlap (ADR-3.6.1-2)
2. **Next**: Generate MATLAB test data (reuse Task 3.3.0 baseline parameters)
3. **Next**: Implement TestTopBoundary (validate MSIS density and atmospheric physics at 500 km)
4. **Next**: Implement TestBottomBoundary (validate density gradient and full energy deposition)
5. **Next**: Implement TestMSISIntegration (validate MSIS data integration accuracy)
6. **Next**: Implement TestDensityPhysicsCoupling (validate coupling between density and physics)
7. **Next**: Implement TestColumnIntegration (validate column integrals and convergence)
8. **Next**: Run validation suite and document results
9. **Final**: Create validation report and update documentation

### Success Metrics
- **Code Coverage**: 100% of boundary and integration interfaces tested (not code coverage - this is integration testing)
- **Test Cases**: ≥ 12 validation tests (4 boundary, 4 MSIS, 4 coupling, 4 column integration)
- **Execution Time**: < 60 seconds for full validation suite (MATLAB execution may be slow)
- **Pass Rate**: 100% of test cases pass (or documented failures with rationale)
- **Numerical Accuracy**: Relative error < 1% for dynamic range, < 0.1% for column convergence

### Owners
- **Architecture Review**: Architecture Planner (@architect)
- **Implementation**: Developer (@developer)
- **Validation**: QA/Testing Agent (@tester)
- **Documentation**: Documentation Specialist (@docs)

---

## 8. Open Questions

### Question 1: Boundary Condition Overlap Clarification
**Status**: ℹ️ **DOCUMENTED IN ADR-3.6.1-2**

Task 3.6.0 already validated boundary conditions. How to avoid confusion about test responsibilities?

**Decision**: Document clear distinction in test code:
- **Task 3.6.0**: Flux consistency at boundaries (q_cum, q_tot values)
- **Task 3.6.1**: Atmospheric physics at boundaries (MSIS density, energy dissipation)

**Rationale**: Different focus (flux vs atmosphere), complementary validation.

---

### Question 2: MSIS Baseline Parameters
**Status**: ℹ️ **DECISION MADE**

Task 3.6.1 requires MSIS reference data. Should we use same baseline as Task 3.3.0 or new parameters?

**Decision**: Use same fixed parameters as Task 3.3.0 (validated baseline).

**Baseline Parameters**:
- F107a = 50, F107 = 50, Ap = 5 (quiet solar/geomagnetic)
- Dates: March 20, June 21, Sept 23, Dec 27, 1999 (equinox/solstice)
- Latitudes: 60°, 70°, 80° N (auroral region)
- Longitudes: 0°, 90°, 180°, 270° (global longitudinal)

**Rationale**: Already validated in Task 3.3.0, provides deterministic baseline, avoids parameter sweep complexity.

---

### Question 3: Column Integration Interpretation
**Status**: ℹ️ **DOCUMENTED IN ADR-3.6.1-4**

Column integration of ionization: Does this differ from cumulative ionization validated in Task 3.6.0?

**Decision**: Yes, different integration types:
- **Cumulative (3.6.0)**: `q_cum(z)` = ionization above altitude z
- **Column (3.6.1)**: `N_col` = ∫ q(z) dz = total ionization in column

**Rationale**: Different physical meanings, different validation approaches (derivative vs convergence).

---

### Question 4: MATLAB Test Data Generation
**Status**: ℹ️ **DECISION MADE IN ADR-3.6.1-5**

Should we create a separate MATLAB script to generate test data, or call MATLAB from Python?

**Decision**: Create separate MATLAB script `generate_boundary_test_data.m` and save to `.mat` file.

**Rationale**: Consistent with Task 3.6.0 pattern, avoids MATLAB Engine dependency, clear separation of concerns.

**File Structure**:
```
IMPACT_MATLAB/
├── generate_boundary_test_data.m      # Generate test data
├── test_data_boundary_3.6.1.mat      # Test data file (tracked)
└── test_atmospheric_boundary_integration.py  # Validation script
```

---

## 9. Recommendations

### For Implementation
1. **Review Task 3.6.0 results first** to understand what has already been validated
2. **Document boundary overlap** in test code comments (ADR-3.6.1-2)
3. **Use same MSIS baseline** as Task 3.3.0 (fixed parameters, validated)
4. **Generate MATLAB test data** using `generate_boundary_test_data.m` script
5. **Validate unit consistency** with dimensional analysis (ADR-3.6.1-3)
6. **Test dynamic range** with relative error (not absolute) to handle 10-order magnitude
7. **Use convergence test** for column integration (ADR-3.6.1-4)

### For Documentation
1. **Update task 3.6.1.md** with:
   - Boundary overlap clarification (ADR-3.6.1-2)
   - Unit mapping table (same as ADR-3.6.0-3)
   - MSIS baseline parameters
   - MATLAB-Python integration approach
2. **Create validation report** `atmospheric_boundary_report.md`:
   - Test results (pass/fail, error percentages)
   - Boundary condition validation
   - MSIS integration accuracy
   - Density-physics coupling validation
   - Column integration convergence
   - Any inconsistencies found with root cause analysis
3. **Update VALIDATION_SUMMARY.md** with boundary integration results

### For Testing
1. **Start with simple test cases** (single energy, fixed pitch angle)
2. **Validate boundaries first** (top 500 km, bottom 80 km)
3. **Validate MSIS integration next** (density profiles, interpolation)
4. **Validate physics coupling last** (density-dissipation, density-ionization)
5. **Test dynamic range** across full altitude range (0-1000 km)
6. **Verify column convergence** with multiple grid resolutions

### For Future Work
1. **Task 3.6.2**: Solar/geomagnetic condition validation (F107, Ap variations)
2. **Task 3.6.3**: Seasonal/diurnal validation (date/time variations)
3. **Task 3.6.4**: Altitude resolution sensitivity analysis (dz optimization)
4. **Task 3.6.5**: Comparison to observational data (satellite measurements)
5. **Task 3.6.6**: Multi-energy and differential flux validation (beyond monoenergetic)

---

## 10. Summary

### Architecture Verdict: **APPROVED WITH CLARIFICATIONS**

**Clarifications**:
1. ✅ Test structure is sound (5 test classes: boundaries, MSIS, coupling, column integration)
2. ✅ Scope is appropriate for element-level task (250-350 LOC, 12-16 tests)
3. ✅ Cohesive and tightly coupled (splitting would create overhead)
4. ✅ Completes atmospheric boundary integration validation
5. ✅ Follows existing test patterns (Python validation scripts)
6. ⚠️ **REQUIRED**: Document boundary overlap with Task 3.6.0 (ADR-3.6.1-2)
7. ⚠️ **REQUIRED**: Use same MSIS baseline as Task 3.3.0 (fixed parameters)
8. ⚠️ **REQUIRED**: Create MATLAB test data generation script (ADR-3.6.1-5)
9. ⚠️ **REQUIRED**: Validate unit consistency with dimensional analysis (ADR-3.6.1-3)
10. ℹ️ **NOTE**: Column integration is distinct from cumulative integration (ADR-3.6.1-4)
11. ℹ️ **NOTE**: Document sensitivity to geophysical conditions (future work)

**Key Strengths**:
- Clear separation of validation concerns (5 test classes)
- Comprehensive coverage of atmospheric boundary integration
- Complements Task 3.6.0 (flux consistency) with atmospheric physics validation
- Consistent with existing validation patterns (Task 3.6.0, 3.5.1, 3.3.0)
- Well-defined boundary conditions and success criteria
- Addresses dynamic range (10 orders of magnitude) with relative error testing

**Key Risks**:
- Boundary condition validation overlap with Task 3.6.0 (mitigated by documentation)
- MSIS reference data availability (mitigated by using Task 3.3.0 baseline)
- Dynamic range numerical issues (mitigated by relative error testing)
- Column integration convergence (mitigated by convergence test)
- Density-physics coupling unit errors (mitigated by unit mapping table)

**Next Steps**:
1. Review Task 3.6.0 results and document boundary overlap (ADR-3.6.1-2)
2. Create MATLAB test data generation script (`generate_boundary_test_data.m`)
3. Implement TestTopBoundary (validate MSIS density and atmospheric physics at 500 km)
4. Implement TestBottomBoundary (validate density gradient and full energy deposition)
5. Implement TestMSISIntegration (validate MSIS data integration accuracy)
6. Implement TestDensityPhysicsCoupling (validate coupling between density and physics)
7. Implement TestColumnIntegration (validate column integrals and convergence)
8. Run validation suite and document results
9. Create validation report and update documentation
10. Address any inconsistencies discovered during validation

---

**Document Version**: 1.0
**Date**: January 16, 2026
**Status**: APPROVED WITH CLARIFICATIONS - Ready for scope review
**Reviewer**: Architecture Planner (@architect)
