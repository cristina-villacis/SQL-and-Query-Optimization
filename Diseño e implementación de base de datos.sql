CREATE DATABASE transporte_urbano;

use transporte_urbano;

SELECT * FROM rutas;
SELECT * FROM horarios;
SELECT * FROM viajes;
SELECT * FROM costos_operacion;
SELECT * FROM vehiculos;

CREATE TABLE Vehiculos (
	id_vehiculo INTEGER AUTO_INCREMENT ,
    tipo_vehiculo VARCHAR(50),
    capacidad INT NOT NULL,
    PRIMARY KEY(id_vehiculo)
);

INSERT INTO Vehiculos (tipo_vehiculo, capacidad) VALUES ('Autobús', 40);
INSERT INTO Vehiculos (tipo_vehiculo, capacidad) VALUES ('Articulado', 80);
INSERT INTO Vehiculos (tipo_vehiculo, capacidad) VALUES ('Minibús', 25);

-- Rutas
ALTER TABLE Rutas
ADD PRIMARY KEY (id_ruta);

ALTER TABLE Rutas
MODIFY COLUMN nombre VARCHAR(50) NOT NULL,
MODIFY COLUMN origen VARCHAR(50) NOT NULL,
MODIFY COLUMN destino VARCHAR(50) NOT NULL,
MODIFY COLUMN tipo_vehiculo VARCHAR(50) NOT NULL,
MODIFY COLUMN distancia_km DECIMAL(5, 2) NOT NULL,
MODIFY COLUMN tiempo_estimado_min INT NOT NULL;

ALTER TABLE Rutas
ADD FOREIGN KEY (tipo_vehiculo) REFERENCES Vehiculos(tipo_vehiculo);

-- Horarios
ALTER TABLE Horarios
ADD PRIMARY KEY (id_horario);

ALTER TABLE Horarios
MODIFY COLUMN frecuencia_min INT NOT NULL,
MODIFY COLUMN tipo_dia VARCHAR(20) NOT NULL;

ALTER TABLE Horarios
ADD FOREIGN KEY (id_ruta) REFERENCES Rutas(id_ruta);

-- Viajes
ALTER TABLE Viajes
ADD PRIMARY KEY (id_viaje);

ALTER TABLE Viajes
MODIFY COLUMN fecha DATE NOT NULL,
MODIFY COLUMN pasajeros_transportados INT NOT NULL,
MODIFY COLUMN tiempo_real_min INT NOT NULL,
MODIFY COLUMN retrasos_min INT NOT NULL;

ALTER TABLE Viajes
ADD FOREIGN KEY (id_horario) REFERENCES Horarios(id_horario);

-- Costos_operacion
ALTER TABLE costos_Operacion
ADD PRIMARY KEY (id_costo);

ALTER TABLE costos_Operacion
MODIFY COLUMN fecha DATE NOT NULL,
MODIFY COLUMN combustible DECIMAL(6, 2) NOT NULL,
MODIFY COLUMN mantenimiento INT NOT NULL,
MODIFY COLUMN conductor INT NOT NULL,
MODIFY COLUMN costo_total DECIMAL(7, 2) NOT NULL;

ALTER TABLE costos_Operacion
ADD FOREIGN KEY (id_ruta) REFERENCES Rutas(id_ruta);

-- Planificación urbana
-- Horas pico
SELECT T2.nombre,
CONCAT(TRUNCATE(AVG(T1.pasajeros_transportados / T3.capacidad) * 100, 0), '%') 
AS porcentaje_ocupacion
FROM Viajes AS T1
JOIN Horarios AS T4 ON T1.id_horario = T4.id_horario
JOIN Rutas AS T2 ON T4.id_ruta = T2.id_ruta
JOIN Vehiculos AS T3 ON T2.tipo_vehiculo = T3.tipo_vehiculo
WHERE TIME(T4.hora_salida) >= '06:00:00' AND TIME(T4.hora_salida) < '09:00:00'
 OR TIME(T4.hora_salida) >= '17:00:00' AND TIME(T4.hora_salida) < '19:00:00'
GROUP BY T2.nombre
ORDER BY porcentaje_ocupacion DESC;

-- Gestión temporal
-- Horarios con menor uso de transporte
SELECT h.hora_salida,
       h.tipo_dia,
       ROUND(AVG(v.pasajeros_transportados),2) AS promedio_pasajeros
FROM Viajes v
JOIN Horarios h ON v.id_horario = h.id_horario
GROUP BY h.hora_salida, h.tipo_dia
ORDER BY promedio_pasajeros ASC;




-- Métricas
-- Costo Por Pasajero
SELECT T2.nombre,
TRUNCATE(SUM(T1.costo_total) / SUM(T4.pasajeros_transportados), 2) AS costo_por_pasajero
FROM costos_operacion AS T1
INNER JOIN rutas AS T2 ON T1.id_ruta = T2.id_ruta
INNER JOIN horarios AS T3 ON T2.id_ruta = T3.id_ruta
INNER JOIN viajes AS T4 ON T3.id_horario = T4.id_horario AND T1.fecha = T4.fecha
GROUP BY T2.nombre
ORDER BY costo_por_pasajero DESC;

-- FUNCION VENTANA
-- Evolución de pasajeros acumulados por ruta
-- Esta consulta muestra cómo se acumulan los pasajeros transportados
-- en cada ruta a lo largo del tiempo (fecha).
-- Permite analizar la tendencia de crecimiento y detectar picos de demanda.

SELECT r.nombre AS ruta,
       v.fecha,
       v.pasajeros_transportados,
       SUM(v.pasajeros_transportados) 
           OVER (PARTITION BY r.nombre ORDER BY v.fecha) AS acumulado_pasajeros
FROM Viajes v
JOIN Horarios h ON v.id_horario = h.id_horario
JOIN Rutas r ON h.id_ruta = r.id_ruta
ORDER BY r.nombre, v.fecha;


-- SUBCONSULTA
-- Análisis de puntualidad
-- Esta consulta identifica las rutas que tienen un retraso promedio
-- mayor al retraso promedio global de todo el sistema.

SELECT r.nombre,
       ROUND(AVG(v.retrasos_min),2) AS retraso_promedio
FROM Viajes v
JOIN Horarios h ON v.id_horario = h.id_horario
JOIN Rutas r ON h.id_ruta = r.id_ruta
GROUP BY r.nombre
HAVING retraso_promedio > (
    SELECT ROUND(AVG(retrasos_min),2)
    FROM Viajes
);



-- Optimicación de consultas 
-- Índice para acelerar búsquedas y joins por fecha en viajes

CREATE INDEX idx_fecha_viajes ON viajes(fecha);

-- Índice compuesto en costos_operacion para consultas por ruta y fecha
CREATE INDEX idx_ruta_fecha_costos ON costos_operacion(id_ruta, fecha);

EXPLAIN
SELECT  r.nombre AS ruta,
        TRUNCATE(SUM(c.costo_total) / NULLIF(SUM(v.pasajeros_transportados),0), 2) AS costo_por_pasajero
FROM costos_operacion c
JOIN Rutas r    ON c.id_ruta = r.id_ruta
JOIN Horarios h ON r.id_ruta = h.id_ruta
JOIN Viajes v   ON h.id_horario = v.id_horario AND c.fecha = v.fecha
GROUP BY r.nombre
ORDER BY costo_por_pasajero DESC;

