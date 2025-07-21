# 🚀 JCL Framework - Student Guide

## What is This?
This framework teaches you IBM mainframe JCL (Job Control Language) concepts using open-source tools. You'll learn real enterprise batch processing with actual COBOL programs!

## What You'll Learn
After completing this course, you'll be able to:
- ✅ Write and execute JCL jobs
- ✅ Create COBOL programs for batch processing  
- ✅ Manage datasets and file processing workflows
- ✅ Handle job dependencies and error conditions
- ✅ Understand enterprise batch processing concepts

## Prerequisites
- Linux/Unix environment (Ubuntu, CentOS, macOS, WSL)
- Bash shell (version 4.0+)
- Basic command-line knowledge
- GnuCOBOL (open-source COBOL compiler)


## 🚀 Quick Setup

### Step 1: Make Scripts Executable
```bash
chmod +x *.sh
```

### Step 2: Initialize Everything
```bash
# Run the demo to see everything working
./demo.sh

# Setup datasets (data files)
./setup_datasets.sh 

# Verify everything is working
./validate_environment.sh
```

## 🎯 Your First JCL Job

### Look at the Example
```bash
# See the JCL job file
cat jobs/hello_world.jcl

# See the COBOL program
cat programs/hello_world.cbl
```

### Run Your First Job
```bash
# Execute the job
./jcl_parser.sh jobs/hello_world.jcl

# View the results
cat ./output/sysout/HELLO_STEP1_cobol.log
```

**What you'll see:**
```
Hello World from JCL Framework!
================================
This is a simple COBOL program demonstration
Program executed successfully
```

This shows **real COBOL compilation and execution** - not just simulation!

## 📚 Understanding JCL Basics

### JCL Syntax
```jcl
//JOBNAME  JOB CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//STEPNAME EXEC PGM=PROGRAM-NAME
//DDNAME   DD   DSN=DATASET.NAME,DISP=SHR
//SYSOUT   DD   SYSOUT=*
```

### Real Example
```jcl
//BANKJOB  JOB  CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//STEP1    EXEC PGM=BATCH-VALIDATOR
//TRANSIN  DD   DSN=TRANSACTIONS.INPUT,DISP=SHR
//SYSOUT   DD   SYSOUT=*
//STEP2    EXEC PGM=ACCOUNT-UPDATE,COND=(0,NE,STEP1)
//ACCOUNTS DD   DSN=ACCOUNTS.MASTER,DISP=SHR
//SYSOUT   DD   SYSOUT=*
```

## 🔧 Key Commands

```bash
# Dataset Management
./dataset_manager.sh list          # List all datasets

# Run Jobs
./jcl_parser.sh <jcl-file>        # Parse and run JCL

# Get Help
./demo.sh                          # See working examples
```

## 📁 File Organization

| What | Where | Purpose |
|------|-------|---------|
| JCL Jobs | `jobs/` | Job control language files |
| COBOL Programs | `programs/` | COBOL source code |
| Datasets | `datasets/` | Data files and catalogs |
| Output | `output/` | Job execution results |

## 🔍 Framework Features

### JCL Support
- JOB statements - Job definition and parameters
- EXEC statements - Program execution  
- DD statements - Dataset definitions
- PROC statements - Procedure calls
- IF/THEN/ELSE - Conditional execution

### Enterprise Features
- Real COBOL compilation and execution
- Job dependencies and return code checking
- SYSOUT capture and detailed logging
- Error handling and resource allocation
- Enterprise logging patterns

### Dataset Types
- Sequential files (PS)
- VSAM-like indexed files
- Generation Data Groups (GDG) simulation
- Temporary datasets

## 🆘 Getting Help

- Each error message includes helpful guidance
- Review exercise instructions carefully
- Run `./demo.sh` to see working examples
- Check execution logs in `./output/sysout/` for details

## 🎓 Ready to Start?

1. Run `./demo.sh` to see everything in action
2. Try the hello world example above
3. Start with the exercises
4. Happy learning!

---

**This framework maps open-source tools to IBM mainframe concepts:**

| Open Source | IBM Mainframe |
|-------------|---------------|
| Shell scripts | JCL |
| File system | VSAM/SMS |
| Exit codes | Return codes |
| Log files | SYSOUT |