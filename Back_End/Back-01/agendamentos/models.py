from datetime import datetime


class Agendamento:

    def __init__(
        self,
        id_agendamento,
        id_usuario,
        id_servico,
        data_hora,
        status="AGENDADO",
        observacao=None
    ):
        self.id_agendamento = id_agendamento
        self.id_usuario = id_usuario
        self.id_servico = id_servico
        self.data_hora = data_hora
        self.status = status
        self.observacao = observacao

    def __str__(self):
        return (
            f"Agendamento {self.id_agendamento} - "
            f"{self.data_hora}"
        )