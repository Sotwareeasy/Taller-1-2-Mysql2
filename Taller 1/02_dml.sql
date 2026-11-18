USE bibliored;
SET SESSION sql_safe_updates = 1;
-- Datos ficticios. IDs de FK corresponden al orden de inserción desde la base vacía.
INSERT INTO branches (name, municipality, address, opened_on) VALUES
    ('Sede Central Chía', 'Chía', 'Calle 10 # 4-20', '2012-01-10'),
    ('Sede Cajicá', 'Cajicá', 'Carrera 3 # 5-10', '2015-02-01'),
    ('Sede Zipaquirá', 'Zipaquirá', 'Calle 8 # 6-15', '2017-03-01'),
    ('Sede Cota', 'Cota', 'Carrera 2 # 7-12', '2020-01-15'),
    ('Sede Tabio', 'Tabio', 'Calle 5 # 3-18', '2026-10-01');
INSERT INTO membership_types (name, loan_limit, loan_days, renewal_limit, daily_fine, annual_fee) VALUES
    ('Básica', 2, 14, 1, 500, 0),
    ('Estudiante', 3, 14, 2, 300, 0),
    ('Docente', 5, 21, 2, 300, 30000),
    ('Infantil', 2, 7, 1, 200, 0),
    ('Institucional', 10, 30, 3, 1000, 250000);
INSERT INTO categories (name) VALUES
    ('Novela'),
    ('Cuento'),
    ('Poesía'),
    ('Historia'),
    ('Ciencia'),
    ('Infantil'),
    ('Referencia'),
    ('Cómic');
INSERT INTO publishers (name, city) VALUES
    ('Luna de Papel', 'Chía'),
    ('Sabana Editores', 'Chía'),
    ('Bosque Azul', 'Chía'),
    ('Faro Andino', 'Chía'),
    ('Semilla Editorial', 'Chía'),
    ('Horizonte Vacío', 'Chía'),
    ('Editorial Temporal', 'Chía');
INSERT INTO authors (full_name, nationality, birth_year) VALUES
    ('Elena Ríos', 'Colombiana', 1960),
    ('Mateo Pardo', 'Colombiana', 1963),
    ('Lucía Robles', 'Colombiana', 1966),
    ('Simón Valle', 'Colombiana', 1969),
    ('Clara Monte', 'Colombiana', 1972),
    ('Diego Luna', 'Colombiana', 1975),
    ('Ana Cedro', 'Colombiana', 1978),
    ('Pablo Niebla', 'Colombiana', 1981),
    ('Rosa Olmo', 'Colombiana', 1984),
    ('Nicolás Viento', 'Colombiana', 1987);
INSERT INTO employees (full_name, email, hired_on, role, branch_id) VALUES
    ('Patricia Lemus', 'patricia@bibliored.example', '2012-01-10', 'COORDINADOR', 1),
    ('Mario Gil', 'mario@bibliored.example', '2015-01-01', 'BIBLIOTECARIO', 1),
    ('Sara Paz', 'sara@bibliored.example', '2015-02-01', 'BIBLIOTECARIO', 2),
    ('Luis Cobo', 'luis@bibliored.example', '2017-03-01', 'BIBLIOTECARIO', 3),
    ('Eva Sol', 'eva@bibliored.example', '2020-01-15', 'BIBLIOTECARIO', 4),
    ('Nora Rey', 'nora@bibliored.example', '2026-10-01', 'AUXILIAR', 5);
