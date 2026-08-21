from servicos.services import ServicoService
from servicos.serializers import ServicoSerializer


service = ServicoService()


print("\n========== TESTE 19 - SERIALIZER ==========")

try:

    servico = service.cadastrar_servico(
        id_usuario=1,
        nome="Corte + Barba",
        descricao="Corte masculino com barba.",
        preco="59.90",
        duracao_minutos=60
    )

    dados = ServicoSerializer.to_dict(servico)

    print("✓ Serviço convertido com sucesso.")

    for chave, valor in dados.items():
        print(f"{chave}: {valor}")

except Exception as erro:

    print("✗ ERRO:", erro)


print("\n========== TESTE 20 - LISTA ==========")

try:

    servico2 = service.cadastrar_servico(
        id_usuario=1,
        nome="Corte Masculino",
        descricao="Corte tradicional.",
        preco="40.00",
        duracao_minutos=45
    )

    dados = ServicoSerializer.many(
        service.listar_todos()
    )

    print("✓ Lista convertida com sucesso.")
    print("Quantidade:", len(dados))

except Exception as erro:

    print("✗ ERRO:", erro)