#!/bin/bash

echo "Script to automate Add, Commit, Pull, Push and Status git commands sequence."

if [ "$1" == "" ] || [ "$2" == "" ] ; then
	echo "Use:"
	echo "gitacp <wilcard> <\"commit comment\">"
	echo "Example:"
	echo "gitacp . \"Added all new files and some new commnets to the project.\""
else
	# Local Variables
	SUCCESSFUL="Successful"
	FAILURE="Failure"

	# ADD
	echo "Starging Add..."
	git add $1
	if [ $? -eq 0 ]
	then
		echo "Add $SUCCESSFUL"
	else
		echo "Add $FAILURE"
	fi

	# COMMIT
	echo "Starting Commit..."
	git commit -m "$2"
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

	# PUSH
	echo "Starting Push..."
	git push
	if [ $? -eq 0 ]
	then
		echo "Push $SUCCESSFUL"
	else
		echo "Push $FAILURE"
	fi

	# END
	echo "Finished!"
fi

git status

