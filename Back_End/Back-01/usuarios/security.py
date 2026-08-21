from argon2 import PasswordHasher
from argon2.exceptions import (
    VerifyMismatchError,
    VerificationError,
    InvalidHashError
)


_password_hasher = PasswordHasher()


def criar_hash_senha(senha):
    """
    Recebe a senha original e retorna somente o hash.
    """

    return _password_hasher.hash(senha)


def verificar_senha(senha, senha_hash):
    """
    Verifica se a senha informada corresponde ao hash.
    """

    try:

        return _password_hasher.verify(
            senha_hash,
            senha
        )

    except (
        VerifyMismatchError,
        VerificationError,
        InvalidHashError
    ):

        return False