# Architecture Review: Task 3.6.0 - Validate Energy and Flux Consistency

## Status: **APPROVED WITH MINOR CONDITIONS**

---

## 1. Architecture Brief

### Context
Task 3.6.0 validates the cross-component energy and flux conservation across all integrated components of the IMPACT electron precipitation model. This is the final integration validation that ensures the fundamental conservation laws are preserved when all modules work together.

### Integration Points Validated
1. **Energy Dissipation** (`calc_Edissipation.m`) → Precipitation model
2. **Ionization** (`calc_ionization.m`) → Energy deposition conversion
3. **Bounce Period** (`bounce_time_arr.m`) → Loss fraction calculation
4. **MSIS Data** (`get_msis_dat.m`) → Atmospheric density profiles
5. **Precipitation Model** (`fang10_precip.m`) → Full integration of all components

### Foundation Available
- **Task 3.1.0**: `calc_Edissipation.m` validated (Fang 2010, 8-parameter coefficient model)
- **Task 3.1.1**: `calc_ionization.m` validated (0.035 keV efficiency factor)
- **Task 3.2.0**: `bounce_time_arr.m` validated (relativistic corrections)
- **Task 3.3.0**: MSIS 2.1 integration validated (atmospheric profiles)
- **Task 3.5.0**: `fang10_precip.m` validated (loss factor calculation, time evolution)
- **Existing Test Patterns**: Python validation scripts with clear structure (`test_calc_ionization_validation.py`, `test_precipitation_loss.py`)

### Validation Scope
1. **Energy Conservation**: Verify that energy is conserved across all components
2. **Flux Consistency**: Ensure particle flux is consistently handled
3. **Component Interfaces**: Validate data flow and unit consistency between modules
4. **Cumulative vs Local Quantities**: Verify derivative relationships
5. **Boundary Conditions**: Test top (500 km) and bottom (ground/80 km) boundaries

---

## 2. Architecture Decision Record

### Decision ADR-3.6.0-1: Cross-Component Validation Strategy
**Context**: This task validates the integration of 5 previously validated components. The validation must ensure that energy and flux are consistently handled when components interact.

**Decision**: Use a **three-class test structure** for comprehensive validation:
1. **TestEnergyConservation**: Validates energy balance across components
2. **TestFluxConsistency**: Validates particle flux calculations
3. **TestComponentIntegration**: Validates module interfaces and unit consistency

**Rationale**:
- **Separation of concerns**: Each test class focuses on a specific validation domain
- **Traceability**: Energy conservation tests map to specific physics requirements
- **Reusability**: Test structure follows existing patterns in the codebase
- **Isolation**: Component interface tests are separated from physics tests

**Consequences**:
- ✅ Clear mapping to validation requirements (energy, flux, interfaces)
- ✅ Enables partial completion if one validation domain fails
- ✅ Consistent with existing test patterns (`test_precipitation_loss.py`)
- ⚠️ Requires MATLAB execution (no Python-only validation possible for integration)
- ⚠️ Depends on all previous validation tasks (3.1.0, 3.1.1, 3.2.0, 3.3.0, 3.5.0)

---

### Decision ADR-3.6.0-2: Energy Conservation Error Tolerance
**Context**: The task specification requires energy conservation error < 0.001%. This is extremely tight and may be difficult to achieve in cross-component integration.

**Decision**: **APPROVE** 0.001% tolerance, but allow relaxed tolerance for numerical integration error.

**Rationale**:
- **Task 3.5.1**: Achieved 0.0000% error for loss calculation (sets precedent)
- **Cumulative integration**: `calc_ionization.m` uses trapezoidal integration (introduces small error)
- **Energy deposition**: `calc_Edissipation.m` uses Fang 2010 parameterization (empirical fit)
- **Consistency**: Tight tolerance ensures numerical accuracy is preserved

