# Phase 2.5: Integration and Validation

## Overview
Test integration between Fortran NRLMSIS 2.1 model and MATLAB analysis scripts, verify numerical accuracy across different compiler configurations, and validate against reference data from the original implementation.

## Scope

### Integration Components
- **Fortran to MATLAB Data Flow**: Output files, array formats, coordinate systems
- **Compiler Variations**: Different optimization levels, precision modes, warning flags
- **Reference Validation**: Comparison with original NRLMSIS 2.1 outputs

## Element 2.5.0: Test compilation with different compiler flags

### Objective
Ensure Fortran code compiles correctly with various compiler configurations and produces consistent, accurate results.

### Deliverables
1. **Compilation Test Suite**
   - Test matrix of compiler flag combinations
   - Build time comparisons
   - Accuracy comparisons across configurations

2. **Compiler Compatibility Report**
   - Document tested compiler versions
   - Identify flag variations that affect accuracy
   - Recommend production compiler settings

### Test Matrix

#### Optimization Levels
- [ ] **-O0**: No optimization (for debugging)
- [ ] **-O1**: Basic optimization
- [ ] **-O2**: Recommended optimization (default)
- [ ] **-O3**: Aggressive optimization (production)

#### Precision Modes
- [ ] **Single precision** (default): -cpp without -DDBLE
- [ ] **Double precision**: -cpp -DDBLE

#### Warning Flags
- [ ] **-Wall**: Enable all warnings
- [ ] **-Wextra**: Enable extra warnings
- [ ] **-fcheck=all**: Runtime checks (bounds, array conformance)
- [ ] **-ffpe-trap=invalid,zero,overflow**: Floating-point exception trapping

#### Target Architectures
- [ ] **x86_64** (default)
- [ ] **-march=native**: Native architecture optimizations
- [ ] **-mfpmath=sse**: SSE floating-point math

### Verification Commands

```bash
# Test 1: Single precision, various optimizations
cd /work/projects/IMPACT/nrlmsis2.1

for OPT in O0 O1 O2 O3; do
  echo "Testing with -$OPT..."
  gfortran -$OPT -cpp -o msis_test_sp_$OPT.exe msis_constants.F90 msis_utils.F90 \
    msis_init.F90 msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90 \
    msis_gtd8d.F90 msis2.1_test.F90
  ./msis_test_sp_$OPT.exe < msis2.1_test_in.txt > msis_test_out_sp_$OPT.txt
done

# Test 2: Double precision, various optimizations
for OPT in O0 O1 O2 O3; do
  echo "Testing with -$OPT double precision..."
  gfortran -$OPT -cpp -DDBLE -o msis_test_dp_$OPT.exe msis_constants.F90 msis_utils.F90 \
    msis_init.F90 msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90 \
    msis_gtd8d.F90 msis2.1_test.F90
  ./msis_test_dp_$OPT.exe < msis2.1_test_in.txt > msis_test_out_dp_$OPT.txt
done

# Test 3: Runtime checks (debugging)
gfortran -O0 -cpp -DDBLE -fcheck=all -ffpe-trap=invalid,zero,overflow \
  -o msis_test_debug.exe msis_constants.F90 msis_utils.F90 \
  msis_init.F90 msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90 \
  msis_gtd8d.F90 msis2.1_test.F90
./msis_test_debug.exe < msis2.1_test_in.txt > msis_test_out_debug.txt
```

### Success Criteria
- All compiler flag combinations compile without errors
- No runtime errors or floating-point exceptions
- Results consistent across optimization levels (within rounding)
- Double precision results match reference (tolerance 1e-6)
- Single precision results physically reasonable (tolerance 1e-4)

### Accuracy Comparison

```bash
# Compare outputs across optimization levels
for OPT in O0 O1 O2 O3; do
  echo "Comparing O2 with -$OPT..."
  diff -u msis_test_out_dp_O2.txt msis_test_out_dp_$OPT.txt | head -50
done

# Compare with reference
diff -u msis2.1_test_ref_dp.txt msis_test_out_dp_O2.txt
```

## Element 2.5.1: Verify test execution against reference outputs

### Objective
Compare NRLMSIS 2.1 test outputs with reference data from the original implementation to verify numerical accuracy.

