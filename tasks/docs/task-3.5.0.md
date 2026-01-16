# Task 3.5.0: Validate precipitation loss calculation (fang10_precip.m)

**Status**: planned
**Type**: Validation
**Component**: `fang10_precip.m`

## Scope

This task validates the core integration logic in `fang10_precip.m` that combines all previous components (energy dissipation, ionization, bounce period, mirror altitude, MSIS data) into the full precipitation model.

### Objectives
1. Validate loss factor calculation (lines 96-102)
2. Validate time evolution integration (lines 114-120)
3. Validate boundary conditions (lines 84-90)
4. Verify integration with validated components (3.1-3.4)
5. Test energy conservation
6. Validate loss cone physics

## Validation Approach

### Tier 1: Static Validation
- Verify loss factor formula matches Fang 2010 derivation
- Check time evolution differential equation structure
- Validate boundary condition implementation
- Verify factor of 2 in time evolution (accounting for two hemispheres per bounce)

### Tier 2: Unit Consistency
- Verify `lossfactor` is dimensionless and bounded [0, 1]
- Check `dQedt` has correct units (flux/time)
- Validate unit conversions across the integration layer

### Tier 3: Numerical Stability
- Test explicit Euler convergence with varying time steps
- Verify no oscillations in `Qe(t)` for all test cases
- Check stability criterion: `dt < t_b / (2 * lossfactor)`
- Confirm negative value clamping works correctly

### Tier 4: Physical Consistency
- Validate energy conservation: `|E_lost - E_deposited| / E_initial < 1%`
- Test boundary cases:
  - `mirr_alt > 1000 km` → `lossfactor = 0` (no loss)
  - `mirr_alt <= 0 km` → `lossfactor = 1` (complete loss)
- Verify loss cone physics: mirror altitude ≈ 1000 km matches dipole loss cone angle
- Confirm loss factor increases monotonically as mirror altitude decreases

## Acceptance Criteria

**MUST** (all required):
- [ ] Loss factor formula validated against physical interpretation (fraction of total ionization)
- [ ] Time evolution differential equation verified
- [ ] Boundary conditions tested (mirror < 0, > 1000, NaN)
- [ ] Unit consistency verified
- [ ] Numerical stability confirmed
- [ ] Energy conservation tested (error < 1%)
- [ ] Loss cone physics validated (dipole approximation)

**SHOULD** (recommended):
- [ ] Time stepping convergence tested
- [ ] Stability criterion documented in code
- [ ] Loss factor interpretation documented in code

## Test Cases

### Test 1: Loss Factor Boundary Cases
- No loss (mirror > 1000 km): `lossfactor = 0`
- Complete loss (mirror < 0 km): `lossfactor = 1`
- Partial loss (mirror = 300 km): `0 < lossfactor < 1`

### Test 2: Time Evolution Convergence
- Run with `dt = [1e-8, 1e-6, 1e-4]` s
- Verify solution converges as `dt → 0`
- Check for monotonic decrease in flux (no oscillations)

### Test 3: Energy Conservation
- Calculate energy lost from particle population
- Calculate energy deposited in atmosphere
- Verify `E_lost = E_deposited` (within 1%)

### Test 4: Loss Cone Physics
- Verify mirror altitude ≈ 1000 km matches dipole loss cone angle `α_LC = arcsin(√(1/L³))`

## Deliverables

1. **Validation Script** (`test_precipitation_loss.m`)
   - Four-tier validation tests
   - Boundary case tests
   - Energy conservation tests
   - Loss cone physics validation

2. **Validation Report** (`validation_report_3.5.0.md`)
   - Tier 1-4 results
   - Loss factor interpretation
   - Known limitations (dipole-only loss cone, explicit Euler stability)

3. **Code Documentation Updates**
   - Add inline comments explaining loss factor calculation
   - Document stability criterion for dt
   - Add note on loss cone physics limitations
