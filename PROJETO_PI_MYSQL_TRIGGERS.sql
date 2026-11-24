USE PROJETO_PI;

DELIMITER //

CREATE TRIGGER TRG_Usuario_ValidaMaioridade
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    IF NEW.data_nascimento > DATE_SUB(CURDATE(), INTERVAL 18 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de Negócio: O usuário deve ter pelo menos 18 anos completos para se cadastrar.';
    END IF;
END //

CREATE TRIGGER TRG_Usuario_CriarFidelidade
AFTER INSERT ON Usuario
FOR EACH ROW
BEGIN
    IF NEW.tipo_usuario = 'CLIENTE' THEN
        INSERT INTO Fidelidade (cliente_id, pontos)
        VALUES (NEW.id, 0);
    END IF;
END //

CREATE TRIGGER TRG_Agendamentos_PenalidadeDesistencia
AFTER UPDATE ON Agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_tem_pagamento INT DEFAULT 0;

    IF NEW.status = 'CANCELADO' AND OLD.status != 'CANCELADO' THEN
        SELECT COUNT(*) INTO v_tem_pagamento
        FROM Pagamentos
        WHERE agendamento_id = NEW.id AND status_pagamento = 'CONFIRMADO';

        IF v_tem_pagamento > 0 THEN
            UPDATE Pagamentos 
            SET status_pagamento = 'ESTORNADO_DOBRO',
                atualizado_em = CURRENT_TIMESTAMP
            WHERE agendamento_id = NEW.id;

            INSERT INTO Avaliacoes (
                agendamento_id, 
                cliente_id, 
                empreendedor_id, 
                nota, 
                comentario, 
                penalidade_sistema
            ) VALUES (
                NEW.id, 
                NEW.cliente_id, 
                NEW.empreendedor_id, 
                1, 
                'Penalidade do Sistema: Desistência/Cancelamento após recebimento da taxa de reserva (Art. 420 C.C.).', 
                1
            );
        END IF;
    END IF;
END //

CREATE TRIGGER TRG_Agendamentos_AuditStatus
AFTER UPDATE ON Agendamentos
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO Historico_Agendamentos (
            agendamento_id, 
            usuario_alterou_id, 
            tipo_alteracao, 
            motivo
        ) 
        VALUES (
            NEW.id, 
            NEW.cliente_id, 
            CONCAT('ALTERACAO_STATUS_', NEW.status),
            CONCAT('Status alterado de ', OLD.status, ' para ', NEW.status)
        );
    END IF;
END //

CREATE TRIGGER TRG_Agendamentos_ImutabilidadeFinal
BEFORE UPDATE ON Agendamentos
FOR EACH ROW
BEGIN
    IF OLD.status IN ('CONCLUIDO', 'CANCELADO') AND NEW.status != OLD.status THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de Segurança: Um agendamento CONCLUÍDO ou CANCELADO não pode alterar seu status.';
    END IF;
END //

CREATE TRIGGER TRG_Pagamentos_AuditFinanceiro
AFTER UPDATE ON Pagamentos
FOR EACH ROW
BEGIN
    IF OLD.status_pagamento != NEW.status_pagamento THEN
        INSERT INTO Notificacoes (
            usuario_id, 
            agendamento_id, 
            tipo, 
            canal, 
            mensagem
        ) 
        SELECT 
            a.cliente_id, 
            NEW.agendamento_id, 
            'PAGAMENTO_STATUS', 
            'SISTEMA', 
            CONCAT('O pagamento da transação ', NEW.gateway_transacao_id, ' mudou de ', OLD.status_pagamento, ' para ', NEW.status_pagamento)
        FROM Agendamentos a
        WHERE a.id = NEW.agendamento_id;
    END IF;
END //

CREATE TRIGGER TRG_Pagamentos_ImutabilidadeDelete
BEFORE DELETE ON Pagamentos
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Segurança: Registros de pagamentos não podem ser excluídos da base de dados.';
END //

DELIMITER ;