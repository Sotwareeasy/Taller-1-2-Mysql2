USE bibliored;
-- Q-01 · Contacto faltante o socio no activo.
SELECT id, CONCAT(first_name,' ',last_name) AS socio, status AS estado,
       phone AS telefono
FROM members WHERE phone IS NULL OR status <> 'ACTIVO' ORDER BY id;

-- Q-02 · El día del vencimiento no cuenta como mora.
SELECT l.id AS prestamo, CONCAT(m.first_name,' ',m.last_name) AS socio,
       mt.name AS membresia, t.title AS titulo, c.barcode AS ejemplar,
       b.name AS sede, l.due_date AS vence,
       DATEDIFF('2026-11-10',l.due_date) AS dias_mora,
       CAST(DATEDIFF('2026-11-10',l.due_date)*mt.daily_fine AS DECIMAL(12,2)) AS multa_estimada
FROM loans l JOIN members m ON m.id=l.member_id
JOIN membership_types mt ON mt.id=m.membership_type_id
JOIN copies c ON c.id=l.copy_id JOIN titles t ON t.id=c.title_id
JOIN branches b ON b.id=c.branch_id
WHERE l.status='ACTIVO' AND l.due_date<'2026-11-10'
ORDER BY dias_mora DESC, l.id;

-- Q-03
SELECT t.title AS titulo, COUNT(*) AS autores
FROM titles t JOIN title_authors ta ON ta.title_id=t.id
GROUP BY t.id,t.title HAVING COUNT(*)>1 ORDER BY t.id;

-- Q-04
SELECT b.name AS sede, COUNT(*) AS prestamos_totales,
       SUM(l.status='ACTIVO') AS prestamos_activos, COUNT(DISTINCT l.member_id) AS socios_distintos
FROM branches b JOIN copies c ON c.branch_id=b.id JOIN loans l ON l.copy_id=c.id
GROUP BY b.id,b.name HAVING COUNT(*)>=5 ORDER BY prestamos_totales DESC,b.name;

-- Q-05
SELECT m.id, CONCAT(m.first_name,' ',m.last_name) AS socio, m.joined_on AS afiliado_desde
FROM members m WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id=m.id) ORDER BY m.id;

-- Q-06
SELECT 'categoria' AS tipo,c.name AS nombre FROM categories c
WHERE NOT EXISTS (SELECT 1 FROM titles t WHERE t.category_id=c.id)
UNION ALL
SELECT 'autor',a.full_name FROM authors a
WHERE NOT EXISTS (SELECT 1 FROM title_authors ta WHERE ta.author_id=a.id)
ORDER BY tipo,nombre;

-- Q-07 · EXISTS no multiplica socios con varias multas.
SELECT m.id,CONCAT(m.first_name,' ',m.last_name) AS socio,m.status AS estado
FROM members m WHERE EXISTS (SELECT 1 FROM fines f JOIN loans l ON l.id=f.loan_id
 WHERE l.member_id=m.id AND f.status='PENDIENTE') ORDER BY m.id;

-- Q-08 · Disponibilidad en la sede de recogida, no en toda la red.
SELECT r.id AS reserva,CONCAT(m.first_name,' ',m.last_name) AS socio,
 t.title AS titulo,b.name AS sede,r.expires_on AS expira
FROM reservations r JOIN members m ON m.id=r.member_id
JOIN titles t ON t.id=r.title_id JOIN branches b ON b.id=r.branch_id
WHERE r.status='PENDIENTE' AND NOT EXISTS
 (SELECT 1 FROM copies c WHERE c.title_id=r.title_id AND c.branch_id=r.branch_id AND c.status='DISPONIBLE')
ORDER BY r.id;

-- Q-09
SELECT title AS titulo,replacement_cost AS costo_reposicion FROM titles
WHERE replacement_cost>(SELECT AVG(replacement_cost) FROM titles)
ORDER BY replacement_cost DESC,title;

-- Q-10 · >= ALL conserva todos los empates.
SELECT m.id,CONCAT(m.first_name,' ',m.last_name) AS socio,COUNT(*) AS prestamos
FROM members m JOIN loans l ON l.member_id=m.id GROUP BY m.id,m.first_name,m.last_name
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM loans GROUP BY member_id) ORDER BY m.id;

-- Q-11 · Conserva empates en fecha de adquisición.
SELECT b.name AS sede,c.barcode AS ejemplar,t.title AS titulo,c.acquired_on AS adquirido
FROM copies c JOIN branches b ON b.id=c.branch_id JOIN titles t ON t.id=c.title_id
WHERE c.acquired_on=(SELECT MIN(c2.acquired_on) FROM copies c2 WHERE c2.branch_id=c.branch_id)
ORDER BY b.id,c.id;

-- Q-12 · Una fila por multa antes de agrupar: una multa con dos cuotas no se duplica.
SELECT m.id,CONCAT(m.first_name,' ',m.last_name) AS socio,SUM(f.amount) AS total_multas,
 SUM(COALESCE(p.paid,0)) AS pagado,SUM(f.amount-COALESCE(p.paid,0)) AS saldo
FROM members m JOIN loans l ON l.member_id=m.id JOIN fines f ON f.loan_id=l.id
LEFT JOIN (SELECT fine_id,SUM(amount) AS paid FROM fine_payments GROUP BY fine_id) p ON p.fine_id=f.id
WHERE f.status<>'ANULADA' GROUP BY m.id,m.first_name,m.last_name
HAVING saldo>0 ORDER BY saldo DESC,m.id;
