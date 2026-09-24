locals {
  # Tablero de estado del servicio. No es una pagina estatica: mide su propia
  # latencia contra el balanceador cada dos segundos y la grafica en vivo.
  # Las variables del shell ($APP_VERSION) las resuelve el contenedor al arrancar.
  pagina = <<-HTML
    <!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>ingest-api</title><style>
    :root{--bg:#05070a;--panel:#111821;--line:#222c38;--ink:#e9f0f7;--muted:#8095ab;
    --ok:#3ddc84;--acc:#FF9900;--bad:#ff6b6b}
    *{margin:0;padding:0;box-sizing:border-box}
    body{min-height:100vh;background:var(--bg);color:var(--ink);
    font-family:-apple-system,"Segoe UI",Inter,sans-serif;padding:26px 22px 40px}
    body::before{content:"";position:fixed;inset:0;z-index:0;pointer-events:none;
    background-image:radial-gradient(circle at 1px 1px,rgba(148,170,196,.13) 1px,transparent 0);
    background-size:32px 32px;
    -webkit-mask-image:radial-gradient(ellipse 80% 70% at 50% 40%,#000 15%,transparent 75%)}
    body::after{content:"";position:fixed;inset:0;z-index:0;pointer-events:none;background:
    radial-gradient(48vw 38vw at 88% -8%,rgba(255,153,0,.13),transparent 60%),
    radial-gradient(42vw 32vw at -5% 105%,rgba(90,130,255,.11),transparent 60%)}
    .wrap{position:relative;z-index:1;max-width:1180px;margin:0 auto}
    header{display:flex;align-items:flex-end;justify-content:space-between;gap:20px;
    flex-wrap:wrap;padding-bottom:20px;border-bottom:1px solid var(--line)}
    h1{font-size:clamp(30px,5vw,54px);font-weight:800;letter-spacing:-.035em;line-height:1}
    h1 span{color:var(--acc)}
    .estado{display:flex;align-items:center;gap:10px;font-size:12px;font-weight:700;
    letter-spacing:.2em;text-transform:uppercase;color:var(--ok);margin-bottom:10px}
    .dot{width:10px;height:10px;border-radius:50%;background:var(--ok);
    box-shadow:0 0 0 0 rgba(61,220,132,.7);animation:pulse 2s infinite}
    @keyframes pulse{70%%{box-shadow:0 0 0 14px rgba(61,220,132,0)}100%%{box-shadow:0 0 0 0 rgba(61,220,132,0)}}
    .up{text-align:right}
    .up .n{font-family:ui-monospace,Menlo,monospace;font-size:clamp(20px,3vw,32px);font-weight:700}
    .up .l{font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);margin-top:4px}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(215px,1fr));gap:14px;margin-top:22px}
    .card{background:linear-gradient(180deg,var(--panel),#0b1118);border:1px solid var(--line);
    border-radius:14px;padding:16px 18px}
    .card h3{font-size:10.5px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);
    font-weight:700;margin-bottom:10px}
    .card .v{font-family:ui-monospace,Menlo,monospace;font-size:clamp(17px,2.2vw,26px);font-weight:700}
    .card .s{font-size:12.5px;color:var(--muted);margin-top:6px}
    .chart{margin-top:14px;background:linear-gradient(180deg,var(--panel),#0b1118);
    border:1px solid var(--line);border-radius:14px;padding:16px 18px}
    .chart-h{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:8px}
    .chart-h h3{font-size:10.5px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);font-weight:700}
    .chart-h b{font-family:ui-monospace,Menlo,monospace;font-size:19px;color:var(--acc)}
    svg{width:100%;height:110px;display:block}
    .log{margin-top:14px;background:#05080c;border:1px solid var(--line);border-radius:14px;
    padding:14px 18px;font-family:ui-monospace,Menlo,monospace;font-size:12.5px;line-height:1.85;
    max-height:168px;overflow:hidden;color:#9fb3c8}
    .log b{color:var(--ok);font-weight:600}
    .log i{color:var(--muted);font-style:normal}
    footer{margin-top:22px;font-size:12.5px;color:var(--muted);line-height:1.7}
    footer a{color:var(--acc);text-decoration:none}
    </style></head><body><div class="wrap">
    <header>
      <div>
        <div class="estado"><span class="dot"></span>servicio operativo</div>
        <h1>ingest-api <span>v$APP_VERSION</span></h1>
      </div>
      <div class="up"><div class="n" id="up">--</div><div class="l">tiempo en linea</div></div>
    </header>

    <div class="grid">
      <div class="card"><h3>Plataforma</h3><div class="v">ECS Fargate</div>
        <div class="s">0,25 vCPU · 0,5 GB · sin IP publica</div></div>
      <div class="card"><h3>Region</h3><div class="v">us-east-2</div>
        <div class="s">dos zonas de disponibilidad</div></div>
      <div class="card"><h3>Despliegue</h3><div class="v">pipeline</div>
        <div class="s">OIDC · sin llaves guardadas</div></div>
      <div class="card"><h3>Sondas</h3><div class="v" id="n">0</div>
        <div class="s"><span id="err">0</span> fallidas · cada 2 s</div></div>
    </div>

    <div class="chart">
      <div class="chart-h"><h3>Latencia extremo a extremo</h3><b id="ms">-- ms</b></div>
      <svg id="g" viewBox="0 0 600 110" preserveAspectRatio="none">
        <defs><linearGradient id="f" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#FF9900" stop-opacity=".30"/>
          <stop offset="100%" stop-color="#FF9900" stop-opacity="0"/></linearGradient></defs>
        <path id="area" fill="url(#f)"></path>
        <path id="line" fill="none" stroke="#FF9900" stroke-width="2" stroke-linejoin="round"></path>
      </svg>
    </div>

    <div class="log" id="log"></div>

    <footer>Plataforma de datos operada por un agente de IA con acceso de solo lectura.
    Cada cambio entra por infraestructura como codigo, con autorizacion humana.<br>
    <a href="https://github.com/mhilara/ai-agents-in-production">github.com/mhilara/ai-agents-in-production</a>
    </footer></div>

    <script>
    var arranque = ARRANQUE * 1000, datos = [], n = 0, err = 0;
    function el(i){ return document.getElementById(i) }

    function dos(x){ return (x < 10 ? "0" : "") + x }
    function tiempo(){
      var s = Math.floor((Date.now() - arranque) / 1000);
      var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
      el("up").textContent = dos(h) + ":" + dos(m) + ":" + dos(s % 60);
    }

    function dibujar(){
      if (!datos.length) return;
      var mx = Math.max.apply(null, datos) * 1.25 || 1, p = "", i, x, y;
      for (i = 0; i < datos.length; i++){
        x = (i / Math.max(datos.length - 1, 1)) * 600;
        y = 105 - (datos[i] / mx) * 95;
        p += (i ? "L" : "M") + x.toFixed(1) + " " + y.toFixed(1);
      }
      el("line").setAttribute("d", p);
      el("area").setAttribute("d", p + "L600 110L0 110Z");
    }

    function registrar(ms, ok){
      var t = new Date().toTimeString().slice(0, 8);
      var fila = ok
        ? '<i>' + t + '</i>  GET /health.json  <b>200</b>  ' + ms + ' ms'
        : '<i>' + t + '</i>  GET /health.json  <span style="color:#ff6b6b">error</span>';
      var l = el("log");
      l.innerHTML = fila + "<br>" + l.innerHTML;
      if (l.childNodes.length > 60) l.innerHTML = l.innerHTML.split("<br>").slice(0, 10).join("<br>");
    }

    function sondear(){
      var t0 = performance.now();
      fetch("health.json?t=" + Date.now(), { cache: "no-store" })
        .then(function(r){ if (!r.ok) throw 0; return r.json() })
        .then(function(){
          var ms = Math.round(performance.now() - t0);
          n++; datos.push(ms); if (datos.length > 60) datos.shift();
          el("n").textContent = n; el("ms").textContent = ms + " ms";
          dibujar(); registrar(ms, true);
        })
        .catch(function(){ n++; err++; el("n").textContent = n; el("err").textContent = err; registrar(0, false) });
    }

    tiempo(); setInterval(tiempo, 1000);
    sondear(); setInterval(sondear, 2000);
    </script></body></html>
  HTML
}
