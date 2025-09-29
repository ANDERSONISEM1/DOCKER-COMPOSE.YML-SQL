SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING ON;
GO

USE MarcadorBasket;
SET NOCOUNT ON;

-------------------------------------------------------
-- EQUIPOS (idempotente)
-------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Equipo WHERE nombre=N'Leones' AND ciudad=N'Lima')
INSERT dbo.Equipo(nombre, ciudad, abreviatura, color_primario, color_secundario)
VALUES (N'Leones',N'Lima',N'LEO',N'#D32F2F',N'#FFC107');

IF NOT EXISTS (SELECT 1 FROM dbo.Equipo WHERE nombre=N'Tigres' AND ciudad=N'Cusco')
INSERT dbo.Equipo(nombre, ciudad, abreviatura, color_primario, color_secundario)
VALUES (N'Tigres',N'Cusco',N'TIG',N'#1976D2',N'#4CAF50');

DECLARE @id_local INT = (SELECT equipo_id FROM dbo.Equipo WHERE nombre=N'Leones' AND ciudad=N'Lima');
DECLARE @id_visit INT = (SELECT equipo_id FROM dbo.Equipo WHERE nombre=N'Tigres' AND ciudad=N'Cusco');

-------------------------------------------------------
-- JUGADORES (idempotente) - LEONES
-------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=4)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,4,N'Juan',N'Pérez',N'Base');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=7)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,7,N'Carlos',N'Gómez',N'Escolta');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=9)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,9,N'Luis',N'Díaz',N'Alero');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=10)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,10,N'Mario',N'Soto',N'Ala-Pívot');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=12)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,12,N'Iván',N'Rojas',N'Pívot');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=14)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,14,N'Ernesto',N'Chávez',N'Alero');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=16)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_local,16,N'Pedro',N'García',N'Base');

-------------------------------------------------------
-- JUGADORES (idempotente) - TIGRES
-------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=5)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,5,N'Andrés',N'Lozano',N'Base');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=6)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,6,N'Felipe',N'Campos',N'Escolta');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=8)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,8,N'Roberto',N'Paz',N'Alero');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=11)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,11,N'Sergio',N'Vega',N'Ala-Pívot');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=13)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,13,N'Gustavo',N'Paredes',N'Pívot');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=15)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,15,N'Raúl',N'Navarro',N'Alero');
IF NOT EXISTS (SELECT 1 FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=17)
INSERT dbo.Jugador(equipo_id,dorsal,nombres,apellidos,posicion) VALUES (@id_visit,17,N'Javier',N'Cano',N'Base');

-------------------------------------------------------
-- PARTIDO (idempotente)  **sin 'sede'**
-------------------------------------------------------
DECLARE @partido_id INT;
SELECT TOP 1 @partido_id = partido_id
FROM dbo.Partido
WHERE equipo_local_id=@id_local AND equipo_visitante_id=@id_visit
ORDER BY partido_id DESC;

IF @partido_id IS NULL
BEGIN
  INSERT dbo.Partido(equipo_local_id,equipo_visitante_id,fecha_hora_inicio,estado,minutos_por_cuarto,cuartos_totales)
  VALUES (@id_local,@id_visit,SYSUTCDATETIME(),N'programado',10,4);
  SET @partido_id = SCOPE_IDENTITY();
END

-------------------------------------------------------
-- CUARTOS (idempotente)
-------------------------------------------------------
DECLARE @dur INT = (SELECT minutos_por_cuarto*60 FROM dbo.Partido WHERE partido_id=@partido_id);
DECLARE @c1 INT,@c2 INT,@c3 INT,@c4 INT;

IF NOT EXISTS (SELECT 1 FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=1)
  INSERT dbo.Cuarto(partido_id,numero,es_prorroga,duracion_segundos,segundos_restantes,estado)
  VALUES(@partido_id,1,0,@dur,@dur,N'pendiente');
IF NOT EXISTS (SELECT 1 FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=2)
  INSERT dbo.Cuarto(partido_id,numero,es_prorroga,duracion_segundos,segundos_restantes,estado)
  VALUES(@partido_id,2,0,@dur,@dur,N'pendiente');
IF NOT EXISTS (SELECT 1 FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=3)
  INSERT dbo.Cuarto(partido_id,numero,es_prorroga,duracion_segundos,segundos_restantes,estado)
  VALUES(@partido_id,3,0,@dur,@dur,N'pendiente');
IF NOT EXISTS (SELECT 1 FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=4)
  INSERT dbo.Cuarto(partido_id,numero,es_prorroga,duracion_segundos,segundos_restantes,estado)
  VALUES(@partido_id,4,0,@dur,@dur,N'pendiente');

