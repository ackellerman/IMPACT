# Task 3.6.0: Validate energy and flux consistency

## Objective

Validate that energy and particle flux are consistently handled across all integrated components of the IMPACT electron precipitation model. This is a cross-component validation that ensures the fundamental conservation laws are preserved when all modules work together.

## Background

From previous validation phases, we have established:
- Energy dissipation follows Fang et al. (2010) with 8-parameter coefficient model
- Ionization rates use 0.035 keV efficiency factor
- Bounce loss fraction is calculated with relativistic corrections
- MSIS 2.1 provides atmospheric density profiles

This task validates that these components work together consistently.

## Validation Requirements

### 3.6.0.1 Energy Conservation Across Components

**Test 1: Energy Balance Validation**
```matlab
% For monoenergetic electron precipitation:
% Total energy deposited = Integral of energy dissipation
% Total ionization = Energy deposited / 0.035 keV
% Bounce loss fraction accounts for particle loss

% Validation criteria:
% 1. Energy deposition calculation matches expected physical behavior
% 2. Ionization production is consistent with energy deposition
% 3. Bounce loss properly reduces particle content without violating energy conservation
```

**Expected Behavior:**
- Energy deposited per unit flux should match Fang 2010 Figure 1
- Ionization rate should scale linearly with flux (constant energy per ionization)
- Bounce loss should reduce total ionization proportionally to loss fraction

### 3.6.0.2 Flux Consistency

**Test 2: Particle Flux Integration**
```matlab
% Input: Differential flux (particles/cm²/s/keV)
% Output: Integrated energy deposition and ionization rates
% Validation: Conservation of particle number and energy

% Key relationships:
% 1. Flux × Cross-section = Precipitation rate
% 2. Precipitation rate × Energy = Energy deposition rate
% 3. Energy deposition rate / Ionization energy = Ionization rate
```

**Test 3: Differential to Integral Conversion**
```matlab
% For energy-dependent precipitation:
% Integrate differential flux to get total flux
% Apply energy-dependent dissipation
% Sum over all energies for total effect

% Validation:
% Linear superposition holds for multiple energy components
% Integration order doesn't affect final result
```

### 3.6.0.3 Component Interface Validation

**Test 4: Module Integration Points**
```matlab
% Interface between calc_Edissipation and fang10_precip:
% - Energy dissipation [keV/cm] → Total energy deposition [erg/cm²/s]

% Interface between calc_ionization and fang10_precip:
% - Energy deposition → Ionization rate [cm⁻³/s]

% Interface between bounce_time_arr and fang10_precip:
% - Bounce period → Loss fraction calculation

% Validation: Units consistent, no double-counting, no missing terms
```

**Test 5: Cumulative vs Local Quantities**
```matlab
% Local quantities: Energy dissipation at altitude z
% Cumulative quantities: Total energy deposited above z

% Validation:
% Local derivative of cumulative = Local value
% Cumulative at top = 0
% Cumulative at bottom = Total energy deposited
% Consistent with MSIS density weighting
```

### 3.6.0.4 Boundary Condition Consistency

**Test 6: Top Boundary (500 km)**
```matlab
% At 500 km:
% Cumulative quantities = 0
% Local quantities = Full precipitation effect
% MSIS density → Small but non-zero
```

**Test 7: Bottom Boundary (Ground/80 km)**
```matlab
% At ground (or 80 km cutoff):
% Cumulative quantities = Total integrated value
% Local quantities = Small (most energy deposited above)
% MSIS density → Maximum at ground, minimum at altitude
```

## Implementation Validation Tests

### Test Suite Structure

