#!/bin/sh

# Access the 'task_request' input
echo "Task Request: $TASK_REQUEST" > task.txt
echo "Validation: $VALIDATION" > validation.txt
 
# Start the Goose session in the background
cd $GITHUB_WORKSPACE

goose session start --plan plan.yaml &
GOOSE_PID=$!

# Poll for success or failure file
while true; do
    if [ -f ./success ]; then
        echo "Goose session succeeded"
        rm task.txt
        rm validation.txt
        rm -f success
        rm -f failure
        rm plan.yaml
        rm entrypoint.sh
        exit 0
    elif [ -f ./failure ]; then
        echo "Goose session failed"
        exit 1
    fi
    sleep 10  # Adjust the sleep interval as needed
done

# Ensure to kill Goose process at the end
kill -9 $GOOSE_PID


