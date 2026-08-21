import re


def limpar_documento(documento):
    return re.sub(r"\D", "", documento)


def validar_cpf(cpf):
    cpf = limpar_documento(cpf)

    if len(cpf) != 11:
        return False

    if cpf == cpf[0] * 11:
        return False

    soma = sum(
        int(cpf[i]) * (10 - i)
        for i in range(9)
    )

    resto = (soma * 10) % 11

    if resto == 10:
        resto = 0

    if resto != int(cpf[9]):
        return False

    soma = sum(
        int(cpf[i]) * (11 - i)
        for i in range(10)
    )

    resto = (soma * 10) % 11

    if resto == 10:
        resto = 0

    return resto == int(cpf[10])


def validar_cnpj(cnpj):
    cnpj = limpar_documento(cnpj)

    if len(cnpj) != 14:
        return False

    if cnpj == cnpj[0] * 14:
        return False

    pesos_1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

    soma = sum(
        int(cnpj[i]) * pesos_1[i]
        for i in range(12)
    )

    resto = soma % 11
    digito_1 = 0 if resto < 2 else 11 - resto

    pesos_2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

    soma = sum(
        int(cnpj[i]) * pesos_2[i]
        for i in range(13)
    )

    resto = soma % 11
    digito_2 = 0 if resto < 2 else 11 - resto

    return (
        int(cnpj[12]) == digito_1
        and int(cnpj[13]) == digito_2
    )


def validar_documento(documento, tipo_documento):
    if not documento:
        raise ValueError("O documento é obrigatório.")

    documento = limpar_documento(documento)

    if tipo_documento == "CPF":
        if not validar_cpf(documento):
            raise ValueError("CPF inválido.")

    elif tipo_documento == "CNPJ":
        if not validar_cnpj(documento):
            raise ValueError("CNPJ inválido.")

    else:
        raise ValueError("Tipo de documento inválido.")

    return True