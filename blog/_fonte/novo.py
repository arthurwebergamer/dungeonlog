#!/usr/bin/env python3
"""Gerador do blog (HTML estatico, sem CMS). Uso, a partir da raiz do repo:

    python3 blog/_fonte/novo.py            # regenera tudo a partir de blog/_fonte/artigos/*.html

Cada artigo-fonte (blog/_fonte/artigos/<slug>.html) tem um cabecalho e o corpo em HTML:

    idioma: pt             (pt = padrao, saida em /blog/<slug>/; en = saida em /en/blog/<slug>/)
    slug: meu-slug         (opcional; padrao = nome do arquivo sem .html; o slug e unico por idioma)
    titulo: Titulo do artigo
    descricao: Resumo de ate ~155 caracteres
    data: 2026-11-07
    publicar: sim          (qualquer outro valor = rascunho: nao gera pagina nem entra no sitemap)
    ---
    <p>Corpo em HTML...</p>

O script gera blog/<slug>/index.html (PT) ou en/blog/<slug>/index.html (EN), com canonical, OG e
JSON-LD Article; regenera blog/index.html e en/blog/index.html (cada um lista so os artigos do seu
idioma; ficam noindex enquanto nao houver artigo publicado nele) e atualiza as URLs de blog
(indices e artigos, PT e EN) no sitemap.xml. Python stdlib apenas.
"""
import html, json, re, sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2] if len(sys.argv) < 2 else Path(sys.argv[1]).resolve()
FONTE = RAIZ / 'blog' / '_fonte'
BASE = 'https://dungeonlog.weberlabs.com.br'
SLUG_OK = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')

IDIOMAS = {
    'pt': dict(lang='pt-BR', ogloc='pt_BR', ogimg='og-pt.jpg', pre='/blog/', home='/', homet='Início',
               nav='Navegação', legal='Legal', priv='/privacy', privt='Política de Privacidade', terms='/terms',
               termst='Termos de Uso', delete='/delete-account', deletet='Excluir Conta', contact='Contato',
               email='E-mail', copy='© 2026 Weberlabs. Todos os direitos reservados.',
               know='Conheça o Dungeonlog', play='Baixe o Dungeonlog no Google Play',
               idxdesc='Artigos do Dungeonlog.', breve='Em breve.', data=lambda d: f'{d[8:]}/{d[5:7]}/{d[:4]}'),
    'en': dict(lang='en', ogloc='en_US', ogimg='og-en.jpg', pre='/en/blog/', home='/en/', homet='Home',
               nav='Navigation', legal='Legal', priv='/en/privacy', privt='Privacy Policy', terms='/en/terms',
               termst='Terms of Use', delete='/en/delete-account', deletet='Delete Account', contact='Contact',
               email='Email', copy='© 2026 Weberlabs. All rights reserved.',
               know='Meet Dungeonlog', play='Get Dungeonlog on Google Play',
               idxdesc='Dungeonlog articles.', breve='Coming soon.', data=lambda d: d),
}
LOC = {'pt': 'pt-BR', 'en': 'en-US'}

def ler(p): return p.read_text(encoding='utf-8')

def carregar(p):
    cab, _, corpo = ler(p).partition('\n---\n')
    meta = {}
    for linha in cab.splitlines():
        if ':' in linha:
            k, v = linha.split(':', 1); meta[k.strip().lower()] = v.strip()
    meta['idioma'] = meta.get('idioma', 'pt').lower()
    if meta['idioma'] not in IDIOMAS: sys.exit(f'{p.name}: idioma deve ser pt ou en')
    meta['slug'] = meta.get('slug', p.stem)
    meta['corpo'] = corpo.strip()
    for k in ('titulo', 'descricao', 'data'):
        if not meta.get(k): sys.exit(f'{p.name}: falta "{k}:" no cabecalho')
    if not SLUG_OK.match(meta['slug']): sys.exit(f'{p.name}: nome de arquivo (slug) invalido')
    if not re.match(r'^\d{4}-\d{2}-\d{2}$', meta['data']): sys.exit(f'{p.name}: data deve ser AAAA-MM-DD')
    return meta

def data_br(d, i='pt'): return IDIOMAS[i]['data'](d)

def trocas(i):
    t = IDIOMAS[i]
    return {'{{LANG}}': t['lang'], '{{OGLOCALE}}': t['ogloc'], '{{OGIMG}}': t['ogimg'], '{{HOMEURL}}': t['home'],
            '{{HOME}}': t['homet'], '{{BLOGURL}}': t['pre'], '{{T_NAV}}': t['nav'], '{{T_LEGAL}}': t['legal'],
            '{{PRIVACY}}': t['priv'], '{{T_PRIVACY}}': t['privt'], '{{TERMS}}': t['terms'], '{{T_TERMS}}': t['termst'],
            '{{DELETE}}': t['delete'], '{{T_DELETE}}': t['deletet'], '{{T_CONTACT}}': t['contact'],
            '{{T_EMAIL}}': t['email'], '{{T_COPY}}': t['copy'], '{{T_KNOW}}': t['know'], '{{T_PLAY}}': t['play'],
            '{{T_IDXDESC}}': t['idxdesc']}

