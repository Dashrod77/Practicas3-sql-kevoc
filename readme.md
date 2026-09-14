SP01 — sp_registrar_prestamo

Firma sugerida:
sp_registrar_prestamo(   IN p_usuario_id INT,   IN p_equipo_id INT,   IN p_fecha_prestamo DATETIME,   IN p_fecha_devolucion_programada DATETIME,   OUT p_prestamo_id INT )

Qué debe hacer:

    Validar usuario (existente y activo) y equipo (existente, activo, DISPONIBLE); abortar con SIGNAL si no.
    Validar fechas (p_fecha_prestamo ≤ p_fecha_devolucion_programada).
    Registrar prestamo y detalle_prestamo, marcar equipo PRESTADO y auditar.
    Atómico: éxito → COMMIT, error → ROLLBACK.
    p_prestamo_id (OUT) = id creado.

Pista: 1.1.1 — DECLARE EXIT HANDLER ... ROLLBACK y START TRANSACTION/COMMIT.

Probar:
SET @o=0; CALL sp_registrar_prestamo(1,31,NOW(),NOW()+INTERVAL 3 DAY,@o); SELECT estado FROM equipo WHERE equipo_id=31; -- PRESTADO CALL sp_registrar_prestamo(1,31,NOW(),NOW()+INTERVAL 3 DAY,@o); -- error, no deja basura
SP02 — sp_registrar_devolucion

Firma:
sp_registrar_devolucion(   IN p_prestamo_id INT,   IN p_condicion_devolucion VARCHAR(20), -- EXCELENTE/BUENA/REGULAR/DANADA   IN p_fecha_real DATETIME -- NULL => NOW() )

Qué debe hacer:

    Bloquear préstamo y validar que permita devolución (ACTIVO/VENCIDO, no DEVUELTO).
    Registrar devolución en detalle_prestamo y prestamo.
    Liberar equipos; documenta si DANADA → DISPONIBLE o MANTENIMIENTO.
    Si hay retraso (real > programada), generar multa. Atómico + auditoría.

Probar:
CALL sp_registrar_devolucion(13,'BUENA',NOW()); -- 13: equipo 36 SELECT estado FROM prestamo WHERE prestamo_id=13; -- DEVUELTO SELECT estado FROM equipo WHERE equipo_id=36; -- DISPONIBLE UPDATE prestamo SET fecha_devolucion_programada=NOW()-INTERVAL 3 DAY WHERE prestamo_id=15; CALL sp_registrar_devolucion(15,'REGULAR',NOW()); SELECT * FROM multa WHERE prestamo_id=15 ORDER BY multa_id DESC LIMIT 1; -- multa RETRASO
SP03 — sp_registrar_pago

Firma:
sp_registrar_pago(   IN p_multa_id INT,   IN p_monto DECIMAL(10,2),   IN p_metodo VARCHAR(20), -- EFECTIVO/TRANSFERENCIA/TARJETA/OTRO   IN p_usuario_id INT )

Qué debe hacer:

    Validar multa existente, monto >0 y ≤ saldo, método permitido.
    Registrar pago, descontar saldo y pasar a PAGADA (0) o PARCIAL. Atómico + auditoría.

Si ya resolviste TR03, decide dónde queda la lógica (SP o trigger) y documenta que no duplique la resta.

Probar:
CALL sp_registrar_pago(2,30,'EFECTIVO',2); -- 100→70 PARCIAL CALL sp_registrar_pago(2,70,'TARJETA',2); -- →0 PAGADA CALL sp_registrar_pago(2,10,'EFECTIVO',2); -- error, ROLLBACK 