**Tolerance Hierarchy**:
| Validation Type | Target Tolerance | Rationale |
|----------------|------------------|-----------|
| Bounce loss calculation | 0.0000% | Analytical formulas, no integration |
| Energy balance (analytical) | 0.001% | Direct calculation |
| Cumulative integration | 0.1% | Trapezoidal numerical integration |
| Flux consistency | 0.01% | Unit conversions and scaling |

**Consequences**:
- ✅ Ensures high numerical accuracy across components
- ✅ Consistent with previous validation achievements
- ⚠️ May require double-precision calculations (already used in MSIS)
- ⚠️ Tight tolerance may expose minor numerical issues in integration

---

### Decision ADR-3.6.0-3: Unit Consistency Validation
**Context**: The test plan validates unit consistency but does not explicitly define the unit mapping between components.

**Decision**: **MANDATE** explicit unit mapping table in test documentation.

**Required Unit Mapping**:
| Component | Input Units | Output Units | Next Component |
|-----------|-------------|--------------|-----------------|
| `calc_Edissipation` | ρ (g/cm³), H (cm), E (keV) | f (dimensionless) | `fang10_precip` |
| `calc_ionization` | Qe (keV cm⁻² s⁻¹), f (dimensionless), H (cm) | q_tot (cm⁻³ s⁻¹), q_cum (cm⁻² s⁻¹) | `fang10_precip` |
| `bounce_time_arr` | L (dimensionless), E (MeV), α (rad) | t_b (s) | `fang10_precip` |
| `get_msis_dat` | alt (km), F107 (sfu), Ap (index) | ρ (g/cm³), H (cm) | `calc_Edissipation` |
| `fang10_precip` | Qe (erg cm⁻² s⁻¹), lossfactor (dimensionless), t_b (s) | dQe/dt (erg cm⁻² s⁻²) | N/A |

**Critical Unit Conversions**:
- **Energy**: keV ↔ MeV ↔ erg (need to verify conversion factors)
- **Flux**: keV cm⁻² s⁻¹ ↔ erg cm⁻² s⁻¹ (need to verify Qe = j × E formula)
- **Density**: g/cm³ ↔ number densities (need to verify molecular weight usage)
- **Length**: km ↔ cm ↔ m (need to verify all scale heights are in cm)

**Consequences**:
- ✅ Ensures unit consistency across all interfaces
- ✅ Provides traceability for energy/flux conservation
- ⚠️ Requires careful verification of unit conversion factors
- ⚠️ May expose hidden unit mismatches in existing code

---

### Decision ADR-3.6.0-4: Cumulative vs Local Quantity Validation
**Context**: The task validates that "Local derivative of cumulative = Local value" (Test 5). This is a mathematical property that must hold if integration is correct.

**Decision**: **MANDATE** derivative validation for cumulative quantities.

**Validation Requirements**:
1. **q_tot relationship**: `q_tot(z) = d(q_cum)/dz`
2. **Numerical derivative**: Use central difference: `(q_cum(z+dz) - q_cum(z-dz)) / (2*dz)`
3. **Tolerance**: 0.1% relative error (numerical derivative accuracy)

**Mathematical Basis**:
- From `calc_ionization.m` (line 38): `q_cum = -flip(cumtrapz(flip(z), flip(q_tot, 1), 1), 1)`
- Differentiating the cumulative sum: `d(q_cum)/dz = q_tot`
- This is a fundamental property of cumulative integration

**Consequences**:
- ✅ Validates that integration is mathematically consistent
- ✅ Catches integration direction errors (top-down vs bottom-up)
- ⚠️ Requires careful numerical derivative calculation
- ⚠️ May expose small numerical errors from trapezoidal integration

---

### Decision ADR-3.6.0-5: Boundary Condition Validation
**Context**: The task validates top (500 km) and bottom (ground/80 km) boundary conditions. This is critical for ensuring physical consistency.

**Decision**: **APPROVE** boundary validation approach with clear pass criteria.

