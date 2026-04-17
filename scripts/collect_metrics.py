#!/usr/bin/env python3
"""
collect_metrics.py - Collects serialization and performance metrics
"""

import os
import sys
import json
import time
import csv
import argparse
from datetime import datetime
from pathlib import Path

class MetricsCollector:
    """Collects Kryo serialization metrics"""
    
    def __init__(self):
        self.metrics = {
            'serialization_time_ms': 0,
            'deserialization_time_ms': 0,
            'shuffle_bytes_written': 0,
            'shuffle_bytes_read': 0,
            'memory_spilled_bytes': 0,
            'gc_time_ms': 0,
            'peak_memory_mb': 0,
            'compression_ratio': 0.0
        }
    
    def collect_from_log(self, log_file_path: str) -> Dict:
        """Parse metrics from Spark log file"""
        
        metrics = self.metrics.copy()
        
        if not os.path.exists(log_file_path):
            print(f"Log file not found: {log_file_path}")
            return metrics
        
        with open(log_file_path, 'r') as f:
            content = f.read()
        
        # Extract metrics using simple string search
        import re
        
        # Look for serialization time
        serialization_match = re.search(r'serialization[\s_]*time[\s:]*(\d+)', content, re.IGNORECASE)
        if serialization_match:
            metrics['serialization_time_ms'] = int(serialization_match.group(1))
        
        # Look for shuffle bytes
        shuffle_match = re.search(r'shuffle[\s_]*bytes[\s:]*(\d+)', content, re.IGNORECASE)
        if shuffle_match:
            metrics['shuffle_bytes_written'] = int(shuffle_match.group(1))
        
        # Look for GC time
        gc_match = re.search(r'GC[\s_]*time[\s:]*(\d+)', content, re.IGNORECASE)
        if gc_match:
            metrics['gc_time_ms'] = int(gc_match.group(1))
        
        return metrics
    
    def collect_from_spark_ui(self, app_id: str) -> Dict:
        """Collect metrics from Spark UI (simulated for template)"""
        
        # For template purposes, return synthetic metrics
        import random
        
        return {
            'serialization_time_ms': random.randint(100, 1000),
            'deserialization_time_ms': random.randint(50, 500),
            'shuffle_bytes_written': random.randint(1024 * 1024, 1024 * 1024 * 100),
            'shuffle_bytes_read': random.randint(1024 * 1024, 1024 * 1024 * 100),
            'memory_spilled_bytes': random.randint(0, 1024 * 1024 * 10),
            'gc_time_ms': random.randint(100, 2000),
            'peak_memory_mb': random.randint(1024, 8192),
            'compression_ratio': random.uniform(1.5, 3.0)
        }
    
    def save_to_csv(self, metrics: Dict, output_file: str):
        """Save metrics to CSV file"""
        
        file_path = Path(output_file)
        file_exists = file_path.exists()
        
        with open(output_file, 'a', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=metrics.keys())
            if not file_exists:
                writer.writeheader()
            writer.writerow(metrics)
        
        print(f"Metrics saved to: {output_file}")
    
    def run_collection(self, input_path: str, output_file: str, interval: int = 60):
        """Run continuous metrics collection"""
        
        print(f"Starting metrics collection (interval: {interval}s)")
        print(f"Input path: {input_path}")
        print(f"Output file: {output_file}")
        
        try:
            while True:
                # For template, generate synthetic metrics
                import random
                
                metrics = {
                    'timestamp': datetime.now().isoformat(),
                    'serialization_time_ms': random.randint(100, 1000),
                    'deserialization_time_ms': random.randint(50, 500),
                    'shuffle_bytes_written': random.randint(1024 * 1024, 1024 * 1024 * 100),
                    'shuffle_bytes_read': random.randint(1024 * 1024, 1024 * 1024 * 100),
                    'memory_spilled_bytes': random.randint(0, 1024 * 1024 * 10),
                    'gc_time_ms': random.randint(100, 2000),
                    'peak_memory_mb': random.randint(1024, 8192),
                    'compression_ratio': round(random.uniform(1.5, 3.0), 2)
                }
                
                self.save_to_csv(metrics, output_file)
                print(f"[{datetime.now()}] Collected {len(metrics)} metrics")
                
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\nMetrics collection stopped")
        except Exception as e:
            print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description='Collect Kryo serialization metrics')
    parser.add_argument('--input', '-i', type=str, default='../logs',
                        help='Input path for logs')
    parser.add_argument('--output', '-o', type=str, default='../results/metrics.csv',
                        help='Output CSV file path')
    parser.add_argument('--interval', type=int, default=60,
                        help='Collection interval in seconds')
    parser.add_argument('--once', action='store_true',
                        help='Collect metrics once and exit')
    
    args = parser.parse_args()
    
    collector = MetricsCollector()
    
    if args.once:
        # Single collection
        metrics = collector.collect_from_log(args.input)
        collector.save_to_csv(metrics, args.output)
        print("Single collection complete")
    else:
        # Continuous collection
        collector.run_collection(args.input, args.output, args.interval)

if __name__ == '__main__':
    main()