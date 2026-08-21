import re
from decimal import Decimal, InvalidOperation


# ============================================================
# VALIDAÇÃO DO NOME DO SERVIÇO
# ============================================================

def validar_nome_servico(nome):

    if not isinstance(nome, str):
        raise ValueError("O nome do serviço deve ser um texto.")

    nome = nome.strip()

    if not nome:
        raise ValueError("O nome do serviço é obrigatório.")

    if len(nome) < 2:
        raise ValueError(
            "O nome do serviço deve possuir pelo menos 2 caracteres."
        )

    if len(nome) > 100:
        raise ValueError(
            "O nome do serviço deve possuir no máximo 100 caracteres."
        )

    # Permite letras, números, espaços e alguns caracteres comuns.
    if not re.fullmatch(r"[A-Za-zÀ-ÿ0-9\s&+\-()]+", nome):
        raise ValueError(
            "O nome do serviço possui caracteres inválidos."
        )

    return nome


# ============================================================
# VALIDAÇÃO DA DESCRIÇÃO
# ============================================================

def validar_descricao(descricao):

    if descricao is None:
        return ""

    if not isinstance(descricao, str):
        raise ValueError("A descrição deve ser um texto.")

    descricao = descricao.strip()

    if len(descricao) > 500:
        raise ValueError(
            "A descrição deve possuir no máximo 500 caracteres."
        )

    return descricao


# ============================================================
# VALIDAÇÃO DO PREÇO
# ============================================================

def validar_preco(preco):

    try:
        valor = Decimal(str(preco))
    except (InvalidOperation, ValueError, TypeError):
        raise ValueError("O preço deve ser um valor numérico.")

    if valor < 0:
        raise ValueError("O preço não pode ser negativo.")

    if valor > Decimal("999999.99"):
        raise ValueError(
            "O preço não pode ser superior a R$ 999.999,99."
        )

    # Máximo de 2 casas decimais.
    if valor.as_tuple().exponent < -2:
        raise ValueError(
            "O preço deve possuir no máximo 2 casas decimais."
        )

    return valor


# ============================================================
# VALIDAÇÃO DA DURAÇÃO
# ============================================================

def validar_duracao(duracao_minutos):

    if isinstance(duracao_minutos, bool):
        raise ValueError(
            "A duração deve ser um número inteiro."
        )

    try:
        duracao = int(duracao_minutos)
    except (ValueError, TypeError):
        raise ValueError(
            "A duração deve ser um número inteiro."
        )

    if duracao <= 0:
        raise ValueError(
            "A duração deve ser maior que zero."
        )

    if duracao > 1440:
        raise ValueError(
            "A duração não pode ultrapassar 24 horas."
        )

    return duracao


# ============================================================
# VALIDAÇÃO DO ID DO USUÁRIO
# ============================================================

def validar_id_usuario(id_usuario):

    if isinstance(id_usuario, bool):
        raise ValueError(
            "O ID do usuário deve ser um número inteiro."
        )

    try:
        id_usuario = int(id_usuario)
    except (ValueError, TypeError):
        raise ValueError(
            "O ID do usuário deve ser um número inteiro."
        )

    if id_usuario <= 0:
        raise ValueError(
            "O ID do usuário deve ser maior que zero."
        )

    return id_usuario