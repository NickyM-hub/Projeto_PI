from .models import Agendamento


class AgendamentoSerializer:

    @staticmethod
    def to_dict(agendamento):

        if not isinstance(
            agendamento,
            Agendamento
        ):
            raise TypeError(
                "O objeto informado não é "
                "um agendamento válido."
            )

        return {
            "id_agendamento":
                agendamento.id_agendamento,

            "id_usuario":
                agendamento.id_usuario,

            "id_servico":
                agendamento.id_servico,

            "data_hora":
                agendamento.data_hora.isoformat(),

            "status":
                agendamento.status,

            "observacao":
                agendamento.observacao
        }

    @staticmethod
    def many(agendamentos):

        if not isinstance(
            agendamentos,
            list
        ):
            raise TypeError(
                "Era esperada uma lista "
                "de agendamentos."
            )

        return [
            AgendamentoSerializer.to_dict(
                agendamento
            )
            for agendamento in agendamentos
        ]