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