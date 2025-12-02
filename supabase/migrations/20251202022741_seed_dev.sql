-- Playbook: pilar Economía (impuesto único 10%)
insert into public.playbook_entries (pillar, slug, title, body_markdown, capsule_short)
values (
  'economia',
  'impuesto_unico_10',
  'Impuesto único 10% y pagos claros',
  'En Municipio 0 simplificamos a un 10% único sobre lo producido. Con eso pagamos directo a productores de alimentos de calidad y logística comunitaria en contraprestación. Sin partidos ni burocracia inútil.',
  '10% único → pago directo a productores y logística comunitaria.'
);

-- Evento + 3 propuestas (usamos CTE para capturar el id)
with e as (
  insert into public.events (title, summary, pillar, topic, status)
  values (
    'Subsidio a combustibles en ciudad X',
    'Se aprueba un subsidio amplio a combustibles; riesgo de más emisión y distorsión.',
    'economia',
    'energia',
    'open'
  )
  returning id
)
insert into public.proposals (event_id, kind, title, body)
select e.id, 'si',  'Sí al subsidio',  'Sostener precios hoy.'                 from e
union all
select e.id, 'no',  'No al subsidio',  'Eliminar distorsiones.'               from e
union all
select e.id, 'neo', 'Alternativa Neo', 'Transición con plazos, 10% único y pagos en NEOC a logística y productores.' from e;
