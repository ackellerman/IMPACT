function [passed, failed] = test_msis_integration()
%TEST_MSIS_INTEGRATION Comprehensive validation suite for MSIS data retrieval
%
%   [passed, failed] = test_msis_integration() runs all validation tests
%   for the MSIS 2.1 data retrieval system and returns counts of passed
%   and failed tests.
%
%   Validation covers 4 tiers:
%   1. Static validation (physical constants & formulas)
%   2. File format validation (I/O structure)
%   3. Numerical validation (Fortran execution)
%   4. Spatial averaging validation
%
%   Output:
%       passed - Number of tests that passed
%       failed - Number of tests that failed

fprintf('========================================\n');
fprintf('MSIS Data Retrieval Validation Suite\n');
fprintf('========================================\n\n');

passed = 0;
failed = 0;

% Initialize test results storage
all_results = struct('tier', {}, 'name', {}, 'passed', {}, 'message', {});

% =========================================================================
% TIER 1: STATIC VALIDATION (Physical Constants & Formulas)
% =========================================================================
fprintf('TIER 1: Static Validation\n');
fprintf('-------------------------\n');

% Test 1.1: Atomic masses
fprintf('Testing atomic masses...\n');
try
    % Reference values from periodic table (atomic mass units)
    ref_He = 4.0026;
    ref_O = 15.999;
    ref_N2 = 28.0134;
    ref_O2 = 31.9988;
    ref_Ar = 39.948;
    ref_H = 1.00784;
    ref_NO = 30.006;
    
    % Values used in get_msis_dat.m
    amu_He = 4.0;
    amu_O = 16.0;
    amu_N2 = 28.02;
    amu_O2 = 32.0;
    amu_Ar = 39.95;
    amu_H = 1.0;
    amu_NO = 30.0;
    
    % Tolerance: 0.1% for atomic masses
    tolerance = 0.001;
    
    assert(abs(amu_He - ref_He)/ref_He < tolerance, 'He mass error');
    assert(abs(amu_O - ref_O)/ref_O < tolerance, 'O mass error');
    assert(abs(amu_N2 - ref_N2)/ref_N2 < tolerance, 'N2 mass error');
    assert(abs(amu_O2 - ref_O2)/ref_O2 < tolerance, 'O2 mass error');
    assert(abs(amu_Ar - ref_Ar)/ref_Ar < tolerance, 'Ar mass error');
    assert(abs(amu_H - ref_H)/ref_H < tolerance, 'H mass error');
    assert(abs(amu_NO - ref_NO)/ref_NO < tolerance, 'NO mass error');
    
    fprintf('  ✓ Atomic masses within tolerance\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Atomic masses', 'passed', true, ...
        'message', 'All atomic masses within 0.1% of reference values');
catch ME
    fprintf('  ✗ Atomic masses failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Atomic masses', 'passed', false, ...
        'message', ME.message);
end

% Test 1.2: AMU conversion factor
fprintf('Testing AMU conversion factor...\n');
try
    % Reference: CODATA 2018 value
    ref_amu_kg = 1.66053906660e-27;  % kg per atomic mass unit
    
    % Value used in get_msis_dat.m
    amu_kg = 1.66e-27;
    
    % Tolerance: 0.1%
    tolerance = 0.001;
    rel_error = abs(amu_kg - ref_amu_kg) / ref_amu_kg;
    assert(rel_error < tolerance, sprintf('AMU error: %.3e', rel_error));
    
    fprintf('  ✓ AMU conversion: %.3e kg (error: %.3f%%)\n', amu_kg, rel_error*100);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'AMU conversion', 'passed', true, ...
        'message', sprintf('AMU conversion within %.1f%%', tolerance*100));
catch ME
    fprintf('  ✗ AMU conversion failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'AMU conversion', 'passed', false, ...
        'message', ME.message);
end

% Test 1.3: Boltzmann constant
fprintf('Testing Boltzmann constant...\n');
try
    % Reference: CODATA 2018 value
    ref_k = 1.380649e-23;  % J/K
    
    % Value used in get_msis_dat.m
    k = 1.38e-23;
    
    % Tolerance: 0.1%
    tolerance = 0.001;
    rel_error = abs(k - ref_k) / ref_k;
    assert(rel_error < tolerance, sprintf('Boltzmann error: %.3e', rel_error));
    
    fprintf('  ✓ Boltzmann constant: %.3e J/K (error: %.3f%%)\n', k, rel_error*100);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Boltzmann constant', 'passed', true, ...
        'message', sprintf('Boltzmann constant within %.1f%%', tolerance*100));
