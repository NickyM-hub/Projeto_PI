from datetime import timedelta

from django.conf import settings
from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken


def autenticar_usuario(email, senha):
    usuario = authenticate(
        username=email,
        password=senha
    )

    if usuario is None:
        raise ValueError("E-mail ou senha inválidos.")

    if not usuario.is_active:
        raise ValueError("Usuário está inativo.")

    return usuario


def gerar_tokens(usuario):
    refresh = RefreshToken.for_user(usuario)

    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
    }


def realizar_login(email, senha):
    usuario = autenticar_usuario(email, senha)
    tokens = gerar_tokens(usuario)

    return {
        "usuario": usuario,
        "tokens": tokens,
    }