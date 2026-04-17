#!/bin/bash
# generate_repo.sh - Creates complete repository structure with templates

echo "Creating Kryo Benchmark Repository..."

# Create directories
mkdir -p spark-kryo-benchmark/{configs,queries/tpcds_100gb,scripts,monitoring/{src,conf},stats,cloudformation,results/{raw,analysis,figures,tables},docker,.github/workflows}

cd spark-kryo-benchmark

# Create config files (using echo commands - simplified)
echo '{"spark.serializer":"org.apache.spark.serializer.JavaSerializer"}' > configs/strategy_1_java_baseline.json
echo '{"spark.serializer":"org.apache.spark.serializer.KryoSerializer","spark.kryoserializer.buffer.max":"64m"}' > configs/strategy_2_default_kryo.json
echo '{"spark.serializer":"org.apache.spark.serializer.KryoSerializer","spark.kryoserializer.buffer.max":"512m","spark.io.compression.codec":"zstd"}' > configs/strategy_3_rule_based.json
echo '{"spark.serializer":"org.apache.spark.serializer.KryoSerializer","spark.kryoserializer.buffer.max":"1g","adaptive.enabled":"true"}' > configs/strategy_4_adaptive.json

# Create a simple README
cat > README.md << 'EOF'
# Kryo Serialization Benchmark - Reproduction Package

## Status: Template / Pre-Experiment

This repository contains the complete structure for reproducing the experiments in our paper. 

**Current status:** Configuration files, scripts, and analysis code are complete. 
Experiment results will be added after execution.

## Quick Start

```bash
# Run synthetic benchmark (no real data needed)
./scripts/run_all_strategies.sh

# Run analysis on synthetic data
cd stats && Rscript analysis.R