DELIMITER //

-- Procedure 1: Cadastro de Usuário (+18 Anos)
CREATE PROCEDURE SP_CadastrarUsuario(
    IN p_nome VARCHAR(150),
    IN p_documento VARCHAR(14),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255),
    IN p_telefone VARCHAR(15),
    IN p_data_nascimento DATE,
    IN p_tipo_usuario VARCHAR(20),
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8),
    OUT p_usuario_id BIGINT
)
BEGIN
    IF p_data_nascimento > DATE_SUB(CURDATE(), INTERVAL 18 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de Negócio: O usuário deve ter pelo menos 18 anos completos para se cadastrar.';
    END IF;

    INSERT INTO Usuario (
        nome, documento, email, senha, telefone, 
        data_nascimento, tipo_usuario, latitude, longitude
    ) 
    VALUES (
        p_nome, p_documento, p_email, p_senha, p_telefone, 
        p_data_nascimento, p_tipo_usuario, p_latitude, p_longitude
    );

    SET p_usuario_id = LAST_INSERT_ID();
END //

-- Procedure 2: Criar Agendamento (Bloqueio, Concorrência e 3 Dias Úteis)
CREATE PROCEDURE SP_CriarAgendamento(
    IN p_cliente_id BIGINT,
    IN p_empreendedor_id BIGINT,
    IN p_servico_id BIGINT,
    IN p_data_hora_inicio DATETIME,
    IN p_recorrente TINYINT(1),
    IN p_regra_recorrencia VARCHAR(50),
    OUT p_agendamento_id BIGINT
)
BEGIN
    DECLARE v_duracao TIME;
    DECLARE v_data_hora_fim DATETIME;
    DECLARE v_bloqueado INT DEFAULT 0;
    DECLARE v_choque INT DEFAULT 0;
    DECLARE v_dias_uteis INT DEFAULT 0;
    DECLARE v_data_aux DATE;

    SELECT COUNT(*) INTO v_bloqueado 
    FROM Bloqueios_Clientes 
    WHERE cliente_id = p_cliente_id 
      AND ativo = 1 
      AND data_fim >= CURRENT_TIMESTAMP;

    IF v_bloqueado > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bloqueio Ativo: Este cliente está temporariamente impedido de realizar novos agendamentos.';
    END IF;

    SET v_data_aux = CURDATE();
    WHILE v_dias_uteis < 3 DO
        SET v_data_aux = DATE_ADD(v_data_aux, INTERVAL 1 DAY);
        IF DAYOFWEEK(v_data_aux) NOT IN (1, 7) THEN
            SET v_dias_uteis = v_dias_uteis + 1;
        END IF;
    END WHILE;

    IF CAST(p_data_hora_inicio AS DATE) < v_data_aux THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de Agendamento: O agendamento exige antecedência mínima de 3 dias úteis.';
    END IF;

    SELECT duracao_estimada INTO v_duracao FROM Servicos WHERE id = p_servico_id;
    SET v_data_hora_fim = ADDTIME(p_data_hora_inicio, v_duracao);

    SELECT COUNT(*) INTO v_choque 
    FROM Agendamentos 
    WHERE cliente_id = p_cliente_id 
      AND status IN ('PENDENTE', 'CONFIRMADO')
      AND (
          (p_data_hora_inicio >= data_hora_inicio AND p_data_hora_inicio < data_hora_fim) OR
          (v_data_hora_fim > data_hora_inicio AND v_data_hora_fim <= data_hora_fim) OR
          (p_data_hora_inicio <= data_hora_inicio AND v_data_hora_fim >= data_hora_fim)
      );

    IF v_choque > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Choque de Horário: O cliente já possui outro agendamento neste mesmo período.';
    END IF;

    INSERT INTO Agendamentos (
        cliente_id, empreendedor_id, servico_id, 
        data_hora_inicio, data_hora_fim, status, 
        recorrente, regra_recorrencia
    ) 
    VALUES (
        p_cliente_id, p_empreendedor_id, p_servico_id, 
        p_data_hora_inicio, v_data_hora_fim, 'PENDENTE', 
        p_recorrente, p_regra_recorrencia
    );

    SET p_agendamento_id = LAST_INSERT_ID();

    INSERT INTO Historico_Agendamentos (agendamento_id, usuario_alterou_id, tipo_alteracao)
    VALUES (p_agendamento_id, p_cliente_id, 'CRIAÇÃO');
END //

-- Procedure 3: Reagendar Agendamento (Limite 3 Alterações + Antecedência 24h + Bloqueio 20 Dias)
CREATE PROCEDURE SP_ReagendarAgendamento(
    IN p_agendamento_id BIGINT,
    IN p_usuario_id BIGINT,
    IN p_nova_data_inicio DATETIME,
    IN p_eh_cliente TINYINT(1)
)
BEGIN
    DECLARE v_qtd_alteracoes INT;
    DECLARE v_cliente_id BIGINT;
    DECLARE v_duracao TIME;
    DECLARE v_nova_data_fim DATETIME;
    DECLARE v_servico_id BIGINT;

    SELECT cliente_id, servico_id INTO v_cliente_id, v_servico_id 
    FROM Agendamentos WHERE id = p_agendamento_id;

    SELECT duracao_estimada INTO v_duracao FROM Servicos WHERE id = v_servico_id;
    SET v_nova_data_fim = ADDTIME(p_nova_data_inicio, v_duracao);

    IF p_eh_cliente = 1 THEN
        IF p_nova_data_inicio < DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 24 HOUR) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo Inválido: Alterações devem ser solicitadas com no mínimo 24 horas de antecedência.';
        END IF;

        SELECT qtd_alteracoes_cliente INTO v_qtd_alteracoes 
        FROM Agendamentos WHERE id = p_agendamento_id;

        IF v_qtd_alteracoes >= 3 THEN
            INSERT INTO Bloqueios_Clientes (cliente_id, data_inicio, ativo)
            VALUES (v_cliente_id, CURRENT_TIMESTAMP, 1);

            UPDATE Agendamentos SET status = 'CANCELADO' WHERE id = p_agendamento_id;

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite Excedido: Limite de 3 alterações atingido. Agendamento cancelado e usuário bloqueado por 20 dias.';
        ELSE
            UPDATE Agendamentos 
            SET data_hora_inicio = p_nova_data_inicio,
                data_hora_fim = v_nova_data_fim,
                qtd_alteracoes_cliente = qtd_alteracoes_cliente + 1
            WHERE id = p_agendamento_id;
        END IF;

    ELSE
        SELECT qtd_alteracoes_emp INTO v_qtd_alteracoes 
        FROM Agendamentos WHERE id = p_agendamento_id;

        IF v_qtd_alteracoes >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite Excedido: O empreendedor atingiu o limite de 3 alterações para este agendamento.';
        ELSE
            UPDATE Agendamentos 
            SET data_hora_inicio = p_nova_data_inicio,
                data_hora_fim = v_nova_data_fim,
                qtd_alteracoes_emp = qtd_alteracoes_emp + 1
            WHERE id = p_agendamento_id;
        END IF;
    END IF;

    INSERT INTO Historico_Agendamentos (agendamento_id, usuario_alterou_id, tipo_alteracao)
    VALUES (p_agendamento_id, p_usuario_id, IF(p_eh_cliente = 1, 'REAGENDAMENTO_CLIENTE', 'REAGENDAMENTO_EMP'));