INSERT INTO titles (isbn, title, publication_year, replacement_cost, category_id, publisher_id) VALUES
    ('9780000000001', 'El río de las garzas', 2000, 30000, 1, 1),
    ('9780000000002', 'Cartas desde el páramo', 2001, 34000, 3, 2),
    ('9780000000003', 'Cuentos de la Sabana', 2002, 38000, 2, 3),
    ('9780000000004', 'La ciudad de los faroles', 2003, 42000, 1, 4),
    ('9780000000005', 'Voces del viento', 2004, 46000, 3, 5),
    ('9780000000006', 'Historia del valle', 2005, 50000, 4, 1),
    ('9780000000007', 'Átomos para curiosos', 2006, 68000, 5, 2),
    ('9780000000008', 'El dragón de Guatavita', 2007, 58000, 6, 3),
    ('9780000000009', 'Diccionario escolar ilustrado', 2008, 62000, 7, 4),
    ('9780000000010', 'Jardines de agua', 2009, 66000, 1, 5),
    ('9780000000011', 'Estrellas cercanas', 2010, 70000, 5, 1),
    ('9780000000012', 'Viaje de una semilla', 2011, 74000, 6, 2);
INSERT INTO titles (isbn, title, publication_year, category_id, publisher_id) VALUES
    ('9780000000013', 'Memorias del puente', 2024, 4, 1),
    ('9780000000014', 'La isla invisible', 2024, 4, 1);
INSERT INTO title_authors (title_id, author_id, authorship_order) VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 1),
    (4, 4, 1),
    (5, 5, 1),
    (6, 6, 1),
    (7, 7, 1),
    (8, 8, 1),
    (9, 9, 1),
    (10, 1, 1),
    (11, 2, 1),
    (12, 3, 1),
    (13, 4, 1),
    (14, 5, 1),
    (1, 2, 2),
    (2, 3, 2),
    (3, 4, 2);
INSERT INTO copies (barcode, acquired_on, status, title_id, branch_id) VALUES
    ('CH-001', '2015-02-10', 'PRESTADO', 1, 1),
    ('CH-002', '2016-02-10', 'PRESTADO', 2, 1),
    ('CH-003', '2017-02-10', 'PRESTADO', 3, 1),
    ('CH-004', '2018-02-10', 'PRESTADO', 4, 1),
    ('CH-005', '2019-02-10', 'PRESTADO', 5, 1),
    ('CH-006', '2020-02-10', 'PRESTADO', 6, 1),
    ('CH-007', '2021-02-10', 'DISPONIBLE', 7, 1),
    ('CH-008', '2022-02-10', 'DISPONIBLE', 8, 1),
    ('CH-009', '2023-02-10', 'DISPONIBLE', 9, 1),
    ('CH-010', '2024-02-10', 'DISPONIBLE', 10, 1),
    ('CH-011', '2015-02-10', 'DISPONIBLE', 11, 1),
    ('CH-012', '2016-02-10', 'DISPONIBLE', 12, 1),
    ('CA-013', '2017-02-10', 'PRESTADO', 13, 2),
    ('CA-014', '2018-02-10', 'PRESTADO', 1, 2),
    ('CA-015', '2019-02-10', 'PRESTADO', 2, 2),
    ('CA-016', '2020-02-10', 'DISPONIBLE', 3, 2),
    ('CA-017', '2021-02-10', 'DISPONIBLE', 4, 2),
    ('CA-018', '2022-02-10', 'DISPONIBLE', 5, 2),
    ('ZI-019', '2011-05-10', 'DISPONIBLE', 6, 3),
    ('ZI-020', '2024-02-10', 'DISPONIBLE', 7, 3),
    ('ZI-021', '2015-02-10', 'DISPONIBLE', 8, 3),
    ('ZI-022', '2016-02-10', 'DISPONIBLE', 9, 3),
    ('ZI-023', '2017-02-10', 'DISPONIBLE', 10, 3),
    ('CO-024', '2018-02-10', 'PERDIDO', 7, 4),
    ('CO-025', '2019-02-10', 'EN_REPARACION', 12, 4),
    ('CO-026', '2020-02-10', 'EN_REPARACION', 13, 4),
    ('CO-027', '2021-02-10', 'DADO_DE_BAJA', 1, 4);
