import requests


def obter_coordenadas(endereco):
    if not endereco:
        raise ValueError("O endereço é obrigatório.")

    url = "https://nominatim.openstreetmap.org/search"

    parametros = {
        "q": endereco,
        "format": "json",
        "limit": 1,
    }

    headers = {
        "User-Agent": "ProjetoPI/1.0"
    }

    resposta = requests.get(
        url,
        params=parametros,
        headers=headers,
        timeout=10
    )

    if resposta.status_code != 200:
        raise ValueError(
            "Não foi possível consultar a localização."
        )

    dados = resposta.json()

    if not dados:
        raise ValueError(
            "Localização não encontrada."
        )

    return {
        "latitude": float(dados[0]["lat"]),
        "longitude": float(dados[0]["lon"]),
    }