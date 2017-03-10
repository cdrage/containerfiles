#!/bin/bash
set -e

# Replace with the appropriate environment variables
sed -i "s,%MM_USER%,$MM_USER,g" "/config.ini" 
sed -i "s,%MM_PASS%,$MM_PASS,g" "/config.ini" 
sed -i "s,%MM_HOST%,$MM_HOST,g" "/config.ini" 
sed -i "s,%MM_PORT%,$MM_PORT,g" "/config.ini" 

exec "$@"
