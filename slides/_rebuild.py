import pathlib, re
p = pathlib.Path('charla.html'); t = p.read_text()

def swap(marca, nuevo):
    global t
    pat = r'<section data-notes="<b>' + re.escape(marca) + r'</b>.*?</section>'
    assert re.search(pat, t, re.S), marca
    t = re.sub(pat, nuevo, t, count=1, flags=re.S)

# ───────────────────────── 6 · el agente, como árbol de terminal
n6 = ("<b>5:00–5:50</b> · Esto es lo que convierte un modelo en un operador, y está todo público. "
 "No es el modelo: es el árbol de archivos. CLAUDE punto eme de son las reglas duras que se cargan en cada "
 "sesión. La carpeta memory guarda lo aprendido, un archivo por tema, con su porqué. Skills son los runbooks, "
 "uno por situación. Commands son los comandos del día a día. Y el mcp punto json define las herramientas: "
 "el secreto se lee del entorno al ejecutar, nunca está en el archivo. Todo esto es texto plano versionado "
 "en git: se revisa en un pull request y se revierte como cualquier código.")
swap("5:00–5:50", f'''<section data-notes="{n6}">
  <div class="diagwrap">
    <div class="kicker an">El agente</div>
    <div class="fill">
      <div class="win an" style="--d:.1s">
        <div class="win-bar"><i style="background:#ff5f57"></i><i style="background:#febc2e"></i><i style="background:#28c840"></i>
          <span class="t">milton@dataplat — agent/</span></div>
        <div class="win-body"><span class="p">$</span> tree agent/

<span class="d">agent/</span>
├── <span class="f">CLAUDE.md</span>              <span class="c">las reglas duras · se carga en cada sesión</span>
├── <span class="f">MEMORY.md</span>              <span class="c">índice corto de lo aprendido</span>
├── <span class="d">memory/</span>                <span class="c">un archivo por tema, con su porqué</span>
│   ├── <span class="f">incidente-kafka-retencion.md</span>
│   ├── <span class="f">leccion-drift-fuera-de-iac.md</span>
│   └── <span class="f">feedback-no-declarar-acceso-denegado.md</span>
├── <span class="d">skills/</span>                <span class="c">un runbook por situación</span>
│   ├── <span class="f">ecs-crash-loop/SKILL.md</span>
│   ├── <span class="f">mongo-disco-lleno/SKILL.md</span>
│   └── <span class="f">kafka-retencion/SKILL.md</span>
├── <span class="d">commands/</span>              <span class="c">el día a día</span>
│   ├── <span class="f">daily-check.md</span>   <span class="f">ecs-debug.md</span>
│   └── <span class="f">ecs-deploy.md</span>   <span class="f">audit-security-groups.md</span>
└── <span class="f">.mcp.json</span>              <span class="c">herramientas · el secreto se lee del entorno</span>

<span class="g">✓</span> texto plano, versionado en git · se revisa en un PR y se revierte como código
<span class="q">→</span> github.com/mhilara/ai-agents-in-production</div>
      </div>
    </div>
  </div>
</section>''')

# ───────────────────────── 7 · la evolución (absorbe la de memoria)
def col(x, titulo, color, nodos, d0):
    out = [f'<text class="lb2" x="{x}" y="46" text-anchor="middle" style="fill:{color};font-size:26px">{titulo}</text>']
    y = 96
    for i, (etq, sub) in enumerate(nodos):
        out.append(f'''<g class="an" style="--d:{d0+i*0.09:.2f}s">
        <circle cx="{x}" cy="{y}" r="21" fill="#0d131b" stroke="{color}" stroke-width="1.8"/>
        <circle cx="{x}" cy="{y}" r="6" fill="{color}"/>
        <text class="lb5" x="{x+34}" y="{y-2}" style="fill:#e6eef7;font-size:16px">{etq}</text>
        <text class="lb5" x="{x+34}" y="{y+18}" style="font-size:13px">{sub}</text></g>''')
        if i < len(nodos) - 1:
            out.append(f'<path class="draw" style="--d:{d0+i*0.09+0.05:.2f}s;--len:44;stroke:{color};stroke-width:1.8;fill:none;opacity:.6" d="M{x} {y+21} L{x} {y+55}"/>')
        y += 76
    return '\n      '.join(out), y

c1, y1 = col(150, "RAG", "#5B9DF9", [("Pregunta","del operador"),("Embeddings","384 dimensiones"),("Base vectorial","busca por significado"),("Contexto","el fragmento que aplica"),("Modelo","responde")], .12)
c2, y2 = col(560, "Agentic RAG", "#B96BFF", [("Pregunta","del operador"),("Agente","decide si busca"),("Herramientas","vector · base · API"),("Contexto","lo que hizo falta"),("Modelo","responde y verifica")], .3)
c3, y3 = col(970, "Memoria", "#5ee89a", [("Pregunta","del operador"),("Agente","busca y escribe"),("Memoria","lee · guarda lo nuevo"),("Contexto","lo de hoy y lo de antes"),("Modelo","responde y aprende")], .48)

