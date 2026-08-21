from servicos.services import ServicoService


service = ServicoService()


print("\n========== TESTE 11 - CADASTRO ==========")

try:

    servico = service.cadastrar_servico(
        id_usuario=1,
        nome="Corte + Barba",
        descricao="Corte masculino com barba.",
        preco="59.90",
        duracao_minutos=60
    )

    print("✓ Serviço cadastrado.")
    print("ID:", servico.id_servico)
    print("Nome:", servico.nome)
    print("Preço:", servico.preco)
    print("Duração:", servico.duracao_minutos)
    print("Ativo:", servico.ativo)

except ValueError as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 12 - DUPLICADO ==========")

try:

    service.cadastrar_servico(
        id_usuario=1,
        nome="Corte + Barba",
        descricao="Outro serviço.",
        preco="70.00",
        duracao_minutos=60
    )

    print("✗ ERRO: serviço duplicado foi aceito.")

except ValueError as erro:

    print("✓ Serviço duplicado rejeitado.")
    print("Mensagem:", erro)


print("\n========== TESTE 13 - OUTRO SERVIÇO ==========")

try:

    servico2 = service.cadastrar_servico(
        id_usuario=1,
        nome="Corte Masculino",
        descricao="Corte tradicional.",
        preco="40.00",
        duracao_minutos=45
    )

    print("✓ Segundo serviço cadastrado.")

except ValueError as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 14 - BUSCAR ==========")

try:

    encontrado = service.buscar_por_id(1)

    print("✓ Serviço encontrado.")
    print("Nome:", encontrado.nome)

except ValueError as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 15 - ALTERAR PREÇO ==========")

try:

    alterado = service.alterar_servico(
        id_servico=1,
        preco="65.90"
    )

    print("✓ Serviço alterado.")
    print("Novo preço:", alterado.preco)

except ValueError as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 16 - LISTAR POR USUÁRIO ==========")

servicos_usuario = service.listar_por_usuario(1)

print(
    "✓ Serviços encontrados:",
    len(servicos_usuario)
)


print("\n========== TESTE 17 - INATIVAR ==========")

try:

    servico = service.inativar_servico(1)

    print("✓ Serviço inativado.")
    print("Ativo:", servico.ativo)

except ValueError as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 18 - REATIVAR ==========")

try:

    servico = service.reativar_servico(1)

    print("✓ Serviço reativado.")
    print("Ativo:", servico.ativo)

except ValueError as erro:

    print("✗ ERRO:", erro)