**Boundary Condition Requirements**:

**Top Boundary (500 km)**:
| Quantity | Expected Value | Physical Meaning |
|----------|----------------|------------------|
| Cumulative ionization | 0 (or very small) | No atmosphere above to ionize |
| Local ionization | Small but non-zero | Low atmospheric density |
| Energy deposition | Small | Few atmospheric particles |
| MSIS density | 10⁻¹⁵ g/cm³ (order of magnitude) | Exospheric density |

**Bottom Boundary (ground or 80 km)**:
| Quantity | Expected Value | Physical Meaning |
|----------|----------------|------------------|
| Cumulative ionization | Total integrated value | All energy deposited |
| Local ionization | Small | Most energy deposited above |
| Energy deposition | Small | Atmosphere thins above |
| MSIS density | 10⁻⁹ g/cm³ (order of magnitude) | Lower thermosphere density |

**Pass Criteria**:
- ✅ Cumulative quantity at top = 0 (within 1% of maximum)
- ✅ Cumulative quantity at bottom = total (within 0.1%)
- ✅ Local quantities follow physical profiles (monotonic where expected)
- ✅ MSIS density profile matches expected altitude dependence

**Consequences**:
- ✅ Ensures physical consistency of boundary conditions
- ✅ Validates integration direction and limits
- ⚠️ Requires careful interpretation of "top" vs "bottom" in altitude arrays
- ⚠️ May expose issues with altitude indexing in loops

---

## 3. Feature Completeness Check

### Is This Task a Stub or Complete Feature?

**Assessment**: **COMPLETE CROSS-COMPONENT VALIDATION TASK**

**What IS included**:
- ✅ Energy conservation validation (monoenergetic and differential flux)
- ✅ Flux consistency validation (particle flux integration, differential to integral conversion)
- ✅ Component interface validation (5 components, all interfaces tested)
- ✅ Cumulative vs local quantity validation (derivative relationships)
- ✅ Boundary condition validation (top and bottom boundaries)
- ✅ Unit consistency validation (explicit unit mapping)
- ✅ Physical consistency validation (energy conservation < 0.001%)

**What is NOT included** (intentional exclusions):
- ❌ Energy range sweep validation (beyond test energies: 10, 100, 1000 keV)
- ❌ Pitch angle sweep validation (beyond test cases)
- ❌ L-shell parameter sweep (fixed L=3 in tests)
- ❌ Solar/geomagnetic condition validation (fixed F107, Ap)
- ❌ Seasonal/diurnal validation (fixed dates/times)
- ❌ Comparison to observational data (satellite measurements, ground observations)
- ❌ Performance testing (execution time, memory usage)

**Rationale for Exclusions**:
- **Scope**: Task focuses on "cross-component consistency", not comprehensive parameter space testing
- **Focus**: Validates fundamental conservation laws and unit consistency
- **Efficiency**: Fixed parameters provide deterministic baseline without sweep complexity
- **Traceability**: Validates specific integration paths between components
- **Future work**: Parameter sweep validation would be separate tasks (not part of cross-component consistency)

**Verdict**: This is a **complete validation task** within its stated scope. The exclusions are appropriate and should be documented as future work, not missing features.

---

## 4. Scope Validation (Element Scope Rules)

### Element Size Analysis

| Metric | Estimated Value | Soft Limit | Status |
|--------|-----------------|------------|--------|
| Lines of code | 200-300 (test code only) | 400 | ✅ APPROVED |
| Files modified | 1-2 (test scripts only) | 5 | ✅ APPROVED |
| Test cases | 8-12 validation tests | 15 | ✅ APPROVED |
| Iterations | 3-6 | 10 | ✅ APPROVED |

### Cohesion Check
**Question**: "Would splitting this require passing significant state between elements?"

