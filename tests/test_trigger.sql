-- =========================================================
-- TEST CASES FOR EMPLOYEE INSERT TRIGGER
-- =========================================================

-- Clean previous data
DELETE FROM Employee;

-- ---------------------------------------------------------
-- Test Case 1
-- ---------------------------------------------------------
INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(101, 'Arun', 'IT', 45000.00);

-- Expected output:
-- Employee inserted: Arun


-- ---------------------------------------------------------
-- Test Case 2
-- ---------------------------------------------------------
INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(102, 'Priya', 'HR', 50000.00);

-- Expected output:
-- Employee inserted: Priya


-- ---------------------------------------------------------
-- Test Case 3
-- ---------------------------------------------------------
INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(103, 'Rahul', 'Finance', 55000.00);

-- Expected output:
-- Employee inserted: Rahul


-- ---------------------------------------------------------
-- Test Case 4
-- ---------------------------------------------------------
INSERT INTO Employee
(emp_id, emp_name, department, salary)
VALUES
(104, 'Meena', 'Marketing', 48000.00);

-- Expected output:
-- Employee inserted: Meena
