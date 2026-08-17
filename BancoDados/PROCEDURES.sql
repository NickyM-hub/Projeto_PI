USE PROJETO_PI

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