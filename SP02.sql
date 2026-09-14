DELIMITER $$
CREATE PROCEDURE sp_registrar_devolucion(   IN p_prestamo_id INT,   IN p_condicion_devolucion VARCHAR(20), IN p_fecha_real DATETIME )
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

      ROLLBACK;
    END;

    IF NOT EXISTS (SELECT 1 FROM prestamo WHERE prestamo_id = p_prestamo_id AND estado IN ('ACTIVO','VENCIDO')) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prestamo no valido';
  END IF;

  START TRANSACTION;

  UPDATE prestamo SET estado = 'DEVUELTO', fecha_devolucion_real = NOW() WHERE prestamo_id = p_prestamo_id;
  INSERT INTO auditoria (tabla_afectada, operacion, registro_id, valor_anterior, valor_nuevo, descripcion)
  VALUES ('prestamo', 'UPDATE', p_prestamo_id, NULL, JSON_OBJECT('estado_anterior', 'ACTIVO/VENCIDO', 'estado_nuevo', 'DEVUELTO'), 'Devolución registrada');

  IF (SELECT fecha_devolucion_programada FROM prestamo WHERE prestamo_id = p_prestamo_id) < NOW() THEN
  INSERT INTO multa (prestamo_id, usuario_id, tipo_multa, monto, saldo, estado)
  SELECT p_prestamo_id, usuario_id, 'RETRASO', 50, 50, 'PENDIENTE' FROM prestamo WHERE prestamo_id = p_prestamo_id;
  END IF;

  COMMIT;
END $$

DELIMITER;
