USE flotaya;
SET SESSION sql_safe_updates = 1;
-- Catálogos y fechas reproducibles. Las FK siguen el orden de inserción.
INSERT INTO departments (name) VALUES
    ('Bogotá D.C.'),
    ('Antioquia'),
    ('Bolívar'),
    ('Valle del Cauca'),
    ('Santander'),
    ('Quindío'),
    ('Magdalena');
INSERT INTO cities (name, department_id) VALUES
    ('Bogotá', 1),
    ('Medellín', 2),
    ('Rionegro', 2),
    ('Cartagena', 3),
    ('Cali', 4),
    ('Bucaramanga', 5),
    ('Armenia', 6);
INSERT INTO branches (name, address, phone, is_airport, city_id) VALUES
    ('FlotaYa Bogotá Calle 26', 'Avenida Calle 26 # 69-76', '6017001001', 0, 1),
    ('FlotaYa Aeropuerto El Dorado', 'Avenida El Dorado # 103-09', '6017001002', 1, 1),
    ('FlotaYa Medellín El Poblado', 'Carrera 43A # 7-50', '6047001003', 0, 2),
    ('FlotaYa Aeropuerto José María Córdova', 'Vía Aeropuerto JMC km 1', '6047001004', 1, 3),
    ('FlotaYa Cartagena Bocagrande', 'Carrera 2 # 8-120', '6057001005', 0, 4),
    ('FlotaYa Cali Granada', 'Avenida 9N # 15-20', '6027001006', 0, 5);
INSERT INTO employees (full_name, email, role, hired_on, branch_id) VALUES
    ('Mónica Gaitán', 'monica.gaitan@flotaya.example.com', 'ADMINISTRADOR', '2020-01-01', 1),
    ('Gustavo Pérez', 'gustavo.perez@flotaya.example.com', 'MECANICO', '2020-01-01', 1),
    ('Ana Rey', 'asesor1@flotaya.example.com', 'ASESOR', '2025-01-01', 1),
    ('Bruno Sol', 'asesor2@flotaya.example.com', 'ASESOR', '2025-01-01', 2),
    ('Celia Luz', 'asesor3@flotaya.example.com', 'ASESOR', '2025-01-01', 3),
    ('David Paz', 'asesor4@flotaya.example.com', 'ASESOR', '2025-01-01', 4),
    ('Elena Gil', 'asesor5@flotaya.example.com', 'ASESOR', '2025-01-01', 5),
    ('Fabio Mar', 'asesor6@flotaya.example.com', 'ASESOR', '2025-01-01', 6),
    ('Irene Cano', 'inspector1@flotaya.example.com', 'INSPECTOR', '2025-01-01', 1),
    ('Jairo Soto', 'inspector2@flotaya.example.com', 'INSPECTOR', '2025-01-01', 2),
    ('Lina Ríos', 'inspector3@flotaya.example.com', 'INSPECTOR', '2025-01-01', 3),
    ('Mario Valle', 'inspector4@flotaya.example.com', 'INSPECTOR', '2025-01-01', 4),
    ('Nora Díaz', 'inspector5@flotaya.example.com', 'INSPECTOR', '2025-01-01', 5),
    ('Óscar Roa', 'inspector6@flotaya.example.com', 'INSPECTOR', '2025-01-01', 6);
INSERT INTO categories (name, minimum_age, deposit_amount) VALUES
    ('Económico', 21, 1500000),
    ('Compacto', 21, 1500000),
    ('SUV', 23, 2500000),
    ('Camioneta 4x4', 25, 3000000),
    ('Van', 25, 3000000),
    ('Lujo', 30, 5000000);
INSERT INTO rates (category_id, season_type, daily_rate) VALUES
    (1, 'BAJA', 120000),
    (1, 'MEDIA', 140000),
    (1, 'ALTA', 180000),
    (2, 'BAJA', 150000),
    (2, 'MEDIA', 175000),
    (2, 'ALTA', 220000),
    (3, 'BAJA', 230000),
    (3, 'MEDIA', 270000),
    (3, 'ALTA', 340000),
    (4, 'BAJA', 300000),
    (4, 'MEDIA', 350000),
    (4, 'ALTA', 430000),
    (5, 'BAJA', 320000),
    (5, 'MEDIA', 370000),
    (5, 'ALTA', 460000),
    (6, 'BAJA', 450000),
    (6, 'MEDIA', 520000),
    (6, 'ALTA', 650000);
