locals {
  # Lo que ve cualquiera que abra la URL del servicio durante la charla.
  # Las variables del shell ($APP_VERSION) las resuelve el contenedor al arrancar.
  pagina = <<-HTML
    <!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>ingest-api</title><style>
    *{margin:0;padding:0;box-sizing:border-box}
    body{min-height:100vh;background:#05070a;color:#f2f6fa;display:grid;place-items:center;
    font-family:-apple-system,"Segoe UI",Inter,sans-serif;overflow:hidden}
    body::before{content:"";position:fixed;inset:0;
    background-image:radial-gradient(circle at 1px 1px,rgba(148,170,196,.16) 1px,transparent 0);
    background-size:34px 34px;
    -webkit-mask-image:radial-gradient(ellipse 70% 60% at 50% 50%,#000 10%,transparent 75%)}
    body::after{content:"";position:fixed;inset:0;background:
    radial-gradient(50vw 40vw at 85% -10%,rgba(255,153,0,.16),transparent 60%),
    radial-gradient(45vw 35vw at -5% 105%,rgba(90,130,255,.13),transparent 60%);
    animation:drift 22s ease-in-out infinite alternate}
    @keyframes drift{to{transform:translate3d(-3%,2%,0) scale(1.06)}}
    .card{position:relative;z-index:1;text-align:center;padding:0 24px}
    .dot{width:12px;height:12px;border-radius:50%;background:#4ade80;display:inline-block;
    margin-right:10px;box-shadow:0 0 0 0 rgba(74,222,128,.7);animation:pulse 2s infinite}
    @keyframes pulse{70%%{box-shadow:0 0 0 16px rgba(74,222,128,0)}100%%{box-shadow:0 0 0 0 rgba(74,222,128,0)}}
    .estado{font-size:13px;letter-spacing:.22em;text-transform:uppercase;color:#5ee89a;font-weight:700}
    h1{font-size:clamp(44px,11vw,118px);font-weight:800;letter-spacing:-.045em;line-height:1;
    margin:18px 0 6px;background:linear-gradient(180deg,#fff,#93a4b8);-webkit-background-clip:text;
    -webkit-text-fill-color:transparent}
    .ver{font-family:ui-monospace,Menlo,monospace;font-size:clamp(20px,4vw,38px);color:#FF9900;font-weight:700}
    .meta{margin-top:34px;display:flex;gap:14px;justify-content:center;flex-wrap:wrap}
    .chip{border:1px solid #2b3644;border-radius:999px;padding:9px 18px;font-size:13px;color:#93a4b8;
    background:rgba(18,24,32,.7);backdrop-filter:blur(8px)}
    .chip b{color:#e6eef7;font-weight:600}
    .pie{margin-top:40px;font-size:13px;color:#5d6b7d;line-height:1.7}
    .pie a{color:#FF9900;text-decoration:none}
    </style></head><body><div class="card">
    <div class="estado"><span class="dot"></span>servicio operativo</div>
    <h1>ingest-api</h1>
    <div class="ver">v$APP_VERSION</div>
    <div class="meta">
      <span class="chip">ECS <b>Fargate</b></span>
      <span class="chip">region <b>us-east-2</b></span>
      <span class="chip">desplegado por <b>pipeline</b></span>
      <span class="chip">sin llaves <b>OIDC</b></span>
    </div>
    <div class="pie">Plataforma de datos operada por un agente de IA con acceso de solo lectura.<br>
    Cada cambio entra por infraestructura como codigo, con autorizacion humana.<br>
    <a href="https://github.com/mhilara/ai-agents-in-production">github.com/mhilara/ai-agents-in-production</a></div>
    </div></body></html>
  HTML
}
