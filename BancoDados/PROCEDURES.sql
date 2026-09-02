USE PROJETO_PI

-- procedure registrar usuario

create or alter procedure sp_RegistrarUsuario
@nome varchar(150),
@documento varchar(14),
@email varchar(100),
@senha varchar(255),
@telefone varchar(15),
@data_nascimento date,
@tipo_usuario varchar(20),
@latitude decimal (10,8) = null,
@longitude decimal(11,8) = null
as
begin

set nocount on;

if exists(select 1 from Usuario where email = @email or documento = @documento)
begin
raiserror('E-mail ou documento ja cadastrado.', 16,1);
return;
end
insert into Usuario(nome, documento, email, senha, telefone, data_nascimento, tipo_usuario, latitude, longitude )
values (@nome, @documento, @email, @senha, @telefone, @data_nascimento, @tipo_usuario, @latitude, @longitude);

select scope_identity() as novo_id;
end;
go

-- procedure agendamento 

create or alter procedure sp_CriarAgendamento
@cliente_id bigint,
@empreendedor_id bigint,
@servico_id bigint,
@data_hora_inicio datetime2,
@cupom_codigo varchar(20) = null
as
begin
set nocount on;
declare @duracao time, @data_fim datetime2, @valor decimal(10,2) = 0, @cupom_id bigint, @valor_desconto decimal(10,2),
@agendamento_id bigint

--validações

if not exists(select 1 from Usuario where id = @empreendedor_id and tipo_usuario = 'EMPREENDEDOR')
raiserror('Empreendedor invalido.', 16, 1);

select @duracao = duracao_estimada, @valor = preco
from Servicos where id = @servico_id;
set @data_fim = dateadd(minute, datediff(minute, '00:00', @duracao), @data_hora_inicio);
begin transaction;
insert into Agendamentos (cliente_id, empreendedor_id, servico_id,data_hora_inicio, data_hora_fim, status)
values (@cliente_id, @empreendedor_id, @servico_id, @data_hora_inicio, @data_fim, 'PENDENTE');

set @agendamento_id = scope_identity();

-- aplicar cupom se informado

if @cupom_codigo is not null
begin
select @cupom_id = id, @valor_desconto = valor
from Cupons
where codigo = @cupom_codigo
and data_validade >= cast(getdate() as date);

if @cupom_id is not null
begin
insert into Cupons_uso(cupom_id, agendamento_id, usuario_id, valor_desconto)
values (@cupom_id, @agendamento_id, @cliente_id, @valor_desconto);
end
end
commit transaction;
select @agendamento_id as agendamento_id;
end
go
