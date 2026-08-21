from .models import Usuario

from .validators import (
    validar_nome,
    validar_documento,
    validar_email,
    validar_telefone,
    validar_cep,
    validar_estado,
    validar_data_nascimento,
    validar_maioridade,
    validar_senha,
    validar_confirmacao_senha
)

from .security import (
    criar_hash_senha,
    verificar_senha
)


class UsuarioService:

    def __init__(self):

        # Temporário.
        # Depois será substituído pelo banco de dados.
        self.usuarios = []


    # ========================================================
    # CADASTRAR USUÁRIO
    # ========================================================

    def cadastrar_usuario(
        self,
        nome,
        tipo_documento,
        documento,
        email,
        telefone,
        data_nascimento,
        senha,
        confirmacao_senha,
        endereco=None,
        numero=None,
        complemento=None,
        bairro=None,
        cidade=None,
        estado=None,
        cep=None
    ):

        # ----------------------------------------------------
        # VALIDAR DADOS
        # ----------------------------------------------------

        nome = validar_nome(nome)

        tipo_documento = (
            tipo_documento.strip().upper()
        )

        documento = validar_documento(
            tipo_documento,
            documento
        )

        email = validar_email(email)

        telefone = validar_telefone(telefone)

        data_nascimento = validar_data_nascimento(
            data_nascimento
        )

        validar_maioridade(
            data_nascimento
        )

        validar_senha(senha)

        validar_confirmacao_senha(
            senha,
            confirmacao_senha
        )

        # ----------------------------------------------------
        # CAMPOS OPCIONAIS
        # ----------------------------------------------------

        if estado is not None:

            estado = validar_estado(estado)

        if cep is not None:

            cep = validar_cep(cep)

        # ----------------------------------------------------
        # VERIFICAR DOCUMENTO DUPLICADO
        # ----------------------------------------------------

        if self.buscar_por_documento(documento):

            raise ValueError(
                "Já existe um usuário cadastrado "
                "com este CPF/CNPJ."
            )

        # ----------------------------------------------------
        # VERIFICAR E-MAIL DUPLICADO
        # ----------------------------------------------------

        if self.buscar_por_email(email):

            raise ValueError(
                "Já existe um usuário cadastrado "
                "com este e-mail."
            )

        # ----------------------------------------------------
        # GERAR HASH DA SENHA
        # ----------------------------------------------------

        senha_hash = criar_hash_senha(
            senha
        )

        # ----------------------------------------------------
        # CRIAR USUÁRIO
        # ----------------------------------------------------

        usuario = Usuario(
            nome=nome,
            tipo_documento=tipo_documento,
            documento=documento,
            email=email,
            telefone=telefone,
            data_nascimento=data_nascimento,
            senha_hash=senha_hash,
            endereco=endereco,
            numero=numero,
            complemento=complemento,
            bairro=bairro,
            cidade=cidade,
            estado=estado,
            cep=cep
        )

        self.usuarios.append(usuario)

        return usuario


    # ========================================================
    # BUSCAR POR DOCUMENTO
    # ========================================================

    def buscar_por_documento(self, documento):

        documento = "".join(
            numero
            for numero in str(documento)
            if numero.isdigit()
        )

        for usuario in self.usuarios:

            if usuario.documento == documento:

                return usuario

        return None


    # ========================================================
    # BUSCAR POR E-MAIL
    # ========================================================

    def buscar_por_email(self, email):

        email = email.strip().lower()

        for usuario in self.usuarios:

            if usuario.email == email:

                return usuario

        return None


    # ========================================================
    # LISTAR USUÁRIOS
    # ========================================================

    def listar_usuarios(self):

        return list(self.usuarios)


    # ========================================================
    # AUTENTICAR / LOGIN
    # ========================================================

    def autenticar(
        self,
        email,
        senha
    ):

        email = validar_email(email)

        usuario = self.buscar_por_email(
            email
        )

        # Não informar se o e-mail existe ou não.
        # Isso evita facilitar enumeração de contas.
        if usuario is None:

            raise ValueError(
                "E-mail ou senha incorretos."
            )

        if not usuario.ativo:

            raise ValueError(
                "E-mail ou senha incorretos."
            )

        senha_correta = verificar_senha(
            senha,
            usuario.senha_hash
        )

        if not senha_correta:

            raise ValueError(
                "E-mail ou senha incorretos."
            )

        return usuario


    # ========================================================
    # TROCAR SENHA
    # ========================================================

    def trocar_senha(
        self,
        usuario,
        senha_atual,
        nova_senha,
        confirmacao_senha
    ):

        if usuario is None:

            raise ValueError(
                "Usuário não encontrado."
            )

        if not usuario.ativo:

            raise ValueError(
                "Usuário está inativo."
            )

        # ----------------------------------------------------
        # VERIFICAR SENHA ATUAL
        # ----------------------------------------------------

        if not verificar_senha(
            senha_atual,
            usuario.senha_hash
        ):

            raise ValueError(
                "A senha atual está incorreta."
            )

        # ----------------------------------------------------
        # NÃO PERMITIR MESMA SENHA
        # ----------------------------------------------------

        if verificar_senha(
            nova_senha,
            usuario.senha_hash
        ):

            raise ValueError(
                "A nova senha deve ser diferente "
                "da senha atual."
            )

        # ----------------------------------------------------
        # VALIDAR NOVA SENHA
        # ----------------------------------------------------

        validar_senha(
            nova_senha
        )

        validar_confirmacao_senha(
            nova_senha,
            confirmacao_senha
        )

        # ----------------------------------------------------
        # GERAR NOVO HASH
        # ----------------------------------------------------

        usuario.senha_hash = criar_hash_senha(
            nova_senha
        )

        return True


    # ========================================================
    # INATIVAR USUÁRIO
    # ========================================================

    def inativar_usuario(self, usuario):

        if usuario is None:

            raise ValueError(
                "Usuário não encontrado."
            )

        if not usuario.ativo:

            raise ValueError(
                "O usuário já está inativo."
            )

        usuario.ativo = False

        return True


    # ========================================================
    # REATIVAR USUÁRIO
    # ========================================================

    def reativar_usuario(self, usuario):

        if usuario is None:

            raise ValueError(
                "Usuário não encontrado."
            )

        if usuario.ativo:

            raise ValueError(
                "O usuário já está ativo."
            )

        usuario.ativo = True

        return True