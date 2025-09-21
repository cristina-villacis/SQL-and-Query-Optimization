create database transporte_urbano;
use transporte_urbano;

CREATE TABLE rutas (
	id_ruta INTEGER NOT NULL,
	id_vehiculo INTEGER,
	nombre VARCHAR(50),
	origen VARCHAR(50),
	destino VARCHAR(50),
	distancia_km DECIMAL(10,2),
	tiempo_estimado_min INTEGER,
	PRIMARY KEY(id_ruta)
);


CREATE TABLE horarios (
	id_horario INTEGER NOT NULL,
	id_ruta INTEGER,
	hora_salida VARCHAR(50),
	frecuencia_min INTEGER,
	tipo_dia VARCHAR(50),
	PRIMARY KEY(id_horario)
);


CREATE TABLE viajes (
	id_viaje INTEGER NOT NULL ,
	id_horario INTEGER,
	fecha VARCHAR(50),
	pasajeros_transportados INTEGER,
	tiempo_real_min INTEGER,
	retrasos_min INTEGER,
	PRIMARY KEY(id_viaje)
);


CREATE TABLE costos_operacion (
	id_costos INTEGER NOT NULL ,
	id_ruta INTEGER,
	fecha VARCHAR(50),
	combustible DECIMAL(10,2),
	mantenimiento DECIMAL(10,2),
	conductor DECIMAL(10,2),
	costo_total DECIMAL(10,2),
	PRIMARY KEY(id_costos)
);


CREATE TABLE `vehiculo` (
	`id_vehiculo` INTEGER NOT NULL AUTO_INCREMENT,
	`tipo_vehiculo` VARCHAR(50),
	`capacidad_vehiculo` INTEGER,
	PRIMARY KEY(`id_vehiculo`)
);


ALTER TABLE `viajes`
ADD FOREIGN KEY(`id_horario`) REFERENCES `horarios`(`id_horario`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `costos_operacion`
ADD FOREIGN KEY(`id_ruta`) REFERENCES `rutas`(`id_ruta`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `horarios`
ADD FOREIGN KEY(`id_ruta`) REFERENCES `rutas`(`id_ruta`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `rutas`
ADD FOREIGN KEY(`id_vehiculo`) REFERENCES `vehiculo`(`id_vehiculo`)
ON UPDATE NO ACTION ON DELETE NO ACTION;