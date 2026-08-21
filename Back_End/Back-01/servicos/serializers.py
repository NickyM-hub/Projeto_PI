from .models import Servico


class ServicoSerializer:

    @staticmethod
    def to_dict(servico):

        if not isinstance(servico, Servico):
            raise TypeError(
                "O objeto informado não é um serviço válido."
            )

        return {
            "id_servico": servico.id_servico,
            "id_usuario": servico.id_usuario,
            "nome": servico.nome,
            "descricao": servico.descricao,
            "preco": str(servico.preco),
            "duracao_minutos": servico.duracao_minutos,
            "ativo": servico.ativo
        }

    @staticmethod
    def many(servicos):

        if not isinstance(servicos, list):
            raise TypeError(
                "Era esperada uma lista de serviços."
            )

        return [
            ServicoSerializer.to_dict(servico)
            for servico in servicos
        ]