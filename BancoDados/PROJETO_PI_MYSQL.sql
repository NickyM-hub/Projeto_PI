CREATE DATABASE IF NOT EXISTS PROJETO_PI 
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE PROJETO_PI;

-- ============================================================================
-- 1. ESTRUTURA DE USUÁRIOS E SEGURANÇA
-- ============================================================================

CREATE TABLE Usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    documento VARCHAR(14) NOT NULL UNIQUE COMMENT 'CPF (11) ou CNPJ (14) único',
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    data_nascimento DATE NOT NULL,
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('CLIENTE', 'EMPREENDEDOR')),
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX IX_Usuario_Email (email),
    INDEX IX_Usuario_Documento (documento),
    INDEX IX_Usuario_Localizacao (latitude, longitude)
);

CREATE TABLE Enderecos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    tipo_endereco VARCHAR(20) NOT NULL CHECK (tipo_endereco IN ('RESIDENCIAL', 'COMERCIAL', 'ATENDIMENTO')),
    cep VARCHAR(8) NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50) NULL,
    bairro VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    estado CHAR(2) NOT NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    principal TINYINT(1) NOT NULL DEFAULT 0,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Endereco_Usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT UQ_Endereco_Principal UNIQUE (usuario_id, tipo_endereco),
    INDEX IX_Enderecos_CEP (cep),
    INDEX IX_Enderecos_Geo (latitude, longitude)
);

-- ============================================================================
-- 2. SERVIÇOS, CATEGORIAS E PORTFÓLIO
-- ============================================================================

CREATE TABLE Categoria_Servicos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    descricao VARCHAR(255) NULL,
    icone_url VARCHAR(255) NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Servicos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    empreendedor_id BIGINT NOT NULL,
    nome_servico VARCHAR(100) NOT NULL,
    descricao TEXT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    duracao_estimada TIME NOT NULL,
    cobra_taxa_reserva TINYINT(1) NOT NULL DEFAULT 0,
    valor_taxa_reserva DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (valor_taxa_reserva >= 0),
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Servicos_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    INDEX IX_Servicos_Empreendedor (empreendedor_id)
);

CREATE TABLE Servicos_Categorias (
    servico_id BIGINT NOT NULL,
    categoria_id BIGINT NOT NULL,
    PRIMARY KEY (servico_id, categoria_id),
    CONSTRAINT FK_ServicosCategorias_Servico FOREIGN KEY (servico_id) REFERENCES Servicos(id) ON DELETE CASCADE,
    CONSTRAINT FK_ServicosCategorias_Categoria FOREIGN KEY (categoria_id) REFERENCES Categoria_Servicos(id) ON DELETE CASCADE
);

CREATE TABLE Portfolio_Fotos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    empreendedor_id BIGINT NOT NULL,
    servico_id BIGINT NULL COMMENT 'Opcional: vincula a foto a um serviço específico',
    url_foto VARCHAR(255) NOT NULL,
    titulo VARCHAR(100) NULL,
    descricao VARCHAR(255) NULL,
    enviado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_PortfolioFotos_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT FK_PortfolioFotos_Servico FOREIGN KEY (servico_id) REFERENCES Servicos(id) ON DELETE SET NULL,
    INDEX IX_Portfolio_Empreendedor (empreendedor_id)
);

-- ============================================================================
-- 3. CALENDÁRIO, DISPONIBILIDADE E BLOQUEIOS
-- ============================================================================

CREATE TABLE Disponibilidades (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    empreendedor_id BIGINT NOT NULL,
    dia_semana INT NOT NULL CHECK (dia_semana BETWEEN 0 AND 6) COMMENT '0 = Domingo, 6 = Sábado',
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT FK_Disponibilidade_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT CK_Horario_Valido CHECK (hora_fim > hora_inicio)
);

CREATE TABLE Bloqueio_Horarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    empreendedor_id BIGINT NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    motivo VARCHAR(100) NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_BloqueioHorarios_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT CK_BloqueioHorario_Valido CHECK (data_fim > data_inicio),
    INDEX IX_BloqueioHorarios_Datas (empreendedor_id, data_inicio, data_fim)
);

CREATE TABLE Bloqueios_Clientes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    data_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fim DATETIME GENERATED ALWAYS AS (DATE_ADD(data_inicio, INTERVAL 20 DAY)) STORED,
    motivo VARCHAR(255) NOT NULL DEFAULT 'Penalidade: Excedeu limite de 3 alterações sem comparecimento',
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT FK_BloqueiosClientes_Usuario FOREIGN KEY (cliente_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    INDEX IX_BloqueiosClientes_Ativo (cliente_id, ativo, data_fim)
);

-- ============================================================================
-- 4. AGENDAMENTOS, HISTÓRICO E CONFIRMAÇÃO DE PRESENÇA
-- ============================================================================