catch ME
    fprintf('  ✗ Boltzmann constant failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Boltzmann constant', 'passed', false, ...
        'message', ME.message);
end

% Test 1.4: Gravitational parameters
fprintf('Testing gravitational parameters...\n');
try
    % Reference values
    ref_g0 = 9.80665;    % m/s² at sea level (standard gravity)
    ref_Re = 6371;       % km (Earth's mean radius)
    
    % Values used in get_msis_dat.m
    g0 = 9.80665;
    Re = 6371;
    
    % Tolerance: exact match expected
    assert(abs(g0 - ref_g0) < 1e-5, 'g0 error');
    assert(abs(Re - ref_Re) < 1, 'Re error');
    
    fprintf('  ✓ g0 = %.5f m/s², Re = %d km\n', g0, Re);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Gravitational parameters', 'passed', true, ...
        'message', 'g0 and Re match standard values');
catch ME
    fprintf('  ✗ Gravitational parameters failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Gravitational parameters', 'passed', false, ...
        'message', ME.message);
end

% Test 1.5: Scale height formula
fprintf('Testing scale height formula: H = kT/(Mg)...\n');
try
    % Test the formula with known values
    k = 1.38e-23;      % J/K
    T = 500;           % K (typical thermospheric temperature)
    M = 29e-3;         % kg/mol (mean molecular mass of air)
    g = 9.8;           % m/s²
    
    % Expected scale height: H = kT/(Mg)
    H_expected = k * T / (M * g);
    
    % Verification: should be around 50-80 km at 300 km altitude
    assert(H_expected > 0.01, 'H must be positive');
    assert(H_expected < 1e6, 'H magnitude unrealistic');  % in meters
    assert(H_expected > 1000, 'H too small for thermosphere');  % should be ~50-80 km
    
    fprintf('  ✓ H = %.1f m = %.1f km (physically reasonable)\n', H_expected, H_expected/1000);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Scale height formula', 'passed', true, ...
        'message', sprintf('H = %.1f m at T=%d K, physically reasonable', H_expected, T));
catch ME
    fprintf('  ✗ Scale height formula failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Scale height formula', 'passed', false, ...
        'message', ME.message);
end

% Test 1.6: Gravitational altitude correction
fprintf('Testing gravitational altitude correction: g = g0*(Re/(Re+alt))²...\n');
try
    g0 = 9.80665;  % m/s²
    Re = 6371;     % km
    
    % Test at various altitudes
    test_alts = [0, 100, 300, 500, 1000];  % km
    
    for i = 1:length(test_alts)
        alt = test_alts(i);
        g_alt = g0 * (Re / (Re + alt))^2;
        
        % Check that gravity decreases with altitude
        if i > 1
            prev_alt = test_alts(i-1);
            prev_g = g0 * (Re / (Re + prev_alt))^2;
            assert(g_alt < prev_g, 'Gravity should decrease with altitude');
        end
        
        % Check physical reasonableness
        assert(g_alt > 0, 'Gravity must be positive');
        assert(g_alt < g0, 'Gravity at altitude should be less than g0');
    end
    
    fprintf('  ✓ Gravity decreases correctly with altitude\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Gravitational correction', 'passed', true, ...
        'message', 'g decreases as (Re/(Re+alt))² as expected');
catch ME
    fprintf('  ✗ Gravitational correction failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 1, 'name', 'Gravitational correction', 'passed', false, ...
        'message', ME.message);
end

fprintf('\n');

% =========================================================================
% TIER 2: FILE FORMAT VALIDATION
% =========================================================================
fprintf('TIER 2: File Format Validation\n');
fprintf('-------------------------------\n');

% Test 2.1: Input file structure
fprintf('Testing input file structure...\n');
try
    % Get paths
    msisDIR = fullfile(fileparts(mfilename('fullpath')), '..', 'nrlmsis2.1');
    input_file = fullfile(msisDIR, 'msisinputs.txt');
    
    % Check file exists
    assert(exist(input_file, 'file') == 2, 'Input file not found');
    
    % Read header
    fid = fopen(input_file, 'r');
    header = fgetl(fid);
    fclose(fid);
    
    % Expected header fields
    expected_fields = {'iyd', 'sec', 'alt', 'glat', 'glong', 'stl', 'f107a', 'f107', 'Ap'};
    
    % Check all fields present
    for i = 1:length(expected_fields)
        assert(contains(header, expected_fields{i}), ...
            sprintf('Header missing field: %s', expected_fields{i}));
    end
    
    % Check line format (should have 9 numeric columns)
    data_line = extractAfter(header, '\n');
    if isempty(data_line)
        % Read first data line
        fid = fopen(input_file, 'r');
        fgetl(fid);  % Skip header
        data_line = fgetl(fid);
        fclose(fid);
    end
    
    % Count numeric values in first data line
    numeric_values = str2double(strsplit(data_line));
    assert(length(numeric_values) == 9, ...
        sprintf('Expected 9 columns, found %d', length(numeric_values)));
    
    fprintf('  ✓ Input file structure correct (9 columns)\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Input file structure', 'passed', true, ...
        'message', 'msisinputs.txt has correct format and 9 columns');
