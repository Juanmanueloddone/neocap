import { supabase } from '@/src/lib/supabaseClient'

type Proposal = { id: string; kind: string; title: string }
type Event = { id: string; title: string; summary: string; pillar: 'educacion'|'economia'|'politica'|'alimentacion'; proposals: Proposal[] }

export default async function Home() {
  const { data, error } = await supabase
    .from('events')
    .select('id,title,summary,pillar,proposals(id,kind,title)')
    .eq('status','open')
    .order('created_at', { ascending: false })
    .limit(5)

  if (error) {
    return <main className="p-8"><h1>Municipio 0</h1><p>Error: {error.message}</p></main>
  }

  const events = (data ?? []) as Event[]

  return (
    <main className="p-8">
      <h1 style={{fontSize:'28px',marginBottom:12}}>Municipio 0 — Eventos abiertos</h1>
      {events.length === 0 ? <p>No hay eventos.</p> : (
        <ul style={{listStyle:'none',padding:0}}>
          {events.map(ev => (
            <li key={ev.id} style={{padding:'12px 16px', marginBottom:12, border:'1px solid #eee', borderRadius:12}}>
              <div style={{fontSize:18, fontWeight:600}}>{ev.title} <small style={{fontWeight:400, opacity:.6}}>· {ev.pillar}</small></div>
              <p style={{margin:'6px 0 8px 0', opacity:.8}}>{ev.summary}</p>
              <div>
                {ev.proposals?.map(pr => (
                  <span key={pr.id} style={{display:'inline-block', padding:'6px 10px', marginRight:8, borderRadius:999, border:'1px solid #ddd'}}>
                    {pr.kind.toUpperCase()}: {pr.title}
                  </span>
                ))}
              </div>
            </li>
          ))}
        </ul>
      )}
    </main>
  )
}
