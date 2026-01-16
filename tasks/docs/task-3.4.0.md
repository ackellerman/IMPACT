# Task 3.4.0: Validate Physical Constants and Unit Conversions

**Status**: Architecture Review Complete - Ready for Scope Review
**Reviewer**: Architecture Planner
**Review Date**: January 16, 2026
**Architecture Decision**: APPROVED with clarifications

---

## Executive Summary

Cross-cutting validation task to audit all physical constants and unit conversions in the IMPACT precipitation model. Architecture approved with clarifications on tolerance specifications and scope boundaries.

---

## Task Scope

### Objectives
1. Verify consistency of constants across all files (e.g., R_E variations)
2. Validate unit conversion factors (eV↔keV↔MeV↔J, density, distance)
3. Check for hardcoded "magic numbers" vs named constants
4. Confirm dimensional homogeneity in key equations

### Foundation Available
- CONSTANT_TRACEABILITY.md: 45 constants documented, 87% traced
- Previous validation reports: Tasks 3.1.0, 3.2.0, 3.3.0

---

## Architecture Review Outcomes

### Approval Status: ✅ APPROVED with Clarifications

**Approvals**:
- Cross-cutting validation approach is correct
- Tolerance-based constant handling is appropriate
- Separation of validation vs refactoring is necessary

**Required Clarifications** (from architecture review):

#### 1. Tolerance Specifications

| Constant Type | Standard Value | Acceptable Range | Rationale |
|---------------|----------------|-----------------|-----------|
| Fundamental constants (c, mc², k_B) | CODATA 2018 | ±0.1% | International standards |
| Geodetic constants (R_E) | IAU 2015: 6371 km | 6370-6378 km | Depends on context (equatorial vs polar) |
| Model-specific constants (0.035 keV) | Literature value | Exact match | No tolerance—empirical parameters |
| Fitted coefficients (Pij, T_pa) | Source table | ±1e-5 | Numerical precision |

#### 2. Scope Boundary

**Task 3.4.0 (Current)**:
- Validation audit only - identify issues, report findings
- Produce documentation (validation report, usage matrix, risk assessment)
- **NO code modifications or refactoring in this task**

**Future Task** (3.4.1 or 3.5.0):
- Implement centralized constants file based on findings
- Refactor all files to use centralized constants

#### 3. High-Priority Findings

From architecture review, these require special attention:

| Priority | Finding | Severity | Action |
|----------|---------|----------|--------|
| 1 | R_E consistency across all files | High | Verify 6371 ± 1 km or document context |
| 2 | Unit conversion factors (J↔eV, g/cm³↔kg/m³) | High | Verify 1.602e-19 and 1.66e-27 factors |
| 3 | T_pa coefficients not traced | Medium | Document as open question |

---

## Architecture Decisions

### Decision 1: Earth Radius Handling

**Observation**: R_E appears as:
- 6371 km in `bounce_time_arr.m:41`, `get_msis_dat.m:172`, test files
- 6.371e6 m in bounce calculations
- Potential for 6371.2 km or 6378 km in future

**Decision**:
- Standardize on R_E = 6371 km (IAU mean radius)
- Accept 6371 ± 1 km as "consistent"
- Require explicit comment if using equatorial (6378 km) or polar (6357 km)

### Decision 2: Magic Number Threshold

**Definition**:
- **Magic number**: Numeric literal appearing < 5 times, not documented as constant
- **Named constant**: Literal appearing ≥ 5 times or documented as model parameter

**Action**:
- Scan all files for numeric literals
- Cross-reference with CONSTANT_TRACEABILITY.md
- Flag literals not in documented constants

### Decision 3: Unit Conversion Risk Prioritization

**High Priority**:
1. Density: particles/cm³ ↔ kg/m³ (requires AMU conversion 1.66e-27 kg)
2. Energy: J ↔ eV (requires factor 1.602e-19)
3. Distance: implicit km↔m in L-shell calculations

**Detection Strategy**:
- Search for explicit conversion factors
- Verify units are documented in function comments
- Test dimensional homogeneity in key equations

---

## Acceptance Criteria

**MUST (all required)**:
- [ ] All physical constants verified against CODATA 2018 or IAU 2015 standards
- [ ] Unit conversion factors validated (energy, distance, density)
- [ ] R_E consistency verified: 6371 km ± 1 km tolerance acceptable
- [ ] Magic numbers identified: All occurrences of < 5 occurrences flagged
- [ ] Dimensional homogeneity verified for 4-5 key equations
- [ ] Validation report produced with severity ratings

**SHOULD (recommended)**:
- [ ] Cross-file consistency matrix showing constant usage
- [ ] T_pa coefficients documented as open question
- [ ] Prioritized refactoring recommendations

---

## Deliverables

1. **Validation Report** (`validation_report_3.4.0.md`):
   - Physical constants audit (all 8 constants)
   - Unit conversion verification
   - Cross-file consistency matrix
   - Magic number inventory
   - Dimensional analysis results

2. **Constant Usage Map** (`constant_usage_matrix.md`):
   - File × constant matrix
   - Consistency violations highlighted

3. **Unit Conversion Risk Assessment** (`unit_conversion_risks.md`):
   - High-priority conversion risks
   - Detection test results

4. **Refactoring Recommendations** (`refactoring_recommendations.md`):
   - Prioritized list for future implementation task

---

## References

- Architecture Review: `tasks/docs/architecture-review-3.4.0.md`
- CONSTANT_TRACEABILITY.md: `tasks/docs/CONSTANT_TRACEABILITY.md`
- Previous validations: 3.1.0, 3.2.0, 3.3.0 reports
