/* ============================================================
   PRY2204 - MODELAMIENTO DE BASES DE DATOS
   EXAMEN FINAL TRANSVERSAL - SEMANA 9
   ASOCIACION NACIONAL DE FUTBOL PROFESIONAL (ANFP)
   ============================================================ */

/* Ejecutar como PRY2204_S9. Este script recrea las tablas del ejercicio. */

/* ============================================================
   FASE 3: IMPLEMENTACION DEL MODELO FISICO
   ============================================================ */

/* ============================================================
   PASO 0: LIMPIEZA CONTROLADA DE OBJETOS
   ============================================================ */

BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN
    ('JUGADOR_IDIOMA','CONTRATO_JUGADOR','PERSONAL_PLANTA','JUGADOR',
     'TRABAJADOR','IDIOMA','PUESTO','ESCUELA_FUTBOL','CLUB_FUTBOL',
     'NACIONALIDAD','ASOCIACION','COMUNA','REGION')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_CLUB_FUTBOL';
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

/* ============================================================
   PASO 1: CREACION DE TABLAS
   ============================================================ */

/* ============================================================
   TABLA REGION
   ============================================================ */

CREATE TABLE REGION (
  id_region NUMBER(3) NOT NULL,
  nombre_region VARCHAR2(80) NOT NULL
);

/* ============================================================
   TABLA COMUNA
   ============================================================ */

CREATE TABLE COMUNA (
  id_comuna NUMBER(5) NOT NULL,
  nombre_comuna VARCHAR2(80) NOT NULL,
  id_region NUMBER(3) NOT NULL
);

/* ============================================================
   TABLA ASOCIACION
   ============================================================ */

CREATE TABLE ASOCIACION (
  id_asociacion NUMBER(5) NOT NULL,
  nombre_asociacion VARCHAR2(100) NOT NULL,
  fecha_creacion DATE NOT NULL,
  tipo_asociacion CHAR(1) NOT NULL
);

/* ============================================================
   TABLA NACIONALIDAD
   IDENTITY: inicia en 210 e incrementa en 2
   ============================================================ */

CREATE TABLE NACIONALIDAD (
  id_nacionalidad NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2),
  nombre_nacionalidad VARCHAR2(60) NOT NULL
);

/* ============================================================
   TABLA CLUB_FUTBOL
   ============================================================ */

CREATE TABLE CLUB_FUTBOL (
  id_club NUMBER(6) NOT NULL,
  nombre_club VARCHAR2(100) NOT NULL,
  patrimonio NUMBER(15,2) NOT NULL,
  direccion VARCHAR2(150) NOT NULL,
  tipo_club CHAR(1) NOT NULL
);

/* ============================================================
   TABLA ESCUELA_FUTBOL
   ============================================================ */

CREATE TABLE ESCUELA_FUTBOL (
  id_escuela NUMBER(5) NOT NULL,
  nombre_escuela VARCHAR2(100) NOT NULL,
  capacidad NUMBER(6) NOT NULL,
  fecha_fundacion DATE
);

/* ============================================================
   TABLA PUESTO
   ============================================================ */

CREATE TABLE PUESTO (
  id_puesto NUMBER(3) NOT NULL,
  nombre_puesto VARCHAR2(60) NOT NULL
);

/* ============================================================
   TABLA IDIOMA
   ============================================================ */

CREATE TABLE IDIOMA (
  id_idioma NUMBER(3) NOT NULL,
  nombre_idioma VARCHAR2(60) NOT NULL
);

/* ============================================================
   TABLA TRABAJADOR
   ============================================================ */

CREATE TABLE TRABAJADOR (
  cod_inscripcion NUMBER(8) NOT NULL,
  rut NUMBER(8) NOT NULL,
  dv CHAR(1) NOT NULL,
  nombres VARCHAR2(100) NOT NULL,
  apellidos VARCHAR2(100) NOT NULL,
  sueldo_base NUMBER(12,2) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  genero CHAR(1),
  estado_civil VARCHAR2(30),
  telefono_movil VARCHAR2(20),
  direccion VARCHAR2(150) NOT NULL,
  id_comuna NUMBER(5) NOT NULL,
  id_nacionalidad NUMBER(5) NOT NULL
);

/* ============================================================
   TABLA JUGADOR
   ============================================================ */