END //

-- Procedure 4: Cancelamento pelo Empreendedor (Art. 420 - Estorno em Dobro)
CREATE PROCEDURE SP_CancelarAgendamentoEmpreendedor(
    IN p_agendamento_id BIGINT,
    IN p_empreendedor_id BIGINT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_cliente_id BIGINT;
    DECLARE v_pagamento_id BIGINT;
    DECLARE v_valor_pago DECIMAL(10,2);
    DECLARE v_status_pagamento VARCHAR(30);

    SELECT cliente_id INTO v_cliente_id 
    FROM Agendamentos 
    WHERE id = p_agendamento_id AND empreendedor_id = p_empreendedor_id;

    UPDATE Agendamentos 
    SET status = 'CANCELADO' 
    WHERE id = p_agendamento_id;

    SELECT id, valor_pago, status_pagamento INTO v_pagamento_id, v_valor_pago, v_status_pagamento
    FROM Pagamentos 
    WHERE agendamento_id = p_agendamento_id AND status_pagamento = 'CONFIRMADO';

    IF v_pagamento_id IS NOT NULL THEN
        UPDATE Pagamentos 
        SET status_pagamento = 'ESTORNADO_DOBRO',
            atualizado_em = CURRENT_TIMESTAMP
        WHERE id = v_pagamento_id;

        INSERT INTO Avaliacoes (
            agendamento_id, cliente_id, empreendedor_id, nota, comentario, penalidade_sistema
        ) VALUES (
            p_agendamento_id, v_cliente_id, p_empreendedor_id, 1,
            'Penalidade do Sistema: Desistência/Cancelamento após recebimento da taxa de reserva (Art. 420 C.C.).', 
            1
        );
    END IF;

    INSERT INTO Historico_Agendamentos (agendamento_id, usuario_alterou_id, tipo_alteracao, motivo)
    VALUES (p_agendamento_id, p_empreendedor_id, 'CANCELAMENTO_EMPREENDEDOR', p_motivo);
END //

-- Procedure 5: Termo de Responsabilidade Sem Pagamento
CREATE PROCEDURE SP_AssinarTermoSemPagamento(
    IN p_agendamento_id BIGINT,
    IN p_empreendedor_id BIGINT,
    IN p_ip VARCHAR(45),
    IN p_hash_termo VARCHAR(255)
)
BEGIN
    UPDATE Agendamentos 
    SET termo_sem_pagamento = 1,
        status = 'CONFIRMADO' 
    WHERE id = p_agendamento_id AND empreendedor_id = p_empreendedor_id;

    INSERT INTO Termos_Responsabilidade (
        agendamento_id, empreendedor_id, ip_assinatura, hash_termo
    ) 
    VALUES (
        p_agendamento_id, p_empreendedor_id, p_ip, p_hash_termo
    );
END //

-- Procedure 6: Geolocalização de Empreendedores (Haversine em KM)
CREATE PROCEDURE SP_BuscarEmpreendedoresPorProximidade(
    IN p_lat_cliente DECIMAL(10,8),
    IN p_lng_cliente DECIMAL(11,8),
    IN p_raio_km INT
)
BEGIN
    SELECT 
        u.id,
        u.nome,
        u.email,
        u.telefone,
        u.latitude,
        u.longitude,
        ROUND(
            (6371 * ACOS(
                COS(RADIANS(p_lat_cliente)) * COS(RADIANS(u.latitude)) *
                COS(RADIANS(u.longitude) - RADIANS(p_lng_cliente)) +
                SIN(RADIANS(p_lat_cliente)) * SIN(RADIANS(u.latitude))
            )), 2
        ) AS distancia_km,
        COALESCE(AVG(a.nota), 0) AS media_avaliacao
    FROM Usuario u
    LEFT JOIN Avaliacoes a ON u.id = a.empreendedor_id
    WHERE u.tipo_usuario = 'EMPREENDEDOR' 
      AND u.ativo = 1
      AND u.latitude IS NOT NULL 
      AND u.longitude IS NOT NULL
    HAVING distancia_km <= p_raio_km
    ORDER BY distancia_km ASC;
END //

-- Procedure 7: Aplicação e Validação de Cupom de Desconto
CREATE PROCEDURE SP_AplicarCupomDesconto(
    IN p_codigo_cupom VARCHAR(20),
    IN p_agendamento_id BIGINT,
    IN p_usuario_id BIGINT,
    OUT p_valor_desconto DECIMAL(10,2)
)
BEGIN
    DECLARE v_cupom_id BIGINT;
    DECLARE v_tipo_desconto VARCHAR(20);
    DECLARE v_valor_cupom DECIMAL(10,2);
    DECLARE v_minimo DECIMAL(10,2);
    DECLARE v_validade DATE;
    DECLARE v_ativo TINYINT(1);
    DECLARE v_preco_servico DECIMAL(10,2);

    SELECT s.preco INTO v_preco_servico 
    FROM Agendamentos a
    JOIN Servicos s ON a.servico_id = s.id
    WHERE a.id = p_agendamento_id;

    SELECT id, tipo_desconto, valor, valor_minimo_agendamento, data_validade, ativo
    INTO v_cupom_id, v_tipo_desconto, v_valor_cupom, v_minimo, v_validade, v_ativo
    FROM Cupons
    WHERE codigo = p_codigo_cupom;

    IF v_cupom_id IS NULL OR v_ativo = 0 OR v_validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cupom Inválido: Cupom inexistente, inativo ou expirado.';
    END IF;

    IF v_preco_servico < v_minimo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Regra Não Atendida: O valor do agendamento é inferior ao mínimo para este cupom.';
    END IF;

    IF v_tipo_desconto = 'PORCENTAGEM' THEN
        SET p_valor_desconto = ROUND((v_preco_servico * (v_valor_cupom / 100)), 2);
    ELSE
        SET p_valor_desconto = v_valor_cupom;
    END IF;

    INSERT INTO Cupons_Uso (cupom_id, agendamento_id, usuario_id, valor_desconto)
    VALUES (v_cupom_id, p_agendamento_id, p_usuario_id, p_valor_desconto);
END //

DELIMITER ;