USE flotaya;
SET SESSION sql_mode='STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
-- fn_prueba_1418. Ejecutar solo si se quiere observar el error:
-- ⚠️ ESPERADO: ERROR 1418 cuando log_bin=ON y log_bin_trust_function_creators=OFF.
-- CREATE FUNCTION fn_prueba_1418() RETURNS INT RETURN 1;
-- No es un error universal: depende de esa configuración. MySQL exige declarar
-- características para evaluar la seguridad de la función con registro binario.
SHOW VARIABLES WHERE Variable_name IN ('log_bin','log_bin_trust_function_creators');

DROP FUNCTION IF EXISTS fn_edad_conductor;
DELIMITER $$
-- Misma entrada, misma edad; solo calcula sobre parámetros.
CREATE FUNCTION fn_edad_conductor(p_birth_date DATE,p_reference_date DATE)
RETURNS INT DETERMINISTIC NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR,p_birth_date,p_reference_date);
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS fn_valor_alquiler;
DELIMITER $$
-- Puede cambiar si cambian tarifas/temporadas; lee ambas tablas.
CREATE FUNCTION fn_valor_alquiler(p_category_id BIGINT,p_start_date DATE,p_end_date DATE)
RETURNS DECIMAL(12,2) NOT DETERMINISTIC READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    DECLARE v_day DATE;
    DECLARE v_rate DECIMAL(12,2);
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_count INT;
    DECLARE v_message VARCHAR(128);
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date<=p_start_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha final debe ser posterior a la inicial';
    END IF;
    SET v_day=p_start_date;
    WHILE v_day<p_end_date DO
        SELECT COUNT(*),MAX(r.daily_rate) INTO v_count,v_rate
        FROM seasons s JOIN rates r ON r.season_type=s.season_type
        WHERE r.category_id=p_category_id AND v_day BETWEEN s.start_date AND s.end_date;
        IF v_count=0 THEN
            SET v_message=CONCAT('No hay temporada o tarifa para el día ',DATE_FORMAT(v_day,'%Y-%m-%d'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
        END IF;
        IF v_count>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El calendario contiene temporadas superpuestas';
        END IF;
        SET v_total=v_total+v_rate;
        SET v_day=DATE_ADD(v_day,INTERVAL 1 DAY);
    END WHILE;
    RETURN v_total;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS fn_licencia_vigente;
DELIMITER $$
-- El resultado cambia al insertar/actualizar licencias; lee datos.
CREATE FUNCTION fn_licencia_vigente(p_customer_id BIGINT,p_reference_date DATE)
RETURNS BOOLEAN NOT DETERMINISTIC READS SQL DATA
SQL SECURITY DEFINER
BEGIN
    RETURN EXISTS (SELECT 1 FROM licenses WHERE customer_id=p_customer_id
                   AND issued_on<=p_reference_date AND expires_on>=p_reference_date);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_crear_reserva;
DELIMITER $$
CREATE PROCEDURE sp_crear_reserva(IN p_customer_id BIGINT,IN p_vehicle_id BIGINT,
 IN p_pickup_branch_id BIGINT,IN p_return_branch_id BIGINT,
 IN p_start_date DATE,IN p_end_date DATE,OUT p_reservation_id BIGINT)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_status VARCHAR(25);
    DECLARE v_birth DATE;
    DECLARE v_category BIGINT;
    DECLARE v_minimum INT;
    DECLARE v_age INT;
    DECLARE v_quote DECIMAL(12,2);
    DECLARE v_message VARCHAR(128);
    SET p_reservation_id=NULL;
    IF NOT EXISTS (SELECT 1 FROM customers WHERE id=p_customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente no existe';
    END IF;
    SELECT status,birth_date INTO v_status,v_birth FROM customers WHERE id=p_customer_id FOR UPDATE;
    IF v_status='BLOQUEADO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente está bloqueado'; END IF;
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date<=p_start_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La devolución debe ser posterior a la recogida';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM vehicles WHERE id=p_vehicle_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo no existe';
    END IF;
    SELECT v.status,m.category_id,c.minimum_age INTO v_status,v_category,v_minimum
    FROM vehicles v JOIN models m ON m.id=v.model_id JOIN categories c ON c.id=m.category_id
    WHERE v.id=p_vehicle_id FOR UPDATE;
    IF v_status='FUERA_DE_SERVICIO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo está fuera de servicio'; END IF;
    IF EXISTS (SELECT 1 FROM reservations WHERE vehicle_id=p_vehicle_id
     AND status IN ('PENDIENTE','CONFIRMADA','CONVERTIDA') AND start_date<=p_end_date AND end_date>=p_start_date) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo ya está reservado en esas fechas';
    END IF;
    SET v_age=fn_edad_conductor(v_birth,p_start_date);
    IF v_age<v_minimum THEN
        SET v_message=CONCAT('El cliente tiene ',v_age,' años y la categoría exige ',v_minimum);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
    END IF;
    -- No basta con dos licencias disjuntas: una misma licencia debe cubrir todo el intervalo.
    IF NOT fn_licencia_vigente(p_customer_id,p_end_date) OR NOT EXISTS
     (SELECT 1 FROM licenses WHERE customer_id=p_customer_id AND issued_on<=p_start_date AND expires_on>=p_end_date) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente no tiene licencia vigente durante todo el alquiler';
    END IF;
    SET v_quote=fn_valor_alquiler(v_category,p_start_date,p_end_date);
    INSERT INTO reservations (customer_id,vehicle_id,pickup_branch_id,return_branch_id,start_date,end_date,quoted_amount,created_at)
    VALUES (p_customer_id,p_vehicle_id,p_pickup_branch_id,p_return_branch_id,p_start_date,p_end_date,v_quote,'2026-11-23 09:00:00');
    SET p_reservation_id=LAST_INSERT_ID();
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_cerrar_contrato;
DELIMITER $$
CREATE PROCEDURE sp_cerrar_contrato(IN p_contract_id BIGINT,IN p_close_date DATE,OUT p_balance DECIMAL(12,2))
SQL SECURITY DEFINER
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_start DATE;
    DECLARE v_vehicle BIGINT;
    DECLARE v_category BIGINT;
    DECLARE v_return_date DATE;
    DECLARE v_branch BIGINT;
    DECLARE v_mileage INT;
    DECLARE v_rental DECIMAL(12,2);
    DECLARE v_extras DECIMAL(12,2);
    DECLARE v_damages DECIMAL(12,2);
    DECLARE v_paid DECIMAL(12,2);
    DECLARE v_deposit BIGINT;
    DECLARE v_deposit_amount DECIMAL(12,2);
    DECLARE v_applied DECIMAL(12,2);
    SET p_balance=NULL;
    IF NOT EXISTS (SELECT 1 FROM contracts WHERE id=p_contract_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no existe';
    END IF;
    SELECT status,start_date,vehicle_id INTO v_status,v_start,v_vehicle FROM contracts WHERE id=p_contract_id FOR UPDATE;
    IF v_status<>'ABIERTO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no está abierto'; END IF;
    IF NOT EXISTS (SELECT 1 FROM returns WHERE contract_id=p_contract_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no tiene devolución registrada';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM inspections WHERE contract_id=p_contract_id AND stage='DEVOLUCION') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falta la inspección de devolución';
    END IF;
    IF p_close_date IS NULL OR p_close_date<=v_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha de cierre debe ser posterior al inicio';
    END IF;
    SELECT DATE(returned_at),branch_id,mileage_km INTO v_return_date,v_branch,v_mileage
    FROM returns WHERE contract_id=p_contract_id;
    IF p_close_date<>v_return_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha de cierre debe coincidir con la devolución registrada';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM deposits WHERE contract_id=p_contract_id AND status='RETENIDO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no tiene depósito retenido';
    END IF;
    SELECT m.category_id INTO v_category FROM vehicles v JOIN models m ON m.id=v.model_id WHERE v.id=v_vehicle;
    SET v_rental=fn_valor_alquiler(v_category,v_start,v_return_date);
    SELECT COALESCE(SUM(quantity*agreed_daily_price),0)*DATEDIFF(v_return_date,v_start)
    INTO v_extras FROM contract_extras WHERE contract_id=p_contract_id;
    SELECT COALESCE(SUM(d.repair_cost),0) INTO v_damages FROM damages d JOIN inspections i ON i.id=d.inspection_id
    WHERE i.contract_id=p_contract_id AND i.stage='DEVOLUCION' AND d.chargeable=TRUE;
    SELECT id,amount INTO v_deposit,v_deposit_amount FROM deposits WHERE contract_id=p_contract_id FOR UPDATE;
    SET v_applied=LEAST(v_deposit_amount,v_damages);
    IF v_applied>0 THEN
        INSERT INTO payments (contract_id,concept,amount,payment_method,paid_at)
        VALUES (p_contract_id,'DAÑOS',v_applied,'DEPOSITO',p_close_date);
    END IF;
    UPDATE deposits SET applied_amount=v_applied,status=IF(v_applied>0,'APLICADO','LIBERADO'),
        released_at=p_close_date WHERE id=v_deposit;
    UPDATE contracts SET actual_end_date=v_return_date,rental_amount=v_rental,status='CERRADO' WHERE id=p_contract_id;
    UPDATE vehicles SET status='DISPONIBLE',branch_id=v_branch,mileage_km=v_mileage WHERE id=v_vehicle;
    SELECT COALESCE(SUM(amount),0) INTO v_paid FROM payments WHERE contract_id=p_contract_id;
    SET p_balance=v_rental+v_extras+v_damages-v_paid;
    -- Sin START TRANSACTION ni COMMIT: entrega, inspección, cierre y cobro deben
    -- estar dentro de UNA transacción del llamador, como se muestra en 05_tcl.sql.
END $$
DELIMITER ;

-- 5.1 · Pruebas de funciones; columnas deben dar 21,22,620000,2300000,1080000,1202500.
SELECT fn_edad_conductor('2004-07-15','2026-07-14') AS antes_cumpleanos,
 fn_edad_conductor('2004-07-15','2026-07-15') AS cumpleanos,
 fn_valor_alquiler(1,'2026-11-27','2026-12-02') AS economico,
 fn_valor_alquiler(5,'2026-12-18','2026-12-23') AS van,
 fn_valor_alquiler(3,'2026-10-08','2026-10-12') AS suv,
 fn_valor_alquiler(6,'2026-12-14','2026-12-16') AS lujo;
-- ⚠️ ESPERADO: ERROR 1644 La fecha final debe ser posterior a la inicial
-- SELECT fn_valor_alquiler(1,'2026-12-05','2026-12-05');
-- ⚠️ ESPERADO: ERROR 1644 No hay temporada o tarifa para el día 2027-01-16
-- SELECT fn_valor_alquiler(1,'2027-01-14','2027-01-18');
SELECT fn_licencia_vigente(7,'2026-11-23') AS jorge,
 fn_licencia_vigente(8,'2026-11-23') AS paola_corte,fn_licencia_vigente(8,'2026-12-15') AS paola_diciembre,
 fn_licencia_vigente(9,'2026-12-15') AS esteban,fn_licencia_vigente(12,'2026-12-15') AS laura;
SELECT CONCAT(first_name,' ',last_name) AS cliente,birth_date AS nacimiento,
 fn_edad_conductor(birth_date,'2026-11-23') AS edad,
 IF(fn_edad_conductor(birth_date,'2026-11-23')>=23,'Sí','No') AS puede_suv,
 IF(fn_edad_conductor(birth_date,'2026-11-23')>=25,'Sí','No') AS puede_4x4_o_van
FROM customers WHERE fn_edad_conductor(birth_date,'2026-11-23')<25 ORDER BY edad,id;
SELECT id,CONCAT(first_name,' ',last_name) AS cliente,
 fn_licencia_vigente(id,'2026-11-23') AS vigente_al_corte,
 fn_licencia_vigente(id,'2026-12-15') AS vigente_15_dic
FROM customers WHERE NOT fn_licencia_vigente(id,'2026-12-15') ORDER BY id;

-- sp_crear_reserva · prueba 1. ROLLBACK permite repetir las pruebas de 04.
START TRANSACTION;
CALL sp_crear_reserva(7,14,3,3,'2026-12-19','2026-12-22',@reserva);
SELECT * FROM reservations WHERE id=@reserva; -- PENDIENTE, 1290000.
ROLLBACK;
-- prueba 2. ⚠️ ESPERADO: ERROR 1644 El vehículo ya está reservado en esas fechas
-- CALL sp_crear_reserva(2,1,1,1,'2026-11-30','2026-12-04',@reserva);
-- Carlos cumple edad y licencia: únicamente falla el cruce con Juliana.
-- prueba 3. ⚠️ ESPERADO: ERROR 1644 El cliente tiene 22 años y la categoría exige 23
-- CALL sp_crear_reserva(3,13,4,4,'2026-12-12','2026-12-14',@reserva);
-- prueba 4. ⚠️ ESPERADO: ERROR 1644 El cliente no tiene licencia vigente durante todo el alquiler
-- CALL sp_crear_reserva(8,2,2,2,'2026-12-08','2026-12-12',@reserva);
-- prueba 5. ⚠️ ESPERADO: ERROR 1644 El cliente está bloqueado
-- CALL sp_crear_reserva(10,2,2,2,'2026-12-01','2026-12-03',@reserva);
-- prueba 6. ⚠️ ESPERADO: ERROR 1644 El vehículo está fuera de servicio
-- CALL sp_crear_reserva(1,3,6,6,'2026-12-01','2026-12-03',@reserva);
-- sp_cerrar_contrato · prueba 1. ⚠️ ESPERADO: ERROR 1644 El contrato no está abierto
-- CALL sp_cerrar_contrato(9001,'2026-11-23',@saldo);
-- prueba 2. ⚠️ ESPERADO: ERROR 1644 El contrato no tiene devolución registrada
-- CALL sp_cerrar_contrato(9008,'2026-11-23',@saldo);

-- prueba 3: auxiliar de prueba idempotente; se elimina al terminar.
DROP PROCEDURE IF EXISTS sp_prueba_ricardo;
DELIMITER $$
CREATE PROCEDURE sp_prueba_ricardo()
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    IF EXISTS (SELECT 1 FROM contracts WHERE id=9007 AND status='ABIERTO') THEN
        START TRANSACTION;
        INSERT INTO returns (contract_id,returned_at,mileage_km,fuel_pct,branch_id,employee_id)
        VALUES (9007,'2026-11-21 10:00:00',30910,100,1,9);
        INSERT INTO inspections (contract_id,stage,inspected_at,exterior_ok,interior_ok,employee_id)
        VALUES (9007,'DEVOLUCION','2026-11-21 10:10:00',TRUE,TRUE,9);
        CALL sp_cerrar_contrato(9007,'2026-11-21',v_balance);
        SELECT v_balance AS saldo_ricardo; -- 60000
        COMMIT;
    END IF;
    SELECT co.id AS contrato,co.status AS estado,co.rental_amount AS alquiler,v.plate AS placa,
        v.status AS estado_vehiculo,v.mileage_km AS kilometraje,v.branch_id AS sede,d.status AS deposito
    FROM contracts co JOIN vehicles v ON v.id=co.vehicle_id JOIN deposits d ON d.contract_id=co.id WHERE co.id=9007;
END $$
DELIMITER ;
CALL sp_prueba_ricardo();
DROP PROCEDURE sp_prueba_ricardo;

-- 5.3 · Solo cuentas del ejercicio en localhost. Ejecutar con administrador
-- en una instancia de prácticas. Se recrean para evitar privilegios residuales.
DROP USER IF EXISTS 'asesor_flotaya'@'localhost','taller_flotaya'@'localhost','auditor_flotaya'@'localhost';
DROP ROLE IF EXISTS 'rol_asesor_flotaya','rol_taller_flotaya','rol_auditor_flotaya';
CREATE ROLE 'rol_asesor_flotaya','rol_taller_flotaya','rol_auditor_flotaya';
GRANT SELECT ON flotaya.reservations TO 'rol_asesor_flotaya';
GRANT UPDATE (status) ON flotaya.reservations TO 'rol_asesor_flotaya';
GRANT SELECT ON flotaya.customers TO 'rol_asesor_flotaya';
GRANT SELECT ON flotaya.vehicles TO 'rol_asesor_flotaya';
GRANT EXECUTE ON PROCEDURE flotaya.sp_crear_reserva TO 'rol_asesor_flotaya';
GRANT EXECUTE ON FUNCTION flotaya.fn_valor_alquiler TO 'rol_asesor_flotaya';

GRANT SELECT,INSERT,UPDATE ON flotaya.maintenances TO 'rol_taller_flotaya';
GRANT SELECT (id,plate,status,mileage_km,branch_id),UPDATE (status) ON flotaya.vehicles TO 'rol_taller_flotaya';

GRANT SELECT ON flotaya.contracts TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.reservations TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.vehicles TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.maintenances TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.returns TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.inspections TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.damages TO 'rol_auditor_flotaya';
GRANT SELECT ON flotaya.deposits TO 'rol_auditor_flotaya';
GRANT SELECT (id,contract_id,concept,amount,paid_at) ON flotaya.payments TO 'rol_auditor_flotaya';

CREATE USER 'asesor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'taller_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'auditor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
GRANT 'rol_asesor_flotaya' TO 'asesor_flotaya'@'localhost';
GRANT 'rol_taller_flotaya' TO 'taller_flotaya'@'localhost';
GRANT 'rol_auditor_flotaya' TO 'auditor_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_asesor_flotaya' TO 'asesor_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_taller_flotaya' TO 'taller_flotaya'@'localhost';
SET DEFAULT ROLE 'rol_auditor_flotaya' TO 'auditor_flotaya'@'localhost';
SHOW GRANTS FOR 'rol_taller_flotaya';
SHOW GRANTS FOR 'asesor_flotaya'@'localhost';
SHOW GRANTS FOR 'asesor_flotaya'@'localhost' USING 'rol_asesor_flotaya';

-- Ejecutar cada bloque siguiente en SU conexión, no como administrador.
-- Se incluyen también como archivos separados en evidencias/ para facilitarlo.
-- Como asesor_flotaya:
-- SELECT CURRENT_USER(),CURRENT_ROLE(); SHOW TABLES;
-- START TRANSACTION;
-- CALL sp_crear_reserva(14,13,4,4,'2026-12-12','2026-12-15',@nueva);
-- UPDATE reservations SET status='CONFIRMADA' WHERE id=@nueva;
-- SELECT * FROM reservations WHERE id=@nueva;
-- COMMIT;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT * FROM payments;
-- ⚠️ ESPERADO: ERROR 1142
-- DELETE FROM reservations WHERE id=@nueva;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT COUNT(*) FROM licenses;
-- SET ROLE NONE; SELECT CURRENT_ROLE(); SHOW GRANTS;
-- SET ROLE DEFAULT; SELECT CURRENT_ROLE();

-- Como taller_flotaya:
-- SELECT CURRENT_USER(),CURRENT_ROLE(); SHOW TABLES;
-- START TRANSACTION;
-- UPDATE maintenances SET end_date='2026-11-23',cost=1850000 WHERE id=1;
-- UPDATE vehicles SET status='DISPONIBLE' WHERE id=15;
-- INSERT INTO maintenances (vehicle_id,maintenance_type,description,workshop,start_date,end_date,cost)
-- VALUES (13,'PREVENTIVO','Alineación y balanceo','Taller FlotaYa Bogotá','2026-11-23','2026-11-23',120000);
-- SELECT id,plate,status,mileage_km,branch_id FROM vehicles WHERE id=15;
-- COMMIT;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT * FROM vehicles;
-- ⚠️ ESPERADO: ERROR 1143
-- UPDATE vehicles SET mileage_km=90000 WHERE id=15;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT COUNT(*) FROM contracts;

-- Como auditor_flotaya:
-- SELECT CURRENT_USER(),CURRENT_ROLE(); SHOW TABLES;
-- SELECT id,contract_id,concept,amount,paid_at FROM payments WHERE contract_id=9004;
-- SELECT status,COUNT(*) AS contratos FROM contracts GROUP BY status;
-- ⚠️ ESPERADO: ERROR 1143
-- SELECT card_last_four FROM payments;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT * FROM payments;
-- ⚠️ ESPERADO: ERROR 1142
-- UPDATE contracts SET status='CERRADO' WHERE id=9008;
-- ⚠️ ESPERADO: ERROR 1142
-- SELECT COUNT(*) FROM customers;

-- Respuestas:
-- 1. SQL SECURITY DEFINER ejecuta la rutina con permisos de su definidor.
--    Permite validar licencias sin conceder SELECT al asesor. Si se escribe mal
--    la rutina, podría exponer o modificar datos con privilegios superiores.
-- 2. SELECT * exige acceso a la tabla completa: 1142. Pedir expresamente una
--    columna no concedida en una tabla con permisos parciales produce 1143.
-- 3. Un rol asignado pero inactivo no aporta sus permisos. SET DEFAULT ROLE
--    activa el perfil al conectar; SET ROLE NONE permite comprobar la diferencia.
SHOW FUNCTION STATUS WHERE Db='flotaya';
SHOW PROCEDURE STATUS WHERE Db='flotaya';
