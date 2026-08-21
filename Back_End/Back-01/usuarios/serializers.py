from .models import Usuario


class UsuarioSerializer:

    # ========================================================
    # CONVERTER USUÁRIO PARA DICIONÁRIO
    # ========================================================

    @staticmethod
    def to_dict(usuario):

        if not isinstance(usuario, Usuario):
            raise TypeError(
                "O objeto informado não é um usuário válido."
            )

        return {
            "nome": usuario.nome,
            "tipo_documento": usuario.tipo_documento,
            "documento": usuario.documento,
            "email": usuario.email,
            "telefone": usuario.telefone,
            "data_nascimento": (
                usuario.data_nascimento.isoformat()
                if usuario.data_nascimento
                else None
            ),
            "endereco": usuario.endereco,
            "numero": usuario.numero,
            "complemento": usuario.complemento,
            "bairro": usuario.bairro,
            "cidade": usuario.cidade,
            "estado": usuario.estado,
            "cep": usuario.cep,
            "ativo": usuario.ativo
        }


    # ========================================================
    # CONVERTER VÁRIOS USUÁRIOS
    # ========================================================

    @staticmethod
    def many(usuarios):

        if not isinstance(usuarios, list):
            raise TypeError(
                "Era esperada uma lista de usuários."
            )

        return [
            UsuarioSerializer.to_dict(usuario)
            for usuario in usuarios
        ]