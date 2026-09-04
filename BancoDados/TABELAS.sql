CREATE DATABASE PROJETO_PI

USE PROJETO_PI


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
 
    status VARCHAR(20)
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

create table Categoria_Servicos(
id bigint identity primary key,
nome varchar(80),
descricao varchar(255),
icone_url varchar(255),
ativo bit not null default 1,
criado_em datetime2 not null default sysdatetime()
);

create table Servicos_Categorias(
servico_id bigint not null,
categoria_id bigint not null,
primary key(servico_id, categoria_id),
constraint FK_SerivicosCategorias_servico
foreign key (servico_id) references servicos(id) on delete cascade,
constraint FK_SerivicosCategorias_Categoria
foreign key (categoria_id) references Categoria_Servicos(id)
);

create table enderecos(
id bigint identity(1,1) primary key,
usuario_id bigint not null,
tipo_endereco varchar(20) not null
  check(tipo_endereco in ('RESIDENCIAL', 'COMERCIAL', 'ATENDIMENTO')),
cep varchar(8) not null,
logradouro varchar(150) not null,
numero varchar(10) not null,
complemento varchar(50) null,
bairro varchar(80) not null,
cidade varchar(80) not null,
estado char(2) not null,
latitude decimal(10,8) null,
longitude decimal(11,8) null,
principal bit not null default 0,
criado_em datetime2 not null default sysdatetime(),
constraint FK_Endereco_Usuario
  foreign key (usuario_id) references Usuario(id) on delete cascade,

  constraint UQ_Endereco_Principal unique (usuario_id, tipo_endereco)

);

create table Disponibilidades(
id bigint identity(1,1) primary key,
empreendedor_id bigint not null,
dia_semana int not null check(dia_semana between 0 and 6),
hora_inicio time not null,
hora_fim time not null,
ativo bit not null default 1,
constraint FK_Disponibilidade_Usuario
foreign key (empreendedor_id) references Usuario(id) on delete cascade,
constraint CK_Horario_valido check (hora_fim > hora_inicio)

);

create table Cupons_uso(
id bigint identity(1,1) primary key,
cupom_id bigint not null,
agendamento_id bigint not null,
usuario_id bigint not null,
valor_desconto decimal(10,2) not null,
usado_em datetime2 not null default sysdatetime(),
constraint FK_CuponsUso
foreign key (cupom_id) references Cupons(id),
constraint FK_CuponsUso_Agendamento
foreign key (agendamento_id) references Agendamentos(id),
constraint FK_CuponsUso_Usuario
foreign key (usuario_id) references Usuario(id)
);

create table Notificacoes(
id bigint identity(1,1) primary key,
usuario_id bigint not null,
tipo varchar(50) not null,
mensagem varchar(max) not null,
lida bit not null default 0,
data_envio datetime2 not null default sysdatetime(),
constraint FK_Notificacoes_Usuario
foreign key (usuario_id) references Usuario(id)
);

create table Favoritos(
cliente_id bigint not null,
empreendedor_id bigint not null,
criado_em datetime2 not null default sysdatetime(),
primary key (cliente_id, empreendedor_id),
constraint FK_Favoritos_Cliente
foreign key(cliente_id) references Usuario(id),
constraint FK_Favoritos_Empreendedor
foreign key(empreendedor_id) references Usuario(id)
);

create table Historico_Agendamentos(
id bigint identity(1,1) primary key,
agendamento_id bigint not null,
usuario_alterou_id bigint not null,
tipo_alteracao varchar(50) not null,
data_alteracao datetime2 not null default sysdatetime(),
constraint FK_Historico_Agendamento
foreign key (agendamento_id) references Agendamentos(id),
constraint FK_Historico_Usuario
foreign key (usuario_alterou_id) references Usuario(id),
);

create table Repasses(
id bigint identity(1,1) primary key,
empreendedor_id bigint not null,
agendamento_id bigint not null,
valor decimal(10,2) not null check(valor > 0),
taxa_plataforma decimal(10,2) not null check(valor > 0),
valor_liquido decimal(10,2) not null,
status varchar(20) not null,
check(status in ('PENDENTE', 'PROCESSANDO', 'REALIZADO', 'FALHA')),
data_solicitacao datetime2 not null default sysdatetime(),
data_pagamento datetime2 null,
constraint FK_Repasse_Usuario
foreign key (empreendedor_id) references Usuario(id),
constraint FK_Repasse_Agendamento
foreign key (agendamento_id) references Agendamentos(id)
);

create table Repasses_Itens(
id bigint identity(1,1) primary key,
repasse_id bigint not null,
empreendedor_id bigint not null,
agendamento_id bigint not null,
valor decimal(10,2) not null,
constraint FK_RepasseItens_Repasse foreign key (repasse_id) references Repasses(id),
constraint FK_RepasseItens_Agendamento foreign key (agendamento_id) references Agendamentos(id),
);

create table Bloqueio_horarios(
id bigint identity(1,1) primary key,
empreendedor_id bigint not null,
data_inicio datetime2 not null,
data_fim datetime2 not null,
motivo varchar(100) null,
constraint FK_BloqueioHorarios_Usuario foreign key (empreendedor_id) references Usuario(id),
constraint CK_Bloqueio_Valido check(data_fim > data_inicio)
);



create index IX_Usuario_Email on Usuario(email);
create index IX_Usuario_Documento on Usuario(documento);
create index IX_Agendamentos_Data on Agendamentos(data_hora_inicio);
create index IX_Agendamento_Status on Agendamentos(status);
create index IX_Servicos_Empreendedor on Servicos(empreendedor_id);
create index IX_Portifolio_Empreendedor on Portfolio_Fotos(empreendedor_id);