**Analysis**:
- ✅ This is a **single coherent validation task** (cross-component energy/flux consistency)
- ✅ Splitting into multiple elements would require:
  - Passing test fixtures and mock data between elements
  - Duplicating MATLAB execution setup code
  - Creating multiple test reports instead of one
  - Increased coordination overhead
- ✅ All test classes are tightly coupled (energy, flux, and interfaces are interrelated)

**Verdict**: **APPROVED** - The element is cohesive and tightly coupled. Splitting would create unnecessary overhead.

### Complexity Smells Check
- [x] Element name contains "and" or multiple verbs: ⚠️ "Validate energy and flux consistency" (acceptable - single validation domain)
- [x] Multiple distinct algorithms in one element: ❌ No - single validation logic
- [x] Element spans multiple architectural layers: ⚠️ Tests validation layer only (acceptable)
- [x] Estimated >150 lines of production code: ⚠️ 200-300 lines of test code (acceptable)
- [x] Element has sub-bullets that could be separate elements: ❌ All sub-bullets are validation tests
- [x] "Also needs X" appears in requirements: ❌ All requirements are part of core scope
- [x] Testing strategy has >8 distinct test cases: ⚠️ 8-12 tests (within limit of 15)

**Verdict**: **APPROVED** - Minor complexity smells are acceptable for a validation task. No major concerns.

---

## 5. Risks & Mitigation

### Risk 1: Numerical Precision at Boundaries
**Probability**: Medium | **Impact**: Medium

**Description**:
- Cumulative integration may have small errors at boundaries (top/bottom)
- Numerical derivative validation may expose trapezoidal integration errors
- MSIS density at very low altitudes may have numerical issues

**Mitigation**:
1. **Primary**: Use relative error tolerances (not absolute) for boundary validation
2. **Secondary**: Validate derivative relationship away from boundaries (avoid edge effects)
3. **Testing**: Test multiple energy values to ensure boundary behavior is consistent
4. **Documentation**: Document any boundary-specific numerical issues discovered

**Success Criteria**:
```python
# Boundary validation with relative error
top_boundary_error = abs(q_cum_top - 0) / max(q_cum)
assert(top_boundary_error < 0.01, 'Top boundary error > 1%')

bottom_boundary_error = abs(q_cum_bottom - q_total) / q_total
assert(bottom_boundary_error < 0.001, 'Bottom boundary error > 0.1%')
```

---

### Risk 2: Hidden Unit Conversion Errors
**Probability**: Low | **Impact**: High

**Description**:
- Energy units: keV ↔ MeV ↔ erg (conversion factor: 1 keV = 1.602×10⁻⁹ erg)
- Flux units: keV cm⁻² s⁻¹ ↔ erg cm⁻² s⁻¹ (need to verify Qe = j × E formula)
- Length units: km ↔ cm ↔ m (scale heights must be in cm for Fang equations)

**Mitigation**:
1. **Primary**: Explicit unit mapping table (ADR-3.6.0-3)
2. **Secondary**: Verify unit conversions with dimensional analysis
3. **Testing**: Create unit conversion validation tests
4. **Documentation**: Document all units in code comments

**Dimensional Analysis**:
```python
# Verify Qe = j × E units
# j: number flux [particles cm^-2 s^-1]
# E: energy [keV]
# Qe: energy flux [keV cm^-2 s^-1]
# Qe_erg: energy flux [erg cm^-2 s^-1]
# Conversion: 1 keV = 1.602e-9 erg
Qe_erg = Qe * 1.602e-9  # Verify this conversion is correct in code
```

---

### Risk 3: Cross-Component Inconsistencies Revealed
**Probability**: Medium | **Impact**: High

**Description**:
- Energy conservation may fail due to small mismatches between components
- Flux consistency may reveal hidden bugs in previous validation tasks
- Component interfaces may have unexpected data type mismatches