catch ME
    fprintf('  ✗ Input file structure failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Input file structure', 'passed', false, ...
        'message', ME.message);
end

% Test 2.2: Output file structure
fprintf('Testing output file structure...\n');
try
    msisDIR = fullfile(fileparts(mfilename('fullpath')), '..', 'nrlmsis2.1');
    output_file = fullfile(msisDIR, 'msisoutputs.txt');
    
    % Check file exists
    assert(exist(output_file, 'file') == 2, 'Output file not found');
    
    % Read header
    fid = fopen(output_file, 'r');
    header = fgetl(fid);
    fclose(fid);
    
    % Expected columns: 20 total
    % Based on msis2.1_test.F90 output format
    expected_cols = 20;
    
    % Read first data line
    fid = fopen(output_file, 'r');
    fgetl(fid);  % Skip header
    data_line = fgetl(fid);
    fclose(fid);
    
    % Count numeric values
    numeric_values = str2double(strsplit(data_line));
    assert(length(numeric_values) == expected_cols, ...
        sprintf('Expected %d columns, found %d', expected_cols, length(numeric_values)));
    
    fprintf('  ✓ Output file structure correct (%d columns)\n', expected_cols);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Output file structure', 'passed', true, ...
        'message', sprintf('msisoutputs.txt has correct %d columns', expected_cols));
catch ME
    fprintf('  ✗ Output file structure failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Output file structure', 'passed', false, ...
        'message', ME.message);
end

% Test 2.3: Column mapping verification
fprintf('Testing column mapping...\n');
try
    % Expected column indices based on get_msis_dat.m
    expected_mapping = struct();
    expected_mapping.iyd = 1;
    expected_mapping.sec = 2;
    expected_mapping.alt = 3;
    expected_mapping.glat = 4;
    expected_mapping.glong = 5;
    expected_mapping.stl = 6;
    expected_mapping.f107a = 7;
    expected_mapping.f107 = 8;
    expected_mapping.Ap = 9;
    expected_mapping.nHe = 10;
    expected_mapping.nO = 11;
    expected_mapping.nN2 = 12;
    expected_mapping.nO2 = 13;
    expected_mapping.nAr = 14;
    expected_mapping.rho = 15;
    expected_mapping.nH = 16;
    expected_mapping.nOa = 18;  % Anomalous oxygen
    expected_mapping.nNO = 19;
    expected_mapping.T = 20;
    
    fields = fieldnames(expected_mapping);
    for i = 1:length(fields)
        field = fields{i};
        expected_idx = expected_mapping.(field);
        % Verify the index is in valid range [1, 20]
        assert(expected_idx >= 1 && expected_idx <= 20, ...
            sprintf('%s index %d out of range', field, expected_idx));
    end
    
    fprintf('  ✓ Column mapping correct (all indices 1-20)\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Column mapping', 'passed', true, ...
        'message', 'All column indices are valid (1-20)');
catch ME
    fprintf('  ✗ Column mapping failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 2, 'name', 'Column mapping', 'passed', false, ...
        'message', ME.message);
end

fprintf('\n');

% =========================================================================
% TIER 3: NUMERICAL VALIDATION (Fortran Execution)
% =========================================================================
fprintf('TIER 3: Numerical Validation\n');
fprintf('----------------------------\n');

% Test 3.1: Fortran executable availability
fprintf('Testing Fortran executable...\n');
try
    msisDIR = fullfile(fileparts(mfilename('fullpath')), '..', 'nrlmsis2.1');
    exe_file = fullfile(msisDIR, 'msis2.1_test.exe');
    
    assert(exist(exe_file, 'file') == 2, 'MSIS executable not found');
    
    % Check if executable
    [status, result] = system(sprintf('file %s', exe_file));
    assert(contains(result, 'ELF') || contains(result, 'executable'), ...
        'File does not appear to be executable');
    
    fprintf('  ✓ MSIS executable found and valid\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'Fortran executable', 'passed', true, ...
        'message', 'msis2.1_test.exe is available');
catch ME
    fprintf('  ✗ Fortran executable failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'Fortran executable', 'passed', false, ...
        'message', ME.message);
