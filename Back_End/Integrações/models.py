from django.db import models
from Usuarios.models import Usuario

class Endereco(models.Model):
    TIPO_RESIDENCIAL = 'RESIDENCIAL'
    TIPO_COMERCIAL = 'COMERCIAL'
    TIPO_ATENDIMENTO = 'ATENDIMENTO'

    TIPO_ENDERECO_CHOICES = [
        (TIPO_RESIDENCIAL, 'Residencial'),
        (TIPO_COMERCIAL, 'Comercial'),
        (TIPO_ATENDIMENTO, 'Atendimento'),
    ]

    usuario = models.ForeignKey(
        Usuario,
        on_delete=models.CASCADE,
        db_column='usuario_id',
        related_name='enderecos',
    )
    tipo_endereco = models.CharField(
        max_length=20,
        choices=TIPO_ENDERECO_CHOICES,
    )
    cep = models.CharField(max_length=8)
    logradouro = models.CharField(max_length=150)
    numero = models.CharField(max_length=10)
    complemento = models.CharField(max_length=50, null=True, blank=True)
    bairro = models.CharField(max_length=80)
    cidade = models.CharField(max_length=80)
    estado = models.CharField(max_length=2)
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    principal = models.BooleanField(default=False)
    criado_em = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'enderecos'
        managed = False 
        constraints = [
            models.UniqueConstraint(
                fields=['usuario', 'tipo_endereco'],
                name='UQ_Endereco_Principal',
            )
        ]

    def __str__(self):
        return f'{self.tipo_endereco} - {self.logradouro}, {self.numero}'