INSERT INTO members (document_number, first_name, last_name, email, phone, birth_date, joined_on, status, membership_type_id, branch_id) VALUES
    ('BR-1', 'Santiago', 'Méndez', 'socio1@example.com', '3005550001', '1990-04-10', '2026-08-01', 'ACTIVO', 1, 1),
    ('BR-2', 'Laura', 'Gómez', 'socio2@example.com', '3005550002', '1990-04-10', '2026-08-01', 'ACTIVO', 2, 2),
    ('BR-3', 'Mariana', 'López', 'socio3@example.com', '3005550003', '1990-04-10', '2026-08-01', 'ACTIVO', 1, 3),
    ('BR-4', 'Juan Pablo', 'Herrera', 'socio4@example.com', '3005550004', '1990-04-10', '2026-08-01', 'SUSPENDIDO', 1, 4),
    ('BR-5', 'Valeria', 'Díaz', 'socio5@example.com', '3005550005', '1990-04-10', '2026-08-01', 'ACTIVO', 2, 1),
    ('BR-6', 'Felipe', 'Ramírez', 'socio6@example.com', '3005550006', '1990-04-10', '2026-08-01', 'ACTIVO', 1, 2),
    ('BR-7', 'Isabela', 'Torres', NULL, NULL, '2015-06-01', '2026-08-01', 'ACTIVO', 4, 3),
    ('BR-8', 'Camilo', 'Rojas', 'socio8@example.com', '3005550008', '1990-04-10', '2026-08-01', 'ACTIVO', 3, 4),
    ('BR-9', 'Daniela', 'Soto', 'socio9@example.com', '3005550009', '1990-04-10', '2026-08-01', 'ACTIVO', 2, 1),
    ('BR-10', 'Andrés', 'Peña', 'socio10@example.com', '3005550010', '1990-04-10', '2026-08-01', 'ACTIVO', 1, 2),
    ('BR-11', 'Mateo', 'Cruz', NULL, NULL, '2015-06-01', '2026-08-01', 'ACTIVO', 4, 3),
    ('BR-12', 'Luciana', 'Vega', NULL, NULL, '2015-06-01', '2026-08-01', 'INACTIVO', 4, 4),
    ('BR-13', 'Tomás', 'Rueda', 'socio13@example.com', NULL, '1990-04-10', '2026-08-01', 'ACTIVO', 1, 1),
    ('BR-14', 'Sara', 'Mora', 'socio14@example.com', '3005550014', '1990-04-10', '2026-10-05', 'ACTIVO', 2, 5);
INSERT INTO loans (copy_id, member_id, employee_id, loan_date, due_date, returned_on, status) VALUES
    (7, 1, 2, '2026-09-01', '2026-09-15', '2026-09-15', 'DEVUELTO'),
    (8, 2, 2, '2026-09-01', '2026-09-15', '2026-09-20', 'DEVUELTO'),
    (9, 3, 2, '2026-09-01', '2026-09-15', '2026-09-20', 'DEVUELTO'),
    (10, 4, 2, '2026-09-01', '2026-09-15', '2026-09-20', 'DEVUELTO'),
    (11, 5, 2, '2026-09-01', '2026-09-15', '2026-09-15', 'DEVUELTO'),
    (12, 6, 2, '2026-09-01', '2026-09-15', '2026-09-20', 'DEVUELTO'),
    (16, 7, 3, '2026-09-01', '2026-09-08', '2026-09-08', 'DEVUELTO'),
    (17, 8, 3, '2026-09-01', '2026-09-22', '2026-09-22', 'DEVUELTO'),
    (18, 9, 3, '2026-09-01', '2026-09-15', '2026-09-15', 'DEVUELTO'),
    (19, 10, 4, '2026-09-01', '2026-09-15', '2026-09-15', 'DEVUELTO'),
    (20, 11, 4, '2026-09-01', '2026-09-08', '2026-09-08', 'DEVUELTO'),
    (21, 12, 4, '2026-09-01', '2026-09-08', '2026-09-08', 'DEVUELTO'),
    (1, 1, 2, '2026-10-27', '2026-11-10', NULL, 'ACTIVO'),
    (2, 1, 2, '2026-10-28', '2026-11-11', NULL, 'ACTIVO'),
    (3, 2, 2, '2026-09-30', '2026-11-11', NULL, 'ACTIVO'),
    (4, 3, 2, '2026-10-27', '2026-11-10', NULL, 'ACTIVO'),
    (5, 5, 2, '2026-11-01', '2026-11-15', NULL, 'ACTIVO'),
    (6, 8, 2, '2026-11-01', '2026-11-22', NULL, 'ACTIVO'),
    (13, 9, 3, '2026-10-10', '2026-10-24', NULL, 'ACTIVO'),
    (14, 7, 3, '2026-10-25', '2026-11-01', NULL, 'ACTIVO'),
    (15, 2, 3, '2026-11-05', '2026-11-19', NULL, 'ACTIVO'),
    (24, 10, 5, '2026-10-01', '2026-10-15', NULL, 'PERDIDO'),
    (22, 4, 4, '2026-10-01', '2026-10-15', '2026-10-20', 'DEVUELTO');
