Reporte de practica 4 - START PROCEDURE

Oziel Elias Rodriguez Gonzalez
Practica 4 - START PROCEDURE
Base de Datos II
13/09/2026


---


Marco teorico:
Un start procedure es una funcion de sql que nos permite crear como un mini backup para una operacion  es decir un checkpoint con el obejtivo de cumplir la primera regla ACID que es ATOMICIDAD esto gracias a ROLLBACK Y COMMIT que funcionan distinto siendo ROLLback para que en caso de fallar no se aplique ningun cambio y commit para cuando queda completo se aplique todo con estos cumplimos la regla de atomicidad ACID


---


Disenio:



---


Conclusion:
En esta ultima practica aprendi a poder hacer el start procedure en este caso tanto la hora como las demas practicas me dejaron frito por lo que tarde mucho mas y quiza cometi mas errores hasta en documentacion para el github donde no cree la branch de desarrollo pero bueno la practica fue algo dificl ya que en auditoria aunque era casi lo mismo siempre tardaba en encontrar los valores necesarios o justo y tambien vi que si leo detenidamente las indicaciones ayudan demasiado.


---


Evidencias:
![SP01]()
![SP02]()
![SP03]()


---


Comparativa:
bueno en este caso no hay mucha diferencia quiza la diferencia mas grande seria su forma de declarar ya que no necesitas poner declare en postgres pero de ahi en mas la mayoria es igual como el rollback y commit tambien el start transicion es diferente en postgres se usa BEGIN y por ultimo tambien se diferencia por el SIGNAL ya que postgres usa RAISE EXCEPTION.


---


Comandos:
-- SP01
SET @pid=0;
CALL sp_registrar_prestamo(1, 31, NOW(), NOW()+INTERVAL 3 DAY, @pid);
SELECT @pid AS prestamo_id;
SELECT estado FROM equipo WHERE equipo_id=31; -- PRESTADO
SELECT * FROM auditoria WHERE tabla_afectada='prestamo' ORDER BY auditoria_id DESC LIMIT 1;

-- SP02
CALL sp_registrar_devolucion(@pid, 'BUENA', NOW());
SELECT estado FROM prestamo WHERE prestamo_id=@pid; -- DEVUELTO
SELECT estado FROM equipo WHERE equipo_id=31; -- DISPONIBLE

-- SP03
CALL sp_registrar_pago(2, 40, 'EFECTIVO', 2);
SELECT monto, saldo, estado FROM multa WHERE multa_id=2; -- saldo reducido
SELECT * FROM auditoria WHERE tabla_afectada='pago' ORDER BY auditoria_id DESC LIMIT 1;
