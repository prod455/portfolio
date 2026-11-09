#!/usr/bin/env bash
# Publica o site em https://prod455.pages.dev (Cloudflare Pages, projeto prod455).
# Empacota index.html, img/, robots.txt e sitemap.xml num _worker.js e manda pela API.
# Precisa de CLOUDFLARE_API_TOKEN com Pages:Edit (atrás do proxy que injeta a credencial, qualquer valor serve).
set -euo pipefail
cd "$(dirname "$0")"
if grep -q PREENCHER index.html robots.txt sitemap.xml; then echo "rode ./preencher.sh antes" >&2; exit 1; fi
conta=0b8babe977ef3fc27badc2c00323d334
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
python3 - "$tmp/_worker.js" <<'PY'
import base64, json, os, sys
tipos = {".html": "text/html; charset=utf-8", ".webp": "image/webp", ".txt": "text/plain; charset=utf-8", ".xml": "application/xml"}
arquivos = {}
imagens = sorted(os.path.join(r, f) for r, _, fs in os.walk("img") for f in fs)
for nome in ["index.html", "robots.txt", "sitemap.xml"] + imagens:
    arquivos["/" + nome] = [tipos[os.path.splitext(nome)[1]], base64.b64encode(open(nome, "rb").read()).decode()]
arquivos["/"] = arquivos["/index.html"]
js = """const F=%s;
const bin=(b)=>Uint8Array.from(atob(b),c=>c.charCodeAt(0));
export default{async fetch(req){const f=F[new URL(req.url).pathname];
if(!f)return new Response("Página não encontrada",{status:404,headers:{"content-type":"text/plain; charset=utf-8"}});
return new Response(bin(f[1]),{headers:{"content-type":f[0],"x-content-type-options":"nosniff","referrer-policy":"strict-origin-when-cross-origin","cache-control":f[0].startsWith("image/")?"public, max-age=604800":"public, max-age=300"}});}};""" % json.dumps(arquivos)
open(sys.argv[1], "w").write(js)
PY
curl -sS -X POST -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN:?defina CLOUDFLARE_API_TOKEN}" \
  "https://api.cloudflare.com/client/v4/accounts/$conta/pages/projects/prod455/deployments" \
  -F "manifest={}" -F "branch=main" -F "_worker.js=@$tmp/_worker.js;type=application/javascript" \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print('publicado:',d['result']['url']) if d['success'] else sys.exit(str(d['errors']))"
