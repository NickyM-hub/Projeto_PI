from servicos.validators import (
    validar_nome_servico,
    validar_descricao,
    validar_preco,
    validar_duracao,
    validar_id_usuario
)


print("\n========== TESTE 1 - NOME VÁLIDO ==========")

try:
    resultado = validar_nome_servico("Corte + Barba")
    print("✓ Nome válido:", resultado)
except ValueError as erro:
    print("✗ ERRO:", erro)


print("\n========== TESTE 2 - NOME VAZIO ==========")

try:
    validar_nome_servico("")
    print("✗ ERRO: nome vazio foi aceito.")
except ValueError as erro:
    print("✓ Nome vazio rejeitado.")
    print("Mensagem:", erro)


print("\n========== TESTE 3 - NOME COM CARACTERE INVÁLIDO ==========")

try:
    validar_nome_servico("Corte @@@")
    print("✗ ERRO: nome inválido foi aceito.")
except ValueError as erro:
    print("✓ Nome inválido rejeitado.")
    print("Mensagem:", erro)


print("\n========== TESTE 4 - DESCRIÇÃO ==========")

try:
    resultado = validar_descricao(
        "Corte masculino com acabamento."
    )
    print("✓ Descrição válida.")
except ValueError as erro:
    print("✗ ERRO:", erro)


print("\n========== TESTE 5 - PREÇO VÁLIDO ==========")

try:
    resultado = validar_preco("59.90")
    print("✓ Preço válido:", resultado)
except ValueError as erro:
    print("✗ ERRO:", erro)


print("\n========== TESTE 6 - PREÇO NEGATIVO ==========")

try:
    validar_preco("-10")
    print("✗ ERRO: preço negativo foi aceito.")
except ValueError as erro:
    print("✓ Preço negativo rejeitado.")
    print("Mensagem:", erro)


print("\n========== TESTE 7 - PREÇO COM MAIS DE 2 CASAS ==========")

try:
    validar_preco("59.999")
    print("✗ ERRO: preço inválido foi aceito.")
except ValueError as erro:
    print("✓ Preço inválido rejeitado.")
    print("Mensagem:", erro)


print("\n========== TESTE 8 - DURAÇÃO VÁLIDA ==========")

try:
    resultado = validar_duracao(60)
    print("✓ Duração válida:", resultado, "minutos")
except ValueError as erro:
    print("✗ ERRO:", erro)


print("\n========== TESTE 9 - DURAÇÃO INVÁLIDA ==========")

try:
    validar_duracao(0)
    print("✗ ERRO: duração inválida foi aceita.")
except ValueError as erro:
    print("✓ Duração inválida rejeitada.")
    print("Mensagem:", erro)


print("\n========== TESTE 10 - ID DO USUÁRIO ==========")

try:
    resultado = validar_id_usuario(1)
    print("✓ ID válido:", resultado)
except ValueError as erro:
    print("✗ ERRO:", erro)