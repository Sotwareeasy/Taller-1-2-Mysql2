DROP DATABASE IF EXISTS bibliored;
CREATE DATABASE bibliored;
USE bibliored;

-- Se requiere modo estricto para rechazar valores fuera de ENUM.
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE TABLE branches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    municipality VARCHAR(80) NOT NULL,
    address VARCHAR(160) NOT NULL,
    opened_on DATE NOT NULL
);

CREATE TABLE membership_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40) NOT NULL UNIQUE,
    loan_limit INT NOT NULL,
    loan_days INT NOT NULL,
    renewal_limit INT NOT NULL,
    daily_fine DECIMAL(10,2) NOT NULL,
    annual_fee DECIMAL(12,2) NOT NULL,
    CHECK (loan_limit > 0 AND loan_days > 0),
    CHECK (renewal_limit >= 0 AND daily_fine >= 0 AND annual_fee >= 0)
);

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE publishers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL
);

CREATE TABLE authors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    nationality VARCHAR(60) NOT NULL,
    birth_year SMALLINT NOT NULL
);

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    hired_on DATE NOT NULL,
    role ENUM('COORDINADOR','BIBLIOTECARIO','AUXILIAR') NOT NULL DEFAULT 'BIBLIOTECARIO',
    branch_id BIGINT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE titles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) NOT NULL UNIQUE,
    title VARCHAR(160) NOT NULL,
    publication_year SMALLINT NOT NULL,
    replacement_cost DECIMAL(12,2) NOT NULL DEFAULT 50000,
    category_id BIGINT NOT NULL,
    publisher_id BIGINT NOT NULL,
    CHECK (replacement_cost > 0),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);

CREATE TABLE title_authors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    authorship_order INT NOT NULL,
    UNIQUE (title_id, author_id),
    UNIQUE (title_id, authorship_order),
    CHECK (authorship_order > 0),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE copies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    barcode VARCHAR(30) NOT NULL UNIQUE,
    acquired_on DATE NOT NULL,
    status ENUM('DISPONIBLE','PRESTADO','EN_REPARACION','PERDIDO','DADO_DE_BAJA') NOT NULL DEFAULT 'DISPONIBLE',
    title_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE members (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(160) UNIQUE,
    phone VARCHAR(30),
    birth_date DATE NOT NULL,
    joined_on DATE NOT NULL,
    status ENUM('ACTIVO','SUSPENDIDO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    membership_type_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    FOREIGN KEY (membership_type_id) REFERENCES membership_types(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE loans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    copy_id BIGINT NOT NULL,
    member_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    returned_on DATE,
    status ENUM('ACTIVO','DEVUELTO','PERDIDO') NOT NULL DEFAULT 'ACTIVO',
    CHECK (due_date > loan_date),
    CHECK (returned_on IS NULL OR returned_on >= loan_date),
    CHECK ((status = 'DEVUELTO' AND returned_on IS NOT NULL) OR (status <> 'DEVUELTO' AND returned_on IS NULL)),
    FOREIGN KEY (copy_id) REFERENCES copies(id),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) AUTO_INCREMENT = 1001;

CREATE TABLE renewals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    renewed_on DATE NOT NULL,
    previous_due_date DATE NOT NULL,
    new_due_date DATE NOT NULL,
    CHECK (new_due_date > previous_due_date),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE reservations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    title_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    reserved_on DATE NOT NULL,
    expires_on DATE NOT NULL,
    status ENUM('PENDIENTE','ATENDIDA','CANCELADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
    CHECK (expires_on >= reserved_on),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE fines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    reason ENUM('MORA','DAÑO','PERDIDA') NOT NULL,
    late_days INT NOT NULL DEFAULT 0,
    amount DECIMAL(12,2) NOT NULL,
    issued_on DATE NOT NULL,
    status ENUM('PENDIENTE','PAGADA','ANULADA') NOT NULL DEFAULT 'PENDIENTE',
    CHECK (amount > 0 AND late_days >= 0),
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE fine_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fine_id BIGINT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    paid_on DATE NOT NULL,
    payment_method ENUM('EFECTIVO','TARJETA','TRANSFERENCIA') NOT NULL,
    CHECK (amount > 0),
    FOREIGN KEY (fine_id) REFERENCES fines(id)
);

SHOW TABLES;
DESCRIBE loans;
-- Las FK son RESTRICT por defecto: no se borran padres con dependencias.
-- R10: vencimiento calculado necesita leer la membresía, no cabe en CHECK.
-- R11: estado, deuda y tope requieren otras filas/tablas.
-- R12: préstamo y ejemplar deben cambiar juntos; exige una transacción.
-- R15: renovar requiere contar renovaciones y consultar reservas.
-- R16: vencer reservas necesita una fecha de referencia y un UPDATE.
-- R18: mora necesita la tarifa de otra tabla; el importe histórico se almacena.
-- R19: pérdida afecta préstamo, ejemplar y multa; se carga coherente en semillas.
-- R20: no sobrepagar y pasar a PAGADA requiere sumar cuotas de otras filas.