INSERT INTO renewals (loan_id, renewed_on, previous_due_date, new_due_date) VALUES
    (1015, '2026-10-14', '2026-10-14', '2026-10-28'),
    (1015, '2026-10-28', '2026-10-28', '2026-11-11'),
    (1009, '2026-09-10', '2026-09-15', '2026-09-29');
SELECT * FROM loans WHERE id = 1009;
UPDATE loans SET due_date = '2026-09-29' WHERE id = 1009;
SELECT * FROM loans WHERE id = 1009;
INSERT INTO reservations (member_id, title_id, branch_id, reserved_on, expires_on, status) VALUES
    (13, 5, 1, '2026-11-01', '2026-11-20', 'PENDIENTE'),
    (14, 14, 5, '2026-11-01', '2026-11-18', 'PENDIENTE'),
    (6, 8, 1, '2026-11-02', '2026-11-20', 'PENDIENTE'),
    (3, 2, 2, '2026-10-01', '2026-10-10', 'PENDIENTE'),
    (5, 1, 1, '2026-09-01', '2026-09-20', 'ATENDIDA'),
    (8, 3, 3, '2026-10-01', '2026-10-20', 'CANCELADA'),
    (9, 4, 2, '2026-09-01', '2026-09-20', 'VENCIDA'),
    (10, 6, 4, '2026-10-01', '2026-10-20', 'CANCELADA');
INSERT INTO fines (loan_id, reason, late_days, amount, issued_on, status) VALUES
    (1002, 'MORA', 5, 1500, '2026-09-20', 'PAGADA'),
    (1003, 'MORA', 5, 2500, '2026-09-20', 'PAGADA'),
    (1004, 'MORA', 5, 2500, '2026-09-20', 'PENDIENTE'),
    (1006, 'MORA', 5, 2500, '2026-09-20', 'PENDIENTE'),
    (1022, 'PERDIDA', 0, 68000, '2026-10-16', 'PENDIENTE'),
    (1005, 'DAÑO', 0, 10000, '2026-09-15', 'ANULADA'),
    (1023, 'MORA', 5, 2500, '2026-10-20', 'PAGADA');
INSERT INTO fine_payments (fine_id, amount, paid_on, payment_method) VALUES
    (1, 1500, '2026-09-22', 'EFECTIVO'),
    (2, 1000, '2026-09-22', 'TARJETA'),
    (2, 1500, '2026-09-25', 'TRANSFERENCIA'),
    (3, 500, '2026-09-25', 'EFECTIVO'),
    (7, 2500, '2026-10-21', 'EFECTIVO');

SELECT * FROM copies WHERE id = 25;
UPDATE copies SET status = 'DISPONIBLE' WHERE id = 25;
SELECT * FROM copies WHERE id = 25;

SELECT * FROM reservations WHERE id = 4;
UPDATE reservations SET status = 'VENCIDA' WHERE id = 4;
SELECT * FROM reservations WHERE id = 4;