**Mitigation**:
1. **Primary**: Start with simple test cases (monoenergetic precipitation)
2. **Secondary**: Gradually increase complexity (differential flux, multiple energies)
3. **Testing**: Isolate each interface test from others
4. **Documentation**: Document any inconsistencies found with clear root cause analysis

**Testing Strategy**:
```python
# Isolated interface testing
# Test 1: calc_Edissipation → fang10_precip (energy dissipation units)
# Test 2: calc_ionization → fang10_precip (ionization rates)
# Test 3: bounce_time_arr → fang10_precip (loss factor timing)
# Test 4: get_msis_dat → calc_Edissipation (atmospheric profiles)
# Test 5: Full integration (all components together)
```

---

### Risk 4: MATLAB-Python Integration Complexity
**Probability**: Low | **Impact**: Medium

**Description**:
- Validation script is Python but tests MATLAB code
- Need to call MATLAB from Python or test MATLAB output files
- May require MATLAB Engine API for Python (adds dependency)

**Mitigation**:
1. **Primary**: Use existing pattern: Python verification scripts that validate MATLAB output files
2. **Secondary**: Generate MATLAB test data files and read them in Python
3. **Testing**: Verify file format compatibility (MATLAB .mat files vs text files)
4. **Documentation**: Document MATLAB-Python integration approach

**Integration Options**:
| Option | Complexity | Dependency | Recommendation |
|--------|------------|------------|----------------|
| MATLAB Engine for Python | High | MATLAB Runtime | ❌ Too complex |
| Python test + MATLAB data files | Low | None | ✅ RECOMMENDED |
| Separate MATLAB and Python tests | Medium | None | ⚠️ Duplicates effort |

**Recommendation**: Use **Python test + MATLAB data files** approach (same as `test_calc_ionization_validation.py`).

---

### Risk 5: Energy Conservation Error Tolerance Too Tight
**Probability**: Low | **Impact**: Low-Medium

**Description**:
- 0.001% energy conservation error is extremely tight
- Cumulative integration (trapezoidal rule) may introduce > 0.001% error
- May cause test failures due to numerical precision, not actual bugs

**Mitigation**:
1. **Primary**: Use tolerance hierarchy (ADR-3.6.0-2) - 0.001% for analytical, 0.1% for numerical
2. **Secondary**: Compare to reference solutions where available
3. **Testing**: Test multiple energy values to identify numerical vs physical errors
4. **Documentation**: Document which tests use which tolerance

**Tolerance Justification**:
| Test Type | Tolerance | Justification |
|-----------|-----------|--------------|
| Analytical energy balance | 0.001% | Direct calculation, no integration |
| Bounce loss calculation | 0.0000% | Analytical formulas (as achieved in 3.5.1) |
| Cumulative integration | 0.1% | Trapezoidal numerical integration |
| Flux conversion | 0.01% | Unit conversions and scaling |
| Derivative validation | 1.0% | Numerical derivative accuracy |

---

## 6. Dependencies

### Hard Dependencies (Required for Completion)
1. ✅ **Task 3.1.0 completed**: `calc_Edissipation.m` validated
2. ✅ **Task 3.1.1 completed**: `calc_ionization.m` validated
3. ✅ **Task 3.2.0 completed**: `bounce_time_arr.m` validated
4. ✅ **Task 3.3.0 completed**: MSIS 2.1 integration validated
5. ✅ **Task 3.5.0 completed**: `fang10_precip.m` validated
6. ✅ **MATLAB installation**: R2019b+ or compatible
7. ✅ **Python 3.x**: For validation script execution

### Soft Dependencies (Optional but Recommended)
1. ⚠️ **Reference validation data**: Energy deposition profiles from Fang 2010 Figure 1
2. ⚠️ **Existing test patterns**: `test_calc_ionization_validation.py`, `test_precipitation_loss.py`
3. ⚠️ **CONSTANT_TRACEABILITY.md**: For verifying physical constants

