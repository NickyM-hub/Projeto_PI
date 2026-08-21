from datetime import datetime, timedelta


# ============================================================
# ID
# ============================================================

def validar_id(valor, nome="ID"):

    if isinstance(valor, bool):
        raise ValueError(
            f"{nome} deve ser um número inteiro."
        )

    try:
        valor = int(valor)

    except (ValueError, TypeError):
        raise ValueError(
            f"{nome} deve ser um número inteiro."
        )

    if valor <= 0:
        raise ValueError(
            f"{nome} deve ser maior que zero."
        )

    return valor


# ============================================================
# DATA E HORA
# ============================================================

def validar_data_hora(data_hora):

    if not isinstance(data_hora, datetime):
        raise ValueError(
            "A data e hora devem ser informadas "
            "como um objeto datetime."
        )

    return data_hora


# ============================================================
# ANTECEDÊNCIA MÍNIMA
# ============================================================

def adicionar_dias_uteis(data, quantidade):

    resultado = data
    adicionados = 0

    while adicionados < quantidade:

        resultado += timedelta(days=1)

        # Segunda = 0
        # Domingo = 6
        if resultado.weekday() < 5:
            adicionados += 1

    return resultado


def validar_antecedencia_minima(
    data_hora,
    agora=None
):

    data_hora = validar_data_hora(data_hora)

    if agora is None:
        agora = datetime.now()

    limite = adicionar_dias_uteis(
        agora,
        3
    )

    if data_hora < limite:

        raise ValueError(
            "O agendamento deve ser realizado "
            "com pelo menos 3 dias úteis de antecedência."
        )

    return data_hora


# ============================================================
# OBSERVAÇÃO
# ============================================================

def validar_observacao(observacao):

    if observacao is None:
        return None

    if not isinstance(observacao, str):
        raise ValueError(
            "A observação deve ser um texto."
        )

    observacao = observacao.strip()

    if len(observacao) > 500:
        raise ValueError(
            "A observação deve possuir no máximo 500 caracteres."
        )

    return observacao


# ============================================================
# STATUS
# ============================================================

STATUS_VALIDOS = {
    "AGENDADO",
    "CONFIRMADO",
    "CANCELADO",
    "CONCLUIDO",
    "REAGENDADO"
}


def validar_status(status):

    if not isinstance(status, str):
        raise ValueError(
            "O status deve ser um texto."
        )

    status = status.strip().upper()

    if status not in STATUS_VALIDOS:
        raise ValueError(
            "Status de agendamento inválido."
        )

    return status