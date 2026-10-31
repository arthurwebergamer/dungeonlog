#!/usr/bin/env python3
"""Gerador do blog (HTML estatico, sem CMS). Uso, a partir da raiz do repo:

    python3 blog/_fonte/novo.py            # regenera tudo a partir de blog/_fonte/artigos/*.html

Cada artigo-fonte (blog/_fonte/artigos/<slug>.html) tem um cabecalho e o corpo em HTML:

    titulo: Titulo do artigo
    descricao: Resumo de ate ~155 caracteres
    data: 2026-11-07
    publicar: sim          (qualquer outro valor = rascunho: nao gera pagina nem entra no sitemap)
    ---
    <p>Corpo em HTML...</p>

O script gera blog/<slug>/index.html (canonical, OG e JSON-LD Article), regenera
blog/index.html (lista; fica noindex enquanto nao houver artigo publicado) e
atualiza as URLs /blog/ e /blog/<slug>/ no sitemap.xml. Python stdlib apenas.
"""
import html, json, re, sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2] if len(sys.argv) < 2 else Path(sys.argv[1]).resolve()
FONTE = RAIZ / 'blog' / '_fonte'
BASE = 'https://dungeonlog.weberlabs.com.br'
SLUG_OK = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')

def ler(p): return p.read_text(encoding='utf-8')

def carregar(p):
    cab, _, corpo = ler(p).partition('\n---\n')
    meta = {}
    for linha in cab.splitlines():
        if ':' in linha:
            k, v = linha.split(':', 1); meta[k.strip().lower()] = v.strip()
    meta['slug'] = p.stem
    meta['corpo'] = corpo.strip()
    for k in ('titulo', 'descricao', 'data'):
        if not meta.get(k): sys.exit(f'{p.name}: falta "{k}:" no cabecalho')
    if not SLUG_OK.match(meta['slug']): sys.exit(f'{p.name}: nome de arquivo (slug) invalido')
    if not re.match(r'^\d{4}-\d{2}-\d{2}$', meta['data']): sys.exit(f'{p.name}: data deve ser AAAA-MM-DD')
    return meta

def data_br(d): a, m, di = d.split('-'); return f'{di}/{m}/{a}'

def jsonld(m, url):
    return json.dumps({
        '@context': 'https://schema.org', '@type': 'Article',
        'headline': m['titulo'], 'description': m['descricao'],
        'datePublished': m['data'], 'dateModified': m['data'],
        'inLanguage': 'pt-BR', 'mainEntityOfPage': url, 'url': url,
        'image': f'{BASE}/img/og-pt.jpg',
        'author': {'@type': 'Organization', 'name': 'Weberlabs', 'url': BASE + '/'},
        'publisher': {'@type': 'Organization', 'name': 'Weberlabs', 'url': BASE + '/'},
    }, ensure_ascii=False)

def main():
    arts = [carregar(p) for p in sorted((FONTE / 'artigos').glob('*.html'))]
    pub = sorted([a for a in arts if a.get('publicar', '').lower() in ('sim', 'true')], key=lambda a: a['data'], reverse=True)
    modelo = ler(FONTE / 'modelo-artigo.html')
    for a in pub:
        url = f"{BASE}/blog/{a['slug']}/"
        esc = lambda s: html.escape(s, quote=True)
        saida = (modelo.replace('{{TITULO}}', esc(a['titulo'])).replace('{{DESCRICAO}}', esc(a['descricao']))
                 .replace('{{URL}}', url).replace('{{DATA}}', a['data']).replace('{{DATA_BR}}', data_br(a['data']))
                 .replace('{{JSONLD}}', jsonld(a, url).replace('</', '<\\/')).replace('{{CONTEUDO}}', a['corpo']))
        d = RAIZ / 'blog' / a['slug']; d.mkdir(parents=True, exist_ok=True)
        (d / 'index.html').write_text(saida, encoding='utf-8')
    # indice
    if pub:
        lista = '\n  <ul>\n' + '\n'.join(
            f'    <li><a href="/blog/{a["slug"]}/">{html.escape(a["titulo"])}</a> <span class="updated">· {data_br(a["data"])}</span></li>' for a in pub) + '\n  </ul>'
        robots = ''
    else:
        lista = '\n  <p>Em breve.</p>'
        robots = '<meta name="robots" content="noindex">\n'
    (RAIZ / 'blog' / 'index.html').write_text(ler(FONTE / 'modelo-indice.html').replace('{{LISTA}}', lista).replace('{{ROBOTS}}', robots), encoding='utf-8')
    # sitemap: remove entradas /blog e re-adiciona so se houver artigo publicado
    sm = RAIZ / 'sitemap.xml'; x = ler(sm)
    x = re.sub(r'  <url><loc>' + re.escape(BASE) + r'/blog/[^<]*</loc>.*?</url>\n', '', x, flags=re.S)
    if pub:
        ultima = pub[0]['data']
        novas = f'  <url><loc>{BASE}/blog/</loc><lastmod>{ultima}</lastmod>\n  </url>\n' + ''.join(
            f'  <url><loc>{BASE}/blog/{a["slug"]}/</loc><lastmod>{a["data"]}</lastmod>\n  </url>\n' for a in pub)
        x = x.replace('</urlset>', novas + '</urlset>')
    sm.write_text(x, encoding='utf-8')
    print(f'{len(pub)} artigo(s) publicado(s); {len(arts) - len(pub)} rascunho(s).')

main()
