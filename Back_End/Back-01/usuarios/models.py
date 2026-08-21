class Usuario:

    def __init__(
        self,
        nome,
        tipo_documento,
        documento,
        email,
        telefone,
        data_nascimento,
        senha_hash,
        endereco=None,
        numero=None,
        complemento=None,
        bairro=None,
        cidade=None,
        estado=None,
        cep=None
    ):
        self.nome = nome
        self.tipo_documento = tipo_documento
        self.documento = documento
        self.email = email
        self.telefone = telefone
        self.data_nascimento = data_nascimento
        self.senha_hash = senha_hash

        self.endereco = endereco
        self.numero = numero
        self.complemento = complemento
        self.bairro = bairro
        self.cidade = cidade
        self.estado = estado
        self.cep = cep

        # Controle da conta
        self.ativo = True

    def __str__(self):
        return self.nome