from datetime import datetime

from agendamentos.services import (
    AgendamentoService
)

from agendamentos.serializers import (
    AgendamentoSerializer
)


service = AgendamentoService()


# ============================================================
# DATA DE TESTE
# ============================================================

agora = datetime(
    2026,
    8,
    17,
    10,
    0
)

data_agendamento = datetime(
    2026,
    8,
    21,
    14,
    0
)


print(
    "\n========== TESTE 1 - CADASTRO =========="
)

try:

    agendamento = (
        service.cadastrar_agendamento(
            id_usuario=1,
            id_servico=1,
            data_hora=data_agendamento,
            observacao="Primeiro agendamento.",
            agora=agora
        )
    )

    print("✓ Agendamento cadastrado.")
    print(
        "ID:",
        agendamento.id_agendamento
    )
    print(
        "Usuário:",
        agendamento.id_usuario
    )
    print(
        "Serviço:",
        agendamento.id_servico
    )
    print(
        "Data:",
        agendamento.data_hora
    )
    print(
        "Status:",
        agendamento.status
    )

except ValueError as erro:

    print("✗ ERRO:", erro)


print(
    "\n========== TESTE 2 - HORÁRIO DUPLICADO =========="
)

try:

    service.cadastrar_agendamento(
        id_usuario=2,
        id_servico=1,
        data_hora=data_agendamento,
        agora=agora
    )

    print(
        "✗ ERRO: horário duplicado foi aceito."
    )

except ValueError as erro:

    print(
        "✓ Horário duplicado rejeitado."
    )

    print(
        "Mensagem:",
        erro
    )


print(
    "\n========== TESTE 3 - USUÁRIO NO MESMO HORÁRIO =========="
)

try:

    service.cadastrar_agendamento(
        id_usuario=1,
        id_servico=2,
        data_hora=data_agendamento,
        agora=agora
    )

    print(
        "✗ ERRO: usuário foi agendado duas vezes."
    )

except ValueError as erro:

    print(
        "✓ Conflito do usuário rejeitado."
    )

    print(
        "Mensagem:",
        erro
    )


print(
    "\n========== TESTE 4 - LISTAR =========="
)

lista = service.listar_todos()

print(
    "✓ Agendamentos encontrados:",
    len(lista)
)


print(
    "\n========== TESTE 5 - LISTAR POR USUÁRIO =========="
)

lista_usuario = (
    service.listar_por_usuario(1)
)

print(
    "✓ Agendamentos do usuário:",
    len(lista_usuario)
)


print(
    "\n========== TESTE 6 - CONFIRMAR =========="
)

try:

    agendamento = (
        service.confirmar_agendamento(1)
    )

    print(
        "✓ Agendamento confirmado."
    )

    print(
        "Status:",
        agendamento.status
    )

except ValueError as erro:

    print("✗ ERRO:", erro)


print(
    "\n========== TESTE 7 - CANCELAR =========="
)

try:

    agendamento = (
        service.cancelar_agendamento(1)
    )

    print(
        "✓ Agendamento cancelado."
    )

    print(
        "Status:",
        agendamento.status
    )

except ValueError as erro:

    print("✗ ERRO:", erro)


print(
    "\n========== TESTE 8 - REAGENDAR =========="
)

try:

    # Criamos outro agendamento
    novo = (
        service.cadastrar_agendamento(
            id_usuario=2,
            id_servico=2,
            data_hora=datetime(
                2026,
                8,
                22,
                15,
                0
            ),
            agora=agora
        )
    )

    reagendado = service.reagendar(
        novo.id_agendamento,
        datetime(
            2026,
            8,
            24,
            15,
            0
        ),
        agora=agora
    )

    print(
        "✓ Agendamento reagendado."
    )

    print(
        "Nova data:",
        reagendado.data_hora
    )

    print(
        "Status:",
        reagendado.status
    )

except ValueError as erro:

    print("✗ ERRO:", erro)


print(
    "\n========== TESTE 9 - SERIALIZER =========="
)

try:

    dados = (
        AgendamentoSerializer.to_dict(
            novo
        )
    )

    print(
        "✓ Agendamento convertido."
    )

    for chave, valor in dados.items():

        print(
            f"{chave}: {valor}"
        )

except Exception as erro:

    print("✗ ERRO:", erro)