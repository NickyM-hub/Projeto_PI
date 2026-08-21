from django.utils import timezone

from .models import Pagamento
from .validators import validar_pagamento_pix


def criar_pagamento(agendamento, usuario, valor):
    validar_pagamento_pix(agendamento, valor)

    if Pagamento.objects.filter(agendamento=agendamento).exists():
        raise ValueError("Este agendamento já possui um pagamento.")

    pagamento = Pagamento.objects.create(
        agendamento=agendamento,
        usuario=usuario,
        valor=valor,
        status="PENDENTE"
    )

    return pagamento


def aprovar_pagamento(pagamento, codigo_transacao=None):
    pagamento.status = "APROVADO"
    pagamento.pago_em = timezone.now()

    if codigo_transacao:
        pagamento.codigo_transacao = codigo_transacao

    pagamento.save()

    return pagamento


def cancelar_pagamento(pagamento):
    pagamento.status = "CANCELADO"
    pagamento.save()

    return pagamento