SELECT @c1 = cuarto_id FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=1;
SELECT @c2 = cuarto_id FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=2;
SELECT @c3 = cuarto_id FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=3;
SELECT @c4 = cuarto_id FROM dbo.Cuarto WHERE partido_id=@partido_id AND numero=4;

-------------------------------------------------------
-- ROSTER (idempotente) - 5 titulares por equipo
-------------------------------------------------------
DECLARE @jL4 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=4);
DECLARE @jL7 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=7);
DECLARE @jL9 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=9);
DECLARE @jL10 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=10);
DECLARE @jL12 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_local AND dorsal=12);

IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jL4)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_local,@jL4,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jL7)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_local,@jL7,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jL9)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_local,@jL9,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jL10)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_local,@jL10,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jL12)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_local,@jL12,1);

DECLARE @jT5  INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=5);
DECLARE @jT6  INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=6);
DECLARE @jT8  INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=8);
DECLARE @jT11 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=11);
DECLARE @jT13 INT = (SELECT jugador_id FROM dbo.Jugador WHERE equipo_id=@id_visit AND dorsal=13);

IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jT5)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_visit,@jT5,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jT6)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_visit,@jT6,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jT8)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_visit,@jT8,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jT11)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_visit,@jT11,1);
IF NOT EXISTS (SELECT 1 FROM dbo.RosterPartido WHERE partido_id=@partido_id AND jugador_id=@jT13)
  INSERT dbo.RosterPartido(partido_id,equipo_id,jugador_id,es_titular) VALUES (@partido_id,@id_visit,@jT13,1);

-------------------------------------------------------
-- EVENTOS DE PRUEBA (idempotentes)
-------------------------------------------------------
-- Anotaciones en el 1er cuarto (sin jugador_id / sin es_correccion / sin descripcion)
IF NOT EXISTS (SELECT 1 FROM dbo.Anotacion WHERE partido_id=@partido_id AND cuarto_id=@c1 AND equipo_id=@id_local AND puntos=2)
INSERT dbo.Anotacion(partido_id,cuarto_id,equipo_id,puntos)
VALUES (@partido_id,@c1,@id_local,2);

IF NOT EXISTS (SELECT 1 FROM dbo.Anotacion WHERE partido_id=@partido_id AND cuarto_id=@c1 AND equipo_id=@id_visit AND puntos=3)
INSERT dbo.Anotacion(partido_id,cuarto_id,equipo_id,puntos)
VALUES (@partido_id,@c1,@id_visit,3);

-- Falta personal (sin libre_convertido ni comentarios)
DECLARE @tipo_personal TINYINT = (SELECT tipo_falta_id FROM dbo.TipoFalta WHERE nombre=N'personal');
IF NOT EXISTS (SELECT 1 FROM dbo.Falta WHERE partido_id=@partido_id AND cuarto_id=@c1 AND jugador_id=@jL4)
INSERT dbo.Falta(partido_id,cuarto_id,equipo_id,jugador_id,tipo_falta_id,es_de_tiro)
VALUES (@partido_id,@c1,@id_local,@jL4,@tipo_personal,0);

-- Tiempo muerto corto para Tigres
IF NOT EXISTS (SELECT 1 FROM dbo.TiempoMuerto WHERE partido_id=@partido_id AND cuarto_id=@c1 AND equipo_id=@id_visit AND tipo=N'corto')
INSERT dbo.TiempoMuerto(partido_id,cuarto_id,equipo_id,tipo)
VALUES (@partido_id,@c1,@id_visit,N'corto');

-- Cronómetro: inicio del 1er cuarto (el CHECK ya permite más tipos)
IF NOT EXISTS (SELECT 1 FROM dbo.CronometroEvento WHERE partido_id=@partido_id AND cuarto_id=@c1 AND tipo=N'inicio')
INSERT dbo.CronometroEvento(partido_id,cuarto_id,tipo,segundos_restantes)
VALUES (@partido_id,@c1,N'inicio',@dur);

-------------------------------------------------------
-- COMPROBACIONES
-------------------------------------------------------
SELECT 'equipos' AS tipo, COUNT(*) AS total FROM dbo.Equipo
UNION ALL SELECT 'jugadores', COUNT(*) FROM dbo.Jugador
UNION ALL SELECT 'partidos', COUNT(*) FROM dbo.Partido
UNION ALL SELECT 'cuartos', COUNT(*) FROM dbo.Cuarto
UNION ALL SELECT 'roster', COUNT(*) FROM dbo.RosterPartido
UNION ALL SELECT 'anotaciones', COUNT(*) FROM dbo.Anotacion
UNION ALL SELECT 'faltas', COUNT(*) FROM dbo.Falta;

SELECT * FROM dbo.vw_MarcadorPartido WHERE partido_id=@partido_id;