```python
# test_energy_flux_consistency.py
class TestEnergyConservation:
    """Validate energy conservation across components"""
    
    def test_monoenergetic_energy_balance(self):
        """Test energy balance for monoenergetic precipitation"""
        # Input: 10 keV electrons, 10⁶ particles/cm²/s
        # Expected: Energy deposition matches Fang 2010 analytical
        pass
    
    def test_differential_flux_integration(self):
        """Test integration over energy spectrum"""
        # Input: Power-law differential flux
        # Expected: Linear superposition holds
        pass
    
    def test_ionization_energy_relationship(self):
        """Test 0.035 keV efficiency factor"""
        # Input: Known energy deposition
        # Expected: Ionization rate = Energy / 0.035 keV
        pass
    
    def test_bounce_loss_consistency(self):
        """Test bounce loss doesn't violate energy conservation"""
        # Input: Precipitation with bounce period
        # Expected: Energy conserved, particle number reduced
        pass

class TestFluxConsistency:
    """Validate flux calculations are consistent"""
    
    def test_flux_to_ionization_mapping(self):
        """Test flux → ionization conversion"""
        pass
    
    def test_differential_to_total_flux(self):
        """Test differential to integral flux conversion"""
        pass
    
    def test_energy_weighted_flux(self):
        """Test energy-weighted flux calculations"""
        pass

class TestComponentIntegration:
    """Validate module interfaces work correctly"""
    
    def test_eddissipation_interface(self):
        """Test calc_Edissipation → fang10_precip interface"""
        pass
    
    def test_ionization_interface(self):
        """Test calc_ionization → fang10_precip interface"""
        pass
    
    def test_bounce_interface(self):
        """Test bounce_time_arr → fang10_precip interface"""
        pass
    
    def test_msis_interface(self):
        """Test get_msis_dat → precipitation physics interface"""
        pass
```

### Validation Criteria

**Energy Conservation:**
- Energy deposited should equal input energy minus reflected energy
- 0.0000% error (as achieved in Task 3.5.1 for loss calculation)
- All energy deposited should be accounted for in ionization

**Flux Consistency:**
- Particle flux should be conserved where appropriate
- Where flux is lost (bounce), energy should be properly redistributed
- No artificial sources or sinks of particles/energy

**Component Integration:**
- All module interfaces should pass consistent units
- No data type mismatches between single/double precision
- No missing parameters or incorrect assumptions

## Verification Command

```bash
cd /work/projects/IMPACT/IMPACT_MATLAB
python3 /work/projects/IMPACT/test_energy_flux_consistency.py --verbose --output=validation_report_3.6.0.md
```

**Expected Output:**
- Test results with pass/fail for each validation
- Energy conservation error (target: < 0.001%)
- Flux consistency metrics
- Component interface validation results

**Success Criteria:**
- All energy conservation tests pass
- All flux consistency tests pass
- All component interface tests pass
- Energy conservation error < 0.001%

## Dependencies

- Requires: Task 3.5.0 (fang10_precip.m validation)
- Requires: Task 3.1.0 (calc_Edissipation.m validation)
- Requires: Task 3.1.1 (calc_ionization.m validation)
- Requires: Task 3.2.0 (bounce_time_arr.m validation)
- Uses: MSIS 2.1 validation results from Task 3.3.0

## Estimated Effort

- Implementation: 3-4 iterations
- Test cases: 8-12 validation tests
- Files modified: 1-2 (test scripts only)
- LOC: ~200-300 lines of test code

## Risk Assessment

**Low Risk:** This is a validation task with no production code changes. Tests only.

**Potential Issues:**
- Numerical precision at boundaries may cause small errors
- Complex interactions may reveal edge cases not covered in individual module tests

**Mitigation:**
- Use relative error tolerances appropriate to expected precision
- Document any edge cases discovered for future reference

## Documentation Requirements

- Update `VALIDATION_SUMMARY.md` with cross-component results
- Document any inconsistencies found between components
- Update `CONSTANT_TRACEABILITY.md` if new constants are discovered
- Create `energy_flux_consistency_report.md` with detailed results

## Review Checklist

- [ ] Energy conservation validated across all energy ranges
- [ ] Flux consistency verified for differential and integral fluxes
- [ ] Component interfaces tested and documented
- [ ] Boundary conditions properly handled
- [ ] All tests pass with acceptable error tolerances
- [ ] Documentation updated with findings
