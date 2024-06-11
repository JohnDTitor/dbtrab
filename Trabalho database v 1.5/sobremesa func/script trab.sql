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