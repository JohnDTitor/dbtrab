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