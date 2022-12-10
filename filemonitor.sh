#!/bin/bash

# Set the files to monitor
FILES=("/etc/passwd" "/etc/hosts")

# Set the interval for checking the files (in seconds)
CHECK_INTERVAL=60

# Set the email address for sending the reports
EMAIL_ADDRESS="admin@example.com"

# Set the file for storing the reports
REPORT_FILE="/var/log/file-monitor.log"

# Loop forever, checking the files at regular intervals
while true; do
  # Loop over the files to monitor
  for file in "${FILES[@]}"; do
    # Check if the file exists
    if [ -f "$file" ]; then
      # Calculate the MD5 hash of the file
      current_hash=$(md5sum "$file" | awk '{print $1}')

      # Check if the file has been checked before
      if [ -f "$file.md5" ]; then
        # Read the previous MD5 hash from the file
        previous_hash=$(cat "$file.md5")

        # Compare the current and previous hashes
        if [ "$current_hash" != "$previous_hash" ]; then
          # The file has been changed, send a report email and write to the log file
          subject="[Vulnerability Remediation] $file has been changed"
          message="The $file file has been changed on $(hostname) at $(date)."
          echo "$message" | mail -s "$subject" "$EMAIL_ADDRESS"
          echo "$message" >> "$REPORT_FILE"
        fi
      fi

      # Save the current MD5 hash to the file
      echo "$current_hash" > "$file.md5"
    fi
  done

  # Sleep for the specified interval before checking the files again
  sleep $CHECK_INTERVAL
done