def aplicar(modelo, d):
    for k, v in d.items(): modelo = modelo.replace(k, v)
    return modelo

def jsonld(m, url):
    return json.dumps({
        '@context': 'https://schema.org', '@type': 'Article',
        'headline': m['titulo'], 'description': m['descricao'],
        'datePublished': m['data'], 'dateModified': m['data'],
        'inLanguage': LOC[m['idioma']], 'mainEntityOfPage': url, 'url': url,
        'image': f"{BASE}/img/{IDIOMAS[m['idioma']]['ogimg']}",
        'author': {'@type': 'Organization', 'name': 'Weberlabs', 'url': BASE + '/'},
        'publisher': {'@type': 'Organization', 'name': 'Weberlabs', 'url': BASE + '/'},
    }, ensure_ascii=False)

def main():
    arts = [carregar(p) for p in sorted((FONTE / 'artigos').glob('*.html'))]
    pub = sorted([a for a in arts if a.get('publicar', '').lower() in ('sim', 'true')], key=lambda a: a['data'], reverse=True)
    vistos = set()
    for a in pub:
        if not SLUG_OK.match(a['slug']): sys.exit(f"slug invalido: {a['slug']}")
        if (a['idioma'], a['slug']) in vistos: sys.exit(f"slug duplicado em {a['idioma']}: {a['slug']}")
        vistos.add((a['idioma'], a['slug']))
    modelo = ler(FONTE / 'modelo-artigo.html')
    esc = lambda s: html.escape(s, quote=True)
    urls = []  # (url, lastmod) de blog para o sitemap
    for i in ('pt', 'en'):
        t = IDIOMAS[i]; pi = [a for a in pub if a['idioma'] == i]
        raiz_blog = RAIZ / t['pre'].strip('/')
        for a in pi:
            url = f"{BASE}{t['pre']}{a['slug']}/"
            saida = aplicar(modelo, trocas(i))
            saida = (saida.replace('{{TITULO}}', esc(a['titulo'])).replace('{{DESCRICAO}}', esc(a['descricao']))
                     .replace('{{URL}}', url).replace('{{DATA}}', a['data']).replace('{{DATA_BR}}', data_br(a['data'], i))
                     .replace('{{JSONLD}}', jsonld(a, url).replace('</', '<\\/')).replace('{{CONTEUDO}}', a['corpo']))
            d = raiz_blog / a['slug']; d.mkdir(parents=True, exist_ok=True)
            (d / 'index.html').write_text(saida, encoding='utf-8')
            urls.append((url, a['data']))
        # indice do idioma
        if pi:
            lista = '\n  <ul>\n' + '\n'.join(
                f'    <li><a href="{t["pre"]}{a["slug"]}/">{html.escape(a["titulo"])}</a> <span class="updated">· {data_br(a["data"], i)}</span></li>' for a in pi) + '\n  </ul>'
            robots = ''
            urls.append((f"{BASE}{t['pre']}", pi[0]['data']))
        else:
            lista = f'\n  <p>{t["breve"]}</p>'
            robots = '<meta name="robots" content="noindex">\n'
        raiz_blog.mkdir(parents=True, exist_ok=True)
        ind = aplicar(ler(FONTE / 'modelo-indice.html'), trocas(i)).replace('{{CANON}}', f"{BASE}{t['pre']}")
        (raiz_blog / 'index.html').write_text(ind.replace('{{LISTA}}', lista).replace('{{ROBOTS}}', robots), encoding='utf-8')
    # sitemap: remove entradas /blog/ e /en/blog/ e re-adiciona so as de idiomas com artigo publicado
    sm = RAIZ / 'sitemap.xml'; x = ler(sm)
    x = re.sub(r'  <url><loc>' + re.escape(BASE) + r'(?:/en)?/blog/[^<]*</loc>.*?</url>\n', '', x, flags=re.S)
    novas = ''.join(f'  <url><loc>{u}</loc><lastmod>{lm}</lastmod>\n  </url>\n' for u, lm in urls)
    x = x.replace('</urlset>', novas + '</urlset>')
    sm.write_text(x, encoding='utf-8')
    print(f'{len(pub)} artigo(s) publicado(s); {len(arts) - len(pub)} rascunho(s).')

main()
