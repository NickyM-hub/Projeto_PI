from django.db import models


class Usuario(models.Model):
    TIPO_CLIENTE = 'CLIENTE'
    TIPO_EMPREENDEDOR = 'EMPREENDEDOR'

    nome = models.CharField(max_length=100)
    documento = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)
    senha = models.CharField(max_length=100)
    telefone = models.CharField(max_length=15, null=True, blank=True)
    data_nascimento = models.DateField(null=True, blank=True)

    class Meta:
        db_table = 'usuarios'
        managed = False

    def __str__(self):
        return self.nome