CREATE TABLE JUGADOR (
  cod_inscripcion NUMBER(8) NOT NULL,
  id_puesto NUMBER(3) NOT NULL,
  premios_acumulados NUMBER(12,2) DEFAULT 0 NOT NULL,
  id_escuela NUMBER(5),
  anio_fin_amateur NUMBER(4),
  id_asociacion NUMBER(5) NOT NULL
);

/* ============================================================
   TABLA PERSONAL_PLANTA
   ============================================================ */

CREATE TABLE PERSONAL_PLANTA (
  cod_inscripcion NUMBER(8) NOT NULL,
  horas_trabajadas NUMBER(6,2),
  valor_hora_extra NUMBER(10,2)
);

/* ============================================================
   TABLA JUGADOR_IDIOMA
   ============================================================ */

CREATE TABLE JUGADOR_IDIOMA (
  cod_inscripcion NUMBER(8) NOT NULL,
  id_idioma NUMBER(3) NOT NULL,
  nivel_dominio VARCHAR2(30) NOT NULL
);

/* ============================================================
   TABLA CONTRATO_JUGADOR
   ============================================================ */

CREATE TABLE CONTRATO_JUGADOR (
  id_contrato NUMBER(8) NOT NULL,
  cod_inscripcion NUMBER(8) NOT NULL,
  id_club NUMBER(6) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_termino DATE
);

/* ============================================================
   PASO 2: CLAVES Y RESTRICCIONES (ALTER TABLE)
   ============================================================ */

ALTER TABLE REGION ADD CONSTRAINT REGION_PK PRIMARY KEY (id_region);

ALTER TABLE COMUNA ADD CONSTRAINT COMUNA_PK PRIMARY KEY (id_comuna);

ALTER TABLE COMUNA ADD CONSTRAINT COMUNA_REGION_FK FOREIGN KEY (id_region) REFERENCES REGION(id_region);

ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_PK PRIMARY KEY (id_asociacion);

ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_FECHA_CK CHECK (fecha_creacion >= DATE '1980-12-31');

ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_TIPO_CK CHECK (tipo_asociacion IN ('P','A'));

ALTER TABLE NACIONALIDAD ADD CONSTRAINT NACIONALIDAD_PK PRIMARY KEY (id_nacionalidad);

ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_PK PRIMARY KEY (id_club);

ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_NOMBRE_UK UNIQUE (nombre_club);

ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_TIPO_CK CHECK (tipo_club IN ('P','A'));

ALTER TABLE ESCUELA_FUTBOL ADD CONSTRAINT ESCUELA_FUTBOL_PK PRIMARY KEY (id_escuela);

ALTER TABLE PUESTO ADD CONSTRAINT PUESTO_PK PRIMARY KEY (id_puesto);

ALTER TABLE IDIOMA ADD CONSTRAINT IDIOMA_PK PRIMARY KEY (id_idioma);

ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_PK PRIMARY KEY (cod_inscripcion);

ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_RUT_UK UNIQUE (rut);

ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_COMUNA_FK FOREIGN KEY (id_comuna) REFERENCES COMUNA(id_comuna);

ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_NACION_FK FOREIGN KEY (id_nacionalidad) REFERENCES NACIONALIDAD(id_nacionalidad);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_PK PRIMARY KEY (cod_inscripcion);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_TRABAJADOR_FK FOREIGN KEY (cod_inscripcion) REFERENCES TRABAJADOR(cod_inscripcion);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_PUESTO_FK FOREIGN KEY (id_puesto) REFERENCES PUESTO(id_puesto);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_ESCUELA_FK FOREIGN KEY (id_escuela) REFERENCES ESCUELA_FUTBOL(id_escuela);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_ASOCIACION_FK FOREIGN KEY (id_asociacion) REFERENCES ASOCIACION(id_asociacion);

ALTER TABLE PERSONAL_PLANTA ADD CONSTRAINT PERSONAL_PLANTA_PK PRIMARY KEY (cod_inscripcion);

ALTER TABLE PERSONAL_PLANTA ADD CONSTRAINT PERSONAL_TRABAJADOR_FK FOREIGN KEY (cod_inscripcion) REFERENCES TRABAJADOR(cod_inscripcion);

ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_PK PRIMARY KEY (cod_inscripcion, id_idioma);

ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_JUG_FK FOREIGN KEY (cod_inscripcion) REFERENCES JUGADOR(cod_inscripcion);

ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_IDI_FK FOREIGN KEY (id_idioma) REFERENCES IDIOMA(id_idioma);

