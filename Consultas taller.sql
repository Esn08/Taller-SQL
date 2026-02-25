/* 1. Consultas sobre una tabla (Básicas) */

/* Oficinas: Devuelve un listado con el código de oficina y la ciudad. */
SELECT codigo_oficina, ciudad FROM oficina;

/* Oficinas en España: Devuelve la ciudad y el teléfono de las oficinas de España. */
SELECT ciudad, teléfono FROM oficina WHERE país = 'España';

/* Empleados y Jefes: Nombre, apellidos y email de los empleados cuyo jefe tiene código 7.*/
SELECT nombre, apellido1, apelllido2, email FROM empleado WHERE codigo_jefe = 7;

/* El Gran Jefe: Nombre del puesto, nombre, apellidos y email del jefe de la empresa (sin jefe). */
SELECT puesto, nombre, apellido1, apelllido2, email FROM empleado WHERE codigo_jefe IS NULL;

/* No Comerciales: Nombre, apellidos y puesto de empleados que no sean 'Representante Ventas'.*/
SELECT nombre, apellido1, apelllido2, puesto FROM empleado WHERE puesto <> 'Representante Ventas';

/* Clientes Nacionales: Nombre de todos los clientes españoles. */
SELECT nombre_cliente FROM cliente WHERE país = 'Spain';

/* Estados de Pedido: Listado de los distintos estados de un pedido (sin repetir). */
SELECT DISTINCT estado FROM pedido;

/* Pagos 2008: Código de cliente de aquellos que realizaron pagos en 2008 (sin repetidos). */
SELECT DISTINCT codigo_cliente FROM pago WHERE YEAR(fecha_pago) = 2008;

/* Pedidos Rechazados: Listado de pedidos rechazados en 2009. */
SELECT * FROM pedido WHERE estado = 'Rechazado' AND YEAR(fecha_pedido) = 2009;

/* Entregas de Enero: Pedidos entregados en el mes de enero de cualquier año. */
SELECT * FROM pedido WHERE MONTH(fecha_enterga) = 1;

/* Paypal 2008: Pagos realizados en 2008 vía Paypal. Ordenar de mayor a menor. */
SELECT * FROM pago WHERE forma_pago = 'PayPal' AND YEAR(fecha_pago) = 2008 ORDER BY total DESC;

/* Formas de Pago: Todas las formas de pago en la tabla pago (sin repetidos). */
SELECT DISTINCT forma_pago FROM pago;

/* Stock Ornamental: Productos 'Ornamentales' con stock > 100. Ordenar por precio (desc).*/
SELECT * FROM producto WHERE gama = 'Ornamentales' AND cantidad_en_stock > 100 ORDER BY precio_venta DESC;

/* Clientes Madrid: Clientes de Madrid cuyo representante tenga código 11 o 30.*/
SELECT * FROM cliente WHERE ciudad = 'Madrid' AND codigo_empleado_rep_ventas IN (11, 30);



/* 2. Consultas Multitabla (JOINs) */

/* Clientes y Representantes: Nombre de cliente y nombre/apellido de su representante. */
SELECT c.nombre_cliente, concat(e.nombre, " ", e.apellido1) as nombre_representante FROM cliente c 
JOIN empleado e on c.codigo_empleado_rep_ventas = e.codigo_empleado;

/* Pagos realizados: Nombre de clientes con pagos y sus representantes. */
SELECT c.nombre_cliente, p.forma_pago, p.fecha_pago, p.total, concat(e.nombre, " ", e.apellido1) as nombre_representante FROM cliente c 
INNER JOIN pago p ON c.codigo_cliente = p.codigo_cliente JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado;

/* Sin Pagos: Nombre de clientes sin pagos realizados y sus representantes. */
SELECT nombre_cliente, concat(e.nombre, " ", e.apellido1) as nombre_representante FROM cliente c
INNER JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado
WHERE codigo_cliente NOT IN (SELECT codigo_cliente FROM pago);

/* Localización: Clientes con pagos, sus representantes y la ciudad de su oficina. */
SELECT nombre_cliente, concat(e.nombre, " ", e.apellido1) as nombre_representante, o.ciudad FROM cliente c
INNER JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado INNER JOIN oficina o ON
o.codigo_oficina = e.codigo_oficina;