INSERT INTO seasons (name, season_type, start_date, end_date) VALUES
    ('Fin de año 2025', 'ALTA', '2025-12-15', '2026-01-15'),
    ('Baja de inicio de año', 'BAJA', '2026-01-16', '2026-03-28'),
    ('Semana Santa', 'ALTA', '2026-03-29', '2026-04-05'),
    ('Baja de abril a junio', 'BAJA', '2026-04-06', '2026-06-12'),
    ('Vacaciones de mitad de año', 'ALTA', '2026-06-13', '2026-07-19'),
    ('Baja de segundo semestre', 'BAJA', '2026-07-20', '2026-10-02'),
    ('Receso escolar de octubre', 'MEDIA', '2026-10-03', '2026-10-12'),
    ('Baja de noviembre', 'BAJA', '2026-10-13', '2026-11-30'),
    ('Temporada de novenas', 'MEDIA', '2026-12-01', '2026-12-14'),
    ('Fin de año 2026', 'ALTA', '2026-12-15', '2027-01-15');
INSERT INTO brands (name) VALUES
    ('Renault'),
    ('Kia'),
    ('Chevrolet'),
    ('Mazda'),
    ('Toyota'),
    ('Hyundai'),
    ('Nissan');
INSERT INTO models (name, transmission, fuel_type, seats, brand_id, category_id) VALUES
    ('Kwid', 'MECANICA', 'GASOLINA', 5, 1, 1),
    ('Picanto', 'AUTOMATICA', 'GASOLINA', 5, 2, 1),
    ('Onix', 'AUTOMATICA', 'GASOLINA', 5, 3, 2),
    ('Mazda 2', 'AUTOMATICA', 'GASOLINA', 5, 4, 2),
    ('Duster', 'MECANICA', 'GASOLINA', 5, 1, 3),
    ('Sportage', 'AUTOMATICA', 'HIBRIDO', 5, 2, 3),
    ('Hilux', 'MECANICA', 'DIESEL', 5, 5, 4),
    ('Staria', 'AUTOMATICA', 'DIESEL', 11, 6, 5),
    ('CX-30', 'AUTOMATICA', 'GASOLINA', 5, 4, 3);
INSERT INTO vehicles (plate, model_year, color, mileage_km, status, model_id, branch_id) VALUES
    ('KWD101', 2024, 'Blanco', 18950, 'DISPONIBLE', 1, 1),
    ('KWD102', 2024, 'Gris', 22100, 'DISPONIBLE', 1, 2),
    ('KWD103', 2021, 'Blanco', 98400, 'FUERA_DE_SERVICIO', 1, 6),
    ('PCN201', 2025, 'Rojo', 10450, 'DISPONIBLE', 2, 2),
    ('PCN202', 2025, 'Blanco', 12400, 'DISPONIBLE', 2, 3),
    ('ONX301', 2024, 'Plata', 30500, 'ALQUILADO', 3, 2),
    ('ONX302', 2023, 'Negro', 41890, 'MANTENIMIENTO', 3, 5),
    ('MZD401', 2025, 'Azul', 9310, 'DISPONIBLE', 4, 4),
    ('MZD402', 2024, 'Rojo', 26300, 'ALQUILADO', 4, 4),
    ('DST501', 2023, 'Blanco', 48620, 'DISPONIBLE', 5, 1),
    ('DST502', 2024, 'Gris', 22710, 'DISPONIBLE', 5, 6),
    ('SPT601', 2025, 'Negro', 11500, 'ALQUILADO', 6, 2),
    ('SPT602', 2025, 'Blanco', 9600, 'DISPONIBLE', 6, 4),
    ('HLX701', 2023, 'Plata', 64380, 'DISPONIBLE', 7, 3),
    ('HLX702', 2022, 'Blanco', 88100, 'MANTENIMIENTO', 7, 6),
    ('STR801', 2024, 'Gris', 35700, 'DISPONIBLE', 8, 2),
    ('STR802', 2025, 'Blanco', 15480, 'DISPONIBLE', 8, 5);
