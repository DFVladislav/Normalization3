-- ============================================================
-- Шаг 4. Проверка, что данные не потерялись и не исказились
-- ============================================================

USE staff_norm;

-- ------------------------------------------------------------
-- Проверка 1. Сравнение общей суммы продаж SUM(sales)
-- до нормализации (плохая таблица) и после (соединение 3 таблиц)
-- ------------------------------------------------------------
SELECT 'до нормализации (плохая таблица)' AS source,
       SUM(sales) AS total_sum,
       COUNT(*)   AS rows_cnt
FROM employees_bad
UNION ALL
SELECT 'после нормализации (3NF)',
       SUM(s.sales),
       COUNT(*)
FROM employee_sales s;

-- ------------------------------------------------------------
-- Проверка 2. Число уникальных сотрудников / отделов / записей продаж
-- ------------------------------------------------------------
SELECT 'employees'          AS what, COUNT(DISTINCT employee_id)   AS cnt FROM employees_bad WHERE employee_id IS NOT NULL
UNION ALL SELECT 'employees (3NF)',  COUNT(*) FROM employees
UNION ALL SELECT 'departments',      COUNT(DISTINCT department_id) FROM employees_bad WHERE department_id IS NOT NULL
UNION ALL SELECT 'departments (3NF)', COUNT(*) FROM departments
UNION ALL SELECT 'sales rows',       COUNT(*) FROM employees_bad WHERE employee_id IS NOT NULL AND sales_month IS NOT NULL
UNION ALL SELECT 'sales rows (3NF)', COUNT(*) FROM employee_sales;

-- ------------------------------------------------------------
-- Проверка 3. Потери и лишние записи (сравнение ключей)
-- ------------------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM
     (SELECT employee_id, sales_month FROM employees_bad
      WHERE employee_id IS NOT NULL AND sales_month IS NOT NULL) b
     LEFT JOIN employee_sales s
       ON s.employee_id = b.employee_id AND s.sales_month = b.sales_month
     WHERE s.employee_id IS NULL) AS missing_from_3nf,
  (SELECT COUNT(*) FROM employee_sales s
     LEFT JOIN
     (SELECT employee_id, sales_month FROM employees_bad
      WHERE employee_id IS NOT NULL AND sales_month IS NOT NULL) b
       ON s.employee_id = b.employee_id AND s.sales_month = b.sales_month
     WHERE b.employee_id IS NULL) AS extra_in_3nf;

-- ------------------------------------------------------------
-- Проверка 4. Полное «собранное» представление (JOIN трёх таблиц)
-- ------------------------------------------------------------
SELECT e.employee_id,
       e.employee_name,
       d.department_id,
       d.department_name,
       s.sales_month,
       s.sales
FROM employee_sales s
JOIN employees  e ON e.employee_id    = s.employee_id
JOIN departments d ON d.department_id = e.department_id
ORDER BY e.employee_id, s.sales_month;

-- ------------------------------------------------------------
-- Тестовые запросы на новой схеме
-- ------------------------------------------------------------

-- 1. Сколько продал каждый отдел?
SELECT d.department_name,
       SUM(s.sales) AS total_sales
FROM departments d
JOIN employees  e ON e.department_id = d.department_id
JOIN employee_sales s ON s.employee_id = e.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY total_sales DESC;

-- 2. Лучший сотрудник по суммарным продажам
SELECT e.employee_name,
       SUM(s.sales) AS total_sales
FROM employees e
JOIN employee_sales s ON s.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_sales DESC
LIMIT 1;

-- 3. Итоги по месяцам
SELECT s.sales_month,
       SUM(s.sales) AS month_total
FROM employee_sales s
GROUP BY s.sales_month
ORDER BY s.sales_month;

-- 4. В каком отделе работает сотрудник с кодом 3?
SELECT e.employee_name, d.department_name
FROM employees e
JOIN departments d ON d.department_id = e.department_id
WHERE e.employee_id = 3;

-- ------------------------------------------------------------
-- Шаг 5 (после успешной проверки). Переименуем исходную таблицу
-- (не удаляем — на случай повторной проверки преподавателем)
-- ------------------------------------------------------------
RENAME TABLE employees_bad TO employees_bad_archive;

SHOW TABLES;