/* Oficinas en Fuenlabrada: Dirección de oficinas con clientes en Fuenlabrada. */
SELECT c.ciudad AS Ciudad_cliente, o.linea_direccion1 AS Dirección_oficina, o.ciudad AS Ciudad_oficina
FROM cliente c INNER JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado 
INNER JOIN oficina o ON o.codigo_oficina = e.codigo_oficina WHERE c.ciudad = "Fuenlabrada";   
    
/*Jerarquía: Empleados junto al nombre de sus jefes.*/
SELECT e.nombre AS Jefe, e1.nombre AS Empleado FROM empleado e INNER JOIN empleado e1
ON e.codigo_empleado = e1.codigo_jefe;

/*Empleado, nombre de su jefe y nombre del jefe de su jefe. */
SELECT e.nombre AS Jefe, e1.nombre AS Segundo_jefe, e2.nombre AS Empleado FROM empleado e INNER JOIN empleado e1 ON e.codigo_empleado = e1.codigo_jefe  
INNER JOIN empleado e2 ON e1.codigo_empleado = e2.codigo_jefe;

/*Retrasos: Clientes con pedidos no entregados a tiempo (fecha_entrega > fecha_esperada). */
SELECT c.nombre_cliente, p.fecha_esperada AS Fecha_esperada, p.fecha_enterga AS Fecha_entrega 
FROM cliente c NATURAL JOIN pedido p WHERE p.fecha_enterga > p.fecha_esperada;

/* Gamas por Cliente: Diferentes gamas de producto compradas por cada cliente. */
SELECT DISTINCT nombre_cliente, gama FROM producto NATURAL JOIN detalle_pedido 
NATURAL JOIN pedido NATURAL JOIN cliente;



/* 3. Consultas de Conjuntos (Subconsultas y Outer Joins) */

/* Clientes sin actividad: Que no han realizado ningún pago. */
SELECT nombre_cliente FROM cliente c WHERE codigo_cliente NOT IN (SELECT codigo_cliente FROM pago);
    
/* Que no han realizado ni pagos ni pedidos.*/
SELECT nombre_cliente FROM cliente c WHERE codigo_cliente NOT IN (SELECT codigo_cliente FROM pago)
OR codigo_cliente NOT IN (SELECT codigo_cliente FROM pedido);

/* Empleados sin actividad: Que no tienen una oficina asociada. */
SELECT e.nombre FROM empleado e WHERE e.codigo_oficina IS NULL;
        
/* Que no tienen un cliente asociado. */
SELECT e.nombre FROM empleado e WHERE codigo_empleado NOT IN (SELECT codigo_empleado_rep_ventas FROM cliente);
        
/* Sin cliente asociado + datos de su oficina. */ 
SELECT e.nombre, o.* FROM empleado e NATURAL JOIN oficina o 
WHERE codigo_empleado NOT IN (SELECT codigo_empleado_rep_ventas FROM cliente);
        
/* Productos olvidados: Productos que nunca han aparecido en un pedido.
Mostrar nombre, descripción e imagen de dichos productos. */
SELECT p.nombre, p.descripcion, gp.imagen FROM producto p INNER JOIN gama_producto gp on gp.gama = p.gama
WHERE codigo_producto NOT IN (SELECT codigo_producto FROM detalle_pedido);
        
/* Casos Avanzados:
/* Clientes con pedidos pero sin pagos realizados. */
SELECT nombre_cliente FROM cliente WHERE codigo_cliente IN (
        SELECT codigo_cliente FROM pedido) AND 
        codigo_cliente NOT IN ( SELECT codigo_cliente FROM pago);
        
/* Empleados sin clientes y el nombre de su jefe. */
SELECT e.nombre AS jefe, e1.nombre AS empleado FROM empleado e INNER JOIN empleado e1 ON e.codigo_empleado = e1.codigo_jefe
    WHERE e.codigo_empleado NOT IN (SELECT codigo_empleado_rep_ventas FROM cliente);
        
/* 4. Agregación y Estadísticas */
/*  Personal: ¿Cuántos empleados hay en la compañía? */
SELECT count(*) from empleado;

/* Países: ¿Cuántos clientes tiene cada país?*/
SELECT país, count(codigo_cliente) as clientes_pais from cliente
GROUP BY 1;

/* Finanzas: ¿Cuál fue el pago medio en 2009? */
SELECT AVG(total) AS pago_medio FROM pago WHERE YEAR(fecha_pago) = 2009;
