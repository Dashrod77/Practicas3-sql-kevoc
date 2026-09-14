DELIMITER $$

CREATE PROCEDURE sp_registrar_prestamo(
    IN p_usuario_id INT,
    IN p_equipo_id INT,
    IN p_fecha_prestamo DATETIME,
    IN p_fecha_devolucion_programada DATETIME,
    OUT p_prestamo_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;
    END;
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE usuario_id = p_usuario_id AND activo = 1) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM equipo WHERE equipo_id = p_equipo_id AND activo = 1 AND estado = 'DISPONIBLE') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El equipo no existe';
    END IF;

    IF p_fecha_prestamo > p_fecha_devolucion_programada THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Fecha invalida';
    END IF;


    START TRANSACTION;

    INSERT INTO prestamo (usuario_id, fecha_prestamo, fecha_devolucion_programada, estado)
    VALUES (p_usuario_id, p_fecha_prestamo, p_fecha_devolucion_programada, 'ACTIVO');
    SET p_prestamo_id = LAST_INSERT_ID();
    INSERT INTO detalle_prestamo (prestamo_id, equipo_id) VALUES (p_prestamo_id ,p_equipo_id);
    UPDATE equipo SET estado = 'PRESTADO' WHERE equipo_id = p_equipo_id;
    INSERT INTO auditoria (tabla_afectada, operacion, registro_id, valor_anterior, valor_nuevo, descripcion)
    VALUES ('prestamo', 'INSERT', p_prestamo_id, NULL, JSON_OBJECT('usuario_id', p_usuario_id, 'equipo_id', p_equipo_id), 'Prestamo registrado');

    COMMIT;

END$$

DELIMITER ;
