#!/usr/bin/env python3
"""Gerador do blog (HTML estatico, sem CMS). Uso, a partir da raiz do repo:

    python3 blog/_fonte/novo.py            # regenera tudo a partir de blog/_fonte/artigos/*.html

Cada artigo-fonte (blog/_fonte/artigos/<slug>.html) tem um cabecalho e o corpo em HTML:

    idioma: pt             (pt = padrao, saida em /blog/<slug>/; en = saida em /en/blog/<slug>/)
    slug: meu-slug         (opcional; padrao = nome do arquivo sem .html; o slug e unico por idioma)
    titulo: Titulo do artigo
    descricao: Resumo de ate ~155 caracteres
    data: 2026-11-07
    capa: /blog/img/nome.jpg   (opcional; imagem 1200x630: card do indice, og:image e topo do artigo;
                                sem capa, usa /img/og-pt.jpg (ou og-en.jpg) e nada no topo)
    publicar: sim          (qualquer outro valor = rascunho: nao gera pagina nem entra no sitemap)
    ---
    <p>Corpo em HTML...</p>

O script gera blog/<slug>/index.html (PT) ou en/blog/<slug>/index.html (EN), com canonical, OG e
JSON-LD Article; regenera blog/index.html e en/blog/index.html (cada um lista so os artigos do seu
idioma; ficam noindex enquanto nao houver artigo publicado nele) e atualiza as URLs de blog
(indices e artigos, PT e EN) no sitemap.xml e o bloco "Ultimo post" das homes (entre <!--ULTIMO-POST--> e
<!--/ULTIMO-POST--> em index.html e en/index.html; vazio se o idioma nao tem artigo). Python stdlib apenas.
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
               termst='Termos de Uso', delete='/delete-account', deletet='Excluir Conta', contact='Contato', social='Redes',
               email='E-mail', copy='© 2026 Weberlabs. Todos os direitos reservados.',
               know='Conheça o Dungeonlog', play='Baixe o Dungeonlog no Google Play',
               idxdesc='Artigos sobre rotina, tarefas e hábitos com RPG, e novidades do Dungeonlog.', t_viewer='Visualizador de imagens', t_close='Fechar', t_prev='Anterior', t_next='Próxima', ttl='TikTok do Dungeonlog', igl='Instagram do Dungeonlog', ultimo='Último post do blog', nav_aria='Navegação do blog', voltar='Voltar ao blog', anterior='Post anterior', proximo='Próximo post', breve='Em breve.', data=lambda d: f'{d[8:]}/{d[5:7]}/{d[:4]}'),
    'en': dict(lang='en', ogloc='en_US', ogimg='og-en.jpg', pre='/en/blog/', home='/en/', homet='Home',
               nav='Navigation', legal='Legal', priv='/en/privacy', privt='Privacy Policy', terms='/en/terms',
               termst='Terms of Use', delete='/en/delete-account', deletet='Delete Account', contact='Contact', social='Social',
               email='Email', copy='© 2026 Weberlabs. All rights reserved.',
               know='Meet Dungeonlog', play='Get Dungeonlog on Google Play',
               idxdesc='Articles on routine, tasks and habits with RPG, and Dungeonlog news.', t_viewer='Image viewer', t_close='Close', t_prev='Previous', t_next='Next', ttl='Dungeonlog on TikTok', igl='Dungeonlog on Instagram', ultimo='Latest blog post', nav_aria='Blog navigation', voltar='Back to blog', anterior='Previous post', proximo='Next post', breve='Coming soon.', data=lambda d: d),
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
    meta['par'] = re.sub(r'-(?:pt|en)$', '', p.stem)  # pares PT/EN: mesmo nome de arquivo, so muda o sufixo
    meta['corpo'] = corpo.strip()
    for k in ('titulo', 'descricao', 'data'):
        if not meta.get(k): sys.exit(f'{p.name}: falta "{k}:" no cabecalho')
    if not SLUG_OK.match(meta['slug']): sys.exit(f'{p.name}: nome de arquivo (slug) invalido')
    capa = meta.get('capa', '')
    if capa and not re.match(r'^/[A-Za-z0-9_./-]+\.(?:jpg|jpeg|png|webp)$', capa): sys.exit(f'{p.name}: capa deve ser caminho absoluto no site (ex.: /blog/img/nome.jpg)')
    if not re.match(r'^\d{4}-\d{2}-\d{2}$', meta['data']): sys.exit(f'{p.name}: data deve ser AAAA-MM-DD')
    return meta

def data_br(d, i='pt'): return IDIOMAS[i]['data'](d)

def trocas(i):
    t = IDIOMAS[i]
    return {'{{LANG}}': t['lang'], '{{OGLOCALE}}': t['ogloc'], '{{OGIMG}}': t['ogimg'], '{{HOMEURL}}': t['home'],
            '{{HOME}}': t['homet'], '{{BLOGURL}}': t['pre'], '{{T_NAV}}': t['nav'], '{{T_LEGAL}}': t['legal'],
            '{{PRIVACY}}': t['priv'], '{{T_PRIVACY}}': t['privt'], '{{TERMS}}': t['terms'], '{{T_TERMS}}': t['termst'],
            '{{DELETE}}': t['delete'], '{{T_DELETE}}': t['deletet'], '{{T_CONTACT}}': t['contact'], '{{T_SOCIAL}}': t['social'],
            '{{T_EMAIL}}': t['email'], '{{T_COPY}}': t['copy'], '{{T_KNOW}}': t['know'], '{{T_PLAY}}': t['play'],
            '{{T_IDXDESC}}': t['idxdesc'], '{{T_VIEWER}}': t['t_viewer'], '{{T_CLOSE}}': t['t_close'],
            '{{T_TTLABEL}}': t['ttl'], '{{T_IGLABEL}}': t['igl'], '{{T_PREV}}': t['t_prev'], '{{T_NEXT}}': t['t_next']}

def seletor(i, a, pub):
    """Seletor PT | EN do cabecalho do blog: cada idioma leva ao artigo par (ou ao indice do idioma, se nao houver)."""
    alvo = {}
    for j in ('pt', 'en'):
        alvo[j] = IDIOMAS[j]['pre']
        if a:
            for b in pub:
                if b['idioma'] == j and b['par'] == a['par']: alvo[j] = f"{IDIOMAS[j]['pre']}{b['slug']}/"
    cl = lambda j: ' class="active"' if j == i else ''
    return (f'<a href="{alvo["pt"]}"{cl("pt")} hreflang="pt-BR">PT</a><span class="sep">·</span>'
            f'<a href="{alvo["en"]}"{cl("en")} hreflang="en">EN</a>')

def navegacao(i, ant, prox):
    """Bloco <nav> com Voltar ao blog e vizinhos (so os que existem)."""
    t = IDIOMAS[i]; e = lambda s: html.escape(s, quote=True)
    L = [f'<a class="bn-v" href="{t["pre"]}">&larr; {t["voltar"]}</a>']
    if ant: L.append(f'<a class="bn-p" href="{t["pre"]}{ant["slug"]}/" rel="prev"><small>&larr; {t["anterior"]}</small>{e(ant["titulo"])}</a>')
    if prox: L.append(f'<a class="bn-n" href="{t["pre"]}{prox["slug"]}/" rel="next"><small>{t["proximo"]} &rarr;</small>{e(prox["titulo"])}</a>')
    return f'<nav class="bnav" aria-label="{t["nav_aria"]}">' + ''.join(L) + '</nav>'

def aplicar(modelo, d):
    for k, v in d.items(): modelo = modelo.replace(k, v)
    return modelo

def imagem(m):
    return BASE + m['capa'] if m.get('capa') else f"{BASE}/img/{IDIOMAS[m['idioma']]['ogimg']}"

def script_ld(obj):
    return '<script type="application/ld+json">' + json.dumps(obj, ensure_ascii=False).replace('</', '<\\/') + '</script>'

def jsonld(m, url):
    t = IDIOMAS[m['idioma']]
    post = {
        '@context': 'https://schema.org', '@type': 'BlogPosting',
        'headline': m['titulo'], 'description': m['descricao'],
        'datePublished': m['data'], 'dateModified': m['data'],
        'inLanguage': LOC[m['idioma']], 'mainEntityOfPage': url,
        'image': imagem(m),
        'author': {'@type': 'Organization', 'name': 'Weberlabs'},
        'publisher': {'@type': 'Organization', 'name': 'Weberlabs'},
    }
    # breadcrumb visivel no artigo: Inicio > Blog (a pagina atual e o h1)
    crumbs = {
        '@context': 'https://schema.org', '@type': 'BreadcrumbList',
        'itemListElement': [
            {'@type': 'ListItem', 'position': 1, 'name': t['homet'], 'item': BASE + t['home']},
            {'@type': 'ListItem', 'position': 2, 'name': 'Blog', 'item': BASE + t['pre']},
            {'@type': 'ListItem', 'position': 3, 'name': m['titulo'], 'item': url},
        ],
    }
    return script_ld(post) + '\n' + script_ld(crumbs)

def pares(a, pub):
    """URLs {pt, en} do par do artigo a (ou dos indices, se a for None); None onde nao ha par."""
    par = {}
    for j in ('pt', 'en'):
        if a is None: par[j] = f"{BASE}{IDIOMAS[j]['pre']}" if any(b['idioma'] == j for b in pub) else None
        else:
            b = next((b for b in pub if b['idioma'] == j and b['par'] == a['par']), None)
            par[j] = f"{BASE}{IDIOMAS[j]['pre']}{b['slug']}/" if b else None
    return par

def alternates(i, par):
    """hreflang pt-BR, en e x-default (PT) se houver par; senao so o idioma da pagina."""
    if par['pt'] and par['en']: L = [('pt-BR', par['pt']), ('en', par['en']), ('x-default', par['pt'])]
    else: L = [(IDIOMAS[i]['lang'], par[i])]
    return '\n'.join(f'<link rel="alternate" hreflang="{h}" href="{u}">' for h, u in L)

def home_block(i, a):
    """Escreve o card do artigo mais recente da home do idioma entre <!--ULTIMO-POST--> e <!--/ULTIMO-POST-->."""
    t = IDIOMAS[i]; f = RAIZ / ('index.html' if i == 'pt' else 'en/index.html')
    if not f.exists(): return
    esc = lambda s: html.escape(s, quote=True)
    if a:
        u = f"{t['pre']}{a['slug']}/"
        capa = f'<a class="lp-img" href="{u}" tabindex="-1" aria-hidden="true"><img src="{esc(a["capa"])}" width="1200" height="630" alt="" loading="lazy" decoding="async"></a>' if a.get('capa') else ''
        NL = chr(10)
        bloco = NL.join([
            '<section class="block lp" aria-labelledby="lp-h">',
            '  <div class="wrapL">',
            f'    <h2 id="lp-h">{t["ultimo"]}</h2>',
            '    <article class="lp-card">',
            f'      {capa}',
            '      <div class="lp-txt">',
            f'        <h3><a href="{u}">{esc(a["titulo"])}</a></h3>',
            f'        <p class="lp-data"><time datetime="{a["data"]}">{data_br(a["data"], i)}</time></p>',
            f'        <p class="lp-desc">{esc(a["descricao"])}</p>',
            '      </div>', '    </article>', '  </div>', '</section>'])
    else:
        bloco = ''
    x = ler(f)
    novo, n = re.subn(r'<!--ULTIMO-POST-->.*?<!--/ULTIMO-POST-->', lambda m: '<!--ULTIMO-POST-->' + bloco + '<!--/ULTIMO-POST-->', x, flags=re.S)
    if n != 1: sys.exit(f'{f.name}: marcadores <!--ULTIMO-POST--> ausentes')
    f.write_text(novo, encoding='utf-8')

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
        cron = sorted(pi, key=lambda a: (a['data'], a['slug']))
        for a in pi:
            k = cron.index(a)
            nav = navegacao(i, cron[k-1] if k > 0 else None, cron[k+1] if k+1 < len(cron) else None)
            url = f"{BASE}{t['pre']}{a['slug']}/"
            saida = aplicar(modelo, trocas(i)).replace('{{LANGSW}}', seletor(i, a, pub)).replace('{{OGIMGURL}}', imagem(a))
            capa_html = f'<img class="capa" src="{esc(a["capa"])}" width="1200" height="630" alt="{esc(a["titulo"])}">' if a.get('capa') else ''
            saida = saida.replace('{{NAV}}', nav).replace('{{CAPA}}', capa_html)
            saida = (saida.replace('{{TITULO}}', esc(a['titulo'])).replace('{{DESCRICAO}}', esc(a['descricao']))
                     .replace('{{URL}}', url).replace('{{DATA}}', a['data']).replace('{{DATA_BR}}', data_br(a['data'], i))
                     .replace('{{JSONLD}}', jsonld(a, url)).replace('{{ALTERNATES}}', alternates(i, pares(a, pub))).replace('{{CONTEUDO}}', a['corpo']))
            d = raiz_blog / a['slug']; d.mkdir(parents=True, exist_ok=True)
            (d / 'index.html').write_text(saida, encoding='utf-8')
            urls.append((url, a['data'], pares(a, pub)))
        # indice do idioma
        modelo_ind = ler(FONTE / 'modelo-indice.html')
        card = re.search(r'<!--CARD-->(.*?)<!--/CARD-->', modelo_ind, re.S).group(1).strip('\n')
        modelo_ind = re.sub(r'[ \t]*<!--CARD-->.*?<!--/CARD-->\n?', '', modelo_ind, flags=re.S)
        if pi:
            cards = []
            for a in pi:
                c = card
                capa_html = f'<img src="{esc(a["capa"])}" width="1200" height="630" alt="{esc(a["titulo"])}" loading="lazy">' if a.get('capa') else ''
                for k, v in (('{{CARD_URL}}', f'{t["pre"]}{a["slug"]}/'), ('{{CARD_CAPA}}', capa_html), ('{{CARD_TITULO}}', esc(a['titulo'])),
                             ('{{CARD_DATA}}', a['data']), ('{{CARD_DATA_BR}}', data_br(a['data'], i)), ('{{CARD_DESC}}', esc(a['descricao']))):
                    c = c.replace(k, v)
                cards.append(c)
            lista = '\n  <div class="cards">\n' + '\n'.join(cards) + '\n  </div>'
            robots = ''
            urls.append((f"{BASE}{t['pre']}", pi[0]['data'], pares(None, pub)))
        else:
            lista = f'\n  <p>{t["breve"]}</p>'
            robots = '<meta name="robots" content="noindex">\n'
        home_block(i, pi[0] if pi else None)
        raiz_blog.mkdir(parents=True, exist_ok=True)
        ind = aplicar(modelo_ind, trocas(i)).replace('{{LANGSW}}', seletor(i, None, pub)).replace('{{CANON}}', f"{BASE}{t['pre']}").replace('{{ALTERNATES}}', alternates(i, pares(None, pub)))
        (raiz_blog / 'index.html').write_text(ind.replace('{{LISTA}}', lista).replace('{{ROBOTS}}', robots), encoding='utf-8')
    # sitemap: remove entradas /blog/ e /en/blog/ e re-adiciona so as de idiomas com artigo publicado
    sm = RAIZ / 'sitemap.xml'; x = ler(sm)
    x = re.sub(r'  <url><loc>' + re.escape(BASE) + r'(?:/en)?/blog/[^<]*</loc>.*?</url>\n', '', x, flags=re.S)
    def entrada(u, lm, par):
        links = ''
        if par['pt'] and par['en']:
            links = ''.join(f'    <xhtml:link rel="alternate" hreflang="{h}" href="{hu}"/>\n' for h, hu in (('pt-BR', par['pt']), ('en', par['en']), ('x-default', par['pt'])))
        return f'  <url><loc>{u}</loc><lastmod>{lm}</lastmod>\n{links}  </url>\n'
    novas = ''.join(entrada(u, lm, par) for u, lm, par in urls)
    x = x.replace('</urlset>', novas + '</urlset>')
    sm.write_text(x, encoding='utf-8')
    print(f'{len(pub)} artigo(s) publicado(s); {len(arts) - len(pub)} rascunho(s).')

main()
