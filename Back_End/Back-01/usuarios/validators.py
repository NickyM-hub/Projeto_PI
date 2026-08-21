import re
from datetime import date, datetime


# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================

def somente_numeros(valor):
    """
    Remove tudo que não for número.
    Exemplo:
        529.982.247-25 -> 52998224725
    """

    if valor is None:
        return ""

    return re.sub(r"\D", "", str(valor))


# ============================================================
# NOME
# ============================================================

def validar_nome(nome):

    if not isinstance(nome, str):
        raise ValueError("O nome deve ser um texto.")

    nome = " ".join(nome.strip().split())

    if not nome:
        raise ValueError("O nome é obrigatório.")

    if len(nome) < 3:
        raise ValueError(
            "O nome deve possuir pelo menos 3 caracteres."
        )

    if len(nome) > 150:
        raise ValueError(
            "O nome deve possuir no máximo 150 caracteres."
        )

    # Aceita letras, espaços e acentos.
    if not re.fullmatch(r"[A-Za-zÀ-ÖØ-öø-ÿ ]+", nome):
        raise ValueError(
            "O nome deve conter apenas letras e espaços."
        )

    return nome


# ============================================================
# CPF
# ============================================================

def validar_cpf(cpf):

    cpf = somente_numeros(cpf)

    if len(cpf) != 11:
        raise ValueError(
            "O CPF deve possuir exatamente 11 números."
        )

    # Rejeita sequências como:
    # 00000000000
    # 11111111111
    # etc.
    if len(set(cpf)) == 1:
        raise ValueError("CPF inválido.")

    # Primeiro dígito verificador
    soma = sum(
        int(cpf[i]) * (10 - i)
        for i in range(9)
    )

    resto = soma % 11

    primeiro_digito = (
        0 if resto < 2 else 11 - resto
    )

    if primeiro_digito != int(cpf[9]):
        raise ValueError("CPF inválido.")

    # Segundo dígito verificador
    soma = sum(
        int(cpf[i]) * (11 - i)
        for i in range(10)
    )

    resto = soma % 11

    segundo_digito = (
        0 if resto < 2 else 11 - resto
    )

    if segundo_digito != int(cpf[10]):
        raise ValueError("CPF inválido.")

    return cpf


# ============================================================
# CNPJ
# ============================================================

def validar_cnpj(cnpj):

    cnpj = somente_numeros(cnpj)

    if len(cnpj) != 14:
        raise ValueError(
            "O CNPJ deve possuir exatamente 14 números."
        )

    if len(set(cnpj)) == 1:
        raise ValueError("CNPJ inválido.")

    # Primeiro dígito verificador
    pesos = [
        5, 4, 3, 2,
        9, 8, 7, 6,
        5, 4, 3, 2
    ]

    soma = sum(
        int(cnpj[i]) * pesos[i]
        for i in range(12)
    )

    resto = soma % 11

    primeiro_digito = (
        0 if resto < 2 else 11 - resto
    )

    if primeiro_digito != int(cnpj[12]):
        raise ValueError("CNPJ inválido.")

    # Segundo dígito verificador
    pesos = [
        6, 5, 4, 3, 2,
        9, 8, 7, 6, 5, 4, 3, 2
    ]

    soma = sum(
        int(cnpj[i]) * pesos[i]
        for i in range(13)
    )

    resto = soma % 11

    segundo_digito = (
        0 if resto < 2 else 11 - resto
    )

    if segundo_digito != int(cnpj[13]):
        raise ValueError("CNPJ inválido.")

    return cnpj


# ============================================================
# DOCUMENTO
# ============================================================

def validar_documento(tipo_documento, documento):

    if not isinstance(tipo_documento, str):
        raise ValueError(
            "O tipo de documento deve ser CPF ou CNPJ."
        )

    tipo_documento = tipo_documento.strip().upper()

    if tipo_documento == "CPF":

        return validar_cpf(documento)

    if tipo_documento == "CNPJ":

        return validar_cnpj(documento)

    raise ValueError(
        "O tipo de documento deve ser CPF ou CNPJ."
    )


# ============================================================
# E-MAIL
# ============================================================

def validar_email(email):

    if not isinstance(email, str):
        raise ValueError("O e-mail deve ser um texto.")

    email = email.strip().lower()

    if not email:
        raise ValueError("O e-mail é obrigatório.")

    if len(email) > 254:
        raise ValueError(
            "O e-mail deve possuir no máximo 254 caracteres."
        )

    # Validação prática para aplicação.
    padrao = (
        r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+"
        r"@"
        r"[A-Za-z0-9]"
        r"(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
        r"(?:\.[A-Za-z0-9]"
        r"(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$"
    )

    if not re.fullmatch(padrao, email):
        raise ValueError("E-mail inválido.")

    return email