### Deliverables
1. **Reference Comparison Report**
   - Detailed diff analysis
   - Numerical tolerance assessment
   - Identified discrepancies with root cause analysis

2. **Accuracy Validation**
   - Quantify maximum absolute errors
   - Quantify maximum relative errors
   - Identify species with largest deviations

### Reference Data Sources
- `nrlmsis2.1/msis2.1_test_ref_dp.txt` - Reference outputs (double precision)
- `nrlmsis2.1/original_MSIScodes/msis2.1_test_ref_dp.txt` - Original reference
- `nrlmsis2.1/msis2.1_test_out.txt` - Current implementation output

### Verification Commands

```bash
# Primary comparison: Current vs. Reference
cd /work/projects/IMPACT/nrlmsis2.1

# Recompile with double precision (required for reference match)
gfortran -O3 -cpp -DDBLE -o msis2.1_test.exe msis_constants.F90 msis_utils.F90 \
  msis_init.F90 msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90 \
  msis_gtd8d.F90 msis2.1_test.F90

# Run test
./msis2.1_test.exe < msis2.1_test_in.txt > msis2.1_test_out.txt

# Compare with reference
echo "=== Comparison with reference ==="
diff -u msis2.1_test_ref_dp.txt msis2.1_test_out.txt | head -100

# Numeric comparison (ignore sign, whitespace)
echo "=== Line-by-line numeric comparison ==="
paste msis2.1_test_ref_dp.txt msis2.1_test_out.txt | awk '{diff=$1-$2; if(diff!=0) print NR, $1, $2, diff}'

# Calculate statistics on deviations
echo "=== Statistics ==="
paste msis2.1_test_ref_dp.txt msis2.1_test_out.txt | awk '{
  diff=$1-$2
  rel=diff/$1
  if(diff>0) {pos++} else if(diff<0) {neg++} else {same++}
  max_abs=sqrt(diff*diff) > max_abs ? sqrt(diff*diff) : max_abs
  max_rel=sqrt(rel*rel) > max_rel ? sqrt(rel*rel) : max_rel
  sum_sq += diff*diff
  n++
}
END {
  print "Lines compared:", n
  print "Same:", same, "Positive diff:", pos, "Negative diff:", neg
  print "Max absolute error:", max_abs
  print "Max relative error:", max_rel
  print "RMS error:", sqrt(sum_sq/n)
}'
```

### Success Criteria
- All values match reference within tolerance (1e-6 for double precision)
- No systematic biases identified
- Random errors attributable to floating-point rounding
- No missing or extra output lines
- Output format identical to reference

### Tolerance Guidelines

| Quantity | Absolute Tolerance | Relative Tolerance | Notes |
|----------|-------------------|-------------------|-------|
| Temperatures (K) | 1e-3 | 1e-6 | Double precision reference |
| Densities (cm-3) | 1e-2 | 1e-6 | Scale with magnitude |
| Altitudes (km) | 1e-6 | N/A | Exact match expected |
| Indices (F10.7, Ap) | 1e-3 | N/A | Should be exact |

## Element 2.5.2: Test end-to-end workflows

### Objective
Create integration tests that run complete workflows from Fortran model output through MATLAB analysis scripts to verify data flow, format compatibility, and computational consistency.

### Deliverables
1. **End-to-End Test Suite**
   - Complete workflow scripts
   - Data validation at each stage
   - Performance metrics

2. **Workflow Documentation**
   - Step-by-step procedures
   - Intermediate data formats
   - Troubleshooting guide

### Workflow Scenarios

#### Workflow 1: Basic MSIS Calculation + Visualization
1. Run NRLMSIS 2.1 with standard inputs
2. Parse output with MATLAB get_msis_dat.m
3. Create altitude profiles
4. Generate plots and visualizations

#### Workflow 2: Energy Deposition Analysis
1. Generate MSIS atmosphere profiles
2. Calculate energy dissipation using calc_Edissipation.m
3. Compute ionization rates using calc_ionization.m
4. Analyze altitude dependence

#### Workflow 3: Precipitation Event Analysis
1. Create atmospheric profiles for various geomagnetic conditions
2. Run Fang 2010 precipitation model (fang10_precip.m)
3. Calculate loss cone angles (dip_losscone.m)
4. Compute bounce times (bounce_time_arr.m)
5. Analyze energy-dependent transport