CREATE TABLE Agendamentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    empreendedor_id BIGINT NOT NULL,
    servico_id BIGINT NOT NULL,
    data_hora_inicio DATETIME NOT NULL,
    data_hora_fim DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO')),
    recorrente TINYINT(1) NOT NULL DEFAULT 0,
    regra_recorrencia VARCHAR(50) NULL COMMENT 'Ex: SEMANAL, MENSAL',
    qtd_alteracoes_cliente INT NOT NULL DEFAULT 0 CHECK (qtd_alteracoes_cliente <= 3),
    qtd_alteracoes_emp INT NOT NULL DEFAULT 0 CHECK (qtd_alteracoes_emp <= 3),
    termo_sem_pagamento TINYINT(1) NOT NULL DEFAULT 0,
    confirmacao_presenca TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'RN2: Confirmação automática de presença',
    data_confirmacao_presenca DATETIME NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Agendamentos_Cliente FOREIGN KEY (cliente_id) REFERENCES Usuario(id),
    CONSTRAINT FK_Agendamentos_Empreendedor FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id),
    CONSTRAINT FK_Agendamentos_Servico FOREIGN KEY (servico_id) REFERENCES Servicos(id),
    CONSTRAINT CK_Agendamentos_Datas CHECK (data_hora_fim > data_hora_inicio),
    INDEX IX_Agendamentos_Cliente (cliente_id),
    INDEX IX_Agendamentos_Empreendedor (empreendedor_id),
    INDEX IX_Agendamentos_Data (data_hora_inicio),
    INDEX IX_Agendamentos_Status (status)
);

CREATE TABLE Historico_Agendamentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    usuario_alterou_id BIGINT NOT NULL,
    tipo_alteracao VARCHAR(50) NOT NULL COMMENT 'CRIAÇÃO, REAGENDAMENTO_CLIENTE, REAGENDAMENTO_EMP, CANCELAMENTO',
    motivo VARCHAR(255) NULL,
    data_alteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Historico_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE CASCADE,
    CONSTRAINT FK_Historico_Usuario FOREIGN KEY (usuario_alterou_id) REFERENCES Usuario(id)
);

-- ============================================================================
-- 5. FINANCEIRO, PAGAMENTOS, TERMOS E NOTAS FISCAIS
-- ============================================================================

CREATE TABLE Pagamentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    gateway_transacao_id VARCHAR(100) NOT NULL UNIQUE,
    metodo_pagamento VARCHAR(20) NOT NULL CHECK (metodo_pagamento IN ('PIX', 'CARTAO', 'BOLETO')),
    status_pagamento VARCHAR(30) NOT NULL CHECK (status_pagamento IN ('PENDENTE', 'CONFIRMADO', 'ESTORNADO', 'ESTORNADO_DOBRO')),
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago >= 0),
    nota_fiscal_emitida TINYINT(1) NOT NULL DEFAULT 0,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Pagamentos_Agendamentos FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE CASCADE,
    INDEX IX_Pagamentos_Status (status_pagamento)
);

CREATE TABLE Termos_Responsabilidade (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    empreendedor_id BIGINT NOT NULL,
    assinado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_assinatura VARCHAR(45) NOT NULL,
    hash_termo VARCHAR(255) NOT NULL COMMENT 'RN4: Assinatura digital ciente dos riscos sem pagamento prévio',
    CONSTRAINT FK_Termos_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE CASCADE,
    CONSTRAINT FK_Termos_Empreendedor FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id)
);

CREATE TABLE Notas_Fiscais (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pagamento_id BIGINT NOT NULL,
    numero_nota VARCHAR(50) NOT NULL UNIQUE,
    url_pdf VARCHAR(255) NULL,
    xml_chave VARCHAR(100) NULL,
    status_emissao VARCHAR(20) NOT NULL CHECK (status_emissao IN ('PROCESSANDO', 'EMITIDA', 'ERRO', 'CANCELADA')),
    emitida_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_NotasFiscais_Pagamento FOREIGN KEY (pagamento_id) REFERENCES Pagamentos(id) ON DELETE CASCADE
);

CREATE TABLE Repasses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    empreendedor_id BIGINT NOT NULL,
    agendamento_id BIGINT NOT NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    taxa_plataforma DECIMAL(10,2) NOT NULL CHECK (taxa_plataforma >= 0),
    valor_liquido DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDENTE', 'PROCESSANDO', 'REALIZADO', 'FALHA')),
    data_solicitacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_pagamento DATETIME NULL,
    CONSTRAINT FK_Repasse_Usuario FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id),
    CONSTRAINT FK_Repasse_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id)
);

CREATE TABLE Repasses_Itens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    repasse_id BIGINT NOT NULL,
    empreendedor_id BIGINT NOT NULL,
    agendamento_id BIGINT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_RepasseItens_Repasse FOREIGN KEY (repasse_id) REFERENCES Repasses(id) ON DELETE CASCADE,
    CONSTRAINT FK_RepasseItens_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id)
);

-- ============================================================================
-- 6. MARKETING, CUPONS E FIDELIDADE
-- ============================================================================