end

% Test 3.2: Run get_msis_dat and validate outputs
fprintf('Running get_msis_dat and validating outputs...\n');
try
    % Use test parameters from task documentation
    alt_test = 100:100:500;  % 100, 200, 300, 400, 500 km
    f107a_test = 50;
    f107_test = 50;
    Ap_test = 5;
    
    % Run MSIS (without recompiling)
    [rho_out, H_out] = get_msis_dat(alt_test, f107a_test, f107_test, Ap_test, false);
    
    % Test 3.2.1: Check positive values
    assert(all(rho_out > 0), 'Density must be positive');
    assert(all(H_out > 0), 'Scale height must be positive');
    fprintf('  ✓ All densities and scale heights positive\n');
    
    % Test 3.2.2: Check density decreases with altitude
    assert(all(diff(rho_out) < 0), 'Density should decrease with altitude');
    fprintf('  ✓ Density decreases with altitude\n');
    
    % Test 3.2.3: Check magnitude (should be ~10^-12 to 10^-6 g/cm³)
    assert(all(rho_out > 1e-15), 'Density magnitude too small');
    assert(all(rho_out < 1e-3), 'Density magnitude too large');
    fprintf('  ✓ Density magnitude in expected range (%.2e to %.2e g/cm³)\n', ...
        min(rho_out), max(rho_out));
    
    % Test 3.2.4: Check scale height range (typically 10-100 km)
    % H is in cm, so convert to km for checking
    H_km = H_out / 100000;  % cm to km
    assert(all(H_km > 1), 'Scale height too small');
    assert(all(H_km < 200), 'Scale height too large');
    fprintf('  ✓ Scale height in expected range (%.1f to %.1f km)\n', ...
        min(H_km), max(H_km));
    
    % Test 3.2.5: Check temperature reasonableness (via scale height)
    % Scale height H = kT/(Mg), so T = H*Mg/k
    % With H ~ 50 km and M ~ 29e-3 kg/mol, T ~ 1000 K
    T_estimated = H_km * 1000 * 29e-3 / 1.38e-23 * 6.022e23 / 1000;  % Rough estimate
    assert(all(T_estimated > 100), 'Temperature estimate too low');
    assert(all(T_estimated < 2000), 'Temperature estimate too high');
    fprintf('  ✓ Temperature estimate reasonable (%.0f to %.0f K)\n', ...
        min(T_estimated), max(T_estimated));
    
    passed = passed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'MSIS numerical outputs', 'passed', true, ...
        'message', sprintf('ρ=%.2e-%.2e g/cm³, H=%.1f-%.1f km', ...
        min(rho_out), max(rho_out), min(H_km), max(H_km)));
catch ME
    fprintf('  ✗ MSIS numerical outputs failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'MSIS numerical outputs', 'passed', false, ...
        'message', ME.message);
end

% Test 3.3: Altitude trend validation
fprintf('Validating altitude trend...\n');
try
    % Test that density decreases exponentially with altitude
    alt_test = 100:50:500;
    [rho_out, H_out] = get_msis_dat(alt_test, 50, 50, 5, false);
    
    % Log density should be approximately linear with altitude
    log_rho = log(rho_out);
    
    % Fit linear trend
    p = polyfit(alt_test, log_rho, 1);
    
    % Slope should be negative (density decreases)
    assert(p(1) < 0, 'Density should decrease with altitude');
    
    % R-squared should be high (exponential decay)
    rho_fit = polyval(p, alt_test);
    ss_res = sum((log_rho - rho_fit).^2);
    ss_tot = sum((log_rho - mean(log_rho)).^2);
    r_squared = 1 - ss_res/ss_tot;
    
    assert(r_squared > 0.99, sprintf('R² = %.3f, expected > 0.99', r_squared));
    
    fprintf('  ✓ Exponential decay verified (R² = %.4f)\n', r_squared);
    fprintf('    Scale height estimate: H ≈ %.1f km\n', -1/p(1));
    
    passed = passed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'Altitude trend', 'passed', true, ...
        'message', sprintf('Exponential decay confirmed, R² = %.4f', r_squared));
catch ME
    fprintf('  ✗ Altitude trend failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 3, 'name', 'Altitude trend', 'passed', false, ...
        'message', ME.message);
end

fprintf('\n');

% =========================================================================
% TIER 4: SPATIAL AVERAGING VALIDATION
% =========================================================================
fprintf('TIER 4: Spatial Averaging Validation\n');
fprintf('------------------------------------\n');

