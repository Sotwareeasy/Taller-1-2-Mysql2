DROP DATABASE IF EXISTS flotaya;
CREATE DATABASE flotaya;
USE flotaya;

-- Se requiere modo estricto para rechazar valores fuera de ENUM.
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE cities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    department_id BIGINT NOT NULL,
    UNIQUE (department_id, name),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE branches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    address VARCHAR(180) NOT NULL,
    phone VARCHAR(30),
    is_airport BOOLEAN NOT NULL DEFAULT FALSE,
    city_id BIGINT NOT NULL,
    CHECK (is_airport IN (0,1)),
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    role ENUM('ADMINISTRADOR','ASESOR','INSPECTOR','MECANICO') NOT NULL,
    hired_on DATE NOT NULL,
    branch_id BIGINT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE,
    minimum_age INT NOT NULL,
    deposit_amount DECIMAL(12,2) NOT NULL,
    CHECK (minimum_age >= 18 AND deposit_amount >= 0)
);

CREATE TABLE seasons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    season_type ENUM('BAJA','MEDIA','ALTA') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date >= start_date)
);

CREATE TABLE rates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    season_type ENUM('BAJA','MEDIA','ALTA') NOT NULL,
    daily_rate DECIMAL(12,2) NOT NULL,
    UNIQUE (category_id, season_type),
    CHECK (daily_rate > 0),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE brands (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE models (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    transmission ENUM('MECANICA','AUTOMATICA') NOT NULL,
    fuel_type ENUM('GASOLINA','DIESEL','HIBRIDO','ELECTRICO') NOT NULL,
    seats INT NOT NULL,
    brand_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    UNIQUE (brand_id, name),
    CHECK (seats > 0),
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    plate VARCHAR(10) NOT NULL UNIQUE,
    model_year SMALLINT NOT NULL,
    color VARCHAR(40) NOT NULL,
    mileage_km INT NOT NULL,
    status ENUM('DISPONIBLE','ALQUILADO','MANTENIMIENTO','FUERA_DE_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE',
    model_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    CHECK (mileage_km >= 0),
    FOREIGN KEY (model_id) REFERENCES models(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE maintenances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    maintenance_type ENUM('PREVENTIVO','CORRECTIVO','LATONERIA') NOT NULL,
    description VARCHAR(200) NOT NULL,
    workshop VARCHAR(120) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    cost DECIMAL(12,2),
    CHECK ((end_date IS NULL AND cost IS NULL) OR (end_date IS NOT NULL AND cost IS NOT NULL AND end_date >= start_date AND cost >= 0)),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);

CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_type ENUM('CC','CE','PASAPORTE') NOT NULL DEFAULT 'CC',
    document_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    phone VARCHAR(30),
    birth_date DATE NOT NULL,
    registered_on DATE NOT NULL,
    status ENUM('ACTIVO','BLOQUEADO') NOT NULL DEFAULT 'ACTIVO',
    city_id BIGINT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE licenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    license_number VARCHAR(40) NOT NULL UNIQUE,
    category ENUM('B1','B2','C1','C2') NOT NULL,
    issued_on DATE NOT NULL,
    expires_on DATE NOT NULL,
    country VARCHAR(80) NOT NULL,
    customer_id BIGINT NOT NULL,
    CHECK (expires_on >= issued_on),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE additional_drivers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    birth_date DATE NOT NULL,
    license_number VARCHAR(40) NOT NULL UNIQUE,
    license_expires_on DATE NOT NULL
);

CREATE TABLE extras (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    daily_price DECIMAL(12,2) NOT NULL,
    CHECK (daily_price >= 0)
);

CREATE TABLE reservations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    vehicle_id BIGINT NOT NULL,
    pickup_branch_id BIGINT NOT NULL,
    return_branch_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    quoted_amount DECIMAL(12,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDIENTE','CONFIRMADA','CONVERTIDA','CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
    CHECK (end_date > start_date AND quoted_amount > 0),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (pickup_branch_id) REFERENCES branches(id),
    FOREIGN KEY (return_branch_id) REFERENCES branches(id)
) AUTO_INCREMENT = 501;

CREATE TABLE contracts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reservation_id BIGINT NOT NULL UNIQUE,
    vehicle_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    expected_end_date DATE NOT NULL,
    actual_end_date DATE,
    rental_amount DECIMAL(12,2) NOT NULL,
    status ENUM('ABIERTO','CERRADO') NOT NULL DEFAULT 'ABIERTO',
    CHECK (expected_end_date > start_date),
    CHECK (actual_end_date IS NULL OR actual_end_date > start_date),
    CHECK (rental_amount > 0),
    CHECK ((status = 'ABIERTO' AND actual_end_date IS NULL) OR (status = 'CERRADO' AND actual_end_date IS NOT NULL)),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
) AUTO_INCREMENT = 9001;

CREATE TABLE contract_extras (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    extra_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    agreed_daily_price DECIMAL(12,2) NOT NULL,
    UNIQUE (contract_id, extra_id),
    CHECK (quantity >= 1 AND agreed_daily_price >= 0),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (extra_id) REFERENCES extras(id)
);

CREATE TABLE contract_drivers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    additional_driver_id BIGINT NOT NULL,
    UNIQUE (contract_id, additional_driver_id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (additional_driver_id) REFERENCES additional_drivers(id)
);

CREATE TABLE deliveries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    delivered_at DATETIME NOT NULL,
    mileage_km INT NOT NULL,
    fuel_pct INT NOT NULL,
    branch_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    CHECK (mileage_km >= 0 AND fuel_pct BETWEEN 0 AND 100),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE returns (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    returned_at DATETIME NOT NULL,
    mileage_km INT NOT NULL,
    fuel_pct INT NOT NULL,
    branch_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    CHECK (mileage_km >= 0 AND fuel_pct BETWEEN 0 AND 100),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE inspections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    stage ENUM('ENTREGA','DEVOLUCION') NOT NULL,
    inspected_at DATETIME NOT NULL,
    exterior_ok BOOLEAN NOT NULL,
    interior_ok BOOLEAN NOT NULL,
    notes VARCHAR(255),
    employee_id BIGINT NOT NULL,
    UNIQUE (contract_id, stage),
    CHECK (exterior_ok IN (0,1) AND interior_ok IN (0,1)),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

CREATE TABLE damages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inspection_id BIGINT NOT NULL,
    description VARCHAR(200) NOT NULL,
    severity ENUM('LEVE','MODERADO','GRAVE') NOT NULL,
    repair_cost DECIMAL(12,2) NOT NULL,
    chargeable BOOLEAN NOT NULL,
    CHECK (repair_cost >= 0 AND chargeable IN (0,1)),
    FOREIGN KEY (inspection_id) REFERENCES inspections(id)
);

CREATE TABLE deposits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    held_at DATETIME NOT NULL,
    released_at DATETIME,
    applied_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    status ENUM('RETENIDO','LIBERADO','APLICADO') NOT NULL DEFAULT 'RETENIDO',
    CHECK (amount >= 0 AND applied_amount BETWEEN 0 AND amount),
    CHECK ((status = 'RETENIDO' AND released_at IS NULL AND applied_amount = 0) OR (status = 'LIBERADO' AND released_at IS NOT NULL AND applied_amount = 0) OR (status = 'APLICADO' AND released_at IS NOT NULL AND applied_amount > 0)),
    FOREIGN KEY (contract_id) REFERENCES contracts(id)
);

CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contract_id BIGINT NOT NULL,
    concept ENUM('ALQUILER','EXTRAS','DAÑOS','CIERRE') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('TARJETA','EFECTIVO','TRANSFERENCIA','DEPOSITO') NOT NULL,
    paid_at DATETIME NOT NULL,
    card_last_four CHAR(4),
    authorization_code VARCHAR(40),
    CHECK (amount > 0),
    FOREIGN KEY (contract_id) REFERENCES contracts(id)
);

SHOW TABLES;
DESCRIBE reservations;
DESCRIBE contracts;