### Verification Commands

```bash
# Workflow 1: Basic MSIS Calculation
cd /work/projects/IMPACT/nrlmsis2.1

# Step 1: Run MSIS model
./msis2.1_test.exe < msis2.1_test_in.txt > workflow1_output.txt

# Step 2: MATLAB processing
cd ../IMPACT_MATLAB
matlab -batch "
  % Parse MSIS output
  data = get_msis_dat('../nrlmsis2.1/workflow1_output.txt');

  % Validate data structure
  assert(isfield(data, 'altitude'));
  assert(isfield(data, 'temperature'));
  assert(isfield(data, 'density'));

  % Create visualization
  figure;
  subplot(2,1,1);
  plot(data.altitude, data.temperature);
  xlabel('Altitude (km)');
  ylabel('Temperature (K)');
  title('MSIS Temperature Profile');

  subplot(2,1,2);
  semilogy(data.altitude, data.density);
  xlabel('Altitude (km)');
  ylabel('Density (cm^-3)');
  title('MSIS Density Profiles');

  saveas(gcf, '../nrlmsis2.1/workflow1_plots.png');

  disp('Workflow 1 completed successfully');
  exit;
"

# Validate outputs
ls -lh ../nrlmsis2.1/workflow1_plots.png
```

```bash
# Workflow 2: Energy Deposition Analysis
cd /work/projects/IMPACT/IMPACT_MATLAB

matlab -batch "
  % Load atmosphere
  data = get_msis_dat('../nrlmsis2.1/msisoutputs.txt');

  % Calculate energy dissipation (example: 10 keV precipitation)
  energy = 10e3; % eV
  pitch_angle = 45; % degrees
  Ediss = calc_Edissipation(data.altitude, energy, pitch_angle, data.density);

  % Calculate ionization
  ionization = calc_ionization(data.density, Ediss);

  % Validate results
  assert(all(Ediss >= 0), 'Energy dissipation must be non-negative');
  assert(all(ionization >= 0), 'Ionization must be non-negative');

  % Save results
  save('../nrlmsis2.1/workflow2_results.mat', 'data', 'Ediss', 'ionization');

  fprintf('Max energy dissipation: %.2e eV/cm3\n', max(Ediss));
  fprintf('Max ionization rate: %.2e cm-3/s\n', max(ionization));

  disp('Workflow 2 completed successfully');
  exit;
"

# Verify output file
ls -lh ../nrlmsis2.1/workflow2_results.mat
```

### Success Criteria
- All workflows execute without errors
- Data structures validated at each step
- Output files created correctly
- Physical quantities within reasonable ranges
- No data corruption in Fortran-MATLAB transfer
- Results reproducible across multiple runs

### Format Compatibility Checks
- [ ] Fortran output file format matches MATLAB parser expectations
- [ ] Array dimensions consistent (N_altitude × N_species)
- [ ] Coordinate systems match (altitude, latitude, longitude)
- [ ] Units consistent across components
- [ ] No truncation or rounding issues in data transfer

## Integration Test Summary

```bash
# Master test script: Run all integration tests
cd /work/projects/IMPACT

echo "=== Running Integration Test Suite ==="
echo ""

echo "Test 1: Compiler flag variations..."
./nrlmsis2.1/run_compiler_tests.sh
echo ""

echo "Test 2: Reference validation..."
./nrlmsis2.1/validate_reference.sh
echo ""

echo "Test 3: End-to-end workflows..."
./IMPACT_MATLAB/run_workflow_tests.sh
echo ""

echo "=== Integration Test Suite Complete ==="
```

## Dependencies
- gfortran compiler (various versions if possible)
- MATLAB with access to IMPACT_MATLAB scripts
- Reference data files
- Sufficient memory for large test matrices

## Risks and Issues
- Floating-point precision differences across compilers
- Reference data tied to specific compiler version
- MATLAB path configuration issues
- File permission issues in cross-component workflows

## References
- NRLMSIS 2.1 Model Documentation
- Fortran 90 Compiler Reference Manual
- MATLAB External Interfaces Documentation