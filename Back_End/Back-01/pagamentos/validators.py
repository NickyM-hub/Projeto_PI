from decimal import Decimal


def validar_valor_pagamento(valor):
    if valor is None:
        raise ValueError("O valor do pagamento é obrigatório.")

    if Decimal(valor) <= 0:
        raise ValueError("O valor do pagamento deve ser maior que zero.")

    return True


def validar_agendamento(agendamento):
    if agendamento is None:
        raise ValueError("O agendamento é obrigatório.")

    return True


def validar_pagamento_pix(agendamento, valor):
    validar_agendamento(agendamento)
    validar_valor_pagamento(valor)

    return True
