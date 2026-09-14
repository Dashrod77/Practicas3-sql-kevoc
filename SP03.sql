DELIMITER $$
CREATE PROCEDURE sp_registrar_pago(   IN p_multa_id INT,   IN p_monto DECIMAL(10,2),   IN p_metodo VARCHAR(20), IN p_usuario_id INT )
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

    ROLLBACK;
  END;

  IF NOT EXISTS (SELECT 1 FROM multa WHERE multa_id = p_multa_id) THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'La multa no existe';
  END IF;

  IF p_monto <= 0 THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'El monto es insuficiente';
  END IF;

  IF p_monto > (SELECT saldo FROM multa WHERE multa_id = p_multa_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monto excede saldo';
  END IF;

  START TRANSACTION;
  INSERT INTO pago (multa_id, usuario_id, monto, metodo_pago)
  VALUES (p_multa_id, p_usuario_id, p_monto, p_metodo);
  INSERT INTO auditoria (tabla_afectada, operacion, registro_id, valor_anterior, valor_nuevo, descripcion)
  VALUES ('pago', 'INSERT', LAST_INSERT_ID(), NULL, JSON_OBJECT('monto', p_monto, 'multa_id', p_multa_id), 'Pago registrado');

COMMIT ;
END $$
DELIMITER;

