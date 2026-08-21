from usuarios.services import UsuarioService
from usuarios.serializers import UsuarioSerializer

service = UsuarioService()


# ============================================================
# 1. CADASTRO VÁLIDO
# ============================================================

print("\n========== TESTE 1 - CADASTRO ==========")

try:

    usuario = service.cadastrar_usuario(
        nome="João da Silva",
        tipo_documento="CPF",
        documento="529.982.247-25",
        email="joao@email.com",
        telefone="11999999999",
        data_nascimento="10/05/2000",
        senha="Senha@123",
        confirmacao_senha="Senha@123",
        endereco="Rua das Flores",
        numero="100",
        bairro="Centro",
        cidade="São Paulo",
        estado="SP",
        cep="01001-000"
    )

    print("✓ Usuário cadastrado.")
    print("Nome:", usuario.nome)
    print("CPF:", usuario.documento)
    print("E-mail:", usuario.email)
    print("Telefone:", usuario.telefone)
    print("Estado:", usuario.estado)
    print("CEP:", usuario.cep)
    print("Conta ativa:", usuario.ativo)

    # IMPORTANTE:
    # A senha original NÃO deve aparecer.
    print("Senha armazenada como hash:", bool(usuario.senha_hash))

except ValueError as erro:

    print("✗ ERRO:", erro)


# ============================================================
# 2. CPF INVÁLIDO
# ============================================================

print("\n========== TESTE 2 - CPF INVÁLIDO ==========")

try:

    service.cadastrar_usuario(
        nome="Maria Silva",
        tipo_documento="CPF",
        documento="123.456.789-00",
        email="maria@email.com",
        telefone="11988888888",
        data_nascimento="15/03/1999",
        senha="Senha@123",
        confirmacao_senha="Senha@123"
    )

    print("✗ ERRO: CPF inválido foi aceito.")

