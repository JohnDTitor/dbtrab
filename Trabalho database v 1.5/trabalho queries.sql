CREATE DATABASE db_restaurante 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_0900_ai_ci
DEFAULT ENCRYPTION='N';

USE db_restaurante;

CREATE TABLE tb_cliente (
  id_cliente int NOT NULL AUTO_INCREMENT,
  cpf_cliente varchar(14) NOT NULL,
  nome_cliente varchar(150) NOT NULL,
  email_cliente varchar(45) DEFAULT NULL,
  telefone_cliente varchar(45) DEFAULT NULL,
  PRIMARY KEY (id_cliente)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_mesa (
  codigo_mesa int NOT NULL AUTO_INCREMENT,
  id_cliente int NOT NULL,
  num_pessoa_mesa int NOT NULL DEFAULT '1',
  data_hora_entrada datetime DEFAULT NULL,
  data_hora_saida datetime DEFAULT NULL,
  PRIMARY KEY (codigo_mesa),
  KEY fk_cliente_idx (id_cliente),
  CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES tb_cliente (id_cliente)
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_tipo_prato (
  codigo_tipo_prato int NOT NULL AUTO_INCREMENT,
  nome_tipo_prato varchar(45) NOT NULL,
  PRIMARY KEY (codigo_tipo_prato)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_situacao_pedido (
  codigo_situacao_pedido int NOT NULL AUTO_INCREMENT,
  nome_situacao_pedido varchar(45) NOT NULL,
  PRIMARY KEY (codigo_situacao_pedido)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_prato (
  codigo_prato int NOT NULL AUTO_INCREMENT,
  codigo_tipo_prato int NOT NULL,
  nome_prato varchar(45) NOT NULL,
  preco_unitario_prato double NOT NULL,
  PRIMARY KEY (codigo_prato),
  KEY fk_tipo_prato_idx (codigo_tipo_prato),
  CONSTRAINT fk_tipo_prato FOREIGN KEY (codigo_tipo_prato) REFERENCES tb_tipo_prato (codigo_tipo_prato)
) ENGINE=InnoDB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_pedido (
  codigo_mesa int NOT NULL,
  codigo_prato int NOT NULL,
  quantidade_pedido varchar(45) NOT NULL,
  codigo_situacao_pedido int NOT NULL,
  KEY fk_situacao_pedido_idx (codigo_situacao_pedido),
  KEY fk_mesa_idx (codigo_mesa),
  KEY fk_prato_idx (codigo_prato),
  CONSTRAINT fk_mesa FOREIGN KEY (codigo_mesa) REFERENCES tb_mesa (codigo_mesa),
  CONSTRAINT fk_prato FOREIGN KEY (codigo_prato) REFERENCES tb_prato (codigo_prato),
  CONSTRAINT fk_situacao_pedido FOREIGN KEY (codigo_situacao_pedido) REFERENCES tb_situacao_pedido (codigo_situacao_pedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_empresa (
  codigo_empresa int NOT NULL AUTO_INCREMENT,
  nome_empresa varchar(500) NOT NULL,
  uf_sede_empresa varchar(2) NOT NULL,
  PRIMARY KEY (codigo_empresa)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_beneficio (
  codigo_funcionario int NOT NULL AUTO_INCREMENT,
  email_funcionario varchar(200),
  codigo_beneficio int NOT NULL,
  codigo_empresa int NOT NULL,
  tipo_beneficio varchar(45),
  valor_beneficio varchar(45),
  PRIMARY KEY (codigo_funcionario),
  KEY fk_empresa_idx (codigo_empresa),
  CONSTRAINT fk_empresa FOREIGN KEY (codigo_empresa) REFERENCES tb_empresa (codigo_empresa)
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Qual o cliente que mais fez pedidos por ano
SELECT 
    ano,
    id_cliente,
    nome_cliente,
    total_pedidos
FROM (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        m.id_cliente,
        c.nome_cliente,
        COUNT(p.codigo_mesa) AS total_pedidos,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(p.codigo_mesa) DESC) AS rn
    FROM 
        tb_pedido p
    JOIN 
        tb_mesa m ON p.codigo_mesa = m.codigo_mesa
    JOIN 
        tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY 
        ano, m.id_cliente, c.nome_cliente
) ranked
WHERE rn = 1;

# Qual o cliente que mais gastou em todos os anos
SELECT 
    c.id_cliente,
    c.nome_cliente,
    SUM(pr.preco_unitario_prato * p.quantidade_pedido) AS total_gasto
FROM 
    tb_pedido p
    JOIN tb_mesa m ON p.codigo_mesa = m.codigo_mesa
    JOIN tb_cliente c ON m.id_cliente = c.id_cliente
    JOIN tb_prato pr ON p.codigo_prato = pr.codigo_prato
GROUP BY 
    c.id_cliente, c.nome_cliente
ORDER BY
    total_gasto DESC
LIMIT 1;

# Qual(is) o(s) cliente(s) que trouxe(ram) mais pessoas por ano
SELECT 
    ano,
    id_cliente,
    nome_cliente,
    total_pessoas
FROM (
    SELECT 
        YEAR(m.data_hora_entrada) AS ano,
        m.id_cliente,
        c.nome_cliente,
        SUM(m.num_pessoa_mesa) AS total_pessoas,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY SUM(m.num_pessoa_mesa) DESC) AS rn
    FROM 
        tb_mesa m
    JOIN 
        tb_cliente c ON m.id_cliente = c.id_cliente
    GROUP BY 
        ano, m.id_cliente, c.nome_cliente
) ranked
WHERE rn = 1;

# Qual a empresa que tem mais funcionarios como clientes do restaurante
SELECT 
    e.nome_empresa,
    COUNT(DISTINCT b.codigo_funcionario) AS total_funcionarios
FROM 
    tb_empresa e
JOIN 
    tb_beneficio b ON e.codigo_empresa = b.codigo_empresa
JOIN 
    tb_mesa m ON b.codigo_funcionario = m.id_cliente
GROUP BY 
    e.nome_empresa
ORDER BY 
    total_funcionarios DESC
LIMIT 1;

# Qual empresa tem mais funcionarios que consomem sobremesas no restaurante por ano;
SELECT 
    e.nome_empresa,
    YEAR(m.data_hora_saida) AS ano,
    COUNT(DISTINCT b.codigo_funcionario) AS num_funcionarios_sobremesas
FROM 
    tb_mesa m
    JOIN tb_beneficio b ON m.id_cliente = b.codigo_funcionario
    JOIN tb_empresa e ON b.codigo_empresa = e.codigo_empresa
    JOIN tb_tipo_prato t ON t.codigo_tipo_prato = t.codigo_tipo_prato
    JOIN tb_pedido p ON m.codigo_mesa = p.codigo_mesa
WHERE 
    t.codigo_tipo_prato = 3
GROUP BY 
    e.nome_empresa, ano
ORDER BY 
    ano DESC, num_funcionarios_sobremesas DESC
LIMIT 10;