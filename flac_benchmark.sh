#!/bin/bash

# Directory containing FLAC files
FLAC_DIR="."  # Change this to your actual directory

# Number of test iterations per config
ITERATIONS=3

# Test configurations: (parallel processes, threads per process)
CONFIGS=(
    "24 1"
    "12 2"
    "6 4"
    "4 6"
    "2 12"
)

LOG_FILE="flac_benchmark_results.log"
echo "Benchmarking FLAC encoding performance" > $LOG_FILE
echo "CPU: $(lscpu | grep 'Model name')" >> $LOG_FILE
echo "--------------------------------------------" >> $LOG_FILE

# Check for required utilities
if ! command -v mpstat &> /dev/null || ! command -v iostat &> /dev/null; then
    echo "Please install sysstat package: sudo apt install sysstat (or equivalent for your distro)"
    exit 1
fi

# Initialize variables for best configuration
BEST_TIME=999999
BEST_CONFIG=""
BEST_BOTTLENECK=""

# Iterate through each configuration
for CONFIG in "${CONFIGS[@]}"; do
    P_COUNT=$(echo $CONFIG | awk '{print $1}')
    T_COUNT=$(echo $CONFIG | awk '{print $2}')

    echo "Testing: -P${P_COUNT} --threads=${T_COUNT}"
    echo "Config: -P${P_COUNT} --threads=${T_COUNT}" >> $LOG_FILE

    TOTAL_TIME=0
    TOTAL_CPU_USAGE=0
    TOTAL_DISK_USAGE=0

    for i in $(seq 1 $ITERATIONS); do
        echo "  Run #$i..."

        # Clear file system cache (requires sudo)
        sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

        # Start monitoring CPU and Disk usage in the background
        MPSTAT_LOG=$(mktemp)
        IOSTAT_LOG=$(mktemp)
        mpstat 1 > "$MPSTAT_LOG" &
        iostat -xm 1 > "$IOSTAT_LOG" &
        MPSTAT_PID=$!
        IOSTAT_PID=$!

        # Run the benchmark
        START_TIME=$(date +%s)
        find "$FLAC_DIR" -type f -name "*.flac" -print0 | xargs -0 -n1 -P$P_COUNT flac -f -8 --threads=$T_COUNT --verify
        END_TIME=$(date +%s)

        # Stop monitoring
        kill $MPSTAT_PID
        kill $IOSTAT_PID

        # Compute elapsed time
        ELAPSED_TIME=$((END_TIME - START_TIME))
        TOTAL_TIME=$((TOTAL_TIME + ELAPSED_TIME))

        echo "    Time taken: ${ELAPSED_TIME} seconds" | tee -a $LOG_FILE

        # Extract CPU usage: average non-idle percentage
        AVG_CPU_USAGE=$(awk '/all/ {print 100 - $12}' "$MPSTAT_LOG" | awk '{sum+=$1} END {print sum/NR}')
        TOTAL_CPU_USAGE=$(echo "$TOTAL_CPU_USAGE + $AVG_CPU_USAGE" | bc)

        # Extract Disk Read Speed (MB/s)
        AVG_DISK_USAGE=$(awk '/sda/ {print $6}' "$IOSTAT_LOG" | awk '{sum+=$1} END {print sum/NR}')
        TOTAL_DISK_USAGE=$(echo "$TOTAL_DISK_USAGE + $AVG_DISK_USAGE" | bc)

        rm "$MPSTAT_LOG" "$IOSTAT_LOG"
    done

    # Compute average time, CPU, and Disk usage
    AVERAGE_TIME=$((TOTAL_TIME / ITERATIONS))
    AVERAGE_CPU_USAGE=$(echo "$TOTAL_CPU_USAGE / $ITERATIONS" | bc)
    AVERAGE_DISK_USAGE=$(echo "$TOTAL_DISK_USAGE / $ITERATIONS" | bc)

    # Determine bottleneck
    if (( $(echo "$AVERAGE_CPU_USAGE > 80" | bc -l) )); then
        BOTTLENECK="CPU-bound"
    elif (( $(echo "$AVERAGE_DISK_USAGE < 50" | bc -l) )); then
        BOTTLENECK="Disk-bound"
    else
        BOTTLENECK="Balanced (both CPU and disk are utilized well)"
    fi

    echo "Average time: ${AVERAGE_TIME} seconds" | tee -a $LOG_FILE
    echo "Average CPU usage: ${AVERAGE_CPU_USAGE}% | Average Disk Read Speed: ${AVERAGE_DISK_USAGE} MB/s" | tee -a $LOG_FILE
    echo "Bottleneck Analysis: ${BOTTLENECK}" | tee -a $LOG_FILE
    echo "--------------------------------------------" >> $LOG_FILE

    # Update best configuration
    if [[ $AVERAGE_TIME -lt $BEST_TIME ]]; then
        BEST_TIME=$AVERAGE_TIME
        BEST_CONFIG="-P${P_COUNT} --threads=${T_COUNT}"
        BEST_BOTTLENECK=$BOTTLENECK
    fi
done

# Provide the best recommendation
echo "" | tee -a $LOG_FILE
echo "===== OPTIMAL CONFIGURATION RECOMMENDATION =====" | tee -a $LOG_FILE
echo "Best Configuration: $BEST_CONFIG" | tee -a $LOG_FILE
echo "Achieved Time: $BEST_TIME seconds" | tee -a $LOG_FILE
echo "Primary Bottleneck: $BEST_BOTTLENECK" | tee -a $LOG_FILE

# Suggest tuning adjustments based on bottleneck
if [[ $BEST_BOTTLENECK == "CPU-bound" ]]; then
    echo "Recommendation: Reduce the number of parallel FLAC instances (-P) and increase --threads per instance." | tee -a $LOG_FILE
elif [[ $BEST_BOTTLENECK == "Disk-bound" ]]; then
    echo "Recommendation: Increase the number of parallel FLAC instances (-P) and reduce --threads per instance to reduce disk contention." | tee -a $LOG_FILE
else
    echo "Recommendation: Your current best configuration is well-balanced." | tee -a $LOG_FILE
fi

echo "=================================================" | tee -a $LOG_FILE
