#!/bin/bash

# Local Variables
SUCCESSFUL="Successful"
FAILURE="Failure"

# ADD
echo "Starging Add..."
git add .
if [ $? -eq 0 ]
then
	echo "Add $SUCCESSFUL"
else
	echo "Add $FAILURE"
fi

# COMMIT
echo "Starting Commit..."
git commit -m "$1"
if [ $? -eq 0 ]
then
	echo "Commit $SUCCESSFUL"
else
	echo "Commit $FAILURE"
fi

# PULL
echo "Starting Pull..."
git pull origin
if [ $? -eq 0 ]
then
	echo "Pull $SUCCESSFUL"
else
	echo "Pull $FAILURE"
fi

# END
echo "Finished!"

