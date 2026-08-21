from django.core.validators import validate_email
from django.core.exceptions import ValidationError


def validar_email(email):
    if not email:
        raise ValueError("O e-mail é obrigatório.")

    try:
        validate_email(email)
    except ValidationError:
        raise ValueError("Informe um e-mail válido.")

    return True


def validar_senha(senha):
    if not senha:
        raise ValueError("A senha é obrigatória.")

    if len(senha) < 8:
        raise ValueError(
            "A senha deve possuir pelo menos 8 caracteres."
        )

    return True


def validar_login(email, senha):
    validar_email(email)
    validar_senha(senha)

    return True