CREATE TABLE Cupons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    empreendedor_id BIGINT NULL COMMENT 'NULL = Global da plataforma; Preenchido = Cupom do Empreendedor',
    tipo_desconto VARCHAR(20) NOT NULL CHECK (tipo_desconto IN ('PORCENTAGEM', 'VALOR_FIXO')),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    valor_minimo_agendamento DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    data_validade DATE NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Cupons_Empreendedor FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

CREATE TABLE Cupons_Uso (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cupom_id BIGINT NOT NULL,
    agendamento_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    valor_desconto DECIMAL(10,2) NOT NULL,
    usado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_CuponsUso_Cupom FOREIGN KEY (cupom_id) REFERENCES Cupons(id),
    CONSTRAINT FK_CuponsUso_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id),
    CONSTRAINT FK_CuponsUso_Usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);

CREATE TABLE Fidelidade (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL UNIQUE,
    pontos INT NOT NULL DEFAULT 0 CHECK (pontos >= 0),
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Fidelidade_Cliente FOREIGN KEY (cliente_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

CREATE TABLE Historico_Pontos_Fidelidade (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fidelidade_id BIGINT NOT NULL,
    agendamento_id BIGINT NULL,
    pontos INT NOT NULL COMMENT 'Positivo para acúmulo, Negativo para resgate',
    descricao VARCHAR(150) NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_HistFidelidade_Fidelidade FOREIGN KEY (fidelidade_id) REFERENCES Fidelidade(id) ON DELETE CASCADE,
    CONSTRAINT FK_HistFidelidade_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE SET NULL
);

-- ============================================================================
-- 7. COMUNICAÇÃO, NOTIFICAÇÕES E CHAT
-- ============================================================================

CREATE TABLE Notificacoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    agendamento_id BIGINT NULL,
    tipo VARCHAR(50) NOT NULL COMMENT 'LEMBRETE_24H, LEMBRETE_3H, CONFIRMACAO, CANCELAMENTO',
    canal VARCHAR(20) NOT NULL DEFAULT 'PUSH' CHECK (canal IN ('PUSH', 'WHATSAPP', 'EMAIL', 'SISTEMA')),
    mensagem TEXT NOT NULL,
    lida TINYINT(1) NOT NULL DEFAULT 0,
    data_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Notificacoes_Usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT FK_Notificacoes_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE SET NULL,
    INDEX IX_Notificacoes_Status (usuario_id, lida)
);

CREATE TABLE Mensagens_Chat (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    remetente_id BIGINT NOT NULL,
    conteudo_mensagem TEXT NOT NULL,
    lida TINYINT(1) NOT NULL DEFAULT 0,
    enviado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_MensagensChat_Agendamentos FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE CASCADE,
    CONSTRAINT FK_MensagensChat_Usuario FOREIGN KEY (remetente_id) REFERENCES Usuario(id),
    INDEX IX_Mensagens_Agendamento (agendamento_id, enviado_em)
);

-- ============================================================================
-- 8. AVALIAÇÕES, FAVORITOS E SUPORTE
-- ============================================================================

CREATE TABLE Avaliacoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL UNIQUE,
    cliente_id BIGINT NOT NULL,
    empreendedor_id BIGINT NOT NULL,
    nota INT NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT NULL,
    penalidade_sistema TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = Baixa automática por descumprimento do Art. 420',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Avaliacoes_Agendamentos FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE CASCADE,
    CONSTRAINT FK_Avaliacoes_Cliente FOREIGN KEY (cliente_id) REFERENCES Usuario(id),
    CONSTRAINT FK_Avaliacoes_Empreendedor FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id),
    INDEX IX_Avaliacoes_Empreendedor (empreendedor_id, nota)
);

CREATE TABLE Favoritos (
    cliente_id BIGINT NOT NULL,
    empreendedor_id BIGINT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cliente_id, empreendedor_id),
    CONSTRAINT FK_Favoritos_Cliente FOREIGN KEY (cliente_id) REFERENCES Usuario(id) ON DELETE CASCADE,
    CONSTRAINT FK_Favoritos_Empreendedor FOREIGN KEY (empreendedor_id) REFERENCES Usuario(id) ON DELETE CASCADE
);

CREATE TABLE Tickets_Suporte (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    agendamento_id BIGINT NULL,
    assunto VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTO' CHECK (status IN ('ABERTO', 'EM_ANDAMENTO', 'FECHADO')),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_TicketsSuporte_Usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(id),
    CONSTRAINT FK_TicketsSuporte_Agendamento FOREIGN KEY (agendamento_id) REFERENCES Agendamentos(id) ON DELETE SET NULL,
    INDEX IX_Tickets_Status (status, criado_em)
);

CREATE TABLE Respostas_Tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL COMMENT 'Atendente ou o próprio Usuário',
    mensagem TEXT NOT NULL,
    enviado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_RespostasTickets_Ticket FOREIGN KEY (ticket_id) REFERENCES Tickets_Suporte(id) ON DELETE CASCADE,
    CONSTRAINT FK_RespostasTickets_Usuario FOREIGN KEY (usuario_id) REFERENCES Usuario(id)
);