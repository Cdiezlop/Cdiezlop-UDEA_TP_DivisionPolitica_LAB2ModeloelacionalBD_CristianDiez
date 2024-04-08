-- Paso 1: Ejecutar el script DDL - Division Politica.sql
-- Paso 2: Ejecutar el script DML - Division Politica.sql

-- Paso 3: Script de Datos y Desnormalizacion

-- Verificar si la tabla de control ya existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'desnormalizacion_imagenes_control') THEN
        -- Crear la tabla de control para la desnormalizacion e imagenes
        CREATE TABLE desnormalizacion_imagenes_control (
            ejecutado BOOLEAN NOT NULL  -- Columna que indica si el script se ha ejecutado o no
        );
        
        -- Insertar un registro inicial que indica que el script no ha sido ejecutado todavia
        INSERT INTO desnormalizacion_imagenes_control (ejecutado) VALUES (FALSE);
    END IF;
END $$;

-- Verificar si el script ya se ha ejecutado antes
DO $$
BEGIN
    IF (SELECT ejecutado FROM desnormalizacion_imagenes_control LIMIT 1) = FALSE THEN
        -- Crear tabla Moneda si no existe
        IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'moneda') THEN
            -- Definir la tabla Moneda para almacenar informacion de las monedas
            CREATE TABLE moneda (
                id SERIAL PRIMARY KEY,         -- Identificador unico de la moneda
                nombre VARCHAR(255) UNIQUE,   -- Nombre de la moneda (unico)
                sigla VARCHAR(10),         -- Sigla de la moneda
                imagen VARCHAR(255)        -- Ruta de la imagen de la moneda
            );
        ELSE
            RAISE NOTICE 'La tabla Moneda ya existe.';  -- Indicar que la tabla Moneda ya existe
        END IF;

        -- Agregar la columna IdMoneda a la tabla Pais si no existe
        IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'pais' AND column_name = 'id_moneda') THEN
            -- Agregar la columna IdMoneda a la tabla Pais para establecer la relacion con Moneda
            ALTER TABLE pais
            ADD id_moneda INT;
        ELSE
            RAISE NOTICE 'La columna IdMoneda ya existe en la tabla Pais.';  -- Indicar que la columna IdMoneda ya existe en la tabla Pais
        END IF;

        -- Establecer la relacion entre Pais y Moneda
        IF NOT EXISTS (SELECT * FROM information_schema.table_constraints WHERE constraint_name = 'fk_pais_moneda') THEN
            -- Definir la relacion entre la tabla Pais y Moneda mediante la columna IdMoneda
            ALTER TABLE pais
            ADD CONSTRAINT fk_pais_moneda FOREIGN KEY (id_moneda) REFERENCES moneda(id);
        ELSE
            RAISE NOTICE 'La relacion entre Pais y Moneda ya existe.';  -- Indicar que la relacion entre Pais y Moneda ya existe
        END IF;

        -- Agregar las columnas MapaImagen y BanderaImagen a la tabla Pais si no existen
        IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'pais' AND column_name = 'mapa_imagen') THEN
            -- Agregar columna MapaImagen para la ruta de la imagen del mapa del pais
            ALTER TABLE pais
            ADD mapa_imagen VARCHAR(255);
        ELSE
            RAISE NOTICE 'La columna MapaImagen ya existe en la tabla Pais.';  -- Indicar que la columna MapaImagen ya existe en la tabla Pais
        END IF;

        IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'pais' AND column_name = 'bandera_imagen') THEN
            -- Agregar columna BanderaImagen para la ruta de la imagen de la bandera del pais
            ALTER TABLE pais
            ADD bandera_imagen VARCHAR(255);
        ELSE
            RAISE NOTICE 'La columna BanderaImagen ya existe en la tabla Pais.';  -- Indicar que la columna BanderaImagen ya existe en la tabla Pais
        END IF;

        -- Actualizar el estado en la tabla de control para indicar que el script ha sido ejecutado
        UPDATE desnormalizacion_imagenes_control SET ejecutado = TRUE;
    ELSE
        RAISE NOTICE 'El script de desnormalizacion e imagenes ya ha sido ejecutado anteriormente.';  -- Indicar que el script ya se ha ejecutado anteriormente
    END IF;
END $$;