INSERT INTO maintenances (vehicle_id, maintenance_type, description, workshop, start_date, end_date, cost) VALUES
    (15, 'CORRECTIVO', 'Cambio de embrague', 'Diésel del Valle', '2026-11-16', NULL, NULL),
    (7, 'LATONERIA', 'Reparación de latonería', 'Latonería Caribe', '2026-10-26', NULL, NULL),
    (3, 'CORRECTIVO', 'Diagnóstico de motor: pérdida total', 'Motores Cali', '2026-09-01', '2026-09-03', 550000),
    (10, 'PREVENTIVO', 'Cambio de aceite', 'Taller FlotaYa Bogotá', '2026-09-05', '2026-09-05', 180000),
    (10, 'CORRECTIVO', 'Reparación de suspensión', 'Taller FlotaYa Bogotá', '2026-10-20', '2026-10-22', 800000),
    (14, 'PREVENTIVO', 'Revisión general', 'Taller Antioquia', '2026-10-25', '2026-10-26', 250000);
INSERT INTO customers (document_type, document_number, first_name, last_name, email, phone, birth_date, registered_on, status, city_id) VALUES
    ('CC', 'FY-100', 'Andrea', 'Salazar', 'cliente1@example.com', '3105550001', '1990-04-12', '2026-08-01', 'ACTIVO', 1),
    ('CC', 'FY-101', 'Carlos', 'Mejía', 'cliente2@example.com', '3105550002', '1985-09-30', '2026-08-01', 'ACTIVO', 2),
    ('CC', 'FY-102', 'Juliana', 'Patiño', 'cliente3@example.com', '3105550003', '2004-07-15', '2026-08-01', 'ACTIVO', 1),
    ('CE', 'FY-103', 'Lucas', 'Ferreira', 'cliente4@example.com', '3105550004', '1979-02-02', '2026-08-01', 'ACTIVO', 4),
    ('CC', 'FY-104', 'Diana', 'Rozo', 'cliente5@example.com', '3105550005', '1993-11-25', '2026-08-01', 'ACTIVO', 5),
    ('PASAPORTE', 'FY-105', 'Emma', 'Walker', 'cliente6@example.com', '3105550006', '1988-06-18', '2026-08-01', 'ACTIVO', 4),
    ('CC', 'FY-106', 'Jorge', 'Arango', 'cliente7@example.com', '3105550007', '1975-01-09', '2026-08-01', 'ACTIVO', 2),
    ('CC', 'FY-107', 'Paola', 'Quintero', 'cliente8@example.com', '3105550008', '1999-12-03', '2026-08-01', 'ACTIVO', 1),
    ('CC', 'FY-108', 'Esteban', 'Rueda', 'cliente9@example.com', '3105550009', '2002-05-21', '2026-08-01', 'ACTIVO', 6),
    ('CC', 'FY-109', 'Martha', 'Cifuentes', 'cliente10@example.com', '3105550010', '1968-03-14', '2026-08-01', 'BLOQUEADO', 1),
    ('CC', 'FY-110', 'Kevin', 'Morales', 'cliente11@example.com', '3105550011', '2005-10-02', '2026-08-01', 'ACTIVO', 5),
    ('CC', 'FY-111', 'Laura', 'Benítez', 'cliente12@example.com', NULL, '1996-08-08', '2026-08-01', 'ACTIVO', 2),
    ('CC', 'FY-112', 'Ricardo', 'Lozano', 'cliente13@example.com', '3105550013', '1982-12-24', '2026-08-01', 'ACTIVO', 1),
    ('CC', 'FY-113', 'Sofía', 'Herrera', 'cliente14@example.com', '3105550014', '2001-01-30', '2026-08-01', 'ACTIVO', 3);
