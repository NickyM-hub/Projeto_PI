import requests


def consultar_cep(cep):
    cep = cep.replace("-", "").replace(".", "").strip()

    if len(cep) != 8 or not cep.isdigit():
        raise ValueError("CEP inválido.")

    url = f"https://viacep.com.br/ws/{cep}/json/"

    resposta = requests.get(url, timeout=10)

    if resposta.status_code != 200:
        raise ValueError("Não foi possível consultar o CEP.")

    dados = resposta.json()

    if dados.get("erro"):
        raise ValueError("CEP não encontrado.")

    return {
        "cep": dados.get("cep"),
        "logradouro": dados.get("logradouro"),
        "bairro": dados.get("bairro"),
        "cidade": dados.get("localidade"),
        "estado": dados.get("uf"),
    }
