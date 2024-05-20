#!/bin/bash

test_dir="./testfile"

# compile the program
make clean all

# test all files in the test data directory
for i in "$test_dir"/*; do
	echo "Testing $i"
	./a.out <"$i"
	echo ""
	echo "---------------------------------"
	echo ""
done
