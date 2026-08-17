USE PROJETO_PI


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