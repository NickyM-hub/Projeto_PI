from django.db import models
from django.conf import settings
from agendamentos.models import Agendamento


class Pagamento(models.Model):

    STATUS_CHOICES = [
        ("PENDENTE", "Pendente"),
        ("APROVADO", "Aprovado"),
        ("RECUSADO", "Recusado"),
        ("CANCELADO", "Cancelado"),
        ("ESTORNADO", "Estornado"),
    ]

    id = models.BigAutoField(primary_key=True)

    agendamento = models.OneToOneField(
        Agendamento,
        on_delete=models.CASCADE,
        related_name="pagamento"
    )

    usuario = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="pagamentos"
    )

    valor = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="PENDENTE"
    )

    codigo_transacao = models.CharField(
        max_length=255,
        unique=True,
        null=True,
        blank=True
    )

    criado_em = models.DateTimeField(auto_now_add=True)

    atualizado_em = models.DateTimeField(auto_now=True)

    pago_em = models.DateTimeField(
        null=True,
        blank=True
    )

    class Meta:
        db_table = "pagamentos"
        ordering = ["-criado_em"]

    def __str__(self):
        return f"Pagamento #{self.id} - {self.status}"