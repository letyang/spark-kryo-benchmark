# Dockerfile - Containerized environment for local reproduction testing
# This creates a complete, reproducible environment for the Kryo Serialization Benchmark
# 
# Build: docker build -t spark-kryo-benchmark .
# Run: docker run -it -v $(pwd)/results:/benchmark/results spark-kryo-benchmark
# 
# This container includes:
# - Spark 3.4.1 with Hadoop 3
# - Python 3.9 with required packages
# - R 4.0+ with statistical analysis packages
# - All benchmark scripts and configurations

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Maintainer information (replace with your info after review)
LABEL maintainer="[Blinded for review]"
LABEL description="Reproduction environment for Kryo Serialization Benchmark"
LABEL version="1.0"
LABEL spark.version="3.4.1"
LABEL emr.version="6.15.0"

# ============================================================
# Install System Dependencies
# ============================================================

RUN apt-get update && apt-get install -y \
    # Basic utilities
    wget \
    curl \
    git \
    unzip \
    zip \
    tar \
    gzip \
    # Java (required for Spark)
    openjdk-11-jdk \
    # Python and pip
    python3 \
    python3-pip \
    python3-dev \
    # R and R packages
    r-base \
    r-base-dev \
    # Build tools (for R packages)
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    # Command line tools
    bc \
    jq \
    sudo \
    # Process management
    procps \
    htop \
    # SSH (for cluster simulation)
    openssh-client \
    # For file watching
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Install Apache Spark
# ============================================================

ENV SPARK_VERSION=3.4.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark

# Download and extract Spark
RUN wget -q --progress=bar:force \
    https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# Set Spark environment variables
ENV PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# ============================================================
# Install Python Dependencies
# ============================================================

RUN pip3 install --no-cache-dir \
    # AWS SDK
    boto3 \
    # Data manipulation
    pandas \
    numpy \
    # HTTP requests
    requests \
    # Metrics collection
    prometheus-client \
    # Parquet support
    pyarrow \
    # YAML parsing
    pyyaml \
    # JSON handling
    simplejson \
    # Progress bars
    tqdm \
    # Parallel processing
    joblib

# ============================================================
# Install R Dependencies
# ============================================================

RUN Rscript -e "install.packages(c(
    'car',           # ANOVA and statistical tests
    'effsize',       # Cohen's d effect size
    'pwr',           # Power analysis
    'ggplot2',       # Visualization
    'dplyr',         # Data manipulation
    'tidyr',         # Data tidying
    'broom',         # Model tidying
    'emmeans',       # Estimated marginal means
    'cowplot',       # Plot arranging
    'ggpubr',        # Publication-ready plots
    'reshape2'       # Data reshaping
), repos='https://cloud.r-project.org/')"

# ============================================================
# Create Working Directory and Copy Files
# ============================================================

WORKDIR /benchmark

# Copy repository contents (excluding large directories)
COPY configs/ ./configs/
COPY queries/ ./queries/
COPY scripts/ ./scripts/
COPY stats/ ./stats/
COPY monitoring/ ./monitoring/
COPY cloudformation/ ./cloudformation/
COPY results/ ./results/
COPY .gitignore ./
COPY LICENSE ./
COPY README.md ./

# Make scripts executable
RUN chmod +x ./scripts/*.sh
RUN chmod +x ./scripts/*.py
RUN chmod +x ./cloudformation/*.sh

# ============================================================
# Create Results Directory with Proper Permissions
# ============================================================

RUN mkdir -p /benchmark/results/raw /benchmark/results/analysis /benchmark/results/figures /benchmark/results/tables
RUN chmod -R 777 /benchmark/results

# ============================================================
# Set Up Entrypoint
# ============================================================

# Default command - shows help menu
ENTRYPOINT ["/bin/bash"]

# Default CMD shows available commands
CMD ["-c", "echo '=========================================='; \
             echo 'Kryo Serialization Benchmark Container'; \
             echo '=========================================='; \
             echo ''; \
             echo 'Available commands:'; \
             echo '  ./scripts/quick_test.sh        - Test environment'; \
             echo '  ./scripts/run_benchmark.sh     - Run single strategy'; \
             echo '  ./scripts/run_all_strategies.sh - Run all strategies'; \
             echo '  cd stats && Rscript analysis.R - Run statistical analysis'; \
             echo ''; \
             echo 'To run the full benchmark:'; \
             echo '  ./scripts/run_all_strategies.sh'; \
             echo ''; \
             echo 'Results will be saved to /benchmark/results/'; \
             echo 'To persist results, mount a volume:'; \
             echo '  docker run -v $(pwd)/results:/benchmark/results ...'; \
             echo '=========================================='"]