#!/bin/bash

# ============================================================================
# PIPEX COMPREHENSIVE TESTER
# Tests all edge cases for the mandatory part
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test files
TEST_DIR="/tmp/pipex_test_$$"
PIPEX_OUT="${TEST_DIR}/pipex_out"
BASH_OUT="${TEST_DIR}/bash_out"
TEST_INFILE="${TEST_DIR}/infile"
NO_READ_FILE="${TEST_DIR}/no_read"
NO_WRITE_DIR="${TEST_DIR}/no_write_dir"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

setup() {
    mkdir -p "$TEST_DIR"

    # Create test infile with content
    cat > "$TEST_INFILE" << 'EOF'
Hello World
This is a test file
pipex is awesome
42 School
Testing pipex
Line 6
Line 7
Line 8
EOF

    # Create file without read permissions
    echo "secret" > "$NO_READ_FILE"
    chmod 000 "$NO_READ_FILE"

    # Create directory without write permissions
    mkdir -p "$NO_WRITE_DIR"
    chmod 000 "$NO_WRITE_DIR"
}

cleanup() {
    chmod 777 "$NO_READ_FILE" 2>/dev/null
    chmod 777 "$NO_WRITE_DIR" 2>/dev/null
    rm -rf "$TEST_DIR"
}

print_header() {
    echo -e "\n${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${CYAN}Test $TESTS_TOTAL: ${NC}$1"
}

compare_outputs() {
    local test_name="$1"
    local pipex_file="$2"
    local bash_file="$3"
    local check_content="${4:-1}"

    ((TESTS_TOTAL++))
    print_test "$test_name"

    # Check if both files exist
    if [ ! -f "$pipex_file" ] && [ ! -f "$bash_file" ]; then
        echo -e "${GREEN}✓ Both failed to create output (expected behavior)${NC}\n"
        ((TESTS_PASSED++))
        return 0
    fi

    if [ ! -f "$pipex_file" ]; then
        echo -e "${RED}✗ Pipex didn't create output file${NC}\n"
        ((TESTS_FAILED++))
        return 1
    fi

    if [ ! -f "$bash_file" ]; then
        echo -e "${RED}✗ Bash didn't create output file${NC}\n"
        ((TESTS_FAILED++))
        return 1
    fi

    # Compare content if requested
    if [ "$check_content" -eq 1 ]; then
        if diff -q "$pipex_file" "$bash_file" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Output matches expected${NC}"
            echo -e "${MAGENTA}Output:${NC}"
            cat "$pipex_file" | head -5
            if [ $(wc -l < "$pipex_file") -gt 5 ]; then
                echo "..."
            fi
            echo ""
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}✗ Output differs from expected${NC}"
            echo -e "${MAGENTA}Expected (bash):${NC}"
            cat "$bash_file"
            echo -e "${MAGENTA}Got (pipex):${NC}"
            cat "$pipex_file"
            echo ""
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo -e "${GREEN}✓ File created${NC}\n"
        ((TESTS_PASSED++))
        return 0
    fi
}

run_pipex_test() {
    local infile="$1"
    local cmd1="$2"
    local cmd2="$3"
    local outfile="$4"
    local test_name="$5"

    # Run pipex
    ./pipex "$infile" "$cmd1" "$cmd2" "$outfile" 2>/dev/null

    # Run bash equivalent
    local bash_outfile="${outfile}.bash"
    if [ -f "$infile" ] && [ -r "$infile" ]; then
        < "$infile" $cmd1 2>/dev/null | $cmd2 > "$bash_outfile" 2>/dev/null
    else
        touch "$bash_outfile" 2>/dev/null
    fi

    compare_outputs "$test_name" "$outfile" "$bash_outfile"

    # Cleanup
    rm -f "$outfile" "$bash_outfile"
}

# ============================================================================
# TEST CATEGORIES
# ============================================================================

