-- ============================================================
-- Шаг 3. Нормализация до 3NF: создание 3 таблиц
--   departments     — справочник отделов (department_id → department_name)
--   employees       — справочник сотрудников (employee_id → employee_name,
--                     department_id; убрали транзитивную зависимость
--                     employee_id → department_name через department_id)
--   employee_sales  — продажи по месяцам ((employee_id, sales_month) → sales)
-- ============================================================

USE staff_norm;

-- Справочник отделов (PK: department_id)
CREATE TABLE departments (
    department_id   INT          NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (department_id)
);

-- Справочник сотрудников (PK: employee_id, FK: department_id -> departments)
CREATE TABLE employees (
    employee_id   INT          NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT          NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

-- Продажи по месяцам (PK составной: (employee_id, sales_month))
CREATE TABLE employee_sales (
    employee_id INT           NOT NULL,
    sales_month DATE          NOT NULL,
    sales       DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (employee_id, sales_month),
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

-- ------------------------------------------------------------
-- Перенос данных из «плохой» таблицы (INSERT ... SELECT)
-- ------------------------------------------------------------

-- 1. Уникальные отделы -> departments
INSERT INTO departments (department_id, department_name)
SELECT DISTINCT department_id, department_name
FROM employees_bad
WHERE department_id IS NOT NULL;

-- 2. Уникальные сотрудники -> employees
INSERT INTO employees (employee_id, employee_name, department_id)
SELECT DISTINCT employee_id, employee_name, department_id
FROM employees_bad
WHERE employee_id IS NOT NULL;

-- 3. Продажи по месяцам -> employee_sales
INSERT INTO employee_sales (employee_id, sales_month, sales)
SELECT employee_id, sales_month, sales
FROM employees_bad
WHERE employee_id IS NOT NULL AND sales_month IS NOT NULL;

-- Что получилось
SELECT 'departments'    AS table_name, COUNT(*) AS rows_cnt FROM departments
UNION ALL SELECT 'employees',      COUNT(*) FROM employees
UNION ALL SELECT 'employee_sales', COUNT(*) FROM employee_sales;
