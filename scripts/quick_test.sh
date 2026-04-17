#!/bin/bash
# quick_test.sh - Quick test to validate environment

set -e

echo "=========================================="
echo "Quick Test - Kryo Serialization Benchmark"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for tests
PASSED=0
FAILED=0

# Function to check test result
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}   ✓ $2${NC}"
        ((PASSED++))
    else
        echo -e "${RED}   ✗ $2${NC}"
        ((FAILED++))
    fi
}

echo ""
echo "1. Checking directory structure..."

# Check root files
[ -f "../.gitignore" ] && check_result 0 ".gitignore exists" || check_result 1 ".gitignore missing"
[ -f "../LICENSE" ] && check_result 0 "LICENSE exists" || check_result 1 "LICENSE missing"
[ -f "../README.md" ] && check_result 0 "README.md exists" || check_result 1 "README.md missing"

# Check configs
echo ""
echo "2. Checking configuration files..."

for config in strategy_1_java_baseline.json strategy_2_default_kryo.json strategy_3_rule_based.json strategy_4_adaptive.json; do
    if [ -f "../configs/$config" ]; then
        # Validate JSON syntax
        if python3 -c "import json; json.load(open('../configs/$config'))" 2>/dev/null; then
            check_result 0 "$config (valid JSON)"
        else
            check_result 1 "$config (invalid JSON)"
        fi
    else
        check_result 1 "$config (missing)"
    fi
done

# Check scripts
echo ""
echo "3. Checking script files..."

for script in run_benchmark.sh run_all_strategies.sh run_benchmark_automated.py collect_metrics.py aggregate_results.py quick_test.sh; do
    if [ -f "../scripts/$script" ]; then
        check_result 0 "$script"
    else
        check_result 1 "$script (missing)"
    fi
done

# Check stats
echo ""
echo "4. Checking R analysis files..."

for rfile in analysis.R power_analysis.R; do
    if [ -f "../stats/$rfile" ]; then
        check_result 0 "$rfile"
    else
        check_result 1 "$rfile (missing)"
    fi
done

# Check results CSV files
echo ""
echo "5. Checking results CSV files..."

for csvfile in experiment_data.csv ablation_data.csv workload_data.csv; do
    if [ -f "../results/$csvfile" ]; then
        # Check if CSV has content
        if [ -s "../results/$csvfile" ]; then
            check_result 0 "$csvfile (has content)"
        else
            check_result 1 "$csvfile (empty)"
        fi
    else
        check_result 1 "$csvfile (missing)"
    fi
done

# Check cloudformation
echo ""
echo "6. Checking cloudformation files..."

for cf in emr-cluster-template.yaml emr-cluster-parameters.json deploy.sh; do
    if [ -f "../cloudformation/$cf" ]; then
        check_result 0 "$cf"
    else
        check_result 1 "$cf (missing)"
    fi
done

# Run a quick Python test
echo ""
echo "7. Testing Python scripts..."

if command -v python3 &> /dev/null; then
    check_result 0 "Python 3 available"
    
    # Test aggregate_results.py
    if [ -f "../scripts/aggregate_results.py" ]; then
        cd ../scripts
        python3 aggregate_results.py --help > /dev/null 2>&1
        check_result $? "aggregate_results.py runs"
        cd - > /dev/null
    fi
else
    check_result 1 "Python 3 not found"
fi

# Run a quick R test
echo ""
echo "8. Testing R environment..."

if command -v Rscript &> /dev/null; then
    check_result 0 "R available"
else
    check_result 1 "R not found (install R to run statistical analysis)"
fi

# Summary
echo ""
echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}"
    echo "✅ ALL TESTS PASSED!"
    echo "Your repository is ready to use."
    echo -e "${NC}"
    exit 0
else
    echo -e "${RED}"
    echo "⚠ SOME TESTS FAILED"
    echo "Please fix the missing files listed above."
    echo -e "${NC}"
    exit 1
fi