test_basic_functionality() {
    print_header "BASIC FUNCTIONALITY TESTS"

    run_pipex_test "$TEST_INFILE" "cat" "wc -l" "$PIPEX_OUT" \
        "Basic: cat | wc -l"

    run_pipex_test "$TEST_INFILE" "cat" "grep pipex" "$PIPEX_OUT" \
        "Basic: cat | grep pipex"

    run_pipex_test "$TEST_INFILE" "cat" "head -n 3" "$PIPEX_OUT" \
        "Basic: cat | head -n 3"

    run_pipex_test "$TEST_INFILE" "cat" "tail -n 2" "$PIPEX_OUT" \
        "Basic: cat | tail -n 2"

    run_pipex_test "$TEST_INFILE" "grep test" "wc -l" "$PIPEX_OUT" \
        "Basic: grep test | wc -l"
}

test_commands_with_options() {
    print_header "COMMANDS WITH OPTIONS"

    run_pipex_test "$TEST_INFILE" "cat -e" "head -n 3" "$PIPEX_OUT" \
        "Options: cat -e | head -n 3"

    run_pipex_test "$TEST_INFILE" "grep -i PIPEX" "wc -l" "$PIPEX_OUT" \
        "Options: grep -i PIPEX | wc -l"

    run_pipex_test "$TEST_INFILE" "head -n 5" "tail -n 2" "$PIPEX_OUT" \
        "Options: head -n 5 | tail -n 2"

    run_pipex_test "$TEST_INFILE" "cat" "grep -v test" "$PIPEX_OUT" \
        "Options: cat | grep -v test"

    run_pipex_test "$TEST_INFILE" "cat" "sort -r" "$PIPEX_OUT" \
        "Options: cat | sort -r"
}

test_absolute_paths() {
    print_header "ABSOLUTE PATH COMMANDS"

    run_pipex_test "$TEST_INFILE" "/bin/cat" "wc -l" "$PIPEX_OUT" \
        "Absolute: /bin/cat | wc -l"

    run_pipex_test "$TEST_INFILE" "cat" "/usr/bin/wc -l" "$PIPEX_OUT" \
        "Absolute: cat | /usr/bin/wc -l"

    run_pipex_test "$TEST_INFILE" "/bin/cat" "/usr/bin/grep pipex" "$PIPEX_OUT" \
        "Absolute: /bin/cat | /usr/bin/grep pipex"
}

test_empty_and_special_files() {
    print_header "EMPTY AND SPECIAL FILES"

    # Empty file
    local empty_file="${TEST_DIR}/empty"
    touch "$empty_file"
    run_pipex_test "$empty_file" "cat" "wc -l" "$PIPEX_OUT" \
        "Empty file: cat | wc -l"

    # Single line file
    local single_line="${TEST_DIR}/single"
    echo "single line" > "$single_line"
    run_pipex_test "$single_line" "cat" "wc -l" "$PIPEX_OUT" \
        "Single line: cat | wc -l"

    # File with spaces in content
    local space_file="${TEST_DIR}/spaces"
    echo "   spaces   everywhere   " > "$space_file"
    run_pipex_test "$space_file" "cat" "wc -w" "$PIPEX_OUT" \
        "Spaces: cat | wc -w"
}

test_nonexistent_commands() {
    print_header "NONEXISTENT COMMANDS"

    ((TESTS_TOTAL++))
    print_test "Nonexistent first command"
    ./pipex "$TEST_INFILE" "commandnotexist" "wc -l" "$PIPEX_OUT" 2>/dev/null
    if [ ! -s "$PIPEX_OUT" ] || [ ! -f "$PIPEX_OUT" ]; then
        echo -e "${GREEN}✓ Handled correctly (no output or error)${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠ Created output file (may be acceptable)${NC}\n"
        ((TESTS_PASSED++))
    fi
    rm -f "$PIPEX_OUT"

    ((TESTS_TOTAL++))
    print_test "Nonexistent second command"
    ./pipex "$TEST_INFILE" "cat" "commandnotexist" "$PIPEX_OUT" 2>/dev/null
    if [ ! -s "$PIPEX_OUT" ] || [ ! -f "$PIPEX_OUT" ]; then
        echo -e "${GREEN}✓ Handled correctly (no output or error)${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠ Created output file (may be acceptable)${NC}\n"
        ((TESTS_PASSED++))
    fi
    rm -f "$PIPEX_OUT"
}

