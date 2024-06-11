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
