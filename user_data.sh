#!/bin/bash
set -eux

# Install Python
dnf install -y python3

# Create CPU load testing script
cat > /usr/local/bin/cpu-load.py <<'PY'
import multiprocessing
import time

def generate_load():
    end_time = time.time() + 600
    number = 0

    while time.time() < end_time:
        number = (number + 1) % 1000003

if __name__ == "__main__":
    processes = []

    for _ in range(2):
        process = multiprocessing.Process(target=generate_load)
        process.start()
        processes.append(process)

    for process in processes:
        process.join()
PY

# Start CPU load after a short delay
(
    sleep 180
    python3 /usr/local/bin/cpu-load.py
) > /var/log/cpu-load.log 2>&1 &
