#!/bin/bash
#########################################################################
# Environment Validation Script - Check if datasets are properly set up
# Ensures consistent environment with hello world demonstration
#########################################################################

echo "JCL Framework - Environment Validation"
echo "=========================================="
echo "Checking essential datasets and hello_world environment..."
echo ""

# Check if dataset manager is working
if ! ./dataset_manager.sh list >/dev/null 2>&1; then
    echo "Dataset manager not working. Run './setup_datasets.sh' first"
    exit 1
fi

# Essential datasets for Tasks 1, 2, 3 & File Copy
REQUIRED_DATASETS=(
    "TRANSACTIONS.INPUT"
    "TRANSACTIONS.VALIDATED"
    "ACCOUNTS.MASTER"
    "CUSTOMERS.MASTER"
    "INPUT.DATA"
    "OUTPUT.DATA"
)

echo "Checking required datasets..."
MISSING_COUNT=0

for dataset in "${REQUIRED_DATASETS[@]}"; do
    if ./dataset_manager.sh list | grep -q "$dataset"; then
        echo "$dataset - OK"
    else
        echo "$dataset - MISSING"
        ((MISSING_COUNT++))
    fi
done

echo ""
echo "Checking data files..."
DATA_FILES=(
    "datasets/transactions_input.dat"
    "datasets/transactions_validated.dat"
    "datasets/accounts_master.dat"
    "datasets/customers_master.dat"
    "datasets/input_data.dat"
)

for file in "${DATA_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Count non-empty lines properly (handles files without final newline)
        line_count=$(grep -c . "$file" 2>/dev/null || echo "0")
        echo "$file - OK ($line_count lines)"
    else
        echo "$file - MISSING"
        ((MISSING_COUNT++))
    fi
done

echo ""
echo "Checking essential COBOL programs..."

if [ -f "programs/hello_world.cbl" ]; then
    echo "programs/hello_world.cbl - OK"
else
    echo "programs/hello_world.cbl - MISSING"
    ((MISSING_COUNT++))
fi

echo ""
echo "Checking essential JCL jobs..."

if [ -f "jobs/hello_world.jcl" ]; then
    echo "jobs/hello_world.jcl - OK"
else
    echo "jobs/hello_world.jcl - MISSING"
    ((MISSING_COUNT++))
fi

echo ""
echo "Checking standardized PGM names..."

if [ -f "jobs/hello_world.jcl" ]; then
    if grep -q "EXEC PGM=HELLO" "jobs/hello_world.jcl"; then
        echo "jobs/hello_world.jcl uses standardized PGM=HELLO"
    else
        echo "jobs/hello_world.jcl does not use standardized PGM=HELLO"
        ((MISSING_COUNT++))
    fi
fi

echo ""
echo "Validation Summary:"
echo "====================="
if [ $MISSING_COUNT -eq 0 ]; then
    echo "Environment is READY!"
    echo "All essential datasets allocated"
    echo "All data files present"
    echo "Hello World COBOL program available"
    echo "Hello World JCL job ready"
    echo "Standardized PGM name verified"
    echo ""
    echo "You can now run the hello world demonstration and start working on tasks!"
    echo ""
    echo "Quick test command:"
    echo "  ./jcl_parser.sh jobs/hello_world.jcl"
    echo ""
    echo "Available:"
    echo "  - Hello World: Basic COBOL demonstration"
    echo "  - Datasets ready for Tasks"
else
    echo "Environment has $MISSING_COUNT missing components"
    echo "Run './setup_datasets.sh' to fix missing datasets"
    echo "Check that hello_world.cbl and hello_world.jcl are present"
    echo "Ensure PGM name is standardized to HELLO"
    exit 1
fi