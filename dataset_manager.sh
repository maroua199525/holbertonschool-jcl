#!/bin/bash
#########################################################################
# Dataset Manager - Simulates IBM VSAM, GDG, and SMS concepts
# Manages dataset allocation, cataloging, and generation data groups
#########################################################################

DATASET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/datasets"
CATALOG_FILE="$DATASET_DIR/master_catalog.dat"
GDG_DIR="$DATASET_DIR/gdg"
VSAM_DIR="$DATASET_DIR/vsam"
TEMP_DIR="$DATASET_DIR/temp"

# Initialize dataset environment
init_datasets() {
    mkdir -p "$DATASET_DIR" "$GDG_DIR" "$VSAM_DIR" "$TEMP_DIR"
    
    if [[ ! -f "$CATALOG_FILE" ]]; then
        create_master_catalog
    fi
    
    echo "Dataset Manager initialized"
    echo "Dataset directory: $DATASET_DIR"
    echo "Master catalog: $CATALOG_FILE"
    echo "GDG directory: $GDG_DIR"
    echo "VSAM directory: $VSAM_DIR"
}

# Create master catalog
create_master_catalog() {
    cat > "$CATALOG_FILE" << 'EOF'
# Master Catalog - Dataset Registry
# Format: DSN|TYPE|LOCATION|STATUS|CREATED|SIZE|RECORDS
TRANSACTIONS.INPUT|PS|../transactions.idx|ACTIVE|2025-01-01|1024|6
ACCOUNTS.MASTER|PS|../accounts.idx|ACTIVE|2025-01-01|512|5
CUSTOMERS.MASTER|PS|../CUSTOMERS.DAT|ACTIVE|2025-01-01|2048|100
USERS.MASTER|PS|../USERS.DAT|ACTIVE|2025-01-01|1024|50
EOF
    
    echo "Master catalog created"
}

# Allocate new dataset
allocate_dataset() {
    local dsn="$1"
    local type="${2:-PS}"
    local space="${3:-1024}"
    local records="${4:-0}"
    
    echo "Allocating dataset: $dsn"
    echo "Type: $type, Space: $space, Records: $records"
    
    local file_path
    case "$type" in
        "PS")
            # Partitioned Sequential
            file_path="$DATASET_DIR/$(echo "$dsn" | tr '.' '_' | tr '[:upper:]' '[:lower:]').dat"
            touch "$file_path"
            ;;
        "VSAM")
            # VSAM dataset
            file_path="$VSAM_DIR/$(echo "$dsn" | tr '.' '_' | tr '[:upper:]' '[:lower:]').vsam"
            create_vsam_dataset "$file_path" "$space"
            ;;
        "GDG")
            # Generation Data Group
            file_path=$(allocate_gdg_generation "$dsn")
            ;;
        "TEMP")
            # Temporary dataset
            file_path="$TEMP_DIR/$(echo "$dsn" | tr '.' '_' | tr '[:upper:]' '[:lower:]')_$$_$(date +%s).tmp"
            touch "$file_path"
            ;;
        *)
            echo "ERROR: Unknown dataset type: $type"
            return 1
            ;;
    esac
    
    # Add to catalog
    echo "$dsn|$type|$file_path|ACTIVE|$(date +%Y-%m-%d)|$space|$records" >> "$CATALOG_FILE"
    
    echo "Dataset allocated: $file_path"
    return 0
}

# Create VSAM dataset
create_vsam_dataset() {
    local file_path="$1"
    local space="$2"
    
    # Create VSAM control file
    cat > "$file_path" << EOF
# VSAM Dataset Control Information
DATASET_TYPE=KSDS
KEY_LENGTH=8
RECORD_LENGTH=80
SPACE_ALLOCATION=$space
CREATED=$(date '+%Y-%m-%d %H:%M:%S')
STATUS=ACTIVE

# Data follows this header
EOF
    
    # Create associated data file
    local data_file="${file_path}.data"
    touch "$data_file"
    
    echo "VSAM dataset created: $file_path"
}

