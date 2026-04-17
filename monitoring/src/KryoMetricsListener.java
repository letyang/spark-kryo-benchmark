// KryoMetricsListener.java - Custom Spark listener for Kryo serialization metrics
// Compile: javac -cp "$SPARK_HOME/jars/*" KryoMetricsListener.java

package com.example.spark.monitoring;

import org.apache.spark.scheduler.*;
import org.apache.spark.sql.SparkSession;
import javax.management.*;
import java.lang.management.ManagementFactory;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * SparkListener that collects detailed Kryo serialization metrics
 * and exposes them via JMX for external monitoring.
 */
public class KryoMetricsListener extends SparkListener implements KryoMetricsListenerMBean {
    
    // JMX Bean interface
    public interface KryoMetricsListenerMBean {
        long getTotalSerializationTime();
        long getTotalDeserializationTime();
        long getKryoBufferCapacity();
        long getKryoBufferUsed();
        long getRegistrationHits();
        long getRegistrationMisses();
        double getAverageCompressionRatio();
        void resetMetrics();
    }
    
    // Metrics storage
    private final AtomicLong totalSerializationTime = new AtomicLong(0);
    private final AtomicLong totalDeserializationTime = new AtomicLong(0);
    private final AtomicLong kryoBufferCapacity = new AtomicLong(0);
    private final AtomicLong kryoBufferUsed = new AtomicLong(0);
    private final AtomicLong registrationHits = new AtomicLong(0);
    private final AtomicLong registrationMisses = new AtomicLong(0);
    private final AtomicLong totalCompressionRatio = new AtomicLong(0);
    private final AtomicLong compressionSampleCount = new AtomicLong(0);
    
    // Per-stage metrics
    private final ConcurrentHashMap<Integer, StageMetrics> stageMetrics = new ConcurrentHashMap<>();
    
    public KryoMetricsListener() {
        registerJMX();
        System.out.println("[KryoMetrics] Listener created and JMX registered");
    }
    
    private void registerJMX() {
        try {
            MBeanServer mbs = ManagementFactory.getPlatformMBeanServer();
            ObjectName name = new ObjectName("com.example.spark:type=KryoMetricsListener");
            if (!mbs.isRegistered(name)) {
                mbs.registerMBean(this, name);
                System.out.println("[KryoMetrics] Registered JMX MBean");
            }
        } catch (Exception e) {
            System.err.println("[KryoMetrics] Failed to register JMX MBean: " + e.getMessage());
        }
    }
    
    @Override
    public void onStageSubmitted(SparkListenerStageSubmitted stageSubmitted) {
        StageInfo stageInfo = stageSubmitted.stageInfo();
        StageMetrics metrics = new StageMetrics(stageInfo.stageId(), stageInfo.name());
        stageMetrics.put(stageInfo.stageId(), metrics);
        
        System.out.println(String.format(
            "[KryoMetrics] Stage %d (%s) submitted - serialization heavy: %b",
            stageInfo.stageId(), stageInfo.name(), isShuffleHeavy(stageInfo)
        ));
    }
    
    @Override
    public void onStageCompleted(SparkListenerStageCompleted stageCompleted) {
        StageInfo stageInfo = stageCompleted.stageInfo();
        StageMetrics metrics = stageMetrics.remove(stageInfo.stageId());
        
        if (metrics != null) {
            totalSerializationTime.addAndGet(metrics.serializationTime);
            totalDeserializationTime.addAndGet(metrics.deserializationTime);
            
            System.out.println(String.format(
                "[KryoMetrics] Stage %d completed - serialization: %d ms, deserialization: %d ms",
                stageInfo.stageId(), metrics.serializationTime, metrics.deserializationTime
            ));
        }
    }
    