ALTER TABLE CONTRATO_JUGADOR ADD CONSTRAINT CONTRATO_JUGADOR_PK PRIMARY KEY (id_contrato);

ALTER TABLE CONTRATO_JUGADOR ADD CONSTRAINT CONTRATO_JUGADOR_JUG_FK FOREIGN KEY (cod_inscripcion) REFERENCES JUGADOR(cod_inscripcion);

ALTER TABLE CONTRATO_JUGADOR ADD CONSTRAINT CONTRATO_JUGADOR_CLUB_FK FOREIGN KEY (id_club) REFERENCES CLUB_FUTBOL(id_club);

ALTER TABLE CONTRATO_JUGADOR ADD CONSTRAINT CONTRATO_FECHAS_CK CHECK (fecha_termino IS NULL OR fecha_termino >= fecha_inicio);

/* ============================================================
   PASO 3: SECUENCIA DE CLUBES
   ============================================================ */

CREATE SEQUENCE SEQ_CLUB_FUTBOL START WITH 703 INCREMENT BY 4 NOCYCLE NOCACHE;

/* ============================================================
   PASO 4: POBLAMIENTO DE TABLAS
   ============================================================ */

/* ============================================================
   REGION
   Incluye regiones complementarias 8 y 16 para las claves foraneas
   ============================================================ */

