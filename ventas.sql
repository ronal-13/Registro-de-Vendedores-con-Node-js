-- Primero, eliminamos los procedimientos almacenados existentes
DROP PROCEDURE IF EXISTS `sp_busven`;
DROP PROCEDURE IF EXISTS `sp_delven`;
DROP PROCEDURE IF EXISTS `sp_ingven`;
DROP PROCEDURE IF EXISTS `sp_modven`;
DROP PROCEDURE IF EXISTS `sp_ingdis`;
DROP PROCEDURE IF EXISTS `sp_moddis`;
DROP PROCEDURE IF EXISTS `sp_deldis`;
DROP PROCEDURE IF EXISTS `sp_seldis`;
DROP PROCEDURE IF EXISTS `sp_selven`;

-- Luego, eliminamos la tabla vendedor existente
DROP TABLE IF EXISTS `vendedor`;

-- Crear tabla distrito (tabla principal)
CREATE TABLE IF NOT EXISTS `distrito` (
  `id_dis` int(11) NOT NULL AUTO_INCREMENT,
  `nom_dis` varchar(50) NOT NULL,
  PRIMARY KEY (`id_dis`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insertar algunos distritos de ejemplo
INSERT INTO `distrito` (`nom_dis`) VALUES
('San Isidro'),
('Miraflores'),
('San Borja'),
('Surco'),
('La Molina');

-- Crear la tabla vendedor con la clave foránea ya incluida
CREATE TABLE `vendedor` (
  `id_ven` int(11) NOT NULL AUTO_INCREMENT,
  `nom_ven` varchar(25) NOT NULL,
  `apel_ven` varchar(25) NOT NULL,
  `cel_ven` char(9) NOT NULL,
  `id_dis` int(11) NOT NULL,
  PRIMARY KEY (`id_ven`),
  KEY `fk_vendedor_distrito` (`id_dis`),
  CONSTRAINT `fk_vendedor_distrito` FOREIGN KEY (`id_dis`) REFERENCES `distrito` (`id_dis`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insertar algunos datos de ejemplo en la tabla vendedor
INSERT INTO `vendedor` (`nom_ven`, `apel_ven`, `cel_ven`, `id_dis`) VALUES
('Carlo', 'Caceres', '999999999', 1),
('Remigio', 'Almeyda', '252372892', 2);

-- Ahora creamos los procedimientos almacenados

-- Procedimiento para buscar vendedor
DELIMITER $$
CREATE PROCEDURE `sp_busven` (IN `p_id_ven` INT)
BEGIN
    -- Buscar vendedor específico por ID
    SELECT v.*, d.nom_dis 
    FROM vendedor v
    JOIN distrito d ON v.id_dis = d.id_dis
    WHERE v.id_ven = p_id_ven;

    -- Validar si existe el vendedor
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Vendedor no encontrado';
    END IF;
END$$
DELIMITER ;

-- Procedimiento para eliminar vendedor
DELIMITER $$
CREATE PROCEDURE `sp_delven` (IN `p_id_ven` INT)
BEGIN
    -- Validar que el vendedor exista
    IF NOT EXISTS (SELECT 1 FROM vendedor WHERE id_ven = p_id_ven) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El vendedor no existe';
    END IF;

    -- Eliminar vendedor
    DELETE FROM vendedor 
    WHERE id_ven = p_id_ven;

    -- Confirmar eliminación
    SELECT ROW_COUNT() AS filas_eliminadas;
END$$
DELIMITER ;

-- Procedimiento para insertar vendedor
DELIMITER $$
CREATE PROCEDURE `sp_ingven` (
    IN `p_nom_ven` VARCHAR(25), 
    IN `p_apel_ven` VARCHAR(25), 
    IN `p_cel_ven` CHAR(9), 
    IN `p_id_dis` INT
)
BEGIN
    -- Validar que los campos no estén vacíos
    IF p_nom_ven IS NULL OR p_nom_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del vendedor no puede estar vacío';
    END IF;

    IF p_apel_ven IS NULL OR p_apel_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El apellido del vendedor no puede estar vacío';
    END IF;

    IF p_cel_ven IS NULL OR p_cel_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El número de celular del vendedor no puede estar vacío';
    END IF;

    -- Validar formato de celular (9 dígitos)
    IF LENGTH(p_cel_ven) != 9 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El número de celular debe tener 9 dígitos';
    END IF;
    
    -- Validar que el distrito exista
    IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El distrito especificado no existe';
    END IF;

    -- Insertar nuevo vendedor
    INSERT INTO vendedor (nom_ven, apel_ven, cel_ven, id_dis)
    VALUES (p_nom_ven, p_apel_ven, p_cel_ven, p_id_dis);

    -- Devolver el ID del vendedor insertado
    SELECT LAST_INSERT_ID() AS nuevo_id_vendedor;
END$$
DELIMITER ;

-- Procedimiento para modificar vendedor
DELIMITER $$
CREATE PROCEDURE `sp_modven` (
    IN `p_id_ven` INT, 
    IN `p_nom_ven` VARCHAR(25), 
    IN `p_apel_ven` VARCHAR(25), 
    IN `p_cel_ven` CHAR(9),
    IN `p_id_dis` INT
)
BEGIN
    -- Validar que el vendedor exista
    IF NOT EXISTS (SELECT 1 FROM vendedor WHERE id_ven = p_id_ven) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El vendedor no existe';
    END IF;

    -- Validaciones de campos
    IF p_nom_ven IS NULL OR p_nom_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del vendedor no puede estar vacío';
    END IF;

    IF p_apel_ven IS NULL OR p_apel_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El apellido del vendedor no puede estar vacío';
    END IF;

    IF p_cel_ven IS NULL OR p_cel_ven = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El número de celular del vendedor no puede estar vacío';
    END IF;

    -- Validar formato de celular (9 dígitos)
    IF LENGTH(p_cel_ven) != 9 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El número de celular debe tener 9 dígitos';
    END IF;
    
    -- Validar que el distrito exista
    IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El distrito especificado no existe';
    END IF;

    -- Actualizar vendedor
    UPDATE vendedor 
    SET 
        nom_ven = p_nom_ven,
        apel_ven = p_apel_ven,
        cel_ven = p_cel_ven,
        id_dis = p_id_dis
    WHERE id_ven = p_id_ven;

    -- Confirmar actualización
    SELECT ROW_COUNT() AS filas_actualizadas;
END$$
DELIMITER ;

-- Procedimiento para seleccionar vendedores
DELIMITER $$
CREATE PROCEDURE `sp_selven` (
    IN `p_filtro` VARCHAR(50), 
    IN `p_tipo_filtro` VARCHAR(20)
)
BEGIN
    -- Selección según el tipo de filtro
    IF p_tipo_filtro = 'id' THEN
        SELECT v.*, d.nom_dis 
        FROM vendedor v
        JOIN distrito d ON v.id_dis = d.id_dis
        WHERE v.id_ven = CAST(p_filtro AS UNSIGNED);
    
    ELSEIF p_tipo_filtro = 'nombre' THEN
        SELECT v.*, d.nom_dis 
        FROM vendedor v
        JOIN distrito d ON v.id_dis = d.id_dis
        WHERE v.nom_ven LIKE CONCAT('%', p_filtro, '%');
    
    ELSEIF p_tipo_filtro = 'apellido' THEN
        SELECT v.*, d.nom_dis 
        FROM vendedor v
        JOIN distrito d ON v.id_dis = d.id_dis
        WHERE v.apel_ven LIKE CONCAT('%', p_filtro, '%');
    
    ELSEIF p_tipo_filtro = 'distrito' THEN
        SELECT v.*, d.nom_dis 
        FROM vendedor v
        JOIN distrito d ON v.id_dis = d.id_dis
        WHERE d.nom_dis LIKE CONCAT('%', p_filtro, '%');
    
    ELSEIF p_tipo_filtro = 'todos' THEN
        SELECT v.*, d.nom_dis 
        FROM vendedor v
        JOIN distrito d ON v.id_dis = d.id_dis;
    
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Tipo de filtro no válido';
    END IF;
END$$
DELIMITER ;

-- Luego, crear el procedimiento nuevamente
DELIMITER $$
CREATE PROCEDURE `sp_ingdis` (
    IN `p_nom_dis` VARCHAR(50)
)
BEGIN
    -- Validar que el nombre no esté vacío
    IF p_nom_dis IS NULL OR p_nom_dis = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del distrito no puede estar vacío';
    END IF;

    -- Insertar nuevo distrito
    INSERT INTO distrito (nom_dis)
    VALUES (p_nom_dis);

    -- Devolver el ID del distrito insertado
    SELECT LAST_INSERT_ID() AS nuevo_id_distrito;
END$$
DELIMITER ;

-- Procedimiento para modificar distrito
DELIMITER $$
CREATE PROCEDURE `sp_moddis` (
    IN `p_id_dis` INT,
    IN `p_nom_dis` VARCHAR(50)
)
BEGIN
    -- Validar que el distrito exista
    IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El distrito no existe';
    END IF;

    -- Validar que el nombre no esté vacío
    IF p_nom_dis IS NULL OR p_nom_dis = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del distrito no puede estar vacío';
    END IF;

    -- Actualizar distrito
    UPDATE distrito 
    SET nom_dis = p_nom_dis
    WHERE id_dis = p_id_dis;

    -- Confirmar actualización
    SELECT ROW_COUNT() AS filas_actualizadas;
END$$
DELIMITER ;

-- Procedimiento para eliminar distrito
DELIMITER $$
CREATE PROCEDURE `sp_deldis` (
    IN `p_id_dis` INT
)
BEGIN
    -- Validar que el distrito exista
    IF NOT EXISTS (SELECT 1 FROM distrito WHERE id_dis = p_id_dis) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El distrito no existe';
    END IF;
    
    -- Verificar si hay vendedores asociados a este distrito
    IF EXISTS (SELECT 1 FROM vendedor WHERE id_dis = p_id_dis) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede eliminar el distrito porque hay vendedores asociados a él';
    END IF;

    -- Eliminar distrito
    DELETE FROM distrito 
    WHERE id_dis = p_id_dis;

    -- Confirmar eliminación
    SELECT ROW_COUNT() AS filas_eliminadas;
END$$
DELIMITER ;

-- Procedimiento para buscar distritos
DELIMITER $$
CREATE PROCEDURE `sp_seldis` (
    IN `p_filtro` VARCHAR(50), 
    IN `p_tipo_filtro` VARCHAR(20)
)
BEGIN
    -- Selección según el tipo de filtro
    IF p_tipo_filtro = 'id' THEN
        SELECT * FROM distrito 
        WHERE id_dis = CAST(p_filtro AS UNSIGNED);
    
    ELSEIF p_tipo_filtro = 'nombre' THEN
        SELECT * FROM distrito 
        WHERE nom_dis LIKE CONCAT('%', p_filtro, '%');
    
    ELSEIF p_tipo_filtro = 'todos' THEN
        SELECT * FROM distrito;
    
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Tipo de filtro no válido';
    END IF;
END$$
DELIMITER ;