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