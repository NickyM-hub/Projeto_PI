USE PROJETO_PI


-- treigger controle agendamento 

create trigger TR_Agendamentos_ControleAlteracoes
on Agendamentos after update
as
begin
set nocount on;

declare @agendamento_id bigint,
@cliente_id bigint,
@empreendedor_id bigint,
@status_antigo varchar(20),
@status_novo varchar(20);

select @agendamento_id = id,
@cliente_id = cliente_id,
@empreendedor_id = empreendedor_id,
@status_novo = status
from inserted;

select @status_antigo = status from deleted;

-- contador de alterações

if @status_antigo <> @status_novo or
(update(data_hora_inicio) or update (data_hora_fim) or update (servico_id))
begin
if(select system_user) like '%cliente%' or exists(select 1 from inserted where cliente_id = (select id from Usuario where email = system_user))
update Agendamentos set qtd_alteracoes_cliente = qtd_alteracoes_cliente + 1
where id = @agendamento_id;
else
update Agendamentos set qtd_alteracoes_emp = qtd_alteracoes_emp + 1
where id = @agendamento_id
end
end;
go

-- trigger bloqueio automatico clientes

create trigger TR_Agendamentos_BloqueioCliente
on Agendamentos after update
as
begin
set nocount on;

insert into Bloqueios_Clientes(cliente_id)
select distinct i.cliente_id
from inserted i 
join deleted d on i.id = d.id
where i.status = 'CANCELADO'
and d.status in ('CONFIRMADO', 'PENDENTE')
and not exists (select 1 from Bloqueios_Clientes bc
where bc.cliente_id = i.cliente_id and bc.ativo = 1);
end;
go;

--trigger auditoria

create trigger TR_Agendamento_Historico
on Agendamentos after update
as
begin
set nocount on;

insert into Historico_Agendamentos(agendamento_id, usuario_alterou_id,tipo_alteracao)
select i.id,
(select id from Usuario where email = system_user),
'ALTERAÇÃO',
concat('Status alterado de ', d.status, ' para', i.status,
' | Data: ', i.data_hora_inicio)
from inserted i 
join deleted d on i.id= d.id
where i.status <> d.status
or i.data_hora_inicio <> d.data_hora_inicio;
end;
go