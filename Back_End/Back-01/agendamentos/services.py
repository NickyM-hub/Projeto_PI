from datetime import datetime

from .models import Agendamento

from .validators import (
    validar_id,
    validar_data_hora,
    validar_antecedencia_minima,
    validar_observacao,
    validar_status
)


class AgendamentoService:

    def __init__(self):

        self.agendamentos = []

        self.proximo_id = 1

    # ========================================================
    # CADASTRAR
    # ========================================================

    def cadastrar_agendamento(
        self,
        id_usuario,
        id_servico,
        data_hora,
        observacao=None,
        agora=None
    ):

        id_usuario = validar_id(
            id_usuario,
            "ID do usuário"
        )

        id_servico = validar_id(
            id_servico,
            "ID do serviço"
        )

        data_hora = validar_antecedencia_minima(
            data_hora,
            agora
        )

        observacao = validar_observacao(
            observacao
        )

        # ----------------------------------------------------
        # Verificar horário ocupado pelo serviço
        # ----------------------------------------------------

        for agendamento in self.agendamentos:

            mesmo_servico = (
                agendamento.id_servico == id_servico
            )

            mesmo_horario = (
                agendamento.data_hora == data_hora
            )

            ativo = agendamento.status not in {
                "CANCELADO"
            }

            if (
                mesmo_servico
                and mesmo_horario
                and ativo
            ):

                raise ValueError(
                    "Este serviço já possui um "
                    "agendamento neste horário."
                )

        # ----------------------------------------------------
        # Verificar conflito do usuário
        # ----------------------------------------------------

        for agendamento in self.agendamentos:

            mesmo_usuario = (
                agendamento.id_usuario == id_usuario
            )

            mesmo_horario = (
                agendamento.data_hora == data_hora
            )

            ativo = agendamento.status not in {
                "CANCELADO"
            }

            if (
                mesmo_usuario
                and mesmo_horario
                and ativo
            ):

                raise ValueError(
                    "O usuário já possui um "
                    "agendamento neste horário."
                )

        # ----------------------------------------------------
        # Criar
        # ----------------------------------------------------

        agendamento = Agendamento(
            id_agendamento=self.proximo_id,
            id_usuario=id_usuario,
            id_servico=id_servico,
            data_hora=data_hora,
            status="AGENDADO",
            observacao=observacao
        )

        self.agendamentos.append(
            agendamento
        )

        self.proximo_id += 1

        return agendamento

    # ========================================================
    # BUSCAR
    # ========================================================

    def buscar_por_id(self, id_agendamento):

        id_agendamento = validar_id(
            id_agendamento,
            "ID do agendamento"
        )

        for agendamento in self.agendamentos:

            if (
                agendamento.id_agendamento
                == id_agendamento
            ):
                return agendamento

        raise ValueError(
            "Agendamento não encontrado."
        )

    # ========================================================
    # LISTAR
    # ========================================================

    def listar_todos(self):

        return self.agendamentos.copy()

    # ========================================================
    # LISTAR POR USUÁRIO
    # ========================================================

    def listar_por_usuario(self, id_usuario):

        id_usuario = validar_id(
            id_usuario,
            "ID do usuário"
        )

        return [
            agendamento
            for agendamento in self.agendamentos
            if agendamento.id_usuario == id_usuario
        ]

    # ========================================================
    # LISTAR POR SERVIÇO
    # ========================================================

    def listar_por_servico(self, id_servico):

        id_servico = validar_id(
            id_servico,
            "ID do serviço"
        )

        return [
            agendamento
            for agendamento in self.agendamentos
            if agendamento.id_servico == id_servico
        ]

    # ========================================================
    # CANCELAR
    # ========================================================

    def cancelar_agendamento(
        self,
        id_agendamento
    ):

        agendamento = self.buscar_por_id(
            id_agendamento
        )

        if agendamento.status == "CANCELADO":

            raise ValueError(
                "O agendamento já está cancelado."
            )

        if agendamento.status == "CONCLUIDO":

            raise ValueError(
                "Não é possível cancelar "
                "um agendamento concluído."
            )

        agendamento.status = "CANCELADO"

        return agendamento

    # ========================================================
    # CONFIRMAR
    # ========================================================

    def confirmar_agendamento(
        self,
        id_agendamento
    ):

        agendamento = self.buscar_por_id(
            id_agendamento
        )

        if agendamento.status == "CANCELADO":

            raise ValueError(
                "Não é possível confirmar "
                "um agendamento cancelado."
            )

        if agendamento.status == "CONCLUIDO":

            raise ValueError(
                "O agendamento já foi concluído."
            )

        agendamento.status = "CONFIRMADO"

        return agendamento

    # ========================================================
    # CONCLUIR
    # ========================================================

    def concluir_agendamento(
        self,
        id_agendamento
    ):

        agendamento = self.buscar_por_id(
            id_agendamento
        )

        if agendamento.status == "CANCELADO":

            raise ValueError(
                "Não é possível concluir "
                "um agendamento cancelado."
            )

        agendamento.status = "CONCLUIDO"

        return agendamento

    # ========================================================
    # REAGENDAR
    # ========================================================

    def reagendar(
        self,
        id_agendamento,
        nova_data_hora,
        agora=None
    ):

        agendamento = self.buscar_por_id(
            id_agendamento
        )

        if agendamento.status == "CANCELADO":

            raise ValueError(
                "Não é possível reagendar "
                "um agendamento cancelado."
            )

        if agendamento.status == "CONCLUIDO":

            raise ValueError(
                "Não é possível reagendar "
                "um agendamento concluído."
            )

        nova_data_hora = validar_antecedencia_minima(
            nova_data_hora,
            agora
        )

        # ----------------------------------------------------
        # Verificar conflito
        # ----------------------------------------------------

        for outro in self.agendamentos:

            if outro.id_agendamento == (
                agendamento.id_agendamento
            ):
                continue

            if outro.status == "CANCELADO":
                continue

            mesmo_servico = (
                outro.id_servico
                == agendamento.id_servico
            )

            mesmo_horario = (
                outro.data_hora
                == nova_data_hora
            )

            if (
                mesmo_servico
                and mesmo_horario
            ):

                raise ValueError(
                    "Este serviço já possui "
                    "outro agendamento neste horário."
                )

            mesmo_usuario = (
                outro.id_usuario
                == agendamento.id_usuario
            )

            if (
                mesmo_usuario
                and mesmo_horario
            ):

                raise ValueError(
                    "O usuário já possui "
                    "outro agendamento neste horário."
                )

        agendamento.data_hora = nova_data_hora

        agendamento.status = "REAGENDADO"

        return agendamento