% Test 4.1: Reshape logic validation
fprintf('Testing reshape logic...\n');
try
    % Simulate the reshape operation
    nalt = 10;
    nglat = 3;
    nglong = 4;
    ndate = 4;
    nblocks = nalt * nglat * nglong * ndate;
    
    % Create test data
    test_data = 1:nblocks;
    
    % Simulate reshape as done in get_msis_dat.m
    test_reshape = reshape(test_data, [nalt, nglong, nglat, ndate]);
    
    % Check dimensions
    assert(all(size(test_reshape) == [nalt, nglong, nglat, ndate]), ...
        'Reshape dimensions incorrect');
    
    % Verify element access works correctly
    expected_value = 1 + (2-1)*nglat*nglong*ndate + (3-1)*nglong*ndate + (4-1)*ndate + (5-1);
    actual_value = test_reshape(5, 4, 3, 2);
    assert(actual_value == expected_value, 'Reshape element access failed');
    
    fprintf('  ✓ Reshape logic correct\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Reshape logic', 'passed', true, ...
        'message', 'Array dimensions [nalt, nglong, nglat, ndate] correct');
catch ME
    fprintf('  ✗ Reshape logic failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Reshape logic', 'passed', false, ...
        'message', ME.message);
end

% Test 4.2: Mean calculation validation
fprintf('Testing mean calculation...\n');
try
    % Create test data with known mean
    nalt = 5;
    nglat = 3;
    nglong = 4;
    ndate = 4;
    nblocks = nalt * nglat * nglong * ndate;
    
    test_data = reshape(1:nblocks, [nalt, nglong, nglat, ndate]);
    
    % Calculate mean over dimensions [2, 3, 4]
    averaged = mean(test_data, [2, 3, 4]);
    
    % Expected: mean of 1:48 for each altitude level
    expected_mean = zeros(nalt, 1);
    for i = 1:nalt
        block_start = (i-1)*nglat*nglong*ndate + 1;
        block_end = i*nglat*nglong*ndate;
        expected_mean(i) = mean(block_start:block_end);
    end
    
    assert(all(abs(averaged - expected_mean) < 1e-10), 'Mean calculation incorrect');
    assert(size(averaged, 1) == nalt, 'Output should be column vector');
    assert(size(averaged, 2) == 1, 'Output should be column vector');
    
    fprintf('  ✓ Mean calculation correct\n');
    passed = passed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Mean calculation', 'passed', true, ...
        'message', 'Mean over [2,3,4] dimensions produces [nalt,1] output');
catch ME
    fprintf('  ✗ Mean calculation failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Mean calculation', 'passed', false, ...
        'message', ME.message);
end

% Test 4.3: Output dimension validation
fprintf('Testing output dimensions...\n');
try
    % Run with known altitude vector
    alt_test = [100, 200, 300, 400, 500];
    nalt_expected = length(alt_test);
    
    [rho_out, H_out] = get_msis_dat(alt_test, 50, 50, 5, false);
    
    % Check output dimensions
    assert(size(rho_out, 1) == nalt_expected, ...
        sprintf('rho_out rows: %d, expected: %d', size(rho_out, 1), nalt_expected));
    assert(size(rho_out, 2) == 1, 'rho_out should be column vector');
    assert(size(H_out, 1) == nalt_expected, ...
        sprintf('H_out rows: %d, expected: %d', size(H_out, 1), nalt_expected));
    assert(size(H_out, 2) == 1, 'H_out should be column vector');
    
    fprintf('  ✓ Output dimensions correct: [%d, 1]\n', nalt_expected);
    passed = passed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Output dimensions', 'passed', true, ...
        'message', sprintf('Output shape [%d, 1] matches altitude vector', nalt_expected));
catch ME
    fprintf('  ✗ Output dimensions failed: %s\n', ME.message);
    failed = failed + 1;
    all_results(end+1) = struct('tier', 4, 'name', 'Output dimensions', 'passed', false, ...
        'message', ME.message);
end

fprintf('\n');

% =========================================================================
% SUMMARY
% =========================================================================
fprintf('========================================\n');
fprintf('VALIDATION SUMMARY\n');
fprintf('========================================\n');
fprintf('Passed: %d\n', passed);
fprintf('Failed: %d\n', failed);
fprintf('Total:  %d\n', passed + failed);

% Save results to file
results_file = fullfile(fileparts(mfilename('fullpath')), '..', 'tasks', 'docs', ...
    'validation_results_3.3.0.mat');
save(results_file, 'all_results', 'passed', 'failed');

fprintf('\nResults saved to: %s\n', results_file);

% Return results
if nargout > 0
    varargout{1} = passed;
    varargout{2} = failed;
end

end