INSERT INTO licenses (license_number, category, issued_on, expires_on, country, customer_id) VALUES
    ('LIC-FY-1', 'B1', '2020-01-01', '2028-05-10', 'Colombia', 1),
    ('LIC-FY-2', 'B1', '2020-01-01', '2027-02-20', 'Colombia', 2),
    ('LIC-FY-3', 'B1', '2022-08-01', '2032-08-01', 'Colombia', 3),
    ('LIC-FY-4', 'B1', '2020-01-01', '2026-12-31', 'Brasil', 4),
    ('LIC-FY-5', 'B1', '2020-01-01', '2029-11-30', 'Colombia', 5),
    ('LIC-FY-6', 'B1', '2020-01-01', '2031-06-01', 'Canadá', 6),
    ('LIC-FY-7', 'C1', '2010-01-15', '2030-01-15', 'Colombia', 7),
    ('LIC-FY-8', 'B1', '2016-12-10', '2026-12-10', 'Colombia', 8),
    ('LIC-FY-9', 'B1', '2020-01-01', '2026-08-01', 'Colombia', 9),
    ('LIC-FY-10', 'B1', '2020-01-01', '2028-04-04', 'Colombia', 10),
    ('LIC-FY-11', 'B1', '2023-10-10', '2033-10-10', 'Colombia', 11),
    ('LIC-FY-13', 'B1', '2020-01-01', '2027-12-24', 'Colombia', 13),
    ('LIC-FY-14', 'B1', '2020-01-01', '2029-02-01', 'Colombia', 14),
    ('LIC-FY-7-ANT', 'C1', '2000-01-15', '2010-01-15', 'Colombia', 7);
INSERT INTO additional_drivers (document_number, full_name, birth_date, license_number, license_expires_on) VALUES
    ('AD-1', 'Felipe Salazar', '1988-03-03', 'AD-LIC-1', '2029-03-03'),
    ('AD-2', 'Mónica Arango', '1977-07-07', 'AD-LIC-2', '2028-07-07'),
    ('AD-3', 'Tomás Ferreira', '2006-03-03', 'AD-LIC-3', '2030-03-03'),
    ('AD-4', 'Natalia Rozo', '1995-05-05', 'AD-LIC-4', '2026-09-30');
INSERT INTO extras (name, daily_price) VALUES
    ('GPS', 15000),
    ('Silla de bebé', 12000),
    ('Seguro total', 45000),
    ('Conductor adicional', 20000),
    ('Wi-Fi portátil', 10000),
    ('Portabicicletas', 18000);
