# Spark Kryo Serialization Benchmark - Reproduction Package

**Paper:** "An Empirical Comparison of Kryo Serialization Optimization Strategies in Apache Spark: Cloud-Based Evaluation at Scale" (under review)

**Authors:** [Blinded for review]

**DOI:** [To be assigned after acceptance]

## Overview

This repository contains all materials to reproduce the experiments described in the paper, including:
- Four Kryo serialization optimization strategies (Java baseline, Default Kryo, Rule-based, Adaptive)
- TPC-DS benchmark at 100GB scale on AWS EMR
- Complete metrics collection and statistical analysis pipeline
- Infrastructure-as-code for full reproducibility

## Repository Structure

| Directory | Contents |
|-----------|----------|
| `/configs` | Spark configuration files for all 4 strategies |
| `/queries` | TPC-DS SQL queries (25 queries, 100GB scale) |
| `/scripts` | Benchmark execution and data collection scripts |
| `/monitoring` | Custom Kryo metrics listeners and JMX exporters |
| `/stats` | R scripts for statistical analysis (ANOVA, effect sizes, power) |
| `/cloudformation` | AWS CloudFormation template for EMR cluster |
| `/results` | Raw experimental data (CSV format) |
| `/docker` | Docker container for local testing |
| `/.github/workflows` | CI/CD pipeline for automated reproduction |

## Prerequisites

### Hardware/Cloud Requirements
- AWS account with EMR, EC2, and S3 permissions
- Budget: ~$50-100 for full reproduction (100GB TPC-DS, 9-node m5.4xlarge cluster, ~8 hours runtime)

### Software Requirements
- AWS CLI v2.x configured with credentials
- Python 3.9+ with packages: boto3, pandas, numpy
- R 4.0+ with packages: car, effsize, pwr, ggplot2, dplyr
- Spark 3.4.1 (EMR 6.15.0)
- Java 11 (Amazon Corretto)
- Docker (optional, for local testing)

### Data Requirements
- TPC-DS dataset at 100GB scale in S3 (see Data Preparation section)

## Quick Start (5 minutes)

```bash
# 1. Clone repository
git clone https://anonymous.4open.science/r/spark-kryo-benchmark
cd spark-kryo-benchmark

# 2. Deploy EMR cluster (requires AWS credentials)
cd cloudformation
./deploy.sh

# 3. Wait for cluster to be ready (~10 minutes)
aws emr wait cluster-running --cluster-id $(cat cluster-id.txt)

# 4. Run all four strategies (main experiment)
cd ../scripts
./run_all_strategies.sh

# 5. Analyze results
cd ../stats
Rscript analysis.R