n7 = ("<b>5:50–6:50</b> · RAG significa Retrieval-Augmented Generation: generación aumentada por recuperación. "
 "En castellano: antes de responder, el sistema recupera información externa y el modelo responde con eso a la "
 "vista, en vez de responder solo con lo que memorizó cuando lo entrenaron. Mirá las tres columnas, que son tres "
 "generaciones. La primera, RAG clásico: la pregunta siempre pasa por la base vectorial, siempre, aunque no haga "
 "falta. La segunda, Agentic RAG: el agente decide SI busca, qué herramienta usa y cuándo parar. Y la tercera, que "
 "es donde estamos yendo: memoria. El agente no solo lee, también escribe: guarda lo que aprendió y mañana lo "
 "recupera. La diferencia entre la primera y la tercera columna es la diferencia entre un buscador y un colega.")
swap("5:50–6:50", f'''<section data-notes="{n7}">
  <div class="diagwrap">
    <div class="kicker an">Qué es RAG</div>
    <div class="fill">
    <svg class="diag" viewBox="0 0 1180 560">
      <g class="an" style="--d:.05s">
        <text class="lb5" x="20" y="24" style="font-size:15px;fill:#8496aa">RAG · Retrieval-Augmented Generation — el modelo responde con información recuperada, no solo con lo que memorizó</text>
      </g>
      {c1}
      <line class="ln" x1="355" y1="70" x2="355" y2="500" opacity=".3" stroke-dasharray="6 6"/>
      {c2}
      <line class="ln" x1="765" y1="70" x2="765" y2="500" opacity=".3" stroke-dasharray="6 6"/>
      {c3}
      <g class="an" style="--d:.9s">
        <text class="lb5" x="150" y="534" text-anchor="middle" style="font-size:14px">siempre busca</text>
        <text class="lb5" x="560" y="534" text-anchor="middle" style="font-size:14px;fill:#c89bff">decide si busca</text>
        <text class="lb5" x="970" y="534" text-anchor="middle" style="font-size:14px;fill:#5ee89a">busca, guarda y recuerda</text>
      </g>
    </svg>
    </div>
  </div>
</section>''')

# ───────────────────────── 8 · memoria, como capas de terminal
n8 = ("<b>6:50–7:30</b> · Memoria son tres capas con vidas distintas. Las instrucciones se cargan enteras en "
 "cada sesión, siempre. La memoria operativa se escribe solo cuando el agente aprende algo o cuando yo lo "
 "corrijo, y se lee cuando hace falta. Y la vectorial nunca se lee entera: se recupera solo el fragmento que "
 "aplica. La diferencia con un chat es que un chat recuerda mientras dura la conversación y después olvida. "
 "Esto persiste entre sesiones, entre días y entre personas del equipo.")
swap("6:50–7:30", f'''<section data-notes="{n8}">
  <div class="diagwrap">
    <div class="kicker an">Qué es memoria</div>
    <div class="fill">
      <div class="win an" style="--d:.1s">
        <div class="win-bar"><i style="background:#ff5f57"></i><i style="background:#febc2e"></i><i style="background:#28c840"></i>
          <span class="t">memoria del agente — tres capas</span></div>
        <div class="win-body"><span class="c">CAPA                    ARCHIVO                      CUÁNDO ACTÚA                       VIDA</span>
<span class="c">─────────────────────────────────────────────────────────────────────────────────────────────</span>
<span class="q">1</span> <span class="f">instrucciones</span>         <span class="d">CLAUDE.md</span>                    se carga entera                    <span class="g">siempre</span>
                                                     <span class="c">en cada sesión, sin excepción</span>

<span class="q">2</span> <span class="f">memoria operativa</span>     <span class="d">MEMORY.md + memory/</span>          se escribe al aprender             <span class="q">permanente</span>
                                                     <span class="c">se lee cuando hace falta</span>

<span class="q">3</span> <span class="f">vectorial</span>             <span class="d">Qdrant</span>                       se recupera, no se lee             <span class="b">bajo demanda</span>
                                                     <span class="c">solo el fragmento que aplica</span>
<span class="c">─────────────────────────────────────────────────────────────────────────────────────────────</span>

<span class="r">✗</span> un chat recuerda mientras dura la conversación
<span class="g">✓</span> esto persiste entre sesiones, entre días y entre personas del equipo</div>
      </div>
    </div>
  </div>
</section>''')

pathlib.Path('charla.html').write_text(t)
print('laminas 6, 7 y 8 reconstruidas')