SELECT * FROM membership_types WHERE id = 3;
UPDATE membership_types SET annual_fee = annual_fee * 1.10 WHERE id = 3;
SELECT * FROM membership_types WHERE id = 3;

SELECT * FROM members WHERE id = 13;
UPDATE members SET phone = '3005559013' WHERE id = 13;
SELECT * FROM members WHERE id = 13;

SELECT * FROM reservations WHERE id = 6;
DELETE FROM reservations WHERE id = 6;
SELECT * FROM reservations WHERE id = 6;
SELECT * FROM publishers WHERE id = 7;
SELECT COUNT(*) AS titulos_dependientes FROM titles WHERE publisher_id = 7;
DELETE FROM publishers WHERE id = 7;
SELECT * FROM publishers WHERE id = 7;

-- ⚠️ ESPERADO: ERROR 1062. UNIQUE de código de barras. Ejecutar solo esta sentencia.
-- INSERT INTO copies (barcode, acquired_on, title_id, branch_id) VALUES ('CH-001','2026-11-10',1,1);
-- ⚠️ ESPERADO: ERROR 3819. CHECK exige cuota positiva.
-- INSERT INTO fine_payments (fine_id, amount, paid_on, payment_method) VALUES (3,0,'2026-11-10','EFECTIVO');
-- ⚠️ ESPERADO: ERROR 1451. La editorial tiene títulos dependientes.
-- DELETE FROM publishers WHERE id = 1;
-- Verificación: branches 5, membership_types 5, categories 8, publishers 6,
-- authors 10, employees 6, titles 14, title_authors 17, copies 27, members 14,
-- loans 23, renewals 3, reservations 7, fines 7, fine_payments 5.
SELECT 'branches' AS tabla, COUNT(*) AS filas FROM branches
UNION ALL
SELECT 'membership_types' AS tabla, COUNT(*) AS filas FROM membership_types
UNION ALL
SELECT 'categories' AS tabla, COUNT(*) AS filas FROM categories
UNION ALL
SELECT 'publishers' AS tabla, COUNT(*) AS filas FROM publishers
UNION ALL
SELECT 'authors' AS tabla, COUNT(*) AS filas FROM authors
UNION ALL
SELECT 'employees' AS tabla, COUNT(*) AS filas FROM employees
UNION ALL
SELECT 'titles' AS tabla, COUNT(*) AS filas FROM titles
UNION ALL
SELECT 'title_authors' AS tabla, COUNT(*) AS filas FROM title_authors
UNION ALL
SELECT 'copies' AS tabla, COUNT(*) AS filas FROM copies
UNION ALL
SELECT 'members' AS tabla, COUNT(*) AS filas FROM members
UNION ALL
SELECT 'loans' AS tabla, COUNT(*) AS filas FROM loans
UNION ALL
SELECT 'renewals' AS tabla, COUNT(*) AS filas FROM renewals
UNION ALL
SELECT 'reservations' AS tabla, COUNT(*) AS filas FROM reservations
UNION ALL
SELECT 'fines' AS tabla, COUNT(*) AS filas FROM fines
UNION ALL
SELECT 'fine_payments' AS tabla, COUNT(*) AS filas FROM fine_payments;

-- D14: las dos columnas deben dar 0. Detecta también dos activos para una copia.
SELECT (SELECT COUNT(*) FROM copies c WHERE
 (c.status = 'PRESTADO' AND (SELECT COUNT(*) FROM loans l WHERE l.copy_id = c.id AND l.status = 'ACTIVO') <> 1)
 OR (c.status <> 'PRESTADO' AND EXISTS (SELECT 1 FROM loans l WHERE l.copy_id = c.id AND l.status = 'ACTIVO'))) AS ejemplares_inconsistentes,
 (SELECT COUNT(*) FROM loans l JOIN copies c ON c.id = l.copy_id WHERE l.status = 'ACTIVO' AND c.status <> 'PRESTADO') AS prestamos_inconsistentes;
