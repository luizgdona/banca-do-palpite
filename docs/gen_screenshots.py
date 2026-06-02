"""
Banca do Palpite — screenshot mockups with the new dark Stitch design.
Run: py -3 docs/gen_screenshots.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

OUT = r"C:\Users\gu150\banca_do_palpite\docs\screenshots"
os.makedirs(OUT, exist_ok=True)

W, H = 390, 844

# ── Color palette ─────────────────────────────────────────────────────────────
BG       = (14,  14,  14)
SURF_LOW = (19,  19,  19)
SURF     = (26,  26,  26)
SURF_HI  = (32,  32,  31)
SURF_HHI = (38,  38,  38)
PRIMARY  = (157, 241, 151)  # #9df197 neon green
PRI_CNT  = ( 98, 178,  96)
ON_PRI   = ( 0,  92,  21)
SECOND   = (245, 206,  83)  # #f5ce53 golden yellow
SEC_CNT  = (115,  92,   0)
ON_SURF  = (255, 255, 255)
ON_SV    = (173, 170, 170)  # on-surface-variant
OUTLINE  = (118, 117, 117)
OUTV     = ( 72,  72,  71)
ERROR    = (255, 113, 108)  # error/live
GOLD     = (245, 206,  83)
SILVER   = (176, 176, 176)
BRONZE   = (205, 127,  50)

APPBAR_H = 56
TAB_H    = 44
SIDEBAR  = 256


def font(size, bold=False):
    candidates_bold    = [r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\calibrib.ttf"]
    candidates_regular = [r"C:\Windows\Fonts\arial.ttf",   r"C:\Windows\Fonts\calibri.ttf",
                           r"C:\Windows\Fonts\segoeui.ttf"]
    for p in (candidates_bold if bold else candidates_regular):
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

FH = lambda s: font(s, True)
FB = lambda s: font(s, False)


def rr(draw, x0, y0, x1, y1, r, fill=None, outline=None, w=1):
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=fill, outline=outline, width=w)


def logo(draw, x, y, size=22):
    """'Banca do Palpite' italic text logo in neon green."""
    draw.text((x, y), "Banca do ", font=FB(size), fill=ON_SURF, anchor="lm")
    w = int(draw.textlength("Banca do ", font=FB(size)))
    draw.text((x + w, y), "Palpite", font=FH(size), fill=PRIMARY, anchor="lm")


def appbar(draw, title, back=True):
    draw.rectangle([0, 0, W, APPBAR_H], fill=SURF_LOW)
    x = 14
    if back:
        draw.text((x, APPBAR_H // 2), "<", font=FH(18), fill=PRIMARY, anchor="lm")
        x = 40
    draw.text((x, APPBAR_H // 2), title, font=FH(18), fill=PRIMARY, anchor="lm")
    # notif icon
    draw.ellipse([W-38, APPBAR_H//2-8, W-22, APPBAR_H//2+8], outline=ON_SV, width=1)
    draw.text((W-14, APPBAR_H//2), "o", font=FB(14), fill=ON_SV, anchor="mm")


def appbar_home(draw):
    draw.rectangle([0, 0, W, APPBAR_H], fill=SURF_LOW)
    logo(draw, 16, APPBAR_H // 2, size=20)
    draw.ellipse([W-36, APPBAR_H//2-9, W-18, APPBAR_H//2+9], outline=PRIMARY, width=1)
    draw.text((W-27, APPBAR_H//2), "i", font=FH(12), fill=PRIMARY, anchor="mm")


def appbar_pool(draw, name, subtitle, tabs, sel):
    ext = APPBAR_H + 52
    draw.rectangle([0, 0, W, ext + TAB_H], fill=SURF_LOW)
    draw.text((14, 20), "<", font=FH(18), fill=PRIMARY, anchor="lm")
    draw.text((W - 44, 20), "o", font=FB(14), fill=ON_SV, anchor="mm")
    draw.text((W - 20, 20), "^", font=FB(14), fill=ON_SV, anchor="mm")
    # Accent bar left
    draw.rectangle([0, 0, 3, ext + TAB_H], fill=PRIMARY)
    draw.text((16, APPBAR_H + 14), name, font=FH(18), fill=ON_SURF, anchor="lm")
    draw.text((16, APPBAR_H + 34), subtitle, font=FB(10), fill=ON_SV, anchor="lm")
    # Tab bar
    ty = ext
    draw.rectangle([0, ty, W, ty + TAB_H], fill=SURF_LOW)
    draw.line([(0, ty), (W, ty)], fill=OUTV, width=1)
    n = len(tabs)
    tw = W // n
    for i, label in enumerate(tabs):
        cx = i * tw + tw // 2
        cy = ty + TAB_H // 2
        active = i == sel
        draw.text((cx, cy), label, font=FH(11),
                  fill=PRIMARY if active else ON_SV, anchor="mm")
        if active:
            draw.rectangle([i*tw+8, ty+TAB_H-2, (i+1)*tw-8, ty+TAB_H], fill=PRIMARY)
    return ext + TAB_H


def accent_card(img, draw, x0, y0, x1, y1, accent=True, border_color=None):
    draw.rectangle([x0, y0, x1, y1], fill=SURF_HI)
    if accent:
        draw.rectangle([x0, y0, x0+3, y1], fill=PRIMARY)
    if border_color:
        draw.rectangle([x0, y0, x1, y1], outline=border_color, width=1)


def input_field(draw, x, y, w, h, label, value="", focused=False):
    draw.rectangle([x, y, x+w, y+h], fill=BG, outline=PRIMARY if focused else OUTV, width=1)
    tx = x + 14
    draw.text((tx, y + h//2), value or label,
              font=FB(14), fill=ON_SURF if value else ON_SV, anchor="lm")
    if focused:
        draw.rectangle([x, y+h-2, x+w, y+h], fill=PRIMARY)


def avatar(draw, cx, cy, r, initial, bg=SURF_HHI, fg=PRIMARY):
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=bg)
    draw.text((cx, cy), initial, font=FH(int(r*0.9)), fill=fg, anchor="mm")


def pts_badge(draw, x, y, txt, color):
    f = FH(10)
    tw = int(draw.textlength(txt, font=f)) + 14
    draw.rectangle([x, y-7, x+tw, y+9], outline=color, width=1)
    draw.text((x+tw//2, y+1), txt, font=f, fill=color, anchor="mm")
    return tw


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 1 — Login
# ─────────────────────────────────────────────────────────────────────────────
def screen_login():
    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    appbar(draw, "ENTRAR", back=True)

    y = APPBAR_H + 48
    logo(draw, 22, y, size=28)
    y += 52

    # Hero headline
    draw.text((22, y), "Bem-vindo", font=FH(42), fill=ON_SURF, anchor="lm")
    y += 46
    draw.text((22, y), "de volta.", font=FH(42), fill=PRIMARY, anchor="lm")
    y += 52
    draw.text((22, y), "Entre para ver seus boloes.", font=FB(13), fill=ON_SV, anchor="lm")
    y += 48

    input_field(draw, 20, y, W-40, 52, "Email")
    y += 62
    input_field(draw, 20, y, W-40, 52, "Senha")
    y += 62

    draw.text((W-20, y+2), "Esqueci minha senha", font=FB(12), fill=PRIMARY, anchor="rm")
    y += 30

    # Gradient button
    for ix in range(W-40):
        t = ix / max(W-41, 1)
        c = tuple(int(a + (b-a)*t) for a, b in zip(PRIMARY, PRI_CNT))
        draw.line([(20+ix, y), (20+ix, y+52)], fill=c)
    rr(draw, 20, y, W-20, y+52, 8, outline=None)
    # Re-draw gradient as approximation
    ImageDraw.Draw(img).rounded_rectangle([20, y, W-20, y+52], radius=8, fill=PRIMARY)
    draw.text((W//2, y+26), "ENTRAR", font=FH(15), fill=ON_PRI, anchor="mm")
    y += 68

    t1 = "Ainda nao tem conta?  "
    w1 = int(draw.textlength(t1, font=FB(13)))
    x0 = (W - w1 - int(draw.textlength("Criar conta", font=FH(13)))) // 2
    draw.text((x0, y), t1, font=FB(13), fill=ON_SV, anchor="lm")
    draw.text((x0+w1, y), "Criar conta", font=FH(13), fill=PRIMARY, anchor="lm")

    img.save(os.path.join(OUT, "01_login.png"))
    print("  01_login.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 2 — Home
# ─────────────────────────────────────────────────────────────────────────────
def screen_home():
    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    appbar_home(draw)

    y = APPBAR_H + 24
    draw.text((20, y), "MEU BOLAO", font=FH(9), fill=PRIMARY, anchor="lm")
    y += 20

    # Headline
    draw.text((20, y), "Ola, ", font=FB(36), fill=ON_SV, anchor="lm")
    x_ola = 20 + int(draw.textlength("Ola, ", font=FB(36)))
    draw.text((x_ola, y), "Rafael", font=FH(36), fill=ON_SURF, anchor="lm")
    y += 50

    # Buttons
    bw = (W - 52) // 2
    rr(draw, 20, y, 20+bw, y+46, 8, fill=PRIMARY)
    draw.text((20+bw//2, y+23), "+ CRIAR BOLAO", font=FH(12), fill=ON_PRI, anchor="mm")
    rr(draw, 20+bw+12, y, W-20, y+46, 8, outline=OUTV, w=1)
    draw.text((20+bw+12+bw//2, y+23), "ENTRAR", font=FH(12), fill=ON_SURF, anchor="mm")
    y += 62

    # Section header
    draw.text((20, y+4), "SEUS BOLOES", font=FH(9), fill=PRIMARY, anchor="lm")
    lx = 20 + int(draw.textlength("SEUS BOLOES  ", font=FH(9)))
    draw.line([(lx, y+8), (W-20, y+8)], fill=OUTV, width=1)
    y += 24

    pools = [
        ("Bolao da Galera",  "UEFA Champions League", "8", "6"),
        ("Champions 2024",   "Champions League",      "5", "8"),
        ("Copa do Brasil",   "Copa do Brasil",        "4", "4"),
    ]
    for name, comp, members, matches in pools:
        ch = 78
        # Card
        accent_card(img, draw, 0, y, W, y+ch)
        # Left border (already done by accent_card)
        # Icon box
        draw.rectangle([20, y+16, 64, y+62], fill=SURF_HHI)
        draw.text((42, y+39), "T", font=FH(20), fill=PRIMARY, anchor="mm")
        # Content
        draw.text((76, y+22), name, font=FH(15), fill=ON_SURF, anchor="lm")
        draw.text((76, y+40), comp, font=FB(10), fill=ON_SV, anchor="lm")
        draw.text((76, y+57), f"{members} membros   {matches} jogos", font=FB(10), fill=ON_SV, anchor="lm")
        # Chevron
        draw.text((W-16, y+39), ">", font=FH(16), fill=ON_SV, anchor="mm")
        y += ch + 1

    img.save(os.path.join(OUT, "02_home.png"))
    print("  02_home.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 3 — Pool Detail
# ─────────────────────────────────────────────────────────────────────────────
def screen_pool_detail():
    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=0)

    CW = 104
    TEAM_L = (W - CW) // 2
    home_xr = TEAM_L
    away_xl = TEAM_L + CW
    cx = TEAM_L + CW // 2

    matches = [
        ("live",      "Real Madrid",     "Barcelona",  2, 1, "45"),
        ("scheduled", "Manchester City", "Arsenal",    None, None, "14/06  21:00"),
        ("finished",  "Bayern Munich",   "PSG",        3, 1, "Encerrado"),
    ]

    for status, home, away, sh, sa, label in matches:
        ch = 84
        is_live = status == "live"
        accent_card(img, draw, 0, body_y, W, body_y+ch,
                    accent=True, border_color=ERROR if is_live else None)

        # Status row (22px)
        if is_live:
            rr(draw, 20, body_y+10, 100, body_y+26, 3,
               fill=(*ERROR, 40), outline=ERROR, w=1)
            draw.text((60, body_y+18), f"AO VIVO {label}'", font=FH(9),
                      fill=ERROR, anchor="mm")
        else:
            draw.text((20, body_y+18), label, font=FB(9), fill=ON_SV, anchor="lm")

        # Teams + score
        ty = body_y + 58
        draw.text((home_xr - 4, ty), home, font=FH(13), fill=ON_SURF, anchor="rm")
        draw.text((away_xl + 4, ty), away, font=FH(13), fill=ON_SURF, anchor="lm")
        if sh is not None:
            draw.text((cx, ty), f"{sh}  x  {sa}", font=FH(22), fill=PRIMARY, anchor="mm")
        else:
            draw.text((cx, ty), "VS", font=FH(20), fill=PRIMARY, anchor="mm")

        body_y += ch + 1

    img.save(os.path.join(OUT, "03_pool_detail.png"))
    print("  03_pool_detail.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 4 — Predictions
# ─────────────────────────────────────────────────────────────────────────────
def screen_predictions():
    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=0)

    CW = 104
    TEAM_L = (W - CW) // 2
    home_xr = TEAM_L
    away_xl = TEAM_L + CW
    cx = TEAM_L + CW // 2

    draw.text((20, body_y+14), "14/06", font=FH(11), fill=ON_SV, anchor="lm")
    body_y += 32

    # Card 1 — user typing 2 x 1
    ch = 96
    accent_card(img, draw, 0, body_y, W, body_y+ch)
    draw.text((20, body_y+14), "21:00", font=FB(9), fill=ON_SV, anchor="lm")
    draw.text((W-20, body_y+14), "salvando...", font=FB(9), fill=PRIMARY, anchor="rm")
    ty = body_y + 62
    draw.text((home_xr-4, ty), "Manchester City", font=FH(12), fill=ON_SURF, anchor="rm")
    draw.text((away_xl+4, ty), "Arsenal",         font=FH(12), fill=ON_SURF, anchor="lm")
    bx1 = cx - 48
    bx2 = cx + 4
    for bx, val in [(bx1, "2"), (bx2, "1")]:
        draw.rectangle([bx, ty-22, bx+44, ty+22], fill=BG, outline=PRIMARY, width=2)
        draw.text((bx+22, ty), val, font=FH(24), fill=PRIMARY, anchor="mm")
    draw.text((cx-2, ty), "x", font=FB(12), fill=ON_SV, anchor="mm")
    body_y += ch + 1

    # Card 2 — empty
    ch = 96
    accent_card(img, draw, 0, body_y, W, body_y+ch)
    draw.text((20, body_y+14), "14/06  18:45", font=FB(9), fill=ON_SV, anchor="lm")
    ty2 = body_y + 62
    draw.text((home_xr-4, ty2), "Real Madrid", font=FH(12), fill=ON_SURF, anchor="rm")
    draw.text((away_xl+4, ty2), "Atletico",    font=FH(12), fill=ON_SURF, anchor="lm")
    for bx in [bx1, bx2]:
        draw.rectangle([bx, ty2-22, bx+44, ty2+22], fill=SURF_HHI, outline=OUTV, width=1)
    draw.text((cx-2, ty2), "x", font=FB(12), fill=ON_SV, anchor="mm")
    body_y += ch + 1

    # Card 3 — locked
    ch = 104
    accent_card(img, draw, 0, body_y, W, body_y+ch)
    draw.text((W-20, body_y+14), "encerrado", font=FB(9), fill=ON_SV, anchor="rm")
    ty3 = body_y + 56
    draw.text((home_xr-4, ty3), "Bayern Munich", font=FH(12), fill=ON_SURF, anchor="rm")
    draw.text((away_xl+4, ty3), "PSG",           font=FH(12), fill=ON_SURF, anchor="lm")
    draw.text((cx, ty3), "3  x  1", font=FH(24), fill=PRIMARY, anchor="mm")
    # Recap row
    recap_y = body_y + 86
    draw.line([(20, recap_y-4), (W-20, recap_y-4)], fill=OUTV, width=1)
    draw.text((20, recap_y+4), "Seu palpite: 3 x 1", font=FB(10), fill=ON_SV, anchor="lm")
    pts_badge(draw, W-82, recap_y+4, "+3 pts", SECOND)

    img.save(os.path.join(OUT, "04_predictions.png"))
    print("  04_predictions.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 5 — Ranking
# ─────────────────────────────────────────────────────────────────────────────
def screen_ranking():
    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=1)

    entries = [
        (1, "R", "Rafael Dona",  47, True,  "3 placares exatos", SECOND, 22),
        (2, "M", "Marcos Silva", 23, False, None,                 SILVER, 16),
        (3, "A", "Ana Costa",    18, False, None,                 BRONZE, 16),
        (4, "C", "Carlos",       12, False, None,                 ON_SV,  14),
    ]

    for pos, init, name, pts, is_me, subtitle, pos_color, pos_sz in entries:
        rh = 64 if subtitle else 52
        mid = body_y + rh // 2

        # Row background
        if is_me:
            draw.rectangle([0, body_y, W, body_y+rh], fill=(30, 50, 30))
            draw.rectangle([0, body_y, 3, body_y+rh], fill=PRIMARY)
        elif pos == 1:
            draw.rectangle([0, body_y, W, body_y+rh], fill=(36, 32, 18))
        else:
            draw.rectangle([0, body_y, W, body_y+rh], fill=BG)
        draw.line([(0, body_y+rh-1), (W, body_y+rh-1)], fill=OUTV, width=1)

        draw.text((14, mid), f"{pos}.", font=FH(pos_sz),
                  fill=pos_color, anchor="lm")
        avatar(draw, 60, mid, 18, init,
               bg=(60, 48, 8) if pos == 1 else SURF_HHI,
               fg=SECOND if pos == 1 else PRIMARY)

        ny = mid - (7 if subtitle else 0)
        name_color = PRIMARY if is_me else SECOND if pos == 1 else ON_SURF
        draw.text((88, ny), name, font=FH(13) if is_me else FB(13),
                  fill=name_color, anchor="lm")
        if subtitle:
            draw.text((88, mid+10), subtitle, font=FB(9), fill=SECOND, anchor="lm")

        pts_color = PRIMARY if is_me else SECOND if pos == 1 else ON_SURF
        draw.text((W-20, mid-6), str(pts), font=FH(20), fill=pts_color, anchor="rm")
        draw.text((W-20, mid+10), "pts", font=FB(9), fill=ON_SV, anchor="rm")

        body_y += rh

    # Sticky footer
    fy = H - 66
    draw.rectangle([0, fy-1, W, H], fill=BG)
    draw.line([(0, fy-1), (W, fy-1)], fill=OUTV, width=1)
    draw.rectangle([0, fy+3, W, fy+55], fill=(25, 45, 25))
    draw.rectangle([0, fy+3, 3, fy+55], fill=PRIMARY)
    avatar(draw, 48, fy+29, 16, "R")
    draw.text((72, fy+21), "Rafael Dona", font=FH(13), fill=PRIMARY, anchor="lm")
    draw.text((72, fy+38), "Sua posicao", font=FB(9), fill=ON_SV, anchor="lm")
    draw.text((W-16, fy+20), "1.", font=FH(20), fill=SECOND, anchor="rm")
    draw.text((W-16, fy+40), "47 pts", font=FH(11), fill=PRIMARY, anchor="rm")

    img.save(os.path.join(OUT, "05_ranking.png"))
    print("  05_ranking.png")


print("Generating dark-theme screenshots...")
screen_login()
screen_home()
screen_pool_detail()
screen_predictions()
screen_ranking()
print(f"\nDone -> {OUT}")
