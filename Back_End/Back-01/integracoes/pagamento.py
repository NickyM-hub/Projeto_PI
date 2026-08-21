import base64
import requests

from django.conf import settings


def obter_token_pix():
    credenciais = (
        f"{settings.PIX_CLIENT_ID}:"
        f"{settings.PIX_CLIENT_SECRET}"
    )

    credenciais_base64 = base64.b64encode(
        credenciais.encode()
    ).decode()

    headers = {
        "Authorization": f"Basic {credenciais_base64}",
        "Content-Type": "application/json",
    }

    resposta = requests.post(
        f"{settings.PIX_API_URL}/oauth/token",
        headers=headers,
        json={
            "grant_type": "client_credentials"
        },
        cert=settings.PIX_CERTIFICADO,
        timeout=10,
    )

    if resposta.status_code != 200:
        raise ValueError(
            "Não foi possível obter o token da API PIX."
        )

    dados = resposta.json()

    return dados["access_token"]


def criar_cobranca_pix(
    txid,
    valor,
    nome_devedor,
    documento_devedor=None
):
    token = obter_token_pix()

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    dados = {
        "calendario": {
            "expiracao": 3600
        },
        "devedor": {
            "nome": nome_devedor
        },
        "valor": {
            "original": f"{valor:.2f}"
        },
        "chave": settings.PIX_CHAVE,
        "solicitacaoPagador": (
            "Pagamento referente ao agendamento."
        )
    }

    if documento_devedor:
        if len(documento_devedor) == 11:
            dados["devedor"]["cpf"] = documento_devedor
        elif len(documento_devedor) == 14:
            dados["devedor"]["cnpj"] = documento_devedor

    resposta = requests.put(
        f"{settings.PIX_API_URL}/v2/cob/{txid}",
        headers=headers,
        json=dados,
        cert=settings.PIX_CERTIFICADO,
        timeout=10,
    )

    if resposta.status_code not in (200, 201):
        raise ValueError(
            "Não foi possível criar a cobrança PIX."
        )

    return resposta.json()


def consultar_cobranca_pix(txid):
    token = obter_token_pix()

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    resposta = requests.get(
        f"{settings.PIX_API_URL}/v2/cob/{txid}",
        headers=headers,
        cert=settings.PIX_CERTIFICADO,
        timeout=10,
    )

    if resposta.status_code != 200:
        raise ValueError(
            "Não foi possível consultar a cobrança PIX."
        )

    return resposta.json()