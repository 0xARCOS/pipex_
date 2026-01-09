#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to compare files
compare_outputs() {
    if diff -q "$1" "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Test passed${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ Test failed${NC}"
        echo "Expected:"
        cat "$2"
        echo "Got:"
        cat "$1"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "Running pipex tests..."
echo "====================="

# Test 1: Basic cat and wc -l
echo -n "Test 1: cat | wc -l ... "
./pipex infile "cat" "wc -l" /tmp/pipex_out1
cat infile | wc -l > /tmp/expected_out1
compare_outputs /tmp/pipex_out1 /tmp/expected_out1

# Test 2: grep filter
echo -n "Test 2: cat | grep pipex ... "
./pipex infile "cat" "grep pipex" /tmp/pipex_out2
cat infile | grep pipex > /tmp/expected_out2
compare_outputs /tmp/pipex_out2 /tmp/expected_out2

# Test 3: ls and grep
echo -n "Test 3: ls -la | grep pipex ... "
./pipex infile "ls -la" "grep pipex" /tmp/pipex_out3
ls -la | grep pipex > /tmp/expected_out3
compare_outputs /tmp/pipex_out3 /tmp/expected_out3

# Test 4: cat and head
echo -n "Test 4: cat | head -n 3 ... "
./pipex infile "cat" "head -n 3" /tmp/pipex_out4
cat infile | head -n 3 > /tmp/expected_out4
compare_outputs /tmp/pipex_out4 /tmp/expected_out4

# Test 5: cat and tail
echo -n "Test 5: cat | tail -n 2 ... "
./pipex infile "cat" "tail -n 2" /tmp/pipex_out5
cat infile | tail -n 2 > /tmp/expected_out5
compare_outputs /tmp/pipex_out5 /tmp/expected_out5

# Cleanup
rm -f /tmp/pipex_out* /tmp/expected_out*

echo "====================="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