except ValueError as erro:

    print("✓ CPF inválido rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 3. CPF DUPLICADO
# ============================================================

print("\n========== TESTE 3 - CPF DUPLICADO ==========")

try:

    service.cadastrar_usuario(
        nome="Outro João",
        tipo_documento="CPF",
        documento="529.982.247-25",
        email="outro@email.com",
        telefone="11988888888",
        data_nascimento="20/01/1998",
        senha="Senha@456",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: CPF duplicado foi aceito.")

except ValueError as erro:

    print("✓ CPF duplicado rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 4. E-MAIL DUPLICADO
# ============================================================

print("\n========== TESTE 4 - E-MAIL DUPLICADO ==========")

try:

    service.cadastrar_usuario(
        nome="Carlos Silva",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="joao@email.com",
        telefone="11977777777",
        data_nascimento="10/08/1995",
        senha="Senha@456",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: E-mail duplicado foi aceito.")

except ValueError as erro:

    print("✓ E-mail duplicado rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 5. NOME COM NÚMERO
# ============================================================

print("\n========== TESTE 5 - NOME INVÁLIDO ==========")

try:

    service.cadastrar_usuario(
        nome="João123",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="joao123@email.com",
        telefone="11966666666",
        data_nascimento="10/08/1995",
        senha="Senha@456",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: Nome inválido foi aceito.")

except ValueError as erro:

    print("✓ Nome inválido rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 6. TELEFONE INVÁLIDO
# ============================================================

print("\n========== TESTE 6 - TELEFONE INVÁLIDO ==========")

try:

    service.cadastrar_usuario(
        nome="Pedro Silva",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="pedro@email.com",
        telefone="123",
        data_nascimento="10/08/1995",
        senha="Senha@456",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: Telefone inválido foi aceito.")

except ValueError as erro:

    print("✓ Telefone inválido rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 7. CEP INVÁLIDO
# ============================================================

print("\n========== TESTE 7 - CEP INVÁLIDO ==========")

try:

    service.cadastrar_usuario(
        nome="Ana Silva",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="ana@email.com",
        telefone="11944444444",
        data_nascimento="10/08/1995",
        senha="Senha@456",
        confirmacao_senha="Senha@456",
        cep="ABC123"
    )

    print("✗ ERRO: CEP inválido foi aceito.")

except ValueError as erro:

    print("✓ CEP inválido rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 8. MENOR DE IDADE
# ============================================================

print("\n========== TESTE 8 - MENOR DE IDADE ==========")

try:

    service.cadastrar_usuario(
        nome="Lucas Silva",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="lucas@email.com",
        telefone="11933333333",
        data_nascimento="10/08/2010",
        senha="Senha@456",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: Menor de idade foi aceito.")

except ValueError as erro:

    print("✓ Menor de idade rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 9. SENHA FRACA
# ============================================================

print("\n========== TESTE 9 - SENHA FRACA ==========")

try:

    service.cadastrar_usuario(
        nome="Carlos Souza",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="carlos@email.com",
        telefone="11922222222",
        data_nascimento="10/08/1995",
        senha="12345678",
        confirmacao_senha="12345678"
    )

    print("✗ ERRO: Senha fraca foi aceita.")

except ValueError as erro:

    print("✓ Senha fraca rejeitada.")
    print("Mensagem:", erro)


# ============================================================
# 10. CONFIRMAÇÃO DE SENHA INCORRETA
# ============================================================

print("\n========== TESTE 10 - CONFIRMAÇÃO ==========")

try:

    service.cadastrar_usuario(
        nome="Carlos Souza",
        tipo_documento="CPF",
        documento="111.444.777-35",
        email="carlos2@email.com",
        telefone="11922222222",
        data_nascimento="10/08/1995",
        senha="Senha@123",
        confirmacao_senha="Senha@456"
    )

    print("✗ ERRO: Confirmação incorreta foi aceita.")

except ValueError as erro:

    print("✓ Confirmação incorreta rejeitada.")
    print("Mensagem:", erro)


# ============================================================
# 11. LOGIN CORRETO
# ============================================================

print("\n========== TESTE 11 - LOGIN ==========")

try:

    usuario_logado = service.autenticar(
        "joao@email.com",
        "Senha@123"
    )

    print("✓ Login realizado.")
    print("Usuário:", usuario_logado.nome)

except ValueError as erro:

    print("✗ ERRO:", erro)


# ============================================================
# 12. LOGIN COM SENHA ERRADA
# ============================================================

print("\n========== TESTE 12 - LOGIN INCORRETO ==========")

try:

    service.autenticar(
        "joao@email.com",
        "SenhaErrada@123"
    )

    print("✗ ERRO: Login com senha errada foi aceito.")

except ValueError as erro:

    print("✓ Login incorreto rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 13. TROCA DE SENHA
# ============================================================

print("\n========== TESTE 13 - TROCA DE SENHA ==========")

try:

    service.trocar_senha(
        usuario,
        "Senha@123",
        "NovaSenha@456",
        "NovaSenha@456"
    )

    print("✓ Senha alterada.")

except ValueError as erro:

    print("✗ ERRO:", erro)


# ============================================================
# 14. LOGIN COM NOVA SENHA
# ============================================================

print("\n========== TESTE 14 - NOVA SENHA ==========")

try:

    service.autenticar(
        "joao@email.com",
        "NovaSenha@456"
    )

    print("✓ Login com nova senha realizado.")

except ValueError as erro:

    print("✗ ERRO:", erro)


# ============================================================
# 15. INATIVAR USUÁRIO
# ============================================================

print("\n========== TESTE 15 - INATIVAR ==========")

try:

    service.inativar_usuario(usuario)

    print("✓ Usuário inativado.")
    print("Ativo:", usuario.ativo)

except ValueError as erro:

    print("✗ ERRO:", erro)


# ============================================================
# 16. LOGIN DE USUÁRIO INATIVO
# ============================================================

print("\n========== TESTE 16 - LOGIN INATIVO ==========")

try:

    service.autenticar(
        "joao@email.com",
        "NovaSenha@456"
    )

    print("✗ ERRO: Usuário inativo conseguiu entrar.")

except ValueError as erro:

    print("✓ Login de usuário inativo rejeitado.")
    print("Mensagem:", erro)


# ============================================================
# 17. REATIVAR
# ============================================================

print("\n========== TESTE 17 - REATIVAR ==========")

try:

    service.reativar_usuario(usuario)

    print("✓ Usuário reativado.")
    print("Ativo:", usuario.ativo)

except ValueError as erro:

    print("✗ ERRO:", erro)



print("\n========== TESTE 18 - SERIALIZER ==========")

try:

    dados_usuario = UsuarioSerializer.to_dict(
        usuario
    )

    print("✓ Usuário convertido com sucesso.")

    print("Dados retornados:")

    for chave, valor in dados_usuario.items():

        print(f"{chave}: {valor}")

    if "senha_hash" in dados_usuario:

        print("✗ ERRO: senha apareceu na resposta.")

    else:

        print("✓ Senha não foi exposta.")

except Exception as erro:

    print("✗ ERRO:", erro)