### External Dependencies (Out of Scope)
1. ❌ **Satellite observation data**: Not validating against real measurements
2. ❌ **Literature data beyond Fang 2010**: Not comparing to other studies
3. ❌ **Fang et al. (2010) authors**: Not contacting authors for clarification

---

## 7. Implementation Guardrails

### Acceptance Criteria Summary

**Task Complete When**:
- [ ] **Energy Conservation**: All energy conservation tests pass (error < 0.001% for analytical, < 0.1% for numerical)
- [ ] **Flux Consistency**: All flux consistency tests pass (error < 0.01%)
- [ ] **Component Interfaces**: All interface tests pass (unit consistency verified)
- [ ] **Cumulative vs Local**: Derivative relationship validated (error < 1%)
- [ ] **Boundary Conditions**: Top and bottom boundaries validated (within specified tolerances)
- [ ] **Documentation**: Validation results documented in `energy_flux_consistency_report.md`
- [ ] **Unit Mapping**: Explicit unit mapping table created and validated
- [ ] **Verification**: At least 8 test cases pass (minimum coverage)

### Sequencing
1. **Start**: Create unit mapping table (ADR-3.6.0-3)
2. **Next**: Implement TestComponentIntegration (validate interfaces first)
3. **Next**: Implement TestEnergyConservation (validate energy conservation)
4. **Next**: Implement TestFluxConsistency (validate flux calculations)
5. **Next**: Run validation suite and document results
6. **Final**: Create validation report and update documentation

### Success Metrics
- **Code Coverage**: 100% of component interfaces tested (not code coverage - this is integration testing)
- **Test Cases**: ≥ 8 validation tests (3 energy, 3 flux, 3 interface, 1 boundary)
- **Execution Time**: < 60 seconds for full validation suite (MATLAB execution may be slow)
- **Pass Rate**: 100% of test cases pass (or documented failures with rationale)
- **Energy Conservation Error**: < 0.001% for analytical tests

### Owners
- **Architecture Review**: Architecture Planner (@architect)
- **Implementation**: Developer (@developer)
- **Validation**: QA/Testing Agent (@tester)
- **Documentation**: Documentation Specialist (@docs)

---

## 8. Open Questions

### Question 1: Energy Conservation Tolerance for Cumulative Integration
**Status**: ℹ️ **DOCUMENTED IN ADR-3.6.0-2**

The task specification requires 0.001% error, but cumulative integration may introduce larger errors.

**Decision**: Use tolerance hierarchy - 0.001% for analytical tests, 0.1% for numerical integration.

**Rationale**: Trapezoidal integration is inherently less accurate than analytical calculations. The 0.1% tolerance balances numerical precision with test robustness.

---

### Question 2: Unit Conversion Factors in Code
**Status**: ⚠️ **VALIDATION REQUIRED**

The code uses keV and erg for energy, but the exact conversion factors need verification.

**Investigation Needed**:
1. Verify `Qe = j × E` formula (energy flux = number flux × energy)
2. Verify keV → erg conversion (1 keV = 1.602×10⁻⁹ erg)
3. Verify all scale heights are in cm (required by Fang equations)

**Decision**: Create unit mapping table (ADR-3.6.0-3) and verify all conversions during validation.

---

### Question 3: MATLAB-Python Integration Approach
**Status**: ℹ️ **DECISION MADE**

The validation script is Python but tests MATLAB code. Need to decide integration approach.

**Decision**: Use **Python test + MATLAB data files** approach.

**Rationale**:
- Consistent with existing test patterns (`test_calc_ionization_validation.py`)
- No MATLAB Engine API dependency
- MATLAB generates test data files, Python reads and validates them
- Clear separation of concerns (MATLAB for physics, Python for validation)

---

### Question 4: Altitude Array Direction (Top-Down vs Bottom-Up)
**Status**: ℹ️ **VALIDATION REQUIRED**