INSERT INTO REGION VALUES (1, 'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO REGION VALUES (2, 'ANTOFAGASTA');
INSERT INTO REGION VALUES (3, 'ATACAMA Y COQUIMBO');
INSERT INTO REGION VALUES (5, 'VALPARAISO');
INSERT INTO REGION VALUES (13, 'METROPOLITANA');

/* Regiones complementarias para mantener las FK de COMUNA.
   No figuran entre las cinco regiones de la tabla de referencia. */

INSERT INTO REGION VALUES (8, 'BIOBIO');
INSERT INTO REGION VALUES (16, 'NUBLE');


/* ============================================================
   COMUNA
   Comunas asociadas a REGION
   ============================================================ */

INSERT INTO COMUNA VALUES (101, 'Santiago', 13);
INSERT INTO COMUNA VALUES (102, 'Valparaiso', 5);
INSERT INTO COMUNA VALUES (103, 'Concepcion', 8);
INSERT INTO COMUNA VALUES (104, 'Antofagasta', 2);
INSERT INTO COMUNA VALUES (105, 'Chillan', 16);


/* ============================================================
   ASOCIACION
   10 asociaciones de la figura 2
   ============================================================ */

INSERT INTO ASOCIACION VALUES
(25, 'Asociación de Fútbol de Santiago',
 TO_DATE('15-05-2001','DD-MM-YYYY'), 'P');

INSERT INTO ASOCIACION VALUES
(26, 'Asociación Nacional de Fútbol Amateur',
 TO_DATE('10-03-1998','DD-MM-YYYY'), 'A');

INSERT INTO ASOCIACION VALUES
(27, 'Asociación de Fútbol de Valparaíso',
 TO_DATE('21-07-1987','DD-MM-YYYY'), 'P');

INSERT INTO ASOCIACION VALUES
(28, 'Asociación de Fútbol de Concepción',
 TO_DATE('30-11-1995','DD-MM-YYYY'), 'A');

INSERT INTO ASOCIACION VALUES
(29, 'Asociación de Fútbol de Antofagasta',
 TO_DATE('25-06-2003','DD-MM-YYYY'), 'P');

INSERT INTO ASOCIACION VALUES
(30, 'Asociación de Fútbol de Temuco',
 TO_DATE('12-01-2010','DD-MM-YYYY'), 'A');

INSERT INTO ASOCIACION VALUES
(31, 'Asociación de Fútbol de Rancagua',
 TO_DATE('08-09-1999','DD-MM-YYYY'), 'P');

INSERT INTO ASOCIACION VALUES
(32, 'Asociación de Fútbol de Puerto Montt',
 TO_DATE('20-04-2005','DD-MM-YYYY'), 'A');

INSERT INTO ASOCIACION VALUES
(33, 'Asociación de Fútbol de La Serena',
 TO_DATE('14-08-2012','DD-MM-YYYY'), 'P');

INSERT INTO ASOCIACION VALUES
(34, 'Asociación de Fútbol de Chillán',
 TO_DATE('01-12-2018','DD-MM-YYYY'), 'A');


/* ============================================================
   NACIONALIDAD
   IDENTITY genera: 210, 212, 214, 216, 218
   ============================================================ */

INSERT INTO NACIONALIDAD (nombre_nacionalidad)
VALUES ('Chilena');

INSERT INTO NACIONALIDAD (nombre_nacionalidad)
VALUES ('Argentina');

INSERT INTO NACIONALIDAD (nombre_nacionalidad)
VALUES ('Peruana');

INSERT INTO NACIONALIDAD (nombre_nacionalidad)
VALUES ('Boliviana');

INSERT INTO NACIONALIDAD (nombre_nacionalidad)
VALUES ('Brasilena');


/* ============================================================
   CLUB_FUTBOL
   SEQ_CLUB_FUTBOL genera: 703, 707, 711, 715, 719
   ============================================================ */

INSERT INTO CLUB_FUTBOL
(id_club, nombre_club, patrimonio, direccion, tipo_club)
VALUES
(SEQ_CLUB_FUTBOL.NEXTVAL, 'Colo-Colo', 500000000,
 'Av. Marathon 5300', 'P');

INSERT INTO CLUB_FUTBOL
(id_club, nombre_club, patrimonio, direccion, tipo_club)
VALUES
(SEQ_CLUB_FUTBOL.NEXTVAL, 'Universidad de Chile', 450000000,
 'Av. El Parron 0931', 'P');

INSERT INTO CLUB_FUTBOL
(id_club, nombre_club, patrimonio, direccion, tipo_club)
VALUES
(SEQ_CLUB_FUTBOL.NEXTVAL, 'Deportes Antofagasta', 180000000,
 'Avenida Angamos 01606', 'P');

INSERT INTO CLUB_FUTBOL
(id_club, nombre_club, patrimonio, direccion, tipo_club)
VALUES
(SEQ_CLUB_FUTBOL.NEXTVAL, 'Huachipato', 220000000,
 'Avenida Desiderio Garcia 909', 'P');

INSERT INTO CLUB_FUTBOL
(id_club, nombre_club, patrimonio, direccion, tipo_club)
VALUES
(SEQ_CLUB_FUTBOL.NEXTVAL, 'Nublense', 170000000,
 'Avenida Pedro Aguirre Cerda 1003', 'P');

COMMIT;


/* ============================================================
   VERIFICACION
   Conteo de registros por tabla
   ============================================================ */

SELECT 'REGION' TABLA, COUNT(*) TOTAL FROM REGION
UNION ALL
SELECT 'COMUNA', COUNT(*) FROM COMUNA
UNION ALL
SELECT 'ASOCIACION', COUNT(*) FROM ASOCIACION
UNION ALL
SELECT 'NACIONALIDAD', COUNT(*) FROM NACIONALIDAD
UNION ALL
SELECT 'CLUB_FUTBOL', COUNT(*) FROM CLUB_FUTBOL;

/* ============================================================
   FASE 4: RECUPERACION DE DATOS
   ============================================================ */

/* ============================================================
   INFORME 1: ASOCIACIONES PROFESIONALES
   Tipo P, creadas despues del ano 2000, orden descendente
   ============================================================ */

SELECT
    'ID:' || id_asociacion || ' * ' || nombre_asociacion AS "ASOCIACION",
    TO_CHAR(fecha_creacion, 'DD-MM-YYYY') AS "CREADA",
    tipo_asociacion AS "TIPO"
FROM ASOCIACION
WHERE tipo_asociacion = 'P'
  AND fecha_creacion >= DATE '2001-01-01'
ORDER BY fecha_creacion DESC;

/* ============================================================
   INFORME 2: PATRIMONIO DE CLUBES
   Clubes profesionales con letra a y patrimonio > 200 millones
   Conversion a dolares: patrimonio / 955
   ============================================================ */

SELECT
    id_club AS "CLUB",
    nombre_club AS "NOMBRE CLUB",
    patrimonio AS "PATRIMONIO EN PESOS",
    patrimonio / 955 AS "PATRIMONIO EN DOLARES"
FROM CLUB_FUTBOL
WHERE LOWER(nombre_club) LIKE '%a%'
  AND patrimonio > 200000000
  AND tipo_club = 'P'
ORDER BY id_club DESC;

/* ============================================================
   FIN DEL SCRIPT - SEMANA 9
   ============================================================ */
