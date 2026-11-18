USE flotaya;
-- Q-01
SELECT status AS estado,COUNT(*) AS vehiculos FROM vehicles
GROUP BY status ORDER BY vehiculos DESC,CAST(status AS CHAR);
-- Q-02 · Intervalo inclusivo: se suma 1.
SELECT name AS temporada,start_date AS desde,end_date AS hasta,
 DATEDIFF(end_date,start_date)+1 AS dias FROM seasons WHERE season_type='ALTA' ORDER BY start_date;
-- Q-03
SELECT v.plate AS placa,b.name AS marca,m.name AS modelo,c.name AS categoria,
 br.name AS sede,ci.name AS ciudad
FROM vehicles v JOIN models m ON m.id=v.model_id JOIN brands b ON b.id=m.brand_id
JOIN categories c ON c.id=m.category_id JOIN branches br ON br.id=v.branch_id
JOIN cities ci ON ci.id=br.city_id WHERE v.status='DISPONIBLE' ORDER BY c.id,v.plate;
-- Q-04 · La subconsulta de conductores devuelve un único conteo por contrato.
SELECT co.id AS contrato,CONCAT(cu.first_name,' ',cu.last_name) AS cliente,
 v.plate AS placa,m.name AS modelo,b.name AS sede_recogida,co.expected_end_date AS fin_esperado,
 DATEDIFF(co.expected_end_date,'2026-11-23') AS dias_para_devolver,
 (SELECT COUNT(*) FROM contract_drivers cd WHERE cd.contract_id=co.id) AS conductores_adicionales
FROM contracts co JOIN reservations r ON r.id=co.reservation_id JOIN customers cu ON cu.id=r.customer_id
JOIN vehicles v ON v.id=co.vehicle_id JOIN models m ON m.id=v.model_id
JOIN branches b ON b.id=r.pickup_branch_id WHERE co.status='ABIERTO' ORDER BY dias_para_devolver,co.id;
-- Q-05 · COUNT DISTINCT evita contar dos veces un contrato con varios pagos.
SELECT b.name AS sede,COUNT(DISTINCT co.id) AS contratos,SUM(p.amount) AS recaudado
FROM payments p JOIN contracts co ON co.id=p.contract_id JOIN reservations r ON r.id=co.reservation_id
JOIN branches b ON b.id=r.pickup_branch_id GROUP BY b.id,b.name
HAVING SUM(p.amount)>2000000 ORDER BY recaudado DESC,b.name;
-- Q-06
SELECT b.name AS marca,m.name AS modelo FROM models m JOIN brands b ON b.id=m.brand_id
WHERE NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.model_id=m.id) ORDER BY b.name,m.name;
-- Q-07 · Jorge queda excluido porque sí tiene una licencia vigente.
SELECT c.id,CONCAT(c.first_name,' ',c.last_name) AS cliente FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM licenses l WHERE l.customer_id=c.id
 AND l.issued_on<='2026-11-23' AND l.expires_on>='2026-11-23') ORDER BY c.id;
-- Q-08 · Se solapan intervalos cerrados, incluso el día de devolución.
SELECT v.plate AS placa,m.name AS modelo,b.name AS sede
FROM vehicles v JOIN models m ON m.id=v.model_id JOIN branches b ON b.id=v.branch_id
WHERE v.status='DISPONIBLE' AND NOT EXISTS (SELECT 1 FROM reservations r WHERE r.vehicle_id=v.id
 AND r.status IN ('PENDIENTE','CONFIRMADA','CONVERTIDA') AND r.start_date<='2026-12-31' AND r.end_date>='2026-12-01')
ORDER BY v.plate;
-- Q-09 · Primero un total por vehículo; luego promedio de dichos totales.
SELECT v.plate AS placa,g.total AS gasto FROM vehicles v
JOIN (SELECT vehicle_id,SUM(cost) AS total FROM maintenances GROUP BY vehicle_id) g ON g.vehicle_id=v.id
WHERE g.total>(SELECT AVG(t.total) FROM (SELECT SUM(cost) AS total FROM maintenances GROUP BY vehicle_id) t)
ORDER BY gasto DESC,v.plate;
SELECT ROUND(AVG(t.total),2) AS promedio_por_vehiculo,COUNT(*) AS vehiculos,COUNT(t.total) AS con_gasto
FROM (SELECT vehicle_id,SUM(cost) AS total FROM maintenances GROUP BY vehicle_id) t;
-- SUM ignora costos NULL. Si un vehículo solo tiene trabajos en curso, su total
-- es NULL: cuenta en vehiculos, pero no en con_gasto ni en el denominador de AVG.
-- Con estas semillas: 593333.33, 5 vehículos, 3 con gasto conocido.
-- Q-10 · Incluye empates. Lujo no aparece porque no tiene vehículos.
SELECT c.name AS categoria,v.plate AS placa,v.mileage_km AS kilometraje
FROM vehicles v JOIN models m ON m.id=v.model_id JOIN categories c ON c.id=m.category_id
WHERE v.mileage_km=(SELECT MAX(v2.mileage_km) FROM vehicles v2 JOIN models m2 ON m2.id=v2.model_id
 WHERE m2.category_id=c.id) ORDER BY c.id,v.plate;
-- Q-11 · Precio pactado, no precio de lista actualizado.
SELECT e.name AS extra,COUNT(ce.id) AS contratos,
 CAST(COALESCE(SUM(ce.quantity*ce.agreed_daily_price*DATEDIFF(COALESCE(co.actual_end_date,co.expected_end_date),co.start_date)),0) AS DECIMAL(12,2)) AS ingresos
FROM extras e LEFT JOIN contract_extras ce ON ce.extra_id=e.id LEFT JOIN contracts co ON co.id=ce.contract_id
GROUP BY e.id,e.name ORDER BY ingresos DESC,e.name;
-- Q-12
SELECT co.id AS contrato,v.plate AS placa,CONCAT(cu.first_name,' ',cu.last_name) AS cliente,
 i.stage AS etapa,d.description AS dano,d.severity AS severidad,d.repair_cost AS costo,
 IF(d.chargeable,'Sí','No') AS se_cobra
FROM damages d JOIN inspections i ON i.id=d.inspection_id JOIN contracts co ON co.id=i.contract_id
JOIN vehicles v ON v.id=co.vehicle_id JOIN reservations r ON r.id=co.reservation_id
JOIN customers cu ON cu.id=r.customer_id ORDER BY co.id,d.id;
