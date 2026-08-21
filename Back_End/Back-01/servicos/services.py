from decimal import Decimal

from .models import Servico
from .validators import (
    validar_nome_servico,
    validar_descricao,
    validar_preco,
    validar_duracao,
    validar_id_usuario
)


class ServicoService:

    def __init__(self):
        self.servicos = []
        self.proximo_id = 1

    # ========================================================
    # CADASTRAR SERVIÇO
    # ========================================================

    def cadastrar_servico(
        self,
        id_usuario,
        nome,
        descricao,
        preco,
        duracao_minutos
    ):

        id_usuario = validar_id_usuario(id_usuario)
        nome = validar_nome_servico(nome)
        descricao = validar_descricao(descricao)
        preco = validar_preco(preco)
        duracao_minutos = validar_duracao(duracao_minutos)

        # ----------------------------------------------------
        # Verifica serviço duplicado
        # ----------------------------------------------------

        for servico in self.servicos:

            mesmo_usuario = (
                servico.id_usuario == id_usuario
            )

            mesmo_nome = (
                servico.nome.lower() == nome.lower()
            )

            if mesmo_usuario and mesmo_nome:

                raise ValueError(
                    "Este usuário já possui um serviço "
                    "cadastrado com este nome."
                )

        # ----------------------------------------------------
        # Criação
        # ----------------------------------------------------

        servico = Servico(
            id_servico=self.proximo_id,
            id_usuario=id_usuario,
            nome=nome,
            descricao=descricao,
            preco=preco,
            duracao_minutos=duracao_minutos,
            ativo=True
        )

        self.servicos.append(servico)

        self.proximo_id += 1

        return servico

    # ========================================================
    # BUSCAR SERVIÇO
    # ========================================================

    def buscar_por_id(self, id_servico):

        if isinstance(id_servico, bool):

            raise ValueError(
                "O ID do serviço deve ser um número inteiro."
            )

        try:
            id_servico = int(id_servico)

        except (ValueError, TypeError):

            raise ValueError(
                "O ID do serviço deve ser um número inteiro."
            )

        if id_servico <= 0:

            raise ValueError(
                "O ID do serviço deve ser maior que zero."
            )

        for servico in self.servicos:

            if servico.id_servico == id_servico:

                return servico

        raise ValueError(
            "Serviço não encontrado."
        )

    # ========================================================
    # LISTAR TODOS
    # ========================================================

    def listar_todos(self):

        return self.servicos.copy()

    # ========================================================
    # LISTAR SERVIÇOS DE UM USUÁRIO
    # ========================================================

    def listar_por_usuario(self, id_usuario):

        id_usuario = validar_id_usuario(id_usuario)

        return [
            servico
            for servico in self.servicos
            if servico.id_usuario == id_usuario
        ]

    # ========================================================
    # ALTERAR SERVIÇO
    # ========================================================

    def alterar_servico(
        self,
        id_servico,
        nome=None,
        descricao=None,
        preco=None,
        duracao_minutos=None
    ):

        servico = self.buscar_por_id(id_servico)

        # ----------------------------------------------------
        # Nome
        # ----------------------------------------------------

        if nome is not None:

            nome = validar_nome_servico(nome)

            for outro in self.servicos:

                if outro.id_servico == servico.id_servico:
                    continue

                if outro.id_usuario != servico.id_usuario:
                    continue

                if outro.nome.lower() == nome.lower():

                    raise ValueError(
                        "Este usuário já possui outro serviço "
                        "com este nome."
                    )

            servico.nome = nome

        # ----------------------------------------------------
        # Descrição
        # ----------------------------------------------------

        if descricao is not None:

            servico.descricao = validar_descricao(
                descricao
            )

        # ----------------------------------------------------
        # Preço
        # ----------------------------------------------------

        if preco is not None:

            servico.preco = validar_preco(
                preco
            )

        # ----------------------------------------------------
        # Duração
        # ----------------------------------------------------

        if duracao_minutos is not None:

            servico.duracao_minutos = validar_duracao(
                duracao_minutos
            )

        return servico

    # ========================================================
    # INATIVAR
    # ========================================================

    def inativar_servico(self, id_servico):

        servico = self.buscar_por_id(id_servico)

        if not servico.ativo:

            raise ValueError(
                "O serviço já está inativo."
            )

        servico.ativo = False

        return servico

    # ========================================================
    # REATIVAR
    # ========================================================

    def reativar_servico(self, id_servico):

        servico = self.buscar_por_id(id_servico)

        if servico.ativo:

            raise ValueError(
                "O serviço já está ativo."
            )

        servico.ativo = True

        return servico

    # ========================================================
    # REMOVER
    # ========================================================

    def remover_servico(self, id_servico):

        servico = self.buscar_por_id(id_servico)

        self.servicos.remove(servico)

        return True