# Allocate GDG generation
allocate_gdg_generation() {
    local gdg_base="$1"
    local gdg_dir="$GDG_DIR/$(echo "$gdg_base" | tr '.' '_' | tr '[:upper:]' '[:lower:]')"
    
    mkdir -p "$gdg_dir"
    
    # Find next generation number
    local next_gen=1
    if ls "$gdg_dir"/G*V00 >/dev/null 2>&1; then
        local last_gen=$(ls "$gdg_dir"/G*V00 | tail -1 | sed 's/.*G\([0-9]*\)V00/\1/')
        next_gen=$((last_gen + 1))
    fi
    
    local gen_file="$gdg_dir/G$(printf "%04d" $next_gen)V00"
    touch "$gen_file"
    
    # Create GDG catalog entry
    local gdg_catalog="$gdg_dir/catalog"
    echo "$(date '+%Y-%m-%d %H:%M:%S')|G$(printf "%04d" $next_gen)V00|$gen_file|ACTIVE" >> "$gdg_catalog"
    
    echo "$gen_file"
}

# Delete dataset
delete_dataset() {
    local dsn="$1"
    
    echo "Deleting dataset: $dsn"
    
    # Find dataset in catalog
    local catalog_line=$(grep "^$dsn|" "$CATALOG_FILE")
    
    if [[ -z "$catalog_line" ]]; then
        echo "ERROR: Dataset not found in catalog: $dsn"
        return 1
    fi
    
    # Extract file path
    local file_path=$(echo "$catalog_line" | cut -d'|' -f3)
    
    # Delete physical file
    if [[ -f "$file_path" ]]; then
        rm "$file_path"
        echo "Physical file deleted: $file_path"
    fi
    
    # Remove from catalog
    grep -v "^$dsn|" "$CATALOG_FILE" > "$CATALOG_FILE.tmp"
    mv "$CATALOG_FILE.tmp" "$CATALOG_FILE"
    
    echo "Dataset deleted from catalog"
    return 0
}

