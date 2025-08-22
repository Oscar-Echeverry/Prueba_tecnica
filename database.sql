DROP DATABASE IF EXISTS prueba;
CREATE DATABASE prueba CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prueba;

-- Seguridad: usuarios, roles, permisos
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE permisos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_usuario_estado CHECK (estado IN ('ACTIVO','INACTIVO'))
) ENGINE=InnoDB;

CREATE TABLE usuario_rol (
    usuario_id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,
    PRIMARY KEY (usuario_id, rol_id),
    CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rol_permiso (
    rol_id BIGINT NOT NULL,
    permiso_id BIGINT NOT NULL,
    PRIMARY KEY (rol_id, permiso_id),
    CONSTRAINT fk_rol_permiso_rol FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_rol_permiso_permiso FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Índices útiles
CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuario_rol_usuario ON usuario_rol(usuario_id);
CREATE INDEX idx_usuario_rol_rol ON usuario_rol(rol_id);
CREATE INDEX idx_rol_permiso_rol ON rol_permiso(rol_id);
CREATE INDEX idx_rol_permiso_permiso ON rol_permiso(permiso_id);

--  Dominio: categorías y documentos
CREATE TABLE categorias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE documentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archivo VARCHAR(255) NULL,  
    estado VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE',
    categoria_id BIGINT NULL,
    usuario_id BIGINT NOT NULL,                   -- dueño/autor
    CONSTRAINT fk_documentos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    CONSTRAINT fk_documentos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    CONSTRAINT chk_documento_estado CHECK (estado IN ('PENDIENTE','APROBADO','RECHAZADO'))
) ENGINE=InnoDB;

-- Índices
CREATE INDEX idx_documentos_usuario ON documentos(usuario_id);
CREATE INDEX idx_documentos_categoria ON documentos(categoria_id);
CREATE INDEX idx_documentos_fecha ON documentos(fecha_carga);
CREATE INDEX idx_documentos_estado ON documentos(estado);


-- Datos base (roles, permisos, usuarios, categorías)

-- Roles
INSERT INTO roles (nombre, descripcion) VALUES
('ADMIN', 'Administrador con acceso total'),
('EDITOR', 'Puede crear/editar documentos'),
('LECTOR', 'Puede ver documentos');

-- Permisos
INSERT INTO permisos (nombre, descripcion) VALUES
('DOCUMENTO_READ',   'Ver documentos'),
('DOCUMENTO_CREATE', 'Crear documentos'),
('DOCUMENTO_EDIT',   'Editar documentos'),
('DOCUMENTO_DELETE', 'Eliminar documentos'),
('CATEGORIA_READ',   'Ver categorías'),
('CATEGORIA_CREATE', 'Crear categorías'),
('CATEGORIA_EDIT',   'Editar categorías'),
('CATEGORIA_DELETE', 'Eliminar categorías');

-- Asignación de permisos a roles
-- ADMIN: todos
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permisos p WHERE r.nombre = 'ADMIN';

-- EDITOR: CRUD documentos + ver categorías
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r
JOIN permisos p ON p.nombre IN ('DOCUMENTO_READ','DOCUMENTO_CREATE','DOCUMENTO_EDIT','DOCUMENTO_DELETE','CATEGORIA_READ')
WHERE r.nombre = 'EDITOR';

-- LECTOR: solo lectura
INSERT INTO rol_permiso (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r
JOIN permisos p ON p.nombre IN ('DOCUMENTO_READ','CATEGORIA_READ')
WHERE r.nombre = 'LECTOR';

-- Usuarios  (contraseña en texto plano)
INSERT INTO usuarios (username, password, estado) VALUES
('admin',  'admin123',  'ACTIVO'),
('editor', 'editor123', 'ACTIVO'),
('lector', 'lector123', 'ACTIVO');

-- Asignación de roles a usuarios
INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuarios u JOIN roles r ON r.nombre='ADMIN'  WHERE u.username='admin';
INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuarios u JOIN roles r ON r.nombre='EDITOR' WHERE u.username='editor';
INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuarios u JOIN roles r ON r.nombre='LECTOR' WHERE u.username='lector';

-- Categorías iniciales
INSERT INTO categorias (nombre, descripcion) VALUES
('Contratos', 'Documentos contractuales'),
('Facturas', 'Facturación y comprobantes'),
('Informes', 'Informes técnicos y de gestión');

-- Documentos de ejemplo
INSERT INTO documentos (titulo, descripcion, estado, categoria_id, usuario_id)
SELECT 'Contrato marco', 'Contrato principal con proveedor', 'PENDIENTE', c.id, (SELECT id FROM usuarios WHERE username='editor')
FROM categorias c WHERE c.nombre='Contratos';

INSERT INTO documentos (titulo, descripcion, estado, categoria_id, usuario_id)
SELECT 'Factura 0001', 'Factura de agosto', 'APROBADO', c.id, (SELECT id FROM usuarios WHERE username='editor')
FROM categorias c WHERE c.nombre='Facturas';

--  Vista resumen
CREATE OR REPLACE VIEW vw_documentos_resumen AS
SELECT d.id,
       d.titulo,
       d.estado,
       d.fecha_carga,
       c.nombre AS categoria,
       u.username AS autor
FROM documentos d
LEFT JOIN categorias c ON c.id = d.categoria_id
JOIN usuarios u ON u.id = d.usuario_id;