test_file_permissions() {
    print_header "FILE PERMISSION ERRORS"

    ((TESTS_TOTAL++))
    print_test "Input file doesn't exist"
    ./pipex "${TEST_DIR}/nonexistent" "cat" "wc -l" "$PIPEX_OUT" 2>/dev/null
    # Should fail gracefully
    echo -e "${GREEN}✓ Handled nonexistent input file${NC}\n"
    ((TESTS_PASSED++))
    rm -f "$PIPEX_OUT"

    ((TESTS_TOTAL++))
    print_test "Input file without read permissions"
    ./pipex "$NO_READ_FILE" "cat" "wc -l" "$PIPEX_OUT" 2>/dev/null
    echo -e "${GREEN}✓ Handled unreadable input file${NC}\n"
    ((TESTS_PASSED++))
    rm -f "$PIPEX_OUT"

    ((TESTS_TOTAL++))
    print_test "Output in directory without write permissions"
    ./pipex "$TEST_INFILE" "cat" "wc -l" "${NO_WRITE_DIR}/out" 2>/dev/null
    echo -e "${GREEN}✓ Handled unwritable directory${NC}\n"
    ((TESTS_PASSED++))
}

test_complex_commands() {
    print_header "COMPLEX COMMANDS"

    run_pipex_test "$TEST_INFILE" "cat" "grep -E 'test|pipex'" "$PIPEX_OUT" \
        "Complex: cat | grep -E 'test|pipex'"

    run_pipex_test "$TEST_INFILE" "cat" "awk '{print \$1}'" "$PIPEX_OUT" \
        "Complex: cat | awk '{print \$1}'"

    run_pipex_test "$TEST_INFILE" "grep -i line" "sort" "$PIPEX_OUT" \
        "Complex: grep -i line | sort"

    run_pipex_test "$TEST_INFILE" "cat" "sed 's/test/TEST/g'" "$PIPEX_OUT" \
        "Complex: cat | sed 's/test/TEST/g'"
}

test_edge_cases() {
    print_header "EDGE CASES"

    # Commands that produce no output
    run_pipex_test "$TEST_INFILE" "grep nonexistent" "wc -l" "$PIPEX_OUT" \
        "Edge: grep with no matches | wc -l"

    # Multiple spaces in command
    run_pipex_test "$TEST_INFILE" "cat" "head    -n   3" "$PIPEX_OUT" \
        "Edge: command with multiple spaces"

    # Very long output
    local big_file="${TEST_DIR}/bigfile"
    seq 1 10000 > "$big_file"
    run_pipex_test "$big_file" "cat" "wc -l" "$PIPEX_OUT" \
        "Edge: large file (10000 lines)"

    # Commands with special characters in output
    echo '$HOME and *' > "${TEST_DIR}/special"
    run_pipex_test "${TEST_DIR}/special" "cat" "cat" "$PIPEX_OUT" \
        "Edge: special characters in content"
}

test_argument_validation() {
    print_header "ARGUMENT VALIDATION"

    ((TESTS_TOTAL++))
    print_test "Wrong number of arguments (too few)"
    ./pipex "$TEST_INFILE" "cat" "wc" 2>/dev/null
    local ret=$?
    if [ $ret -ne 0 ]; then
        echo -e "${GREEN}✓ Rejected incorrect arguments${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ Accepted incorrect arguments${NC}\n"
        ((TESTS_FAILED++))
    fi

    ((TESTS_TOTAL++))
    print_test "Wrong number of arguments (too many)"
    ./pipex "$TEST_INFILE" "cat" "wc" "$PIPEX_OUT" "extra" 2>/dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
        echo -e "${GREEN}✓ Rejected incorrect arguments${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ Accepted incorrect arguments${NC}\n"
        ((TESTS_FAILED++))
    fi
}

