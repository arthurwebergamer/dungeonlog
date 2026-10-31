#!/usr/bin/env python3
"""Avisa o IndexNow (Bing, Yandex etc.) das URLs novas ou atualizadas do sitemap.xml. Stdlib apenas.

    python blog/_fonte/indexnow.py             # envia so o que e novo ou tem lastmod mais recente que o ultimo envio
    python blog/_fonte/indexnow.py --dry-run   # so imprime as URLs, nao envia nem grava estado
    python blog/_fonte/indexnow.py --todas     # ignora o estado e envia tudo

Estado: blog/_fonte/indexnow-estado.json ({url: lastmod enviado}); so e gravado apos envio aceito (200/202).
Prova de dono: o arquivo <chave>.txt na raiz do site deve conter a chave.
"""
import json, sys, urllib.request, urllib.error
import xml.etree.ElementTree as ET
from pathlib import Path

CHAVE = "a7c8f0cdaf3f2d066b75eeb369f54abe"
HOST = "dungeonlog.weberlabs.com.br"
ENDPOINT = "https://api.indexnow.org/indexnow"
RAIZ = Path(__file__).resolve().parents[2]
ESTADO = Path(__file__).resolve().parent / "indexnow-estado.json"
NS = "{http://www.sitemaps.org/schemas/sitemap/0.9}"

def ler_sitemap():
    r = ET.parse(RAIZ / "sitemap.xml").getroot()
    return {u.findtext(NS + "loc").strip(): (u.findtext(NS + "lastmod") or "").strip() for u in r.iter(NS + "url")}

def ler_estado():
    try:
        return json.loads(ESTADO.read_text(encoding="utf-8") or "{}")
    except (FileNotFoundError, ValueError):
        return {}

def main():
    dry, todas = "--dry-run" in sys.argv, "--todas" in sys.argv
    site, estado = ler_sitemap(), ({} if "--todas" in sys.argv else ler_estado())
    novas = [u for u, lm in site.items() if u not in estado or lm > estado[u]]
    if not novas:
        print("Nada novo para enviar."); return 0
    print(f"{len(novas)} URL(s) para enviar:")
    for u in novas: print("  " + u)
    if dry:
        print("(dry-run: nada enviado)"); return 0
    corpo = json.dumps({"host": HOST, "key": CHAVE, "keyLocation": f"https://{HOST}/{CHAVE}.txt", "urlList": novas}).encode("utf-8")
    req = urllib.request.Request(ENDPOINT, data=corpo, method="POST", headers={"Content-Type": "application/json; charset=utf-8"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r: cod = r.status
    except urllib.error.HTTPError as e:
        cod = e.code
    except OSError as e:
        print(f"Erro de rede: {e}"); return 1
    if cod in (200, 202):
        novo = ler_estado(); novo.update({u: site[u] for u in novas})
        ESTADO.write_text(json.dumps(novo, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"IndexNow aceitou (HTTP {cod})."); return 0
    print(f"IndexNow recusou: HTTP {cod} (400 requisicao invalida, 403 chave nao confere, 422 URLs fora do host, 429 muitas requisicoes). Sem nova tentativa.")
    return 1

sys.exit(main())
