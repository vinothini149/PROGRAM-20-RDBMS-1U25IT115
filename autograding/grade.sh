#!/bin/bash

set -e

echo "======================================"
echo " Employee Trigger Autograder"
echo "======================================"

STUDENT_FILE="starter/solution.sql"

if [ ! -f "$STUDENT_FILE" ]; then
    echo "❌ FAIL: starter/solution.sql not found."
    exit 1
fi

echo "✓ Student SQL file found."

# Create a temporary PostgreSQL database
DB_NAME="employee_trigger_test"

dropdb --if-exists "$DB_NAME" 2>/dev/null || true
createdb "$DB_NAME"

echo ""
echo "Running student SQL..."

if ! psql "$DB_NAME" -v ON_ERROR_STOP=1 -f "$STUDENT_FILE" > student_output.txt 2>&1; then
    echo "❌ FAIL: Student SQL contains errors."
    cat student_output.txt
    exit 1
fi

echo "✓ Student SQL executed successfully."

# ---------------------------------------------------------
# Check that a trigger exists
# ---------------------------------------------------------

TRIGGER_COUNT=$(psql "$DB_NAME" -tAc "
SELECT COUNT(*)
FROM pg_trigger
WHERE tgrelid = 'employee'::regclass
AND NOT tgisinternal;
")

if [ "$TRIGGER_COUNT" -lt 1 ]; then
    echo "❌ FAIL: No trigger found on Employee table."
    exit 1
fi

echo "✓ Trigger found."

# ---------------------------------------------------------
# Check trigger timing and event
# ---------------------------------------------------------

TRIGGER_INFO=$(psql "$DB_NAME" -tAc "
SELECT pg_get_triggerdef(oid)
FROM pg_trigger
WHERE tgrelid = 'employee'::regclass
AND NOT tgisinternal
LIMIT 1;
")

echo ""
echo "Trigger definition:"
echo "$TRIGGER_INFO"

if ! echo "$TRIGGER_INFO" | grep -qi "AFTER INSERT"; then
    echo "❌ FAIL: Trigger must be an AFTER INSERT trigger."
    exit 1
fi

echo "✓ AFTER INSERT trigger verified."

# ---------------------------------------------------------
# Run test cases and capture PostgreSQL NOTICE messages
# ---------------------------------------------------------

echo ""
echo "Running test cases..."

psql "$DB_NAME" > test_output.txt 2>&1 <<'SQL'
INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(101, 'Arun', 'IT', 45000.00);

INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(102, 'Priya', 'HR', 50000.00);

INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(103, 'Rahul', 'Finance', 55000.00);

INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(104, 'Meena', 'Marketing', 48000.00);
SQL

# ---------------------------------------------------------
# Validate messages
# ---------------------------------------------------------

FAILED=0

for NAME in Arun Priya Rahul Meena
do
    if grep -q "Employee inserted: $NAME" test_output.txt; then
        echo "✓ Test passed: $NAME"
    else
        echo "❌ Test failed: Expected message for $NAME"
        FAILED=1
    fi
done

# ---------------------------------------------------------
# Validate that all four rows were inserted
# ---------------------------------------------------------

ROW_COUNT=$(psql "$DB_NAME" -tAc "
SELECT COUNT(*) FROM Employee;
")

if [ "$ROW_COUNT" -eq 4 ]; then
    echo "✓ All employee records inserted successfully."
else
    echo "❌ FAIL: Expected 4 employee records, found $ROW_COUNT."
    FAILED=1
fi

# ---------------------------------------------------------
# Final result
# ---------------------------------------------------------

dropdb --if-exists "$DB_NAME" 2>/dev/null || true

echo ""
echo "======================================"

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED"
    echo "======================================"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    echo "======================================"
    exit 1
fi
