#!/bin/bash
# health.sh is a simple health check script to ensure network connectivity exits.
# If this fails, it is expected that the container orchestrator will restart the container.
ping -I tun0 -c 1 google.com
