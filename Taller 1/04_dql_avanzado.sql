USE bibliored;
-- Estos seis procedimientos no hacen COMMIT. El llamador controla la transacción.
-- sp_prestar_ejemplar conserva el orden UPDATE/INSERT exigido para el experimento TCL.
DROP PROCEDURE IF EXISTS sp_resumen_socio;
DELIMITER $$
CREATE PROCEDURE sp_resumen_socio(IN p_member_id BIGINT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM members WHERE id=p_member_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio no existe';
    END IF;
    SELECT (SELECT COUNT(*) FROM loans WHERE member_id=p_member_id AND status='ACTIVO') AS prestamos_activos,
           COALESCE((SELECT SUM(f.amount-COALESCE(p.paid,0)) FROM fines f
           JOIN loans l ON l.id=f.loan_id
           LEFT JOIN (SELECT fine_id,SUM(amount) AS paid FROM fine_payments GROUP BY fine_id) p ON p.fine_id=f.id
           WHERE l.member_id=p_member_id AND f.status='PENDIENTE'),0.00) AS saldo_pendiente;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_prestar_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_prestar_ejemplar(IN p_copy_id BIGINT,IN p_member_id BIGINT,IN p_employee_id BIGINT,IN p_loan_date DATE)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_limit INT;
    DECLARE v_days INT;
    DECLARE v_message VARCHAR(128);
    IF NOT EXISTS (SELECT 1 FROM members WHERE id=p_member_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio no existe';
    END IF;
    SELECT status INTO v_status FROM members WHERE id=p_member_id FOR UPDATE;
    IF v_status<>'ACTIVO' THEN
        SET v_message=CONCAT('El socio no está activo: ',v_status);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM copies WHERE id=p_copy_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El ejemplar no existe';
    END IF;
    SELECT status INTO v_status FROM copies WHERE id=p_copy_id FOR UPDATE;
    IF v_status<>'DISPONIBLE' THEN
        SET v_message=CONCAT('El ejemplar no está disponible: ',v_status);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
    END IF;
    IF EXISTS (SELECT 1 FROM fines f JOIN loans l ON l.id=f.loan_id WHERE l.member_id=p_member_id AND f.status='PENDIENTE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio tiene multas pendientes';
    END IF;
    SELECT mt.loan_limit,mt.loan_days INTO v_limit,v_days
    FROM membership_types mt JOIN members m ON m.membership_type_id=mt.id WHERE m.id=p_member_id;
    IF (SELECT COUNT(*) FROM loans WHERE member_id=p_member_id AND status='ACTIVO')>=v_limit THEN
        SET v_message=CONCAT('El socio alcanzó su tope de ',v_limit,' préstamos');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
    END IF;
    UPDATE copies SET status='PRESTADO' WHERE id=p_copy_id;
    INSERT INTO loans (copy_id,member_id,employee_id,loan_date,due_date)
    VALUES (p_copy_id,p_member_id,p_employee_id,p_loan_date,DATE_ADD(p_loan_date,INTERVAL v_days DAY));
    SELECT LAST_INSERT_ID() AS prestamo;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_devolver_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_devolver_ejemplar(IN p_loan_id BIGINT,IN p_return_date DATE)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_start DATE;
    DECLARE v_due DATE;
    DECLARE v_copy BIGINT;
    DECLARE v_days INT;
    DECLARE v_rate DECIMAL(10,2);
    DECLARE v_amount DECIMAL(12,2) DEFAULT 0;
    IF NOT EXISTS (SELECT 1 FROM loans WHERE id=p_loan_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no existe';
    END IF;
    SELECT status,loan_date,due_date,copy_id INTO v_status,v_start,v_due,v_copy
    FROM loans WHERE id=p_loan_id FOR UPDATE;
    IF v_status<>'ACTIVO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no está activo'; END IF;
    IF p_return_date IS NULL OR p_return_date<v_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha de devolución es anterior al préstamo';
    END IF;
    SELECT mt.daily_fine INTO v_rate FROM membership_types mt JOIN members m ON m.membership_type_id=mt.id
    JOIN loans l ON l.member_id=m.id WHERE l.id=p_loan_id;
    SET v_days=GREATEST(DATEDIFF(p_return_date,v_due),0);
    SET v_amount=v_days*v_rate;
    IF v_amount>0 THEN
        INSERT INTO fines (loan_id,reason,late_days,amount,issued_on)
        VALUES (p_loan_id,'MORA',v_days,v_amount,p_return_date);
    END IF;
    UPDATE loans SET status='DEVUELTO',returned_on=p_return_date WHERE id=p_loan_id;
    UPDATE copies SET status='DISPONIBLE' WHERE id=v_copy;
    SELECT v_amount AS multa_generada;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_renovar_prestamo;
DELIMITER $$
CREATE PROCEDURE sp_renovar_prestamo(IN p_loan_id BIGINT,IN p_renewal_date DATE)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_due DATE;
    DECLARE v_start DATE;
    DECLARE v_new DATE;
    DECLARE v_title BIGINT;
    DECLARE v_limit INT;
    DECLARE v_days INT;
    DECLARE v_message VARCHAR(128);
    IF NOT EXISTS (SELECT 1 FROM loans WHERE id=p_loan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no existe'; END IF;
    SELECT l.status,l.due_date,l.loan_date,c.title_id,mt.renewal_limit,mt.loan_days
    INTO v_status,v_due,v_start,v_title,v_limit,v_days FROM loans l
    JOIN copies c ON c.id=l.copy_id JOIN members m ON m.id=l.member_id
    JOIN membership_types mt ON mt.id=m.membership_type_id WHERE l.id=p_loan_id FOR UPDATE;
    IF v_status<>'ACTIVO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no está activo'; END IF;
    IF p_renewal_date>v_due THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo está vencido: primero debe devolverse'; END IF;
    IF (SELECT COUNT(*) FROM renewals WHERE loan_id=p_loan_id)>=v_limit THEN
        SET v_message=CONCAT('El préstamo ya usó sus ',v_limit,' renovaciones');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
    END IF;
    IF EXISTS (SELECT 1 FROM reservations WHERE title_id=v_title AND status='PENDIENTE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Hay reservas pendientes para este título';
    END IF;
    IF p_renewal_date IS NULL OR p_renewal_date<v_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La renovación no puede ser anterior al préstamo';
    END IF;
    SET v_new=DATE_ADD(v_due,INTERVAL v_days DAY);
    INSERT INTO renewals (loan_id,renewed_on,previous_due_date,new_due_date) VALUES (p_loan_id,p_renewal_date,v_due,v_new);
    UPDATE loans SET due_date=v_new WHERE id=p_loan_id;
    SELECT v_new AS nuevo_vencimiento;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_reporte_sedes;
DELIMITER $$
CREATE PROCEDURE sp_reporte_sedes(IN p_cutoff DATE)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_id BIGINT;
    DECLARE v_name VARCHAR(100);
    DECLARE v_copies INT;
    DECLARE v_loans INT;
    DECLARE v_overdue INT;
    DECLARE v_branches CURSOR FOR SELECT id,name FROM branches ORDER BY id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=TRUE;
    DROP TEMPORARY TABLE IF EXISTS branch_report;
    CREATE TEMPORARY TABLE branch_report (sede VARCHAR(100),ejemplares INT,prestados INT,vencidos INT,ocupacion_pct DECIMAL(7,2));
    OPEN v_branches;
    read_branches: LOOP
        FETCH v_branches INTO v_id,v_name;
        IF v_done THEN LEAVE read_branches; END IF;
        SELECT COUNT(*) INTO v_copies FROM copies WHERE branch_id=v_id AND status NOT IN ('PERDIDO','DADO_DE_BAJA');
        SELECT COUNT(*),COALESCE(SUM(l.due_date<p_cutoff),0) INTO v_loans,v_overdue
        FROM loans l JOIN copies c ON c.id=l.copy_id WHERE c.branch_id=v_id AND l.status='ACTIVO';
        INSERT INTO branch_report (sede,ejemplares,prestados,vencidos,ocupacion_pct)
        VALUES (v_name,v_copies,v_loans,v_overdue,ROUND(v_loans*100.0/NULLIF(v_copies,0),2));
    END LOOP;
    CLOSE v_branches;
    SELECT sede,ejemplares,prestados,vencidos,ocupacion_pct FROM branch_report ORDER BY ocupacion_pct DESC,sede;
    DROP TEMPORARY TABLE branch_report;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_pagar_multa;
DELIMITER $$
CREATE PROCEDURE sp_pagar_multa(IN p_fine_id BIGINT,IN p_amount DECIMAL(12,2),IN p_method VARCHAR(30),IN p_paid_on DATE)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_balance DECIMAL(12,2);
    -- ENUM inválido produce 1265 en modo estricto. NULL produce 1048.
    DECLARE EXIT HANDLER FOR 1265,1048
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Medio de pago no válido: use EFECTIVO, TARJETA o TRANSFERENCIA';
    IF NOT EXISTS (SELECT 1 FROM fines WHERE id=p_fine_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La multa no existe'; END IF;
    SELECT status,amount INTO v_status,v_total FROM fines WHERE id=p_fine_id FOR UPDATE;
    IF v_status<>'PENDIENTE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La multa no está pendiente'; END IF;
    SELECT v_total-COALESCE(SUM(amount),0) INTO v_balance FROM fine_payments WHERE fine_id=p_fine_id;
    IF p_amount IS NULL OR p_amount<=0 OR p_amount>v_balance THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El abono debe ser mayor que 0 y no superar el saldo';
    END IF;
    INSERT INTO fine_payments (fine_id,amount,paid_on,payment_method) VALUES (p_fine_id,p_amount,p_paid_on,p_method);
    SET v_balance=v_balance-p_amount;
    IF v_balance=0 THEN UPDATE fines SET status='PAGADA' WHERE id=p_fine_id; END IF;
    SELECT v_balance AS saldo;
END $$
DELIMITER ;

-- PRUEBAS. Las fallidas están comentadas para ejecutar 01-05 completos.
-- sp_resumen_socio · 1: Juan Pablo, suspendido, debe 2000 después de su abono.
CALL sp_resumen_socio(4);
-- sp_resumen_socio · 2: Santiago tiene 2 activos y saldo cero.
CALL sp_resumen_socio(1);
-- sp_resumen_socio · 3. ⚠️ ESPERADO: ERROR 1644 El socio no existe
-- CALL sp_resumen_socio(999);

-- sp_prestar_ejemplar · 1: Tomás, activo y sin historia, copia 7 disponible.
START TRANSACTION;
CALL sp_prestar_ejemplar(7,13,2,'2026-11-10');
SELECT * FROM loans WHERE id=LAST_INSERT_ID();
SELECT * FROM copies WHERE id=7;
COMMIT;
-- sp_prestar_ejemplar · 2. ⚠️ ESPERADO: ERROR 1644 El socio no está activo: SUSPENDIDO
-- CALL sp_prestar_ejemplar(8,4,2,'2026-11-10');
-- sp_prestar_ejemplar · 3. ⚠️ ESPERADO: ERROR 1644 El ejemplar no está disponible: PRESTADO
-- CALL sp_prestar_ejemplar(1,13,2,'2026-11-10');
-- sp_prestar_ejemplar · 4. ⚠️ ESPERADO: ERROR 1644 El socio tiene multas pendientes
-- CALL sp_prestar_ejemplar(9,6,2,'2026-11-10');
-- sp_prestar_ejemplar · 5. ⚠️ ESPERADO: ERROR 1644 El socio alcanzó su tope de 2 préstamos
-- CALL sp_prestar_ejemplar(8,1,2,'2026-11-10');
-- sp_prestar_ejemplar · 6. ⚠️ ESPERADO: ERROR 1644 El ejemplar no existe
-- CALL sp_prestar_ejemplar(999,13,2,'2026-11-10');

-- sp_devolver_ejemplar · 1: 1019 era el más atrasado (17 días × 300 = 5100).
START TRANSACTION;
CALL sp_devolver_ejemplar(1019,'2026-11-10');
COMMIT;
-- sp_devolver_ejemplar · 2: 1021 todavía no vence.
START TRANSACTION;
CALL sp_devolver_ejemplar(1021,'2026-11-10');
COMMIT;
-- sp_devolver_ejemplar · 3. ⚠️ ESPERADO: ERROR 1644 El préstamo no está activo
-- CALL sp_devolver_ejemplar(1001,'2026-11-10');
-- sp_devolver_ejemplar · 4. ⚠️ ESPERADO: ERROR 1644 La fecha de devolución es anterior al préstamo
-- CALL sp_devolver_ejemplar(1018,'2026-10-01');

-- sp_renovar_prestamo · 1: 1018, Docente, título 6 sin reservas pendientes.
START TRANSACTION;
CALL sp_renovar_prestamo(1018,'2026-11-10');
COMMIT;
-- sp_renovar_prestamo · 2. ⚠️ ESPERADO: ERROR 1644 El préstamo ya usó sus 2 renovaciones
-- CALL sp_renovar_prestamo(1015,'2026-11-10');
-- sp_renovar_prestamo · 3. ⚠️ ESPERADO: ERROR 1644 El préstamo está vencido: primero debe devolverse
-- CALL sp_renovar_prestamo(1020,'2026-11-10');
-- sp_renovar_prestamo · 4. ⚠️ ESPERADO: ERROR 1644 Hay reservas pendientes para este título
-- CALL sp_renovar_prestamo(1017,'2026-11-10');

-- sp_reporte_sedes · 1 y 2: cinco filas; Tabio 0,0,0,NULL. Queda un vencido en Cajicá.
CALL sp_reporte_sedes('2026-11-10');
-- sp_pagar_multa · 1: Felipe, única multa pendiente, sin cuotas.
START TRANSACTION;
CALL sp_pagar_multa(4,2500,'EFECTIVO','2026-11-10');
-- sp_pagar_multa · 2: se permite el préstamo antes rechazado.
CALL sp_prestar_ejemplar(9,6,2,'2026-11-10');
COMMIT;
-- sp_pagar_multa · 3: multa parcialmente abonada de Juan Pablo, quedan 1500.
START TRANSACTION;
CALL sp_pagar_multa(3,500,'TARJETA','2026-11-10');
COMMIT;
-- sp_pagar_multa · 4. ⚠️ ESPERADO: ERROR 1644 La multa no está pendiente
-- CALL sp_pagar_multa(1,100,'EFECTIVO','2026-11-10');
-- sp_pagar_multa · 5. ⚠️ ESPERADO: ERROR 1644 El abono debe ser mayor que 0 y no superar el saldo
-- CALL sp_pagar_multa(3,99999,'EFECTIVO','2026-11-10');
-- sp_pagar_multa · 6. ⚠️ ESPERADO: ERROR 1644 Medio de pago no válido: use EFECTIVO, TARJETA o TRANSFERENCIA
-- CALL sp_pagar_multa(3,100,'CHEQUE','2026-11-10');
SHOW PROCEDURE STATUS WHERE Db='bibliored';
