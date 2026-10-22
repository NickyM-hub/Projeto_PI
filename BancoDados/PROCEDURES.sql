
-- ============================================================
-- MODULO: USUARIO
-- ============================================================

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

-- ============================================================
-- MODULO: SERVICOS
-- ============================================================

create or alter procedure sp_CadastrarServico
@empreendedorId bigint,
@nome_servico varchar(100),
@descricao varchar(max),
@preco decimal(10,2),
@duracao_estimada time,
@cobra_taxa_reserva bit = 0,
@valor_taxa_reserva decimal(10,2) = 0.00
as
begin
set nocount on

if not exists (select 1 from Usuario where id = @empreendedorId and tipo_usuario = 'EMPREENDEDOR')
begin
raiserror('Empreendedor invalido', 16,11),
return;
end

insert into Servicos (empreendedor_id, nome_servico, descricao, preco, duracao_estimada, cobra_taxa_reserva, valor_taxa_reserva)
values (@empreendedorId,@nome_servico,@descricao,@preco,@duracao_estimada,@cobra_taxa_reserva,@valor_taxa_reserva);

select SCOPE_IDENTITY() as servico_id;
end
go;

create or alter procedure sp_AtualizarServico
@servicoId bigint,
@nome_servico varchar(100)= null,
@descricao varchar(max) = null,
@preco decimal(10,2) = null,
@duracao_estimada time = null,
@cobra_taxa_reserva bit = null,
@valor_taxa_reserva decimal(10,2) = null
as
begin
set nocount on

if not exists (select 1 from Servicos where id = @servicoId)
begin
raiserror('Serviço não encontrado', 16,1);
return;
end

update Servicos
set nome_servico = coalesce(@nome_servico, nome_servico),
descricao = coalesce(@descricao, descricao),
preco = coalesce(@preco, preco),
duracao_estimada = coalesce(@duracao_estimada, duracao_estimada),
cobra_taxa_reserva = coalesce(@cobra_taxa_reserva, cobra_taxa_reserva),
valor_taxa_reserva = coalesce(@valor_taxa_reserva, valor_taxa_reserva)
where id = @servicoId
end
go;

-- inativar serviços

create or alter procedure sp_inativarServico
@servicoId bigint
as
begin
set nocount on

if not exists(select 1 from Servicos where id = @servicoId)
begin
raiserror('Serviço não encontrado', 16,1);
return;
end

if exists(select 1 from Agendamentos where servico_id = @servicoId and status in ('PENDENTE','CONFIRMADO ')
)
begin
raiserror('Serviço possio agendamentos ativos e não pode ser inativado.', 16,1 );
return;
end
delete from Servicos where id = @servicoId;
end
go


-- ============================================================
-- MODULO: AGENDAMENTOS
-- ============================================================

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




if not exists(select 1 from Usuario where id = @empreendedor_id and tipo_usuario = 'EMPREENDEDOR')
raiserror('Empreendedor invalido.', 16, 1);
return;
end



if exists(select 1 from Bloqueios_Clientes where cliente_id = @cliente_id and ativo = 1 and data_fim > SYSDATETIME())
begin
raiserror('Usuario bloqueado no momento', 16,1)
return;
end


select @duracao = duracao_estimada, @valor = preco
from Servicos where id = @servico_id;

if @duracao is null
begin
raiserror ('Serviço não encontrado', 16,1)
return;
end


set @data_fim = dateadd(minute, datediff(minute, '00:00', @duracao), @data_hora_inicio);

if exists (select 1 from Agendamentos where empreendedor_id = @empreendedor_id
and status in ('PENDENTE','CONFIRMADO')
and data_hora_inicio < @data_fim
and data_hora_fim > @data_hora_inicio)
begin
raiserror('Empreendedor ja possui agendamento nesse horario', 16,1);
return;
end

begin transaction
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
go

create or alter procedure sp_AtualizarStatusAgendamento
@agendamentoId bigint,
@novo_status varchar(20),
@usuario_alterou_id bigint
as
begin
set nocount on

if not exists(select 1 from Agendamentos where id = @agendamentoID )
begin
raiserror('Agendamento não encontrado', 16,1);
return;
end

if @novo_status not in('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'CONCLUIDO')
begin
raiserror('Status invalido', 16,1)
return;
end;

EXEC sp_set_session_context @key = N'usuario_id', @value = @usuario_alterou_id;

update Agendamentos
set status = @novo_status
where id = @agendamentoId;
end
go;

create or alter procedure sp_ReagendarAgendamento
@agendamentoID bigint,
@nova_data_hora_inicio datetime2,
@usuario_alterou_id bigint,
@tipo_usuario varchar(20)
as
begin
set nocount on

declare @servicoId bigint, @duracao time, @nova_data_fim datetime2,
@qtd_cliente int, @qtd_emp int;

select @servicoId = servico_id, @qtd_cliente = qtd_alteracoes_cliente, @qtd_emp = qtd_alteracoes_emp
from Agendamentos where id = @agendamentoID;

if @servicoId is null
begin
raiserror('Agendamento nao encontrado', 16,1);
return;
end

if @tipo_usuario not in ('CLIENTE','EMPREENDEDOR')
begin
raiserror('Tipo de usuario invalido', 16, 1)
return;
end

if(@tipo_usuario = 'CLIENTE' and @qtd_cliente >=3) or (@tipo_usuario = 'EMPREENDEDOR' and @qtd_emp >=3)
begin
raiserror('Limite de alterações atingido por esse usuario',16,1);
return
end

select @duracao = duracao_estimada from Servicos where id = @servicoId;
set @nova_data_fim = dateadd(MINUTE, DATEDIFF(minute, '00:00', @duracao), @nova_data_hora_inicio);

   EXEC sp_set_session_context @key = N'usuario_id', @value = @usuario_alterou_id;
    EXEC sp_set_session_context @key = N'tipo_usuario', @value = @tipo_usuario;
 



-- procedure registrar aceite termo

create or alter procedure sp_RegistrarAceiteTermo
@usuario_id bigint,
@termo_id bigint,
@ip_aceite varchar(45) = null,
@user_agent varchar(255) = null

as
begin
set nocount on

begin try


-- verifica se o usuario existe 
if not exists(select 1 from Usuario where id = @usuario_id)
begin
raiserror('Usuario nao encontrado', 16, 1);
return;
end

--verifica se o termo existe e esta ativo

if not exists(select 1 from Termos where id = @termo_id and ativo = 1)
begin
raiserror('Termo não encontrado ou não esta ativo', 16,1);
return;
end

-- evita registrar aceites duplicados para a mesma versao do termo

if exists(select 1 from Usuario_Termos_Aceite
where usuario_id = @usuario_id and termo_id = @termo_id)
begin
raiserror('Usuario ja aceitou essa versão do termo', 16,1);
return;
end

   insert into Usuario_Termos_Aceite (usuario_id, termo_id, ip_aceite, user_agent)
        values (@usuario_id, @termo_id, @ip_aceite, @user_agent);
        select SCOPE_IDENTITY() as aceite_id;

        end try
        begin catch
        throw;
        end catch
        end


    exec sp_RegistrarAceiteTermo
    @usuario_id = 123,
    @termo_id = 1,
    @ip_aceite = '187.10.20.30',
    @user_agent = 'Mozilla/5.0 ...';