# List datasets
list_datasets() {
    local pattern="${1:-*}"
    
    echo "Dataset Catalog Listing"
    echo "======================="
    echo "DSN                    TYPE   STATUS   CREATED     SIZE   RECORDS"
    echo "--------------------------------------------------------------------"
    
    while IFS='|' read -r dsn type location status created size records; do
        # Skip comments and empty lines
        [[ "$dsn" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$dsn" ]] && continue
        
        # Apply pattern filter
        if [[ "$pattern" != "*" ]] && [[ ! "$dsn" =~ $pattern ]]; then
            continue
        fi
        
        printf "%-22s %-6s %-8s %-10s %6s %8s\n" \
               "$dsn" "$type" "$status" "$created" "$size" "$records"
    done < "$CATALOG_FILE"
}

# Show dataset information
show_dataset_info() {
    local dsn="$1"
    
    if [[ -z "$dsn" ]]; then
        echo "Usage: show_dataset_info <dataset_name>"
        return 1
    fi
    
    local catalog_line=$(grep "^$dsn|" "$CATALOG_FILE")
    
    if [[ -z "$catalog_line" ]]; then
        echo "ERROR: Dataset not found: $dsn"
        return 1
    fi
    
    IFS='|' read -r dsn type location status created size records <<< "$catalog_line"
    
    echo "Dataset Information"
    echo "==================="
    echo "Dataset Name: $dsn"
    echo "Type: $type"
    echo "Location: $location"
    echo "Status: $status"
    echo "Created: $created"
    echo "Space Allocation: $size bytes"
    echo "Record Count: $records"
    
    if [[ -f "$location" ]]; then
        echo "Physical Size: $(stat -c%s "$location" 2>/dev/null || echo "Unknown") bytes"
        echo "Last Modified: $(stat -c%y "$location" 2>/dev/null || echo "Unknown")"
    else
        echo "Physical File: NOT FOUND"
    fi
    
    # Show GDG generations if applicable
    if [[ "$type" == "GDG" ]]; then
        show_gdg_generations "$dsn"
    fi
}

# Show GDG generations
show_gdg_generations() {
    local gdg_base="$1"
    local gdg_dir="$GDG_DIR/$(echo "$gdg_base" | tr '.' '_' | tr '[:upper:]' '[:lower:]')"
    local gdg_catalog="$gdg_dir/catalog"
    
    if [[ ! -f "$gdg_catalog" ]]; then
        echo "No GDG generations found"
        return
    fi
    
    echo ""
    echo "GDG Generations:"
    echo "----------------"
    echo "Created              Generation  Status"
    echo "------------------------------------"
    
    while IFS='|' read -r created generation file_path status; do
        printf "%-18s %-11s %-8s\n" "$created" "$generation" "$status"
    done < "$gdg_catalog"
}

# Copy dataset
copy_dataset() {
    local source_dsn="$1"
    local target_dsn="$2"
    
    if [[ -z "$source_dsn" || -z "$target_dsn" ]]; then
        echo "Usage: copy_dataset <source_dsn> <target_dsn>"
        return 1
    fi
    
    echo "Copying dataset: $source_dsn -> $target_dsn"
    
    # Find source dataset
    local source_line=$(grep "^$source_dsn|" "$CATALOG_FILE")
    if [[ -z "$source_line" ]]; then
        echo "ERROR: Source dataset not found: $source_dsn"
        return 1
    fi
    
    # Extract source information
    IFS='|' read -r _ source_type source_location _ _ source_size source_records <<< "$source_line"
    
    # Check if source file exists
    if [[ ! -f "$source_location" ]]; then
        echo "ERROR: Source file not found: $source_location"
        return 1
    fi
    
    # Allocate target dataset
    allocate_dataset "$target_dsn" "$source_type" "$source_size" "$source_records"
    
    # Find target location
    local target_line=$(grep "^$target_dsn|" "$CATALOG_FILE")
    local target_location=$(echo "$target_line" | cut -d'|' -f3)
    
    # Copy data
    cp "$source_location" "$target_location"
    
    echo "Dataset copied successfully"
    return 0
}

# Backup dataset
backup_dataset() {
    local dsn="$1"
    local backup_suffix="${2:-$(date +%Y%m%d_%H%M%S)}"
    
    if [[ -z "$dsn" ]]; then
        echo "Usage: backup_dataset <dataset_name> [suffix]"
        return 1
    fi
    
    local backup_dsn="${dsn}.BACKUP.${backup_suffix}"
    copy_dataset "$dsn" "$backup_dsn"
    
    echo "Dataset backed up as: $backup_dsn"
}

# Cleanup temporary datasets
cleanup_temp() {
    echo "Cleaning up temporary datasets..."
    
    # Remove temporary files older than 1 day
    find "$TEMP_DIR" -name "*.tmp" -mtime +1 -delete 2>/dev/null
    
    # Remove temporary entries from catalog
    grep -v "|TEMP|" "$CATALOG_FILE" > "$CATALOG_FILE.tmp"
    mv "$CATALOG_FILE.tmp" "$CATALOG_FILE"
    
    echo "Temporary datasets cleaned up"
}

# Show help
show_help() {
    cat << 'EOF'
Dataset Manager - Usage

Commands:
  init                           Initialize dataset environment
  allocate <dsn> [type] [space] [records]
                                Allocate new dataset
  delete <dsn>                  Delete dataset
  list [pattern]                List datasets (with optional pattern)
  info <dsn>                    Show dataset information
  copy <source> <target>        Copy dataset
  backup <dsn> [suffix]         Backup dataset
  cleanup                       Cleanup temporary datasets
  help                          Show this help

Dataset Types:
  PS      - Partitioned Sequential (default)
  VSAM    - Virtual Storage Access Method
  GDG     - Generation Data Group
  TEMP    - Temporary dataset

Examples:
  ./dataset_manager.sh init
  ./dataset_manager.sh allocate TRANSACTIONS.DAILY PS 2048 1000
  ./dataset_manager.sh allocate CUSTOMER.INDEX VSAM 4096
  ./dataset_manager.sh allocate REPORTS.MONTHLY GDG
  ./dataset_manager.sh list TRANSACTIONS.*
  ./dataset_manager.sh info ACCOUNTS.MASTER
  ./dataset_manager.sh copy TRANSACTIONS.INPUT TRANSACTIONS.BACKUP
  ./dataset_manager.sh backup ACCOUNTS.MASTER
  ./dataset_manager.sh cleanup
EOF
}

# Main function
main() {
    case "${1:-help}" in
        "init")
            init_datasets
            ;;
        "allocate")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 allocate <dsn> [type] [space] [records]"
                exit 1
            fi
            allocate_dataset "$2" "$3" "$4" "$5"
            ;;
        "delete")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 delete <dsn>"
                exit 1
            fi
            delete_dataset "$2"
            ;;
        "list")
            list_datasets "$2"
            ;;
        "info")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 info <dsn>"
                exit 1
            fi
            show_dataset_info "$2"
            ;;
        "copy")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 copy <source> <target>"
                exit 1
            fi
            copy_dataset "$2" "$3"
            ;;
        "backup")
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 backup <dsn> [suffix]"
                exit 1
            fi
            backup_dataset "$2" "$3"
            ;;
        "cleanup")
            cleanup_temp
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"