from rest_framework import serializers
from .models import Pagamento


class PagamentoSerializer(serializers.ModelSerializer):

    class Meta:
        model = Pagamento
        fields = [
            "id",
            "agendamento",
            "usuario",
            "valor",
            "status",
            "codigo_transacao",
            "criado_em",
            "atualizado_em",
            "pago_em",
        ]

        read_only_fields = [
            "id",
            "usuario",
            "status",
            "codigo_transacao",
            "criado_em",
            "atualizado_em",
            "pago_em",
        ]