INSERT INTO reservations (customer_id, vehicle_id, pickup_branch_id, return_branch_id, start_date, end_date, quoted_amount, status, created_at) VALUES
    (1, 2, 2, 2, '2026-09-10', '2026-09-13', 360000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (4, 17, 5, 5, '2026-10-01', '2026-10-06', 1750000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (7, 14, 3, 3, '2026-10-15', '2026-10-20', 1500000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (6, 7, 5, 5, '2026-10-20', '2026-10-24', 600000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (5, 11, 6, 6, '2026-10-08', '2026-10-12', 920000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (8, 12, 2, 2, '2026-11-15', '2026-11-22', 1610000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (13, 6, 2, 1, '2026-11-17', '2026-11-21', 600000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (2, 9, 4, 4, '2026-11-18', '2026-11-25', 1050000, 'CONVERTIDA', '2026-08-15 09:00:00'),
    (3, 1, 1, 1, '2026-11-27', '2026-12-02', 620000, 'CONFIRMADA', '2026-08-15 09:00:00'),
    (5, 16, 2, 2, '2026-12-18', '2026-12-23', 2300000, 'CONFIRMADA', '2026-08-15 09:00:00'),
    (11, 5, 3, 3, '2026-12-10', '2026-12-17', 980000, 'PENDIENTE', '2026-08-15 09:00:00'),
    (14, 13, 4, 4, '2026-12-05', '2026-12-09', 1080000, 'PENDIENTE', '2026-08-15 09:00:00'),
    (10, 4, 2, 2, '2026-09-20', '2026-09-23', 360000, 'CANCELADA', '2026-08-15 09:00:00'),
    (9, 8, 4, 4, '2026-09-20', '2026-09-23', 450000, 'CANCELADA', '2026-08-15 09:00:00');
INSERT INTO contracts (reservation_id, vehicle_id, employee_id, start_date, expected_end_date, actual_end_date, rental_amount, status) VALUES
    (501, 2, 4, '2026-09-10', '2026-09-13', '2026-09-13', 360000, 'CERRADO'),
    (502, 17, 7, '2026-10-01', '2026-10-06', '2026-10-06', 1750000, 'CERRADO'),
    (503, 14, 5, '2026-10-15', '2026-10-20', '2026-10-20', 1500000, 'CERRADO'),
    (504, 7, 7, '2026-10-20', '2026-10-24', '2026-10-24', 600000, 'CERRADO'),
    (505, 11, 8, '2026-10-08', '2026-10-12', '2026-10-13', 1350000, 'CERRADO'),
    (506, 12, 4, '2026-11-15', '2026-11-22', NULL, 1610000, 'ABIERTO'),
    (507, 6, 4, '2026-11-17', '2026-11-21', NULL, 600000, 'ABIERTO'),
    (508, 9, 6, '2026-11-18', '2026-11-25', NULL, 1050000, 'ABIERTO');
INSERT INTO contract_extras (contract_id, extra_id, quantity, agreed_daily_price) VALUES
    (9001, 1, 1, 15000),
    (9001, 4, 1, 20000),
    (9002, 4, 1, 20000),
    (9003, 4, 1, 20000),
    (9004, 1, 1, 15000),
    (9006, 3, 1, 45000),
    (9006, 4, 1, 20000),
    (9007, 1, 1, 15000),
    (9008, 4, 1, 20000),
    (9008, 2, 2, 12000);
INSERT INTO contract_drivers (contract_id, additional_driver_id) VALUES
    (9001, 1),
    (9002, 3),
    (9003, 4),
    (9006, 1),
    (9008, 2);
INSERT INTO deliveries (contract_id, delivered_at, mileage_km, fuel_pct, branch_id, employee_id) VALUES
    (9001, '2026-09-10 08:00:00', 21000, 100, 2, 10),
    (9002, '2026-10-01 08:00:00', 14000, 100, 5, 13),
    (9003, '2026-10-15 08:00:00', 63000, 100, 3, 11),
    (9004, '2026-10-20 08:00:00', 41000, 100, 5, 13),
    (9005, '2026-10-08 08:00:00', 22000, 100, 6, 14),
    (9006, '2026-11-15 08:00:00', 11500, 100, 2, 10),
    (9007, '2026-11-17 08:00:00', 30500, 100, 2, 10),
    (9008, '2026-11-18 08:00:00', 26300, 100, 4, 12);
INSERT INTO returns (contract_id, returned_at, mileage_km, fuel_pct, branch_id, employee_id) VALUES
    (9001, '2026-09-13 09:00:00', 22100, 100, 2, 10),
    (9002, '2026-10-06 09:00:00', 15480, 100, 5, 13),
    (9003, '2026-10-20 09:00:00', 64380, 100, 3, 11),
    (9004, '2026-10-24 09:00:00', 41890, 100, 5, 13),
    (9005, '2026-10-13 09:00:00', 22710, 100, 6, 14);
INSERT INTO inspections (contract_id, stage, inspected_at, exterior_ok, interior_ok, notes, employee_id) VALUES
    (9001, 'ENTREGA', '2026-09-10 08:10:00', 1, 1, NULL, 10),
    (9002, 'ENTREGA', '2026-10-01 08:10:00', 0, 1, 'Rayón previo en el bómper trasero', 13),
    (9003, 'ENTREGA', '2026-10-15 08:10:00', 1, 1, NULL, 11),
    (9004, 'ENTREGA', '2026-10-20 08:10:00', 1, 1, NULL, 13),
    (9005, 'ENTREGA', '2026-10-08 08:10:00', 1, 1, NULL, 14),
    (9006, 'ENTREGA', '2026-11-15 08:10:00', 1, 1, NULL, 10),
    (9007, 'ENTREGA', '2026-11-17 08:10:00', 1, 1, NULL, 10),
    (9008, 'ENTREGA', '2026-11-18 08:10:00', 1, 1, NULL, 12),
    (9001, 'DEVOLUCION', '2026-09-13 09:10:00', 1, 1, NULL, 10),
    (9002, 'DEVOLUCION', '2026-10-06 09:10:00', 1, 1, NULL, 13),
    (9003, 'DEVOLUCION', '2026-10-20 09:10:00', 0, 1, NULL, 11),
    (9004, 'DEVOLUCION', '2026-10-24 09:10:00', 0, 1, NULL, 13),
    (9005, 'DEVOLUCION', '2026-10-13 09:10:00', 1, 1, NULL, 14);
INSERT INTO damages (inspection_id, description, severity, repair_cost, chargeable) VALUES
    (2, 'Rayón previo en el bómper trasero', 'LEVE', 180000, 0),
    (11, 'Rayón en la puerta del conductor', 'LEVE', 350000, 1),
    (12, 'Golpe en la puerta trasera derecha', 'GRAVE', 2400000, 1);
INSERT INTO deposits (contract_id, amount, held_at, released_at, applied_amount, status) VALUES
    (9001, 1500000, '2026-09-10 08:00:00', '2026-09-13 10:00:00', 0, 'LIBERADO'),
    (9002, 3000000, '2026-10-01 08:00:00', '2026-10-06 10:00:00', 0, 'LIBERADO'),
    (9003, 3000000, '2026-10-15 08:00:00', '2026-10-20 10:00:00', 350000, 'APLICADO'),
    (9004, 1500000, '2026-10-20 08:00:00', '2026-10-24 10:00:00', 1500000, 'APLICADO'),
    (9005, 2500000, '2026-10-08 08:00:00', '2026-10-13 10:00:00', 0, 'LIBERADO'),
    (9006, 2500000, '2026-11-15 08:00:00', NULL, 0, 'RETENIDO'),
    (9007, 1500000, '2026-11-17 08:00:00', NULL, 0, 'RETENIDO'),
    (9008, 1500000, '2026-11-18 08:00:00', NULL, 0, 'RETENIDO');
INSERT INTO payments (contract_id, concept, amount, payment_method, paid_at, card_last_four, authorization_code) VALUES
    (9001, 'ALQUILER', 200000, 'TARJETA', '2026-09-10 08:00:00', '1001', 'AUT-1'),
    (9001, 'CIERRE', 265000, 'EFECTIVO', '2026-09-13 10:00:00', NULL, NULL),
    (9002, 'ALQUILER', 1000000, 'TRANSFERENCIA', '2026-10-01 08:00:00', NULL, NULL),
    (9002, 'CIERRE', 850000, 'TARJETA', '2026-10-06 10:00:00', '1002', 'AUT-2'),
    (9003, 'ALQUILER', 1500000, 'TARJETA', '2026-10-15 08:00:00', '1003', 'AUT-3'),
    (9003, 'EXTRAS', 100000, 'EFECTIVO', '2026-10-20 10:00:00', NULL, NULL),
    (9003, 'DAÑOS', 350000, 'DEPOSITO', '2026-10-20 10:00:00', NULL, NULL),
    (9004, 'ALQUILER', 600000, 'TARJETA', '2026-10-20 08:00:00', '1004', 'AUT-4'),
    (9004, 'EXTRAS', 60000, 'TRANSFERENCIA', '2026-10-24 10:00:00', NULL, NULL),
    (9004, 'DAÑOS', 1500000, 'DEPOSITO', '2026-10-24 10:00:00', NULL, NULL),
    (9005, 'ALQUILER', 1350000, 'TARJETA', '2026-10-13 10:00:00', '1005', 'AUT-5'),
    (9006, 'ALQUILER', 1610000, 'TARJETA', '2026-11-15 08:00:00', '3307', 'AUT-6'),
    (9007, 'ALQUILER', 600000, 'TARJETA', '2026-11-17 08:00:00', '1007', 'AUT-7');

-- Conteos de SEMILLAS: departments 7, cities 7, branches 6, employees 14,
-- categories 6, seasons 10, rates 18, brands 7, models 9, vehicles 17,
-- maintenances 6, customers 14, licenses 14, additional_drivers 4, extras 6,
-- reservations 14, contracts 8, contract_extras 10, contract_drivers 5,
-- deliveries 8, returns 5, inspections 13, damages 3, deposits 8, payments 13.
SELECT 'departments' AS tabla, COUNT(*) AS filas FROM departments
UNION ALL
SELECT 'cities' AS tabla, COUNT(*) AS filas FROM cities
UNION ALL
SELECT 'branches' AS tabla, COUNT(*) AS filas FROM branches
UNION ALL
SELECT 'employees' AS tabla, COUNT(*) AS filas FROM employees
UNION ALL
SELECT 'categories' AS tabla, COUNT(*) AS filas FROM categories
UNION ALL
SELECT 'seasons' AS tabla, COUNT(*) AS filas FROM seasons
UNION ALL
SELECT 'rates' AS tabla, COUNT(*) AS filas FROM rates
UNION ALL
SELECT 'brands' AS tabla, COUNT(*) AS filas FROM brands
UNION ALL
SELECT 'models' AS tabla, COUNT(*) AS filas FROM models
UNION ALL
SELECT 'vehicles' AS tabla, COUNT(*) AS filas FROM vehicles
UNION ALL
SELECT 'maintenances' AS tabla, COUNT(*) AS filas FROM maintenances
UNION ALL
SELECT 'customers' AS tabla, COUNT(*) AS filas FROM customers
UNION ALL
SELECT 'licenses' AS tabla, COUNT(*) AS filas FROM licenses
UNION ALL
SELECT 'additional_drivers' AS tabla, COUNT(*) AS filas FROM additional_drivers
UNION ALL
SELECT 'extras' AS tabla, COUNT(*) AS filas FROM extras
UNION ALL
SELECT 'reservations' AS tabla, COUNT(*) AS filas FROM reservations
UNION ALL
SELECT 'contracts' AS tabla, COUNT(*) AS filas FROM contracts
UNION ALL
SELECT 'contract_extras' AS tabla, COUNT(*) AS filas FROM contract_extras
UNION ALL
SELECT 'contract_drivers' AS tabla, COUNT(*) AS filas FROM contract_drivers
UNION ALL
SELECT 'deliveries' AS tabla, COUNT(*) AS filas FROM deliveries
UNION ALL
SELECT 'returns' AS tabla, COUNT(*) AS filas FROM returns
UNION ALL
SELECT 'inspections' AS tabla, COUNT(*) AS filas FROM inspections
UNION ALL
SELECT 'damages' AS tabla, COUNT(*) AS filas FROM damages
UNION ALL
SELECT 'deposits' AS tabla, COUNT(*) AS filas FROM deposits
UNION ALL
SELECT 'payments' AS tabla, COUNT(*) AS filas FROM payments;

-- Operación 1: valores por defecto, sin especificar aeropuerto ni estado.
INSERT INTO branches (name, address, phone, city_id) VALUES
    ('FlotaYa Bucaramanga Cabecera', 'Carrera 35 # 48-20', '6077001007', 6);
INSERT INTO employees (full_name, email, role, hired_on, branch_id) VALUES
    ('Daniel Rojas', 'daniel.rojas@flotaya.example.com', 'ASESOR', '2026-11-20', 7);
INSERT INTO vehicles (plate, model_year, color, mileage_km, model_id, branch_id) VALUES
    ('DST503', 2026, 'Rojo', 1200, 5, 7);
SELECT b.name AS sede,b.is_airport AS es_aeropuerto,c.name AS ciudad,e.full_name AS asesor,v.plate AS vehiculo,v.status AS estado
FROM branches b JOIN cities c ON c.id=b.city_id JOIN employees e ON e.branch_id=b.id
JOIN vehicles v ON v.branch_id=b.id WHERE b.id=7;
-- Operación 2: historial de extras preservado.
SELECT * FROM rates WHERE id=18;
UPDATE rates SET daily_rate=daily_rate*1.05 WHERE id=18;
SELECT * FROM rates WHERE id=18;
SELECT * FROM extras WHERE id=1;
UPDATE extras SET daily_price=16000 WHERE id=1;
SELECT * FROM extras WHERE id=1;
SELECT e.name AS extra,e.daily_price AS precio_lista,ce.contract_id AS contrato,ce.agreed_daily_price AS precio_pactado
FROM extras e JOIN contract_extras ce ON ce.extra_id=e.id WHERE e.id=1;
-- Operación 3. ⚠️ ESPERADO: ERROR 1175 con SQL_SAFE_UPDATES=1 (WHERE sin índice).
-- UPDATE reservations SET status='CONFIRMADA' WHERE status='PENDIENTE' AND start_date BETWEEN '2026-12-01' AND '2026-12-31';
SELECT * FROM reservations WHERE id IN (511,512);
UPDATE reservations SET status='CONFIRMADA' WHERE id IN (511,512);
SELECT * FROM reservations WHERE id IN (511,512);
-- Operación 4: padres sin hijos.
SELECT * FROM brands WHERE id=7;
SELECT COUNT(*) AS modelos FROM models WHERE brand_id=7;
DELETE FROM brands WHERE id=7;
SELECT * FROM brands WHERE id=7;
SELECT * FROM extras WHERE id=6;
SELECT COUNT(*) AS contratos FROM contract_extras WHERE extra_id=6;
DELETE FROM extras WHERE id=6;
SELECT * FROM extras WHERE id=6;
SELECT * FROM categories WHERE id=1;
SELECT (SELECT COUNT(*) FROM models WHERE category_id=1) AS modelos,(SELECT COUNT(*) FROM rates WHERE category_id=1) AS tarifas;
-- ⚠️ ESPERADO: ERROR 1451. Categoría referenciada por modelos y tarifas.
-- DELETE FROM categories WHERE id=1;
SELECT * FROM categories WHERE id=1;
-- Operación 5: tres restricciones diferentes; ejecutar cada sentencia por separado.
-- ⚠️ ESPERADO: ERROR 1062. Placa UNIQUE.
-- INSERT INTO vehicles (plate,model_year,color,mileage_km,model_id,branch_id) VALUES ('KWD101',2026,'Rojo',0,1,1);
-- ⚠️ ESPERADO: ERROR 3819. CHECK de tarifa positiva.
-- UPDATE rates SET daily_rate=0 WHERE id=1;
-- ⚠️ ESPERADO: ERROR 1265. ENUM rechaza CHEQUE en modo estricto.
-- INSERT INTO payments (contract_id,concept,amount,payment_method,paid_at) VALUES (9008,'CIERRE',100,'CHEQUE','2026-11-23 10:00:00');
-- Conteos finales: branches 7, employees 15, vehicles 18, brands 6, extras 5;
-- el resto conserva los conteos de semillas.
SELECT 'departments' AS tabla, COUNT(*) AS filas FROM departments
UNION ALL
SELECT 'cities' AS tabla, COUNT(*) AS filas FROM cities
UNION ALL
SELECT 'branches' AS tabla, COUNT(*) AS filas FROM branches
UNION ALL
SELECT 'employees' AS tabla, COUNT(*) AS filas FROM employees
UNION ALL
SELECT 'categories' AS tabla, COUNT(*) AS filas FROM categories
UNION ALL
SELECT 'seasons' AS tabla, COUNT(*) AS filas FROM seasons
UNION ALL
SELECT 'rates' AS tabla, COUNT(*) AS filas FROM rates
UNION ALL
SELECT 'brands' AS tabla, COUNT(*) AS filas FROM brands
UNION ALL
SELECT 'models' AS tabla, COUNT(*) AS filas FROM models
UNION ALL
SELECT 'vehicles' AS tabla, COUNT(*) AS filas FROM vehicles
UNION ALL
SELECT 'maintenances' AS tabla, COUNT(*) AS filas FROM maintenances
UNION ALL
SELECT 'customers' AS tabla, COUNT(*) AS filas FROM customers
UNION ALL
SELECT 'licenses' AS tabla, COUNT(*) AS filas FROM licenses
UNION ALL
SELECT 'additional_drivers' AS tabla, COUNT(*) AS filas FROM additional_drivers
UNION ALL
SELECT 'extras' AS tabla, COUNT(*) AS filas FROM extras
UNION ALL
SELECT 'reservations' AS tabla, COUNT(*) AS filas FROM reservations
UNION ALL
SELECT 'contracts' AS tabla, COUNT(*) AS filas FROM contracts
UNION ALL
SELECT 'contract_extras' AS tabla, COUNT(*) AS filas FROM contract_extras
UNION ALL
SELECT 'contract_drivers' AS tabla, COUNT(*) AS filas FROM contract_drivers
UNION ALL
SELECT 'deliveries' AS tabla, COUNT(*) AS filas FROM deliveries
UNION ALL
SELECT 'returns' AS tabla, COUNT(*) AS filas FROM returns
UNION ALL
SELECT 'inspections' AS tabla, COUNT(*) AS filas FROM inspections
UNION ALL
SELECT 'damages' AS tabla, COUNT(*) AS filas FROM damages
UNION ALL
SELECT 'deposits' AS tabla, COUNT(*) AS filas FROM deposits
UNION ALL
SELECT 'payments' AS tabla, COUNT(*) AS filas FROM payments;