MATLAB code uses increasing altitude arrays (bottom to top: 0, 1, 2, ..., 1000 km), but cumulative integration is performed from top down.

**Investigation Needed**:
1. Verify integration direction in `calc_ionization.m` (line 38)
2. Ensure boundary conditions are correct for both directions
3. Validate that "top" and "bottom" in validation requirements match code implementation

**Decision**: Validate derivative relationship (ADR-3.6.0-4) to catch integration direction errors.

---

## 9. Recommendations

### For Implementation
1. **Create unit mapping table** before writing tests (ADR-3.6.0-3)
2. **Implement TestComponentIntegration first** (validate interfaces before physics)
3. **Use tolerance hierarchy** (different tolerances for analytical vs numerical tests)
4. **Generate MATLAB data files** for Python validation (avoid MATLAB Engine dependency)
5. **Validate derivative relationship** to catch integration direction errors

### For Documentation
1. **Update task 3.6.0.md** with:
   - Unit mapping table
   - Tolerance hierarchy
   - MATLAB-Python integration approach
   - Open questions and resolutions
2. **Create validation report** `energy_flux_consistency_report.md`:
   - Test results (pass/fail, error percentages)
   - Unit mapping verification
   - Component interface validation
   - Energy conservation metrics
   - Any inconsistencies found with root cause analysis

### For Future Work
1. **Task 3.6.1**: Energy range sweep validation (1-1000 keV)
2. **Task 3.6.2**: Pitch angle sweep validation (0-180°)
3. **Task 3.6.3**: L-shell parameter sweep (L=2-6)
4. **Task 3.6.4**: Solar/geomagnetic condition validation (F107, Ap variations)
5. **Task 3.6.5**: Comparison to observational data (satellite measurements, ground observations)

---

## 10. Summary

### Architecture Verdict: **APPROVED WITH MINOR CONDITIONS**

**Conditions**:
1. ✅ Test structure is sound (TestEnergyConservation, TestFluxConsistency, TestComponentIntegration)
2. ✅ Scope is appropriate for element-level task (200-300 LOC, 8-12 tests)
3. ✅ Cohesive and tightly coupled (splitting would create overhead)
4. ✅ Completes cross-component validation (energy, flux, interfaces, boundaries)
5. ✅ Follows existing test patterns (Python validation scripts)
6. ⚠️ **REQUIRED**: Create explicit unit mapping table (ADR-3.6.0-3)
7. ⚠️ **REQUIRED**: Document tolerance hierarchy (ADR-3.6.0-2)
8. ⚠️ **REQUIRED**: Validate derivative relationship (ADR-3.6.0-4)
9. ℹ️ **NOTE**: Use Python test + MATLAB data files approach (avoid MATLAB Engine)
10. ℹ️ **NOTE**: Document any cross-component inconsistencies found

**Key Strengths**:
- Clear separation of validation concerns (3 test classes)
- Comprehensive coverage of cross-component integration
- Conservative tolerances ensure numerical accuracy
- Consistent with existing validation patterns
- Well-defined boundary conditions and success criteria

**Key Risks**:
- Hidden unit conversion errors (mitigated by unit mapping table)
- Cross-component inconsistencies revealed (mitigated by incremental testing)
- Numerical precision at boundaries (mitigated by tolerance hierarchy)
- MATLAB-Python integration complexity (mitigated by data file approach)

**Next Steps**:
1. Create unit mapping table (ADR-3.6.0-3)
2. Implement TestComponentIntegration (validate interfaces first)
3. Implement TestEnergyConservation (validate energy conservation)
4. Implement TestFluxConsistency (validate flux calculations)
5. Run validation suite and document results
6. Update task documentation with findings
7. Address any cross-component inconsistencies discovered

---

**Document Version**: 1.0
**Date**: January 16, 2026
**Status**: APPROVED WITH MINOR CONDITIONS - Ready for scope review
**Reviewer**: Architecture Planner (@architect)
