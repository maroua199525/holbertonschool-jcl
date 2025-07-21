#!/bin/bash
#########################################################################
# Dataset Setup Script - Essential datasets for Tasks 0, 1, 2, 3
# Streamlined setup for required exercises only
#########################################################################

echo "🚀 JCL Framework - Essential Dataset Setup"
echo "=========================================="
echo "Setting up required datasets for Tasks 0, 1, 2, 3..."
echo ""

# Initialize dataset manager
./dataset_manager.sh init

echo "📁 Allocating Task 0 (Basic File Operations) Datasets..."
if ! ./dataset_manager.sh list | grep -q "INPUT.DATA"; then
    ./dataset_manager.sh allocate INPUT.DATA PS 1024 50
else
    echo "✓ INPUT.DATA already allocated"
fi
if ! ./dataset_manager.sh list | grep -q "OUTPUT.DATA"; then
    ./dataset_manager.sh allocate OUTPUT.DATA PS 1024 50
else
    echo "✓ OUTPUT.DATA already allocated"
fi

echo "📁 Allocating Task 1 (Batch Validator) Datasets..."
if ! ./dataset_manager.sh list | grep -q "TRANSACTIONS.INPUT"; then
    ./dataset_manager.sh allocate TRANSACTIONS.INPUT PS 2048 100
else
    echo "✓ TRANSACTIONS.INPUT already allocated"
fi
if ! ./dataset_manager.sh list | grep -q "TRANSACTIONS.VALIDATED"; then
    ./dataset_manager.sh allocate TRANSACTIONS.VALIDATED PS 2048 100
else
    echo "✓ TRANSACTIONS.VALIDATED already allocated"
fi

echo "📁 Allocating Task 2 (Account Updater) Datasets..."
if ! ./dataset_manager.sh list | grep -q "ACCOUNTS.MASTER"; then
    ./dataset_manager.sh allocate ACCOUNTS.MASTER PS 1024 50
else
    echo "✓ ACCOUNTS.MASTER already allocated"
fi

echo "📁 Allocating Task 3 (Customer Reporter) Datasets..."
if ! ./dataset_manager.sh list | grep -q "CUSTOMERS.MASTER"; then
    ./dataset_manager.sh allocate CUSTOMERS.MASTER PS 1024 50
else
    echo "✓ CUSTOMERS.MASTER already allocated"
fi

echo "📁 Initializing Dataset Files..."
# Initialize empty dataset files if they don't exist
if [ ! -f "datasets/transactions_input.dat" ]; then
    touch datasets/transactions_input.dat
    echo "✓ TRANSACTIONS.INPUT dataset file created"
else
    echo "✓ TRANSACTIONS.INPUT dataset file exists"
fi

if [ ! -f "datasets/accounts_master.dat" ]; then
    touch datasets/accounts_master.dat
    echo "✓ ACCOUNTS.MASTER dataset file created"
else
    echo "✓ ACCOUNTS.MASTER dataset file exists"
fi

if [ ! -f "datasets/customers_master.dat" ]; then
    touch datasets/customers_master.dat
    echo "✓ CUSTOMERS.MASTER dataset file created"
else
    echo "✓ CUSTOMERS.MASTER dataset file exists"
fi

if [ ! -f "datasets/input_data.dat" ]; then
    touch datasets/input_data.dat
    echo "✓ INPUT.DATA dataset file created (empty)"
else
    echo "✓ INPUT.DATA dataset file exists"
fi

if [ ! -f "datasets/output_data.dat" ]; then
    touch datasets/output_data.dat
    echo "✓ OUTPUT.DATA dataset file created (empty, ready for copy operation)"
else
    echo "✓ OUTPUT.DATA dataset file exists"
fi

echo ""
echo "📋 Essential Dataset Summary:"
echo "============================="
./dataset_manager.sh list

echo ""
echo "✅ Essential dataset setup complete!"
echo "📚 Streamlined setup for required tasks only"
echo ""
echo "🎯 Ready for essential JCL exercises:"
echo "  • Task 0: Basic file operations (INPUT.DATA → OUTPUT.DATA)"
echo "  • Task 1: Batch Validator (TRANSACTIONS.INPUT)"
echo "  • Task 2: Account Updater (ACCOUNTS.MASTER + TRANSACTIONS.VALIDATED)"
echo "  • Task 3: Customer Reporter (CUSTOMERS.MASTER)"
echo ""
echo "💡 Only essential datasets allocated - faster setup, cleaner environment!"