create database Marvie;
-- sequencial organizada
use marvie;
-- Marvie, uma loja de roupas de frio para todos os gostos!

-- criação das tabelas
drop table usuario;
CREATE TABLE usuario (
    usu_id INT AUTO_INCREMENT PRIMARY KEY,
    usu_nome VARCHAR(45) NULL,
    usu_email VARCHAR(45) NULL,
    usu_CPF VARCHAR(45) NOT NULL,
    usu_data_Nascimento DATE NULL,
    usu_cep VARCHAR(8) NOT NULL
);

CREATE TABLE pedido (
    ped_id INT AUTO_INCREMENT PRIMARY KEY,
    ped_data_pedido TIMESTAMP NOT NULL,
    ped_usu_id INT NOT NULL,
    FOREIGN KEY (ped_usu_id) REFERENCES usuario(usu_id)
);

CREATE TABLE categoria (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,
    cat_nome VARCHAR(45) NOT NULL,
    descricao VARCHAR(45) NOT NULL
);

CREATE TABLE funcionario (
    func_id INT AUTO_INCREMENT PRIMARY KEY,
    func_nome VARCHAR(45) NOT NULL,
    func_cpf VARCHAR(14) NOT NULL
);

CREATE TABLE produto (
    prod_id INT AUTO_INCREMENT PRIMARY KEY,
    prod_nome VARCHAR(45) NULL,
    prod_descricao VARCHAR(45) NOT NULL,
    prod_estoque INT NOT NULL,
    prod_data_fabricacao DATE NOT NULL,
    prod_valor FLOAT NOT NULL,
    cat_int_id INT NOT NULL,
    func_int_id INT NOT NULL,
    FOREIGN KEY (cat_int_id) REFERENCES categoria(cat_id),
    FOREIGN KEY (func_int_id) REFERENCES funcionario(func_id)
);

CREATE TABLE pedido_produto (
    pedPro_id INT AUTO_INCREMENT PRIMARY KEY,
    prod_int_id INT NOT NULL,
    ped_int_id INT NOT NULL,
    FOREIGN KEY (prod_int_id) REFERENCES produto(prod_id),
    FOREIGN KEY (ped_int_id) REFERENCES pedido(ped_id)
);


-- Índice do produto
CREATE INDEX prod1_index ON produto(prod_nome, prod_estoque, prod_id);
CREATE INDEX prod2_index ON produto(prod_valor, prod_data_fabricacao);

-- Índice do usuário
CREATE INDEX usu1_index ON usuario(usu_id, usu_nome, usu_CPF, usu_data_Nascimento);
CREATE INDEX usu2_index ON usuario(usu_nome, usu_email);

-- Índice do pedido
CREATE INDEX ped1_index ON pedido(ped_id, ped_data_pedido, ped_usu_id);


-- criação da view nota_fiscal

CREATE VIEW nota_fiscal AS
SELECT
    u.usu_nome AS "Nome",
    u.usu_CPF AS "CPF",
    p.ped_data_pedido AS "Data do Pedido",
    p2.prod_nome AS "Nome do Produto",
    p2.prod_valor AS "Valor",
    f.func_nome AS "Funcionário"
FROM usuario u
INNER JOIN pedido p ON u.usu_id = p.ped_usu_id
INNER JOIN pedido_produto pp ON p.ped_id = pp.ped_int_id 
INNER JOIN produto p2 ON pp.prod_int_id = p2.prod_id 
INNER JOIN funcionario f ON p2.func_int_id = f.func_id;


select * from nota_fiscal;



-- Criação dos usuários
CREATE USER 'administrator'@'localhost' IDENTIFIED BY '1234';
-- CREATE USER 'empregado'@'localhost' IDENTIFIED BY '1010';
CREATE USER 'cliente'@'%' IDENTIFIED BY 'your_password';

-- Conceder todos os privilégios ao administrador
GRANT ALL PRIVILEGES ON *.* TO 'administrator'@'localhost' WITH GRANT OPTION;

/* Permissões para o empregado
GRANT SELECT, UPDATE, INSERT, REFERENCES ON produto TO 'empregado'@'localhost';
GRANT SELECT ON categoria TO 'empregado'@'localhost';
GRANT UPDATE, SELECT ON funcionario TO 'empregado'@'localhost';
GRANT SELECT(usu_nome) ON usuario TO 'empregado'@'localhost';
GRANT SELECT, INSERT ON nota_fiscal TO 'empregado'@'localhost';*/

-- Permissões para o cliente
GRANT SELECT ON produto TO 'cliente'@'%';
GRANT SELECT ON categoria TO 'cliente'@'%';
GRANT SELECT (usu_nome, usu_email, usu_CPF), UPDATE (usu_nome, usu_email, usu_CPF) ON usuario TO 'cliente'@'%';
GRANT DELETE ON usuario TO 'cliente'@'%';
GRANT SELECT, UPDATE, DELETE, INSERT ON pedido TO 'cliente'@'%';
GRANT SELECT, UPDATE, DELETE, INSERT ON pedido_produto TO 'cliente'@'%';
GRANT SELECT ON nota_fiscal TO 'cliente'@'%';
GRANT SELECT (func_nome) ON funcionario TO 'cliente'@'%';


select * from funcionario;

select func_nome from funcionario;


-- Inner join para descobri os usuários que compraram qualquer produto.

select * from produto;

SELECT u.usu_id, u.usu_nome, prod_nome
FROM usuario u
INNER JOIN pedido p ON u.usu_id = p.ped_usu_id
INNER JOIN pedido_produto pp ON p.ped_id = pp.ped_int_id
INNER JOIN produto p2 ON p2.prod_id = pp.prod_int_id
WHERE p2.prod_nome = 'prod'; 


select * from pedido_produto;

-- Deletar o pedido 
DELETE
FROM
	pedido_produto
WHERE
	pedpro_id = 8; -- exemplo de valor


-- Alterar o pedido 

UPDATE
	pedido_produto
SET
	prod_id = 1 -- Substitua pelo ID correto
WHERE
	pedpro_id = 7;

-- Mostrar tabelas de itens que nao foram comprados.
-- adm.

SELECT 
    p.prod_id,
    p.prod_nome,
    p.prod_valor
FROM produto p 
LEFT JOIN pedido_produto pp ON p.prod_id = pp.prod_int_id
WHERE pp.prod_int_id IS NULL
ORDER BY p.prod_id ASC;


-- busca o produto mais barato de cada categoria.

SELECT 
    c.cat_nome AS "Categoria",
    p.prod_nome AS "Produto", 
    p.prod_valor AS "Preço"
FROM
    produto p
INNER JOIN categoria c ON
    c.cat_id = p.cat_int_id
INNER JOIN (
    SELECT  p.cat_int_id,
        MIN(p.prod_valor) AS "Mais barato"
    FROM  produto p
    GROUP BY 
        p.cat_int_id
) min_p ON
    p.cat_int_id = min_p.cat_int_id
    AND p.prod_valor = min_p.min_valor
ORDER BY 
    c.cat_nome;