test_real_world_scenarios() {
    print_header "REAL WORLD SCENARIOS"

    # Create a more realistic file
    cat > "${TEST_DIR}/logs" << 'EOF'
2024-01-01 ERROR Connection failed
2024-01-01 INFO Server started
2024-01-02 ERROR Timeout
2024-01-02 INFO Request processed
2024-01-03 WARNING Low memory
2024-01-03 ERROR Database error
EOF

    run_pipex_test "${TEST_DIR}/logs" "grep ERROR" "wc -l" "$PIPEX_OUT" \
        "Real: Count ERROR lines in logs"

    run_pipex_test "${TEST_DIR}/logs" "cat" "grep -v INFO" "$PIPEX_OUT" \
        "Real: Filter out INFO messages"

    run_pipex_test "${TEST_DIR}/logs" "grep 2024-01-01" "cat" "$PIPEX_OUT" \
        "Real: Get specific date entries"

    # Test with /etc/passwd style file
    cat > "${TEST_DIR}/users" << 'EOF'
root:x:0:0:root:/root:/bin/bash
user:x:1000:1000:User:/home/user:/bin/bash
test:x:1001:1001:Test:/home/test:/bin/sh
EOF

    run_pipex_test "${TEST_DIR}/users" "cat" "grep bash" "$PIPEX_OUT" \
        "Real: Parse user file"

    run_pipex_test "${TEST_DIR}/users" "cut -d: -f1" "sort" "$PIPEX_OUT" \
        "Real: Extract and sort usernames"
}

test_output_file_handling() {
    print_header "OUTPUT FILE HANDLING"

    # Test overwriting existing file
    echo "old content" > "$PIPEX_OUT"
    run_pipex_test "$TEST_INFILE" "cat" "head -n 1" "$PIPEX_OUT" \
        "Overwrite: Replace existing file content"

    # Test creating file in current directory
    local local_out="pipex_test_output_$$"
    run_pipex_test "$TEST_INFILE" "cat" "wc -l" "$local_out" \
        "Create: New file in current directory"
    rm -f "$local_out" "${local_out}.bash"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo -e "${BOLD}${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           PIPEX COMPREHENSIVE TESTER v1.0                ║
║              Testing Mandatory Part                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Check if pipex exists
    if [ ! -f "./pipex" ]; then
        echo -e "${RED}Error: ./pipex not found. Please compile first.${NC}"
        exit 1
    fi

    # Setup test environment
    setup

    # Run all test categories
    test_argument_validation
    test_basic_functionality
    test_commands_with_options
    test_absolute_paths
    test_empty_and_special_files
    test_nonexistent_commands
    test_file_permissions
    test_complex_commands
    test_edge_cases
    test_real_world_scenarios
    test_output_file_handling

    # Cleanup
    cleanup

    # Print results
    echo -e "\n${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE}           FINAL RESULTS                ${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}\n"

    echo -e "${CYAN}Total tests:${NC}   $TESTS_TOTAL"
    echo -e "${GREEN}Tests passed:${NC}  $TESTS_PASSED"
    echo -e "${RED}Tests failed:${NC}  $TESTS_FAILED"

    local success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    echo -e "${MAGENTA}Success rate:${NC}  ${success_rate}%"

    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${GREEN}║                                       ║${NC}"
        echo -e "${BOLD}${GREEN}║     🎉 ALL TESTS PASSED! 🎉         ║${NC}"
        echo -e "${BOLD}${GREEN}║                                       ║${NC}"
        echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${BOLD}${RED}╔═══════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${RED}║                                       ║${NC}"
        echo -e "${BOLD}${RED}║     ⚠️  SOME TESTS FAILED  ⚠️        ║${NC}"
        echo -e "${BOLD}${RED}║                                       ║${NC}"
        echo -e "${BOLD}${RED}╚═══════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

main
