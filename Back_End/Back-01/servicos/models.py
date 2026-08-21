class Servico:

    def __init__(
        self,
        id_servico,
        id_usuario,
        nome,
        descricao,
        preco,
        duracao_minutos,
        ativo=True
    ):
        self.id_servico = id_servico
        self.id_usuario = id_usuario
        self.nome = nome
        self.descricao = descricao
        self.preco = preco
        self.duracao_minutos = duracao_minutos
        self.ativo = ativo

    def __str__(self):
        return self.nome