# ============================================================
# TELEFONE
# ============================================================

def validar_telefone(telefone):

    telefone = somente_numeros(telefone)

    if len(telefone) not in (10, 11):
        raise ValueError(
            "O telefone deve possuir 10 ou 11 números."
        )

    # Não aceita telefone composto por um único número repetido.
    if len(set(telefone)) == 1:
        raise ValueError("Telefone inválido.")

    # DDD brasileiro: 11 a 99, sem 0.
    ddd = int(telefone[:2])

    if not 11 <= ddd <= 99:
        raise ValueError("DDD inválido.")

    # Celular brasileiro possui 11 dígitos e começa com 9.
    if len(telefone) == 11 and telefone[2] != "9":
        raise ValueError(
            "Número de celular inválido."
        )

    return telefone


# ============================================================
# CEP
# ============================================================

def validar_cep(cep):

    cep = somente_numeros(cep)

    if len(cep) != 8:
        raise ValueError(
            "O CEP deve possuir exatamente 8 números."
        )

    return cep


# ============================================================
# ESTADO
# ============================================================

UF_VALIDAS = {
    "AC", "AL", "AP", "AM",
    "BA", "CE", "DF", "ES",
    "GO", "MA", "MT", "MS",
    "MG", "PA", "PB", "PR",
    "PE", "PI", "RJ", "RN",
    "RS", "RO", "RR", "SC",
    "SP", "SE", "TO"
}


def validar_estado(estado):

    if not isinstance(estado, str):
        raise ValueError(
            "O estado deve ser informado por sua UF."
        )

    estado = estado.strip().upper()

    if estado not in UF_VALIDAS:
        raise ValueError(
            "UF inválida."
        )

    return estado


# ============================================================
# DATA DE NASCIMENTO
# ============================================================

def validar_data_nascimento(data_nascimento):

    if isinstance(data_nascimento, datetime):
        data_nascimento = data_nascimento.date()

    if isinstance(data_nascimento, date):
        data = data_nascimento

    elif isinstance(data_nascimento, str):

        try:

            data = datetime.strptime(
                data_nascimento.strip(),
                "%d/%m/%Y"
            ).date()

        except ValueError:

            raise ValueError(
                "A data deve estar no formato DD/MM/AAAA "
                "e representar uma data válida."
            )

    else:

        raise ValueError(
            "Data de nascimento inválida."
        )

    hoje = date.today()

    if data > hoje:
        raise ValueError(
            "A data de nascimento não pode ser futura."
        )

    return data


# ============================================================
# MAIORIDADE
# ============================================================

def validar_maioridade(data_nascimento):

    hoje = date.today()

    idade = (
        hoje.year
        - data_nascimento.year
        - (
            (hoje.month, hoje.day)
            < (data_nascimento.month, data_nascimento.day)
        )
    )

    if idade < 18:
        raise ValueError(
            "O usuário deve possuir 18 anos ou mais."
        )

    return True


# ============================================================
# SENHA
# ============================================================

def validar_senha(senha):

    if not isinstance(senha, str):
        raise ValueError(
            "A senha deve ser um texto."
        )

    if len(senha) < 8:
        raise ValueError(
            "A senha deve possuir pelo menos 8 caracteres."
        )

    if len(senha) > 128:
        raise ValueError(
            "A senha deve possuir no máximo 128 caracteres."
        )

    if not re.search(r"[A-Z]", senha):
        raise ValueError(
            "A senha deve possuir pelo menos uma letra maiúscula."
        )

    if not re.search(r"[a-z]", senha):
        raise ValueError(
            "A senha deve possuir pelo menos uma letra minúscula."
        )

    if not re.search(r"\d", senha):
        raise ValueError(
            "A senha deve possuir pelo menos um número."
        )

    if not re.search(r"[^A-Za-z0-9]", senha):
        raise ValueError(
            "A senha deve possuir pelo menos um caractere especial."
        )

    return senha


# ============================================================
# CONFIRMAÇÃO DA SENHA
# ============================================================

def validar_confirmacao_senha(
    senha,
    confirmacao
):

    if senha != confirmacao:
        raise ValueError(
            "A confirmação da senha não corresponde à senha."
        )

    return True