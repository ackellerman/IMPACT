#!/bin/bash
# Fallback verification script for MSIS data retrieval validation
# Runs Python implementation when MATLAB is not available

echo "========================================"
echo "MSIS Data Retrieval Validation Suite"
echo "Fallback Verification (Shell)"
echo "========================================"
echo "Date: January 16, 2026"
echo ""

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo "Running Python validation suite..."
    cd /work/projects/IMPACT/IMPACT_MATLAB
    python3 test_msis_integration_fallback.py
else
    echo "ERROR: Python3 not found"
    echo "Cannot run validation tests"
    exit 1
fi

echo ""
echo "========================================"
echo "Manual Verification Commands"
echo "========================================"

# Manual verification commands
echo ""
echo "Tier 2: File Format Validation"
echo "--------------------------------"
echo "Checking input file columns..."
head -2 /work/projects/IMPACT/nrlmsis2.1/msisinputs.txt | awk 'NR==2 {print "Input columns:", NF}'

echo ""
echo "Checking output file columns..."
head -2 /work/projects/IMPACT/nrlmsis2.1/msisoutputs.txt | awk 'NR==2 {print "Output columns:", NF}'

echo ""
echo "Fortran Executable Check"
echo "-------------------------"
if [ -x "/work/projects/IMPACT/nrlmsis2.1/msis2.1_test.exe" ]; then
    echo "✓ MSIS executable exists and is executable"
    file /work/projects/IMPACT/nrlmsis2.1/msis2.1_test.exe | grep -q "ELF" && echo "✓ Executable format correct (ELF)"
else
    echo "✗ MSIS executable not found or not executable"
fi

echo ""
echo "Parameter Files"
echo "---------------"
if [ -f "/work/projects/IMPACT/nrlmsis2.1/msis21.parm" ]; then
    echo "✓ MSIS parameter file exists ($(ls -lh /work/projects/IMPACT/nrlmsis2.1/msis21.parm | awk '{print $5}'))"
else
    echo "✗ MSIS parameter file missing"
fi

echo ""
echo "========================================"
echo "Fallback Verification Complete"
echo "========================================"