    @Override
    public void onTaskEnd(SparkListenerTaskEnd taskEnd) {
        TaskInfo taskInfo = taskEnd.taskInfo();
        TaskMetrics taskMetrics = taskEnd.taskMetrics();
        
        StageMetrics metrics = stageMetrics.get(taskEnd.stageId());
        if (metrics != null && taskMetrics != null) {
            // Accumulate serialization metrics from tasks
            if (taskMetrics.shuffleWriteMetrics() != null) {
                metrics.serializationTime += taskMetrics.shuffleWriteMetrics().serializeTime();
            }
            if (taskMetrics.shuffleReadMetrics() != null) {
                metrics.deserializationTime += taskMetrics.shuffleReadMetrics().fetchWaitTime();
            }
        }
    }
    
    /**
     * Record Kryo registration event (called from custom Kryo registrator)
     */
    public void recordRegistration(boolean isHit) {
        if (isHit) {
            registrationHits.incrementAndGet();
        } else {
            registrationMisses.incrementAndGet();
        }
    }
    
    /**
     * Record compression ratio achieved
     */
    public void recordCompressionRatio(double ratio) {
        totalCompressionRatio.addAndGet((long)(ratio * 1000));
        compressionSampleCount.incrementAndGet();
    }
    
    /**
     * Update Kryo buffer usage metrics
     */
    public void updateBufferMetrics(long capacity, long used) {
        kryoBufferCapacity.set(capacity);
        kryoBufferUsed.set(used);
    }
    
    // JMX MBean implementations
    @Override
    public long getTotalSerializationTime() {
        return totalSerializationTime.get();
    }
    
    @Override
    public long getTotalDeserializationTime() {
        return totalDeserializationTime.get();
    }
    
    @Override
    public long getKryoBufferCapacity() {
        return kryoBufferCapacity.get();
    }
    
    @Override
    public long getKryoBufferUsed() {
        return kryoBufferUsed.get();
    }
    
    @Override
    public long getRegistrationHits() {
        return registrationHits.get();
    }
    
    @Override
    public long getRegistrationMisses() {
        return registrationMisses.get();
    }
    
    @Override
    public double getAverageCompressionRatio() {
        long samples = compressionSampleCount.get();
        if (samples == 0) return 0.0;
        return totalCompressionRatio.get() / (double) samples / 1000.0;
    }
    
    @Override
    public void resetMetrics() {
        totalSerializationTime.set(0);
        totalDeserializationTime.set(0);
        kryoBufferCapacity.set(0);
        kryoBufferUsed.set(0);
        registrationHits.set(0);
        registrationMisses.set(0);
        totalCompressionRatio.set(0);
        compressionSampleCount.set(0);
    }
    
    /**
     * Determine if a stage is likely serialization-heavy based on shuffle operations
     */
    private boolean isShuffleHeavy(StageInfo stageInfo) {
        // Heuristic: stages with many tasks or shuffle dependencies are serialization-heavy
        return stageInfo.numTasks() > 100 || 
               (stageInfo.name() != null && (
                   stageInfo.name().contains("shuffle") ||
                   stageInfo.name().contains("exchange") ||
                   stageInfo.name().contains("join")
               ));
    }
    
    /**
     * Inner class for per-stage metrics
     */
    private static class StageMetrics {
        final int stageId;
        final String stageName;
        long serializationTime = 0;
        long deserializationTime = 0;
        
        StageMetrics(int stageId, String stageName) {
            this.stageId = stageId;
            this.stageName = stageName != null ? stageName : "unknown";
        }
    }
    
    /**
     * Factory method to create and register listener with SparkSession
     * 
     * Usage in Spark application:
     *   import com.example.spark.monitoring.KryoMetricsListener;
     *   KryoMetricsListener listener = KryoMetricsListener.register(spark);
     */
    public static KryoMetricsListener register(SparkSession spark) {
        KryoMetricsListener listener = new KryoMetricsListener();
        spark.sparkContext().addSparkListener(listener);
        System.out.println("[KryoMetrics] Listener registered with SparkSession");
        return listener;
    }
    
    /**
     * Get singleton instance (if needed)
     */
    private static KryoMetricsListener instance = null;
    
    public static KryoMetricsListener getInstance() {
        if (instance == null) {
            instance = new KryoMetricsListener();
        }
        return instance;
    }
}