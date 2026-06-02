"""
Generate Banca do Palpite app screenshot mockups.
Matches the Flutter design system: colors, radii, gradients, typography.
Run: py -3 docs/gen_screenshots.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

OUT = r"C:\Users\gu150\banca_do_palpite\docs\screenshots"
os.makedirs(OUT, exist_ok=True)

# ── Design tokens ─────────────────────────────────────────────────────────────
W, H = 390, 844
CREAM      = (245, 238, 220)
GREEN      = (18,  72,  50)
GREEN_DARK = (12,  48,  32)
GREEN_MID  = (30, 100,  68)
GREEN_LT   = (45, 130,  85)
AMBER      = (220, 140,  20)
AMBER_LT   = (240, 170,  50)
AMBER_DK   = (192, 120,  16)
OFF_WHITE  = (252, 248, 238)
MUTED      = (122, 154, 122)
MUTED_DK   = (138, 138, 122)
DARK_TEXT  = ( 22,  30,  22)
INPUT_FILL = (237, 228, 204)
DIVIDER    = (212, 201, 168)
LIVE_RED   = (180,  55,  40)
GOLD       = (255, 215,   0)
SILVER     = (176, 176, 176)
BRONZE     = (205, 127,  50)

APPBAR_H = 56
TAB_H    = 46
RADIUS   = 16   # card radius (updated)


# ── Helpers ───────────────────────────────────────────────────────────────────
def font(size, bold=False):
    candidates_bold    = [r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\calibrib.ttf"]
    candidates_regular = [r"C:\Windows\Fonts\arial.ttf",   r"C:\Windows\Fonts\calibri.ttf",
                          r"C:\Windows\Fonts\segoeui.ttf"]
    for path in (candidates_bold if bold else candidates_regular):
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()

FH = lambda s: font(s, bold=True)   # heading / bold
FB = lambda s: font(s, bold=False)  # body


def rr(draw, x0, y0, x1, y1, r, fill=None, outline=None, width=1):
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r,
                            fill=fill, outline=outline, width=width)


def gradient_rect(img, x0, y0, x1, y1, r, color_top, color_bot):
    """Vertical gradient fill inside a rounded rect."""
    gw, gh = x1 - x0, y1 - y0
    grad = Image.new("RGBA", (gw, gh))
    for y in range(gh):
        t = y / max(gh - 1, 1)
        c = tuple(int(a + (b - a) * t) for a, b in zip(color_top, color_bot)) + (255,)
        ImageDraw.Draw(grad).line([(0, y), (gw, y)], fill=c)
    mask = Image.new("L", (gw, gh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, gw, gh], radius=r, fill=255)
    img.paste(grad, (x0, y0), mask)


def shadow_card(img, x0, y0, x1, y1, r=RADIUS):
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d  = ImageDraw.Draw(sh)
    d.rounded_rectangle([x0+1, y0+3, x1+1, y1+4], radius=r, fill=(0,0,0,40))
    img.paste(Image.alpha_composite(Image.new("RGBA", img.size), sh.filter(ImageFilter.GaussianBlur(6))),
              mask=Image.alpha_composite(Image.new("RGBA", img.size), sh.filter(ImageFilter.GaussianBlur(6))).split()[3])


def hex_logo(draw, img, cx, cy, size=28):
    """Draw the gradient hexagon B logo."""
    r = size * 0.5
    pts_outer = []
    pts_inner = []
    for i in range(6):
        a = math.radians(60 * i - 30)
        pts_outer.append((cx + r * math.cos(a), cy + r * math.sin(a)))
        pts_inner.append((cx + r * 0.7 * math.cos(a), cy + r * 0.7 * math.sin(a)))
    # Dark ring
    draw.polygon(pts_outer, fill=AMBER_DK)
    # Amber gradient approximation (two-tone)
    draw.polygon([(cx + r*0.92*math.cos(math.radians(60*i-30)),
                   cy + r*0.92*math.sin(math.radians(60*i-30))) for i in range(6)],
                 fill=AMBER)
    # Letter B
    fs = int(size * 0.52)
    draw.text((cx, cy), "B", font=FH(fs), fill=GREEN, anchor="mm")


def appbar(draw, img, title="", back=True, logo=False, icons=None):
    draw.rectangle([0, 0, W, APPBAR_H], fill=GREEN)
    x = 14
    if back:
        draw.text((x, APPBAR_H//2), "←", font=FH(18), fill=OFF_WHITE, anchor="lm")
        x = 42
    if logo:
        hex_logo(draw, img, x + 14, APPBAR_H//2)
        draw.text((x + 34, APPBAR_H//2 - 7), "BANCA DO",
                  font=FB(9), fill=(*OFF_WHITE[:3], 180), anchor="lm")
        draw.text((x + 34, APPBAR_H//2 + 5), "PALPITE",
                  font=FH(16), fill=AMBER, anchor="lm")
    elif title:
        draw.text((x, APPBAR_H//2), title, font=FH(19), fill=OFF_WHITE, anchor="lm")
    if icons:
        rx = W - 14
        for ic in reversed(icons):
            draw.text((rx, APPBAR_H//2), ic, font=FB(16), fill=OFF_WHITE, anchor="rm")
            rx -= 34
    draw.text((W - 14, APPBAR_H//2), "👤" if not icons else "", font=FB(16),
              fill=OFF_WHITE, anchor="rm")


def appbar_pool(draw, img, name, subtitle, tabs, selected):
    """Extended app bar for pool screens."""
    ext = APPBAR_H + 48
    draw.rectangle([0, 0, W, ext + TAB_H], fill=GREEN)
    draw.text((14, 18), "←", font=FH(18), fill=OFF_WHITE, anchor="lm")
    draw.text((W-48, 18), "⚙", font=FB(15), fill=OFF_WHITE, anchor="lm")
    draw.text((W-18, 18), "↑", font=FB(15), fill=OFF_WHITE, anchor="rm")
    draw.text((16, APPBAR_H + 14), name, font=FH(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 36), subtitle, font=FB(11), fill=MUTED, anchor="lm")
    # Tab bar
    ty = ext
    draw.rectangle([0, ty, W, ty + TAB_H], fill=GREEN)
    n = len(tabs)
    tw = W // n
    for i, label in enumerate(tabs):
        cx = i * tw + tw // 2
        cy = ty + TAB_H // 2
        active = i == selected
        draw.text((cx, cy), label, font=FH(13), fill=AMBER if active else MUTED, anchor="mm")
        if active:
            draw.rectangle([i*tw+6, ty+TAB_H-3, (i+1)*tw-6, ty+TAB_H], fill=AMBER)
    return ext + TAB_H


def input_field(draw, x, y, w, h, label, icon=None, value=""):
    rr(draw, x, y, x+w, y+h, 10, fill=INPUT_FILL, outline=DIVIDER, width=1)
    ox = x + 14
    if icon:
        draw.text((ox, y + h//2), icon, font=FB(13), fill=GREEN_LT, anchor="lm")
        ox += 22
    draw.text((ox, y + h//2), value or label,
              font=FB(14), fill=MUTED_DK if not value else DARK_TEXT, anchor="lm")


def circle_avatar(draw, cx, cy, r, initial, bg=GREEN, fg=AMBER):
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=bg)
    draw.text((cx, cy), initial, font=FH(int(r*0.9)), fill=fg, anchor="mm")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 1 — Login
# ─────────────────────────────────────────────────────────────────────────────
def screen_login():
    img  = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    # App bar
    draw.rectangle([0, 0, W, APPBAR_H], fill=GREEN)
    draw.text((14, APPBAR_H//2), "←", font=FH(18), fill=OFF_WHITE, anchor="lm")
    draw.text((46, APPBAR_H//2), "ENTRAR", font=FH(19), fill=OFF_WHITE, anchor="lm")

    y = APPBAR_H + 48
    hex_logo(draw, img, W//2, y + 28, size=64)
    y += 80

    draw.text((22, y), "Bem-vindo de volta!", font=FH(26), fill=DARK_TEXT, anchor="lm")
    y += 34
    draw.text((22, y), "Entre para ver seus bolões.", font=FB(14), fill=MUTED_DK, anchor="lm")
    y += 44

    input_field(draw, 20, y, W-40, 52, "Email", icon="✉")
    y += 64
    input_field(draw, 20, y, W-40, 52, "Senha", icon="🔒")
    draw.text((W-32, y+26), "👁", font=FB(13), fill=MUTED_DK, anchor="mm")
    y += 64

    draw.text((W-20, y), "Esqueci minha senha", font=FB(12), fill=AMBER, anchor="rm")
    y += 32

    # Button with gradient
    gradient_rect(img, 20, y, W-20, y+52, 12, AMBER_LT, AMBER_DK)
    draw.text((W//2, y+26), "ENTRAR", font=FH(16), fill=GREEN, anchor="mm")
    y += 68

    tw = draw.textlength("Ainda não tem conta?  ", font=FB(13))
    x0 = (W - tw - draw.textlength("Criar conta", font=FH(13))) // 2
    draw.text((x0, y), "Ainda não tem conta?  ", font=FB(13), fill=MUTED_DK, anchor="lm")
    draw.text((x0 + tw, y), "Criar conta", font=FH(13), fill=AMBER, anchor="lm")

    img.save(os.path.join(OUT, "01_login.png"))
    print("✓ 01_login.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 2 — Home
# ─────────────────────────────────────────────────────────────────────────────
def screen_home():
    img  = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    # Custom app bar
    draw.rectangle([0, 0, W, APPBAR_H], fill=GREEN)
    hex_logo(draw, img, 28, APPBAR_H//2, size=28)
    draw.text((50, APPBAR_H//2 - 7), "BANCA DO", font=FB(9),  fill=(*OFF_WHITE[:3], 180), anchor="lm")
    draw.text((50, APPBAR_H//2 + 5), "PALPITE",  font=FH(16), fill=AMBER, anchor="lm")
    draw.text((W-16, APPBAR_H//2), "👤", font=FB(17), fill=OFF_WHITE, anchor="rm")

    y = APPBAR_H + 24
    draw.text((20, y), "Olá, Rafael! 👋", font=FH(26), fill=DARK_TEXT, anchor="lm")
    y += 44

    # Buttons row
    bw = (W - 52) // 2
    gradient_rect(img, 20, y, 20+bw, y+46, 12, AMBER_LT, AMBER_DK)
    draw.text((20+bw//2, y+23), "+ CRIAR BOLÃO", font=FH(13), fill=GREEN, anchor="mm")
    rr(draw, 20+bw+12, y, W-20, y+46, 12, outline=GREEN, width=2)
    draw.text((20+bw+12+bw//2, y+23), "ENTRAR", font=FH(13), fill=GREEN, anchor="mm")
    y += 62

    pools = [
        ("Bolão da Galera",  "UEFA Champions League", "8", "6"),
        ("Champions 2024",   "Champions League",      "5", "8"),
        ("Copa do Brasil",   "Copa do Brasil",        "4", "4"),
    ]
    for name, comp, members, matches in pools:
        ch = 82
        shadow_card(img, 20, y, W-20, y+ch)
        gradient_rect(img, 20, y, W-20, y+ch, RADIUS, GREEN, GREEN_DARK)
        # Left icon
        rr(draw, 32, y+18, 78, y+64, 10, fill=(GREEN_MID[0],GREEN_MID[1],GREEN_MID[2]))
        draw.text((55, y+41), "🏆", font=FB(18), fill=AMBER, anchor="mm")
        # Text
        tx = 90
        draw.text((tx, y+22), name, font=FH(16), fill=OFF_WHITE, anchor="lm")
        draw.text((tx, y+40), comp, font=FB(11), fill=MUTED, anchor="lm")
        draw.text((tx, y+58), f"👥 {members}   ⚽ {matches} jogos", font=FB(11), fill=MUTED, anchor="lm")
        # Chevron
        draw.text((W-26, y+41), "›", font=FH(22), fill=MUTED, anchor="mm")
        y += ch + 10

    img.save(os.path.join(OUT, "02_home.png"))
    print("✓ 02_home.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 3 — Pool Detail
# ─────────────────────────────────────────────────────────────────────────────
def screen_pool_detail():
    img  = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolão da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], selected=0)
    body_y += 16

    matches = [
        ("live",      "Real Madrid",     "Barcelona",  2, 1, "45'"),
        ("scheduled", "Manchester City", "Arsenal",    None, None, "14/06  21:00"),
        ("finished",  "Bayern Munich",   "PSG",        3, 1, "Encerrado"),
    ]

    for status, home, away, sh, sa, label in matches:
        ch = 90
        is_live = status == "live"
        shadow_card(img, 16, body_y, W-16, body_y+ch)
        gradient_rect(img, 16, body_y, W-16, body_y+ch, RADIUS, GREEN, GREEN_DARK)
        if is_live:
            draw.rectangle([16, body_y, W-16, body_y+ch],
                           outline=LIVE_RED, width=0)
            rr(draw, 16, body_y, W-16, body_y+ch, RADIUS, outline=LIVE_RED, width=2)
            rr(draw, 28, body_y+10, 120, body_y+26, 4, fill=LIVE_RED)
            draw.text((74, body_y+18), f"● VIVO  {label}",
                      font=FH(10), fill=OFF_WHITE, anchor="mm")
        else:
            draw.text((28, body_y+16), label, font=FB(10), fill=MUTED, anchor="lm")

        mid_y = body_y + 60
        draw.text((W//2-64, mid_y), home, font=FH(14), fill=OFF_WHITE, anchor="rm")
        draw.text((W//2+64, mid_y), away, font=FH(14), fill=OFF_WHITE, anchor="lm")
        if sh is not None:
            draw.text((W//2, mid_y), f"{sh}  ×  {sa}", font=FH(24), fill=AMBER, anchor="mm")
        else:
            draw.text((W//2, mid_y), "×", font=FH(20), fill=MUTED, anchor="mm")
        body_y += ch + 10

    img.save(os.path.join(OUT, "03_pool_detail.png"))
    print("✓ 03_pool_detail.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 4 — Predictions
# ─────────────────────────────────────────────────────────────────────────────
def screen_predictions():
    img  = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolão da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], selected=0)
    body_y += 16

    # Date header
    draw.text((20, body_y+4), "14/06", font=FH(13), fill=MUTED_DK, anchor="lm")
    body_y += 28

    # Card 1 — typing 2 × 1
    ch = 102
    shadow_card(img, 16, body_y, W-16, body_y+ch)
    gradient_rect(img, 16, body_y, W-16, body_y+ch, RADIUS, GREEN, GREEN_DARK)
    draw.text((28, body_y+14), "21:00", font=FB(10), fill=MUTED, anchor="lm")
    draw.text((W-28, body_y+14), "salvando...", font=FB(10), fill=AMBER, anchor="rm")
    mid_y = body_y + 64
    draw.text((W//2-68, mid_y), "Manchester City", font=FH(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W//2+68, mid_y), "Arsenal", font=FH(13), fill=OFF_WHITE, anchor="lm")
    for bx, val in [(W//2-52, "2"), (W//2+8, "1")]:
        rr(draw, bx, mid_y-22, bx+44, mid_y+22, 8, fill=GREEN_MID, outline=AMBER, width=2)
        draw.text((bx+22, mid_y), val, font=FH(22), fill=AMBER, anchor="mm")
    draw.text((W//2-4, mid_y), "×", font=FH(16), fill=MUTED, anchor="mm")
    body_y += ch + 10

    # Card 2 — empty inputs
    ch2 = 102
    shadow_card(img, 16, body_y, W-16, body_y+ch2)
    gradient_rect(img, 16, body_y, W-16, body_y+ch2, RADIUS, GREEN, GREEN_DARK)
    draw.text((28, body_y+14), "14/06  18:45", font=FB(10), fill=MUTED, anchor="lm")
    mid_y2 = body_y + 64
    draw.text((W//2-68, mid_y2), "Real Madrid", font=FH(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W//2+68, mid_y2), "Atlético", font=FH(13), fill=OFF_WHITE, anchor="lm")
    for bx in [W//2-52, W//2+8]:
        rr(draw, bx, mid_y2-22, bx+44, mid_y2+22, 8, fill=GREEN_MID, outline=GREEN_LT, width=1)
    draw.text((W//2-4, mid_y2), "×", font=FH(16), fill=MUTED, anchor="mm")
    body_y += ch2 + 10

    # Card 3 — locked / finished
    ch3 = 108
    shadow_card(img, 16, body_y, W-16, body_y+ch3)
    gradient_rect(img, 16, body_y, W-16, body_y+ch3, RADIUS, GREEN, GREEN_DARK)
    draw.text((W-28, body_y+14), "🔒  encerrado", font=FB(10), fill=MUTED, anchor="rm")
    mid_y3 = body_y + 58
    draw.text((W//2-60, mid_y3), "Bayern Munich", font=FH(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W//2+60, mid_y3), "PSG", font=FH(13), fill=OFF_WHITE, anchor="lm")
    draw.text((W//2, mid_y3), "3  ×  1", font=FH(26), fill=AMBER, anchor="mm")
    recap_y = body_y + 86
    draw.text((28, recap_y), "Seu palpite: 3 × 1", font=FB(11), fill=MUTED, anchor="lm")
    bw = int(draw.textlength("+3 pts 🎯", font=FH(11))) + 16
    rr(draw, W-28-bw, recap_y-7, W-28, recap_y+10, 4, outline=GOLD, width=1)
    draw.text((W-28-bw//2, recap_y+1), "+3 pts 🎯", font=FH(11), fill=GOLD, anchor="mm")

    img.save(os.path.join(OUT, "04_predictions.png"))
    print("✓ 04_predictions.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 5 — Ranking
# ─────────────────────────────────────────────────────────────────────────────
def screen_ranking():
    img  = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolão da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], selected=1)
    body_y += 12

    entries = [
        (1, "R", "Rafael Doná",  47, True,  "3 placares exatos 🎯", GOLD,    26),
        (2, "M", "Marcos Silva", 23, False, "",                      SILVER,  20),
        (3, "A", "Ana Costa",    18, False, "",                      BRONZE,  20),
        (4, "C", "Carlos",       12, False, "",                      MUTED_DK,18),
    ]

    for pos, init, name, pts, is_me, subtitle, pos_color, pos_size in entries:
        rh = 66 if subtitle else 52
        if is_me:
            rr(draw, 16, body_y, W-16, body_y+rh, 10,
               fill=(245, 226, 190), outline=AMBER, width=2)
        elif pos <= 3:
            rr(draw, 16, body_y, W-16, body_y+rh, 10,
               fill=(230, 240, 232))

        mid_r = body_y + rh//2
        draw.text((28, mid_r), f"{pos}°", font=FH(pos_size), fill=pos_color, anchor="lm")
        circle_avatar(draw, 72, mid_r, 18, init)
        ny = mid_r - (7 if subtitle else 0)
        draw.text((100, ny), name,
                  font=FH(14) if is_me else FB(13),
                  fill=DARK_TEXT, anchor="lm")
        if subtitle:
            draw.text((100, mid_r+9), subtitle, font=FB(10), fill=MUTED_DK, anchor="lm")
        draw.text((W-32, mid_r-5), str(pts),
                  font=FH(24), fill=AMBER if is_me else DARK_TEXT, anchor="rm")
        draw.text((W-32, mid_r+12), "pts", font=FB(10), fill=MUTED_DK, anchor="rm")
        body_y += rh + 8

    # Sticky footer
    fy = H - 70
    draw.rectangle([0, fy-1, W, H], fill=CREAM)
    draw.line([(0, fy-1), (W, fy-1)], fill=DIVIDER, width=1)
    rr(draw, 16, fy+4, W-16, fy+56, 10, fill=(245, 226, 190), outline=AMBER, width=2)
    circle_avatar(draw, 52, fy+30, 16, "R")
    draw.text((76, fy+22), "Rafael Doná", font=FH(13), fill=DARK_TEXT, anchor="lm")
    draw.text((76, fy+38), "Sua posição", font=FB(10), fill=MUTED_DK, anchor="lm")
    draw.text((W-30, fy+22), "1°", font=FH(22), fill=GOLD, anchor="rm")
    draw.text((W-30, fy+40), "47 pts", font=FB(11), fill=AMBER, anchor="rm")

    img.save(os.path.join(OUT, "05_ranking.png"))
    print("✓ 05_ranking.png")


# ── Run ───────────────────────────────────────────────────────────────────────
screen_login()
screen_home()
screen_pool_detail()
screen_predictions()
screen_ranking()
print(f"\nSaved to: {OUT}")
