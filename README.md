# SeeYouCM-Thief_Bash
- Remake of the SeeYouCM-Theif by TrustedSec - Only used for username enumeration

# CUCM User Identifier Script

- This script is designed to interact with the Cisco Unified Communications Manager (CUCM) server to retrieve usernames. It uses HTTP requests to query user information and can be customized to connect on different ports.

## Features

- Fetches usernames from a specified CUCM server.
- Supports both IP addresses and hostnames.
- Allows for custom port configuration (default is 443).
- Displays curl commands in debug mode.
- Provides a loading bar for user feedback during execution.
- Outputs found usernames to a file named after the CUCM host.

## Prerequisites

- Ensure you have `bash`, `curl`, and `grep` installed on your system.
- The script may require appropriate permissions to execute.

## Usage

```bash
./cucm_thief_bash.sh <CUCM_host> [port] [-debug] [-h]
```

### Arguments
- <CUCM_host>: The IP address or hostname of the CUCM server.
- [port]: Optional. The port number to connect to (default is 443).
- [-debug]: Optional. Displays curl commands when executing.
- [-h]: Displays the help menu.

## Output
- The script saves the retrieved usernames to a file named <CUCM_host>_usernames.txt, where <CUCM_host> is the IP address or hostname of the CUCM server.

## License
- This project is licensed under the MIT License. 

## Acknowledgments
- https://github.com/trustedsec/SeeYouCM-Thief/tree/main
