CREATE DATABASE PROJETO_PI
USE PROJETO_PI


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- TABELAS

CREATE TABLE Usuario (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    nome VARCHAR(150) NOT NULL,

    documento VARCHAR(14) NOT NULL UNIQUE,

    email VARCHAR(100) NOT NULL UNIQUE,

    senha VARCHAR(255) NOT NULL,

    telefone VARCHAR(15) NOT NULL,

    data_nascimento DATE NOT NULL,

    tipo_usuario VARCHAR(20) NOT NULL
        CHECK (tipo_usuario IN ('CLIENTE', 'EMPREENDEDOR')),

    latitude DECIMAL(10,8) NULL,

    longitude DECIMAL(11,8) NULL,

    criado_em DATETIME2 NOT NULL
        CONSTRAINT DF_Usuario_CriadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Usuario_MaiorIdade
        CHECK (
            data_nascimento <= DATEADD(YEAR, -18, CAST(GETDATE() AS DATE))
        )
);

CREATE TABLE Servicos (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    empreendedor_id BIGINT NOT NULL,

    nome_servico VARCHAR(100) NOT NULL,

    descricao VARCHAR(MAX) NULL,

    preco DECIMAL(10,2) NOT NULL
        CHECK (preco >= 0),

    duracao_estimada TIME NOT NULL,

    cobra_taxa_reserva BIT NOT NULL
        CONSTRAINT DF_Servicos_CobraTaxaReserva DEFAULT 0,

    valor_taxa_reserva DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_Servicos_ValorTaxaReserva DEFAULT 0.00
        CHECK (valor_taxa_reserva >= 0),

    CONSTRAINT FK_Servicos_Usuario
        FOREIGN KEY (empreendedor_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Portfolio_Fotos (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    empreendedor_id BIGINT NOT NULL,

    url_foto VARCHAR(255) NOT NULL,

    enviado_em DATETIME2 NOT NULL
        CONSTRAINT DF_PortfolioFotos_EnviadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT FK_PortfolioFotos_Usuario
        FOREIGN KEY (empreendedor_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Agendamentos (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    cliente_id BIGINT NOT NULL,

    empreendedor_id BIGINT NOT NULL,

    servico_id BIGINT NOT NULL,

    data_hora_inicio DATETIME2 NOT NULL,

    data_hora_fim DATETIME2 NOT NULL,

    status VARCHAR(20) NOT NULL
        CHECK (status IN ('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO')),

    recorrente BIT NOT NULL
        CONSTRAINT DF_Agendamentos_Recorrente DEFAULT 0,

    qtd_alteracoes_cliente INT NOT NULL
        CONSTRAINT DF_Agendamentos_QtdAltCliente DEFAULT 0
        CHECK (qtd_alteracoes_cliente <= 3),

    qtd_alteracoes_emp INT NOT NULL
        CONSTRAINT DF_Agendamentos_QtdAltEmp DEFAULT 0
        CHECK (qtd_alteracoes_emp <= 3),

    termo_sem_pagamento BIT NOT NULL
        CONSTRAINT DF_Agendamentos_TermoSemPagamento DEFAULT 0,

    criado_em DATETIME2 NOT NULL
        CONSTRAINT DF_Agendamentos_CriadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Agendamentos_Cliente
        FOREIGN KEY (cliente_id)
        REFERENCES Usuario(id),

    CONSTRAINT FK_Agendamentos_Empreendedor
        FOREIGN KEY (empreendedor_id)
        REFERENCES Usuario(id),

    CONSTRAINT FK_Agendamentos_Servico
        FOREIGN KEY (servico_id)
        REFERENCES Servicos(id),

    CONSTRAINT CK_Agendamentos_Datas
        CHECK (data_hora_fim > data_hora_inicio)
);

CREATE TABLE Bloqueios_Clientes (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    cliente_id BIGINT NOT NULL,

    data_inicio DATETIME2 NOT NULL
        CONSTRAINT DF_BloqueiosClientes_DataInicio DEFAULT SYSDATETIME(),

    data_fim AS DATEADD(DAY, 20, data_inicio) PERSISTED,

    ativo BIT NOT NULL
        CONSTRAINT DF_BloqueiosClientes_Ativo DEFAULT 1,

    CONSTRAINT FK_BloqueiosClientes_Usuario
        FOREIGN KEY (cliente_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Pagamentos (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    agendamento_id BIGINT NOT NULL,

    gateway_transacao_id VARCHAR(100) NOT NULL UNIQUE,

    metodo_pagamento VARCHAR(20) NOT NULL
        CHECK (metodo_pagamento IN ('PIX', 'CARTAO', 'BOLETO')),

    status_pagamento VARCHAR(30) NOT NULL
        CHECK (status_pagamento IN ('PENDENTE', 'CONFIRMADO', 'ESTORNADO', 'ESTORNADO_DOBRO')),

    valor_pago DECIMAL(10,2) NOT NULL
        CHECK (valor_pago >= 0),

    nota_fiscal_emitida BIT NOT NULL
        CONSTRAINT DF_Pagamentos_NotaFiscal DEFAULT 0,

    atualizado_em DATETIME2 NOT NULL
        CONSTRAINT DF_Pagamentos_AtualizadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Pagamentos_Agendamentos
        FOREIGN KEY (agendamento_id)
        REFERENCES Agendamentos(id)
);

CREATE TABLE Cupons (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    codigo VARCHAR(20) NOT NULL UNIQUE,

    tipo_desconto VARCHAR(20) NOT NULL
        CHECK (tipo_desconto IN ('PORCENTAGEM', 'VALOR_FIXO')),

    valor DECIMAL(10,2) NOT NULL
        CHECK (valor > 0),

    data_validade DATE NOT NULL
);

CREATE TABLE Mensagens_Chat (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    agendamento_id BIGINT NOT NULL,

    remetente_id BIGINT NOT NULL,

    conteudo_mensagem VARCHAR(MAX) NOT NULL,

    enviado_em DATETIME2 NOT NULL
        CONSTRAINT DF_MensagensChat_EnviadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT FK_MensagensChat_Agendamentos
        FOREIGN KEY (agendamento_id)
        REFERENCES Agendamentos(id),

    CONSTRAINT FK_MensagensChat_Usuario
        FOREIGN KEY (remetente_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Avaliacoes (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    agendamento_id BIGINT NOT NULL UNIQUE,

    cliente_id BIGINT NOT NULL,

    empreendedor_id BIGINT NOT NULL,

    nota INT NOT NULL
        CHECK (nota BETWEEN 1 AND 5),

    comentario VARCHAR(MAX) NULL,

    penalidade_sistema BIT NOT NULL
        CONSTRAINT DF_Avaliacoes_Penalidade DEFAULT 0,

    criado_em DATETIME2 NOT NULL
        CONSTRAINT DF_Avaliacoes_CriadoEm DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Avaliacoes_Agendamentos
        FOREIGN KEY (agendamento_id)
        REFERENCES Agendamentos(id),

    CONSTRAINT FK_Avaliacoes_Cliente
        FOREIGN KEY (cliente_id)
        REFERENCES Usuario(id),

    CONSTRAINT FK_Avaliacoes_Empreendedor
        FOREIGN KEY (empreendedor_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Fidelidade (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    cliente_id BIGINT NOT NULL UNIQUE,

    pontos INT DEFAULT 0,

    FOREIGN KEY (cliente_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Tickets_Suporte (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,

    usuario_id BIGINT NOT NULL,

    assunto VARCHAR(200) NOT NULL,

    descricao VARCHAR(MAX) NOT NULL,

    status VARCHAR(20) NOT NULL
        CONSTRAINT DF_TicketsSuporte_Status DEFAULT 'ABERTO'
        CHECK (
            status IN (
                'ABERTO',
                'EM_ANDAMENTO',
                'FECHADO'
            )
        ),

    criado_em DATETIME2 DEFAULT SYSDATETIME(),

    FOREIGN KEY (usuario_id)
        REFERENCES Usuario(id)
);

CREATE TABLE Categoria_Servicos(
id BIGINT IDENTITY PRIMARY KEY,
nome VARCHAR(80) NOT NULL,
descricao VARCHAR(255),
icone_url VARCHAR(255),
ativo BIT NOT NULL DEFAULT 1,
criado_em DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE Servicos_Categorias(
servico_id BIGINT NOT NULL,
categoria_id BIGINT NOT NULL,
PRIMARY KEY(servico_id, categoria_id),
CONSTRAINT FK_ServicosCategorias_Servico
FOREIGN KEY (servico_id) REFERENCES servicos(id) ON DELETE CASCADE,
CONSTRAINT FK_ServicosCategorias_Categoria
FOREIGN KEY (categoria_id) REFERENCES Categoria_Servicos(id)
);

CREATE TABLE enderecos(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
usuario_id BIGINT NOT NULL,
tipo_endereco VARCHAR(20) NOT NULL
  CHECK(tipo_endereco IN ('RESIDENCIAL', 'COMERCIAL', 'ATENDIMENTO')),
cep VARCHAR(8) NOT NULL,
logradouro VARCHAR(150) NOT NULL,
numero VARCHAR(10) NOT NULL,
complemento VARCHAR(50) NULL,
bairro VARCHAR(80) NOT NULL,
cidade VARCHAR(80) NOT NULL,
estado CHAR(2) NOT NULL,
latitude DECIMAL(10,8) NULL,
longitude DECIMAL(11,8) NULL,
principal BIT NOT NULL DEFAULT 0,
criado_em DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
CONSTRAINT FK_Endereco_Usuario
  FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,

  CONSTRAINT UQ_Endereco_Principal UNIQUE (usuario_id, tipo_endereco)

);

CREATE TABLE Disponibilidades(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
empreendedor_id BIGINT NOT NULL,
dia_semana INT NOT NULL CHECK(dia_semana BETWEEN 0 AND 6),
hora_inicio TIME NOT NULL,
hora_fim TIME NOT NULL,
ativo BIT NOT NULL DEFAULT 1,
CONSTRAINT FK_Disponibilidade_Usuario
FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE,
CONSTRAINT CK_Horario_valido CHECK (hora_fim > hora_inicio)
);

CREATE TABLE Cupons_uso(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
cupom_id BIGINT NOT NULL,
agendamento_id BIGINT NOT NULL,
usuario_id BIGINT NOT NULL,
valor_desconto DECIMAL(10,2) NOT NULL,
usado_em DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
CONSTRAINT FK_CuponsUso
FOREIGN KEY (cupom_id) REFERENCES Cupons(id),
CONSTRAINT FK_CuponsUso_Agendamento
FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id),
CONSTRAINT FK_CuponsUso_Usuario
FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);

CREATE TABLE Notificacoes(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
usuario_id BIGINT NOT NULL,
tipo VARCHAR(50) NOT NULL,
mensagem VARCHAR(MAX) NOT NULL,
lida BIT NOT NULL DEFAULT 0,
data_envio DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
CONSTRAINT FK_Notificacoes_Usuario
FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);

CREATE TABLE Favoritos(
cliente_id BIGINT NOT NULL,
empreendedor_id BIGINT NOT NULL,
criado_em DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
PRIMARY KEY (cliente_id, empreendedor_id),
CONSTRAINT FK_Favoritos_Cliente
FOREIGN KEY(cliente_id) REFERENCES Usuario(id),
CONSTRAINT FK_Favoritos_Empreendedor
FOREIGN KEY(empreendedor_id) REFERENCES Usuario(id)
);

CREATE TABLE Historico_Agendamentos(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
agendamento_id BIGINT NOT NULL,
usuario_alterou_id BIGINT NOT NULL,
tipo_alteracao VARCHAR(50) NOT NULL,
data_alteracao DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
CONSTRAINT FK_Historico_Agendamento
FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id),
CONSTRAINT FK_Historico_Usuario
FOREIGN KEY (usuario_alterou_id) REFERENCES Usuario(id)
);

CREATE TABLE Repasses(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
empreendedor_id BIGINT NOT NULL,
agendamento_id BIGINT NOT NULL,
valor DECIMAL(10,2) NOT NULL CHECK(valor > 0),
taxa_plataforma DECIMAL(10,2) NOT NULL CHECK(taxa_plataforma > 0),
valor_liquido DECIMAL(10,2) NOT NULL,
status VARCHAR(20) NOT NULL
  CONSTRAINT CK_Repasse_Status CHECK(status IN ('PENDENTE', 'PROCESSANDO', 'REALIZADO', 'FALHA')),
data_solicitacao DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
data_pagamento DATETIME2 NULL,
CONSTRAINT FK_Repasse_Usuario
FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id),
CONSTRAINT FK_Repasse_Agendamento
FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id)
);

CREATE TABLE Repasses_Itens(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
repasse_id BIGINT NOT NULL,
empreendedor_id BIGINT NOT NULL,
agendamento_id BIGINT NOT NULL,
valor DECIMAL(10,2) NOT NULL CHECK(valor > 0),
CONSTRAINT FK_RepasseItens_Repasse FOREIGN KEY (repasse_id) REFERENCES Repasses(id),
CONSTRAINT FK_RepasseItens_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id),
CONSTRAINT FK_RepasseItens_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id)
);

CREATE TABLE Bloqueio_horarios(
id BIGINT IDENTITY(1,1) PRIMARY KEY,
empreendedor_id BIGINT NOT NULL,
data_inicio DATETIME2 NOT NULL,
data_fim DATETIME2 NOT NULL,
motivo VARCHAR(100) NULL,
CONSTRAINT FK_BloqueioHorarios_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id),
CONSTRAINT CK_Bloqueio_Valido CHECK(data_fim > data_inicio)
);

CREATE INDEX IX_Usuario_Email ON Usuario(email);
CREATE INDEX IX_Usuario_Documento ON Usuario(documento);
CREATE INDEX IX_Agendamentos_Data ON Agendamentos(data_hora_inicio);
CREATE INDEX IX_Agendamento_Status ON Agendamentos(status);
CREATE INDEX IX_Servicos_Empreendedor ON Servicos(empreendedor_id);
CREATE INDEX IX_Portifolio_Empreendedor ON Portfolio_Fotos(empreendedor_id);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- PROCEDURES

-- =========================================================
-- PROCEDURE: registrar usuario
-- =========================================================
CREATE OR ALTER PROCEDURE sp_RegistrarUsuario
    @nome VARCHAR(150),
    @documento VARCHAR(14),
    @email VARCHAR(100),
    @senha VARCHAR(255),
    @telefone VARCHAR(15),
    @data_nascimento DATE,
    @tipo_usuario VARCHAR(20),
    @latitude DECIMAL(10,8) = NULL,
    @longitude DECIMAL(11,8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Usuario WHERE email = @email OR documento = @documento)
    BEGIN
        RAISERROR('E-mail ou documento ja cadastrado.', 16, 1);
        RETURN;
    END

    INSERT INTO Usuario (nome, documento, email, senha, telefone, data_nascimento, tipo_usuario, latitude, longitude)
    VALUES (@nome, @documento, @email, @senha, @telefone, @data_nascimento, @tipo_usuario, @latitude, @longitude);

    SELECT SCOPE_IDENTITY() AS novo_id;
END
GO


-- =========================================================
-- PROCEDURE: criar agendamento
-- =========================================================
CREATE OR ALTER PROCEDURE sp_CriarAgendamento
    @cliente_id BIGINT,
    @empreendedor_id BIGINT,
    @servico_id BIGINT,
    @data_hora_inicio DATETIME2,
    @cupom_codigo VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @duracao TIME,
            @data_fim DATETIME2,
            @valor DECIMAL(10,2) = 0,
            @cupom_id BIGINT,
            @valor_desconto DECIMAL(10,2),
            @agendamento_id BIGINT;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id = @empreendedor_id AND tipo_usuario = 'EMPREENDEDOR')
    BEGIN
        RAISERROR('Empreendedor invalido.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id = @cliente_id AND tipo_usuario = 'CLIENTE')
    BEGIN
        RAISERROR('Cliente invalido.', 16, 1);
        RETURN;
    END

    SELECT @duracao = duracao_estimada, @valor = preco
    FROM Servicos
    WHERE id = @servico_id AND empreendedor_id = @empreendedor_id;

    IF @duracao IS NULL
    BEGIN
        RAISERROR('Servico invalido ou nao pertence ao empreendedor informado.', 16, 1);
        RETURN;
    END

    SET @data_fim = DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', @duracao), @data_hora_inicio);

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Agendamentos (cliente_id, empreendedor_id, servico_id, data_hora_inicio, data_hora_fim, status)
        VALUES (@cliente_id, @empreendedor_id, @servico_id, @data_hora_inicio, @data_fim, 'PENDENTE');

        SET @agendamento_id = SCOPE_IDENTITY();

        IF @cupom_codigo IS NOT NULL
        BEGIN
            SELECT @cupom_id = id, @valor_desconto = valor
            FROM Cupons
            WHERE codigo = @cupom_codigo
              AND data_validade >= CAST(GETDATE() AS DATE);

            IF @cupom_id IS NOT NULL
            BEGIN
                INSERT INTO Cupons_uso (cupom_id, agendamento_id, usuario_id, valor_desconto)
                VALUES (@cupom_id, @agendamento_id, @cliente_id, @valor_desconto);
            END
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH

    SELECT @agendamento_id AS agendamento_id;
END
GO

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- TRIGGERS

ALTER TABLE Historico_Agendamentos
    ADD detalhes VARCHAR(500) NULL;
GO



-- =========================================================
-- TRIGGER: controle de quantidade de altera��es (cliente/empreendedor)
-- =========================================================
CREATE OR ALTER TRIGGER TR_Agendamentos_ControleAlteracoes
ON Agendamentos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- RECURSIVE_TRIGGERS do banco.
    IF TRIGGER_NESTLEVEL(OBJECT_ID('TR_Agendamentos_ControleAlteracoes')) > 1
        RETURN;

    DECLARE @usuario_atual_id BIGINT = TRY_CAST(SESSION_CONTEXT(N'usuario_id') AS BIGINT);

    UPDATE a
    SET a.qtd_alteracoes_cliente = a.qtd_alteracoes_cliente
            + CASE WHEN x.tipo_usuario = 'CLIENTE' THEN 1 ELSE 0 END,
        a.qtd_alteracoes_emp = a.qtd_alteracoes_emp
            + CASE WHEN x.tipo_usuario = 'EMPREENDEDOR' THEN 1 ELSE 0 END
    FROM Agendamentos a
    JOIN (
        SELECT
            i.id,
            COALESCE(
                u.tipo_usuario,
                (SELECT TOP 1 tipo_usuario FROM Usuario WHERE email = SYSTEM_USER)
            ) AS tipo_usuario
        FROM inserted i
        JOIN deleted d ON d.id = i.id
        LEFT JOIN Usuario u ON u.id = @usuario_atual_id
        WHERE i.status <> d.status
           OR i.data_hora_inicio <> d.data_hora_inicio
           OR i.data_hora_fim <> d.data_hora_fim
           OR i.servico_id <> d.servico_id
    ) x ON x.id = a.id;
END
GO


-- =========================================================
-- TRIGGER: bloqueio autom�tico de clientes que cancelam
-- =========================================================
CREATE OR ALTER TRIGGER TR_Agendamentos_BloqueioCliente
ON Agendamentos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Bloqueios_Clientes (cliente_id)
    SELECT DISTINCT i.cliente_id
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    WHERE i.status = 'CANCELADO'
      AND d.status IN ('CONFIRMADO', 'PENDENTE')
      AND NOT EXISTS (
            SELECT 1 FROM Bloqueios_Clientes bc
            WHERE bc.cliente_id = i.cliente_id AND bc.ativo = 1
      );
END
GO


-- =========================================================
-- TRIGGER: auditoria de altera��es
-- =========================================================
CREATE OR ALTER TRIGGER TR_Agendamento_Historico
ON Agendamentos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @usuario_atual_id BIGINT = TRY_CAST(SESSION_CONTEXT(N'usuario_id') AS BIGINT);

    INSERT INTO Historico_Agendamentos (agendamento_id, usuario_alterou_id, tipo_alteracao, detalhes)
    SELECT
        i.id,
        COALESCE(
            @usuario_atual_id,
            (SELECT TOP 1 id FROM Usuario WHERE email = SYSTEM_USER),
            i.cliente_id
        ),
        'ALTERACAO',
        CONCAT('Status alterado de ', d.status, ' para ', i.status,
               ' | Data: ', i.data_hora_inicio)
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    WHERE i.status <> d.status
       OR i.data_hora_inicio <> d.data_hora_inicio;
END
GO

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++