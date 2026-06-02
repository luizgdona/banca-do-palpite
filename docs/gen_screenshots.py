"""
Banca do Palpite — screenshot mockup generator.
Matches the Flutter design system exactly. No emoji (Windows fonts don't render them).
Run: py -3 docs/gen_screenshots.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

OUT = r"C:\Users\gu150\banca_do_palpite\docs\screenshots"
os.makedirs(OUT, exist_ok=True)

# ── Design tokens ─────────────────────────────────────────────────────────────
W, H = 390, 844

C = {
    "cream":      (245, 238, 220),
    "green":      ( 18,  72,  50),
    "green_dark": ( 12,  48,  32),
    "green_mid":  ( 30, 100,  68),
    "green_lt":   ( 45, 130,  85),
    "amber":      (220, 140,  20),
    "amber_lt":   (240, 170,  50),
    "amber_dk":   (192, 120,  16),
    "off_white":  (252, 248, 238),
    "muted":      (122, 154, 122),
    "muted_dk":   (138, 138, 122),
    "dark_text":  ( 22,  30,  22),
    "input":      (237, 228, 204),
    "divider":    (212, 201, 168),
    "live_red":   (180,  55,  40),
    "gold":       (255, 215,   0),
    "silver":     (176, 176, 176),
    "bronze":     (205, 127,  50),
    "white":      (255, 255, 255),
    "black":      (  0,   0,   0),
    "transp":     None,
}

APPBAR  = 56
TABBAR  = 46
RADIUS  = 16   # card
IN_RAD  = 10   # input


def font(size, bold=False):
    paths = (
        [r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\calibrib.ttf"]
        if bold else
        [r"C:\Windows\Fonts\arial.ttf",   r"C:\Windows\Fonts\calibri.ttf",
         r"C:\Windows\Fonts\segoeui.ttf"]
    )
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

FH = lambda s: font(s, True)
FB = lambda s: font(s, False)


# ── Drawing primitives ────────────────────────────────────────────────────────

def rr(draw, x0, y0, x1, y1, r, fill=None, outline=None, w=1):
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r,
                            fill=fill, outline=outline, width=w)


def vgrad(img, x0, y0, x1, y1, r, top, bot):
    """Vertical gradient inside a rounded-rect mask."""
    gw, gh = x1 - x0, y1 - y0
    if gw <= 0 or gh <= 0:
        return
    g = Image.new("RGBA", (gw, gh))
    for y in range(gh):
        t = y / max(gh - 1, 1)
        c = tuple(int(a + (b - a) * t) for a, b in zip(top, bot)) + (255,)
        ImageDraw.Draw(g).line([(0, y), (gw, y)], fill=c)
    mask = Image.new("L", (gw, gh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, gw, gh], radius=r, fill=255)
    img.paste(g, (x0, y0), mask)


def card_shadow(img, x0, y0, x1, y1, r=RADIUS):
    s = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(s).rounded_rectangle(
        [x0 + 1, y0 + 4, x1 + 1, y1 + 4], radius=r, fill=(0, 0, 0, 36))
    blurred = s.filter(ImageFilter.GaussianBlur(8))
    img.paste(blurred, mask=blurred.split()[3])


def card(img, draw, x0, y0, x1, y1, border_color=None, border_w=2):
    """Draw a gradient green card with shadow and optional border."""
    card_shadow(img, x0, y0, x1, y1)
    vgrad(img, x0, y0, x1, y1, RADIUS, C["green"], C["green_dark"])
    if border_color:
        rr(draw, x0, y0, x1, y1, RADIUS, outline=border_color, w=border_w)


def appbar(draw, title="", back=True, icon_right=None):
    draw.rectangle([0, 0, W, APPBAR], fill=C["green"])
    x = 14
    if back:
        draw.text((x, APPBAR // 2), "←", font=FH(18), fill=C["off_white"], anchor="lm")
        x = 42
    if title:
        draw.text((x, APPBAR // 2), title, font=FH(19), fill=C["off_white"], anchor="lm")
    # person icon (geometric)
    if icon_right:
        _icon_person(draw, W - 20, APPBAR // 2, 10, C["off_white"])


def appbar_logo(draw, img):
    """Home screen app bar with hex logo + logotype."""
    draw.rectangle([0, 0, W, APPBAR], fill=C["green"])
    _hex_logo(draw, 28, APPBAR // 2, 14)
    draw.text((48, APPBAR // 2 - 7), "BANCA DO",
              font=FB(9), fill=C["muted"], anchor="lm")
    draw.text((48, APPBAR // 2 + 5), "PALPITE",
              font=FH(16), fill=C["amber"], anchor="lm")
    _icon_person(draw, W - 18, APPBAR // 2, 10, C["off_white"])


def tabbar(draw, tabs, selected, top):
    draw.rectangle([0, top, W, top + TABBAR], fill=C["green"])
    tw = W // len(tabs)
    for i, label in enumerate(tabs):
        cx = i * tw + tw // 2
        cy = top + TABBAR // 2
        active = i == selected
        draw.text((cx, cy), label, font=FH(13),
                  fill=C["amber"] if active else C["muted"], anchor="mm")
        if active:
            rr(draw, i * tw + 10, top + TABBAR - 3, (i + 1) * tw - 10, top + TABBAR,
               2, fill=C["amber"])
    return top + TABBAR


def appbar_pool(draw, img, name, subtitle, tabs, sel):
    ext = APPBAR + 52
    draw.rectangle([0, 0, W, ext], fill=C["green"])
    draw.text((14, 20), "←", font=FH(18), fill=C["off_white"], anchor="lm")
    _icon_settings(draw, W - 46, 20, 9, C["off_white"])
    _icon_share(draw, W - 18, 20, 9, C["off_white"])
    draw.text((16, APPBAR + 14), name, font=FH(20), fill=C["off_white"], anchor="lm")
    draw.text((16, APPBAR + 36), subtitle, font=FB(11), fill=C["muted"], anchor="lm")
    return tabbar(draw, tabs, sel, ext)


# ── Geometric icon helpers ────────────────────────────────────────────────────

def _hex_logo(draw, cx, cy, size):
    r = size
    pts_o = [(cx + r * math.cos(math.radians(60*i-30)),
               cy + r * math.sin(math.radians(60*i-30))) for i in range(6)]
    pts_i = [(cx + r*.8*math.cos(math.radians(60*i-30)),
               cy + r*.8*math.sin(math.radians(60*i-30))) for i in range(6)]
    draw.polygon(pts_o, fill=C["amber_dk"])
    draw.polygon(pts_i, fill=C["amber"])
    draw.text((cx, cy), "B", font=FH(int(size * 1.1)), fill=C["green"], anchor="mm")


def _icon_person(draw, cx, cy, r, color):
    draw.ellipse([cx-r*.45, cy-r*.9, cx+r*.45, cy-r*.1], outline=color, width=1)
    draw.arc([cx-r, cy+r*.1, cx+r, cy+r*2], start=0, end=180, fill=color, width=1)


def _icon_settings(draw, cx, cy, r, color):
    draw.ellipse([cx-r*.4, cy-r*.4, cx+r*.4, cy+r*.4], outline=color, width=1)
    for a in range(0, 360, 60):
        x1 = cx + r*.4*math.cos(math.radians(a))
        y1 = cy + r*.4*math.sin(math.radians(a))
        x2 = cx + r*math.cos(math.radians(a))
        y2 = cy + r*math.sin(math.radians(a))
        draw.line([x1, y1, x2, y2], fill=color, width=1)


def _icon_share(draw, cx, cy, r, color):
    draw.line([cx, cy - r, cx, cy + r], fill=color, width=1)
    draw.line([cx - r*.5, cy - r*.4, cx, cy - r], fill=color, width=1)
    draw.line([cx + r*.5, cy - r*.4, cx, cy - r], fill=color, width=1)


def _icon_trophy(draw, cx, cy, r, color):
    draw.rectangle([cx-r*.3, cy-r, cx+r*.3, cy+r*.2], fill=color)
    draw.arc([cx-r, cy-r, cx+r, cy], start=180, end=0, fill=color, width=2)
    draw.line([cx-r*.3, cy+r*.2, cx-r*.5, cy+r*.6], fill=color, width=2)
    draw.line([cx+r*.3, cy+r*.2, cx+r*.5, cy+r*.6], fill=color, width=2)
    draw.line([cx-r*.6, cy+r*.6, cx+r*.6, cy+r*.6], fill=color, width=2)


def _icon_lock(draw, cx, cy, r, color):
    rr(draw, cx-r*.6, cy-r*.1, cx+r*.6, cy+r*.8, 2, outline=color, w=1)
    draw.arc([cx-r*.4, cy-r*.9, cx+r*.4, cy+r*.1], start=180, end=0, fill=color, width=1)


def _icon_check(draw, cx, cy, r, color):
    draw.line([cx-r, cy, cx-r*.2, cy+r*.8, cx+r, cy-r*.6], fill=color, width=2)


def _avatar(draw, cx, cy, r, initial, bg=None, fg=None):
    bg = bg or C["green_mid"]
    fg = fg or C["amber"]
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=bg)
    draw.text((cx, cy), initial, font=FH(int(r)), fill=fg, anchor="mm")


def input_field(draw, x, y, w, h, label, has_icon=False):
    rr(draw, x, y, x+w, y+h, IN_RAD, fill=C["input"], outline=C["divider"], w=1)
    tx = x + (30 if has_icon else 14)
    if has_icon:
        draw.ellipse([x+10, y+h//2-5, x+24, y+h//2+5], outline=C["green_lt"], width=1)
    draw.text((tx, y + h//2), label, font=FB(14), fill=C["muted_dk"], anchor="lm")


def pts_badge(draw, x, y, pts_text, color):
    """Small points badge with border."""
    f = FH(11)
    tw = int(draw.textlength(pts_text, font=f)) + 14
    rr(draw, x, y-7, x+tw, y+9, 3, outline=color, w=1)
    draw.text((x + tw//2, y + 1), pts_text, font=f, fill=color, anchor="mm")
    return tw


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 1 — Login
# ─────────────────────────────────────────────────────────────────────────────
def screen_login():
    img  = Image.new("RGB", (W, H), C["cream"])
    draw = ImageDraw.Draw(img)

    appbar(draw, "ENTRAR", back=True)

    y = APPBAR + 48
    # Logo
    _hex_logo(draw, W//2, y + 32, 32)
    y += 88

    draw.text((22, y), "Bem-vindo de volta!", font=FH(26), fill=C["dark_text"], anchor="lm")
    y += 34
    draw.text((22, y), "Entre para ver seus boloes.", font=FB(13), fill=C["muted_dk"], anchor="lm")
    y += 48

    input_field(draw, 20, y, W-40, 52, "Email", has_icon=True)
    y += 64
    input_field(draw, 20, y, W-40, 52, "Senha", has_icon=True)
    _icon_lock(draw, W-30, y+26, 8, C["muted_dk"])
    y += 64

    draw.text((W-20, y+2), "Esqueci minha senha", font=FB(12), fill=C["amber"], anchor="rm")
    y += 30

    # Primary button (gradient)
    vgrad(img, 20, y, W-20, y+52, 12, C["amber_lt"], C["amber_dk"])
    draw.text((W//2, y+26), "ENTRAR", font=FH(16), fill=C["green"], anchor="mm")
    y += 68

    # Sign-up link
    t1 = "Ainda nao tem conta?  "
    t2 = "Criar conta"
    w1 = int(draw.textlength(t1, font=FB(13)))
    total = w1 + int(draw.textlength(t2, font=FH(13)))
    x0 = (W - total) // 2
    draw.text((x0, y), t1, font=FB(13), fill=C["muted_dk"], anchor="lm")
    draw.text((x0 + w1, y), t2, font=FH(13), fill=C["amber"], anchor="lm")

    img.save(os.path.join(OUT, "01_login.png"))
    print("  01_login.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 2 — Home
# ─────────────────────────────────────────────────────────────────────────────
def screen_home():
    img  = Image.new("RGB", (W, H), C["cream"])
    draw = ImageDraw.Draw(img)

    appbar_logo(draw, img)

    y = APPBAR + 24
    draw.text((20, y), "Ola, Rafael!", font=FH(26), fill=C["dark_text"], anchor="lm")
    y += 44

    # Action buttons
    bw = (W - 52) // 2
    vgrad(img, 20, y, 20+bw, y+46, 12, C["amber_lt"], C["amber_dk"])
    draw.text((20+bw//2, y+23), "+ CRIAR BOLAO", font=FH(12), fill=C["green"], anchor="mm")
    rr(draw, 20+bw+12, y, W-20, y+46, 12, outline=C["green"], w=2)
    draw.text((20+bw+12+bw//2, y+23), "ENTRAR", font=FH(12), fill=C["green"], anchor="mm")
    y += 62

    pools = [
        ("Bolao da Galera",  "UEFA Champions League", "8 membros", "6 jogos"),
        ("Champions 2024",   "Champions League",      "5 membros", "8 jogos"),
        ("Copa do Brasil",   "Copa do Brasil",        "4 membros", "4 jogos"),
    ]
    for name, comp, members, matches in pools:
        ch = 80
        card_shadow(img, 20, y, W-20, y+ch)
        vgrad(img, 20, y, W-20, y+ch, RADIUS, C["green"], C["green_dark"])

        # Competition icon box
        rr(draw, 32, y+17, 78, y+63, 10, fill=C["green_mid"])
        _icon_trophy(draw, 55, y+40, 10, C["amber"])

        # Pool info
        tx = 90
        draw.text((tx, y+20), name, font=FH(16), fill=C["off_white"], anchor="lm")
        draw.text((tx, y+39), comp, font=FB(11), fill=C["muted"], anchor="lm")
        draw.text((tx, y+57), f"{members}   {matches}", font=FB(11), fill=C["muted"], anchor="lm")

        # Chevron
        draw.text((W-22, y+40), ">", font=FH(18), fill=C["muted"], anchor="mm")
        y += ch + 12

    img.save(os.path.join(OUT, "02_home.png"))
    print("  02_home.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 3 — Pool Detail (Jogos tab)
# ─────────────────────────────────────────────────────────────────────────────
def screen_pool_detail():
    img  = Image.new("RGB", (W, H), C["cream"])
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=0)
    body_y += 16

    # Fixed-center-width (104px) — matches MatchTeamsRow.centerWidth
    CW = 104
    TEAM_L = (W - 32 - CW) // 2   # width for each team name column

    matches = [
        ("live",      "Real Madrid",     "Barcelona",  2, 1,    "45"),
        ("scheduled", "Manchester City", "Arsenal",    None, None, "14/06  21:00"),
        ("finished",  "Bayern Munich",   "PSG",        3, 1,    "Encerrado"),
    ]

    for status, home, away, sh, sa, label in matches:
        ch = 90
        is_live = status == "live"
        card_shadow(img, 16, body_y, W-16, body_y+ch)
        vgrad(img, 16, body_y, W-16, body_y+ch, RADIUS, C["green"], C["green_dark"])
        if is_live:
            rr(draw, 16, body_y, W-16, body_y+ch, RADIUS, outline=C["live_red"], w=2)

        # ── Status row (fixed height 22px) ──────────────────────────────────
        sy = body_y + 14
        if is_live:
            rr(draw, 28, sy, 28+90, sy+16, 3, fill=C["live_red"])
            draw.text((73, sy+8), f"AO VIVO  {label}'", font=FH(10),
                      fill=C["white"], anchor="mm")
        else:
            draw.text((28, sy+8), label, font=FB(10), fill=C["muted"], anchor="lm")

        # ── Teams row (fixed geometry) ───────────────────────────────────────
        ty = body_y + 58
        home_x_right = 16 + TEAM_L         # right edge of home team area
        away_x_left  = home_x_right + CW   # left edge of away team area
        cx = home_x_right + CW // 2        # center point

        draw.text((home_x_right - 4, ty), home, font=FH(14), fill=C["off_white"], anchor="rm")
        draw.text((away_x_left  + 4, ty), away, font=FH(14), fill=C["off_white"], anchor="lm")

        if sh is not None:
            draw.text((cx, ty), f"{sh}  x  {sa}", font=FH(24), fill=C["amber"], anchor="mm")
        else:
            draw.text((cx, ty), "x", font=FH(20), fill=C["muted"], anchor="mm")

        body_y += ch + 10

    img.save(os.path.join(OUT, "03_pool_detail.png"))
    print("  03_pool_detail.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 4 — Predictions
# ─────────────────────────────────────────────────────────────────────────────
def screen_predictions():
    img  = Image.new("RGB", (W, H), C["cream"])
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=0)
    body_y += 16

    CW = 104  # fixed center width (matches Flutter MatchTeamsRow.centerWidth)
    TEAM_L = (W - 32 - CW) // 2
    home_xr = 16 + TEAM_L
    away_xl = home_xr + CW
    cx = home_xr + CW // 2

    # Date header
    draw.text((20, body_y + 4), "14/06", font=FH(12), fill=C["muted_dk"], anchor="lm")
    body_y += 28

    # ── Card 1: user actively typing 2 x 1 ───────────────────────────────────
    ch = 100
    card_shadow(img, 16, body_y, W-16, body_y+ch)
    vgrad(img, 16, body_y, W-16, body_y+ch, RADIUS, C["green"], C["green_dark"])

    # Header row (22px tall)
    draw.text((28, body_y+14+3), "21:00", font=FB(10), fill=C["muted"], anchor="lm")
    draw.text((W-28, body_y+14+3), "salvando...", font=FB(10), fill=C["amber"], anchor="rm")
    # Tiny spinner circle
    draw.ellipse([W-97, body_y+17, W-89, body_y+25], outline=C["amber"], width=1)

    ty = body_y + 62
    draw.text((home_xr-4, ty), "Manchester City", font=FH(13), fill=C["off_white"], anchor="rm")
    draw.text((away_xl+4, ty), "Arsenal",         font=FH(13), fill=C["off_white"], anchor="lm")
    # Score inputs (44x44) centered within the 104px zone
    bx1 = cx - 48
    bx2 = cx + 4
    for bx, val in [(bx1, "2"), (bx2, "1")]:
        rr(draw, bx, ty-22, bx+44, ty+22, 8, fill=C["green_mid"], outline=C["amber"], w=2)
        draw.text((bx+22, ty), val, font=FH(22), fill=C["amber"], anchor="mm")
    draw.text((cx, ty), "x", font=FH(14), fill=C["muted"], anchor="mm")
    body_y += ch + 10

    # ── Card 2: empty inputs ──────────────────────────────────────────────────
    ch = 100
    card_shadow(img, 16, body_y, W-16, body_y+ch)
    vgrad(img, 16, body_y, W-16, body_y+ch, RADIUS, C["green"], C["green_dark"])
    draw.text((28, body_y+14+3), "14/06  18:45", font=FB(10), fill=C["muted"], anchor="lm")
    ty2 = body_y + 62
    draw.text((home_xr-4, ty2), "Real Madrid", font=FH(13), fill=C["off_white"], anchor="rm")
    draw.text((away_xl+4, ty2), "Atletico",    font=FH(13), fill=C["off_white"], anchor="lm")
    for bx in [bx1, bx2]:
        rr(draw, bx, ty2-22, bx+44, ty2+22, 8, fill=C["green_mid"], outline=C["green_lt"], w=1)
    draw.text((cx, ty2), "x", font=FH(14), fill=C["muted"], anchor="mm")
    body_y += ch + 10

    # ── Card 3: locked — finished match with recap ────────────────────────────
    ch = 108
    card_shadow(img, 16, body_y, W-16, body_y+ch)
    vgrad(img, 16, body_y, W-16, body_y+ch, RADIUS, C["green"], C["green_dark"])
    # Header
    _icon_lock(draw, W-84, body_y+14+4, 7, C["muted"])
    draw.text((W-72, body_y+14+4), "encerrado", font=FB(10), fill=C["muted"], anchor="lm")
    # Teams + score
    ty3 = body_y + 58
    draw.text((home_xr-4, ty3), "Bayern Munich", font=FH(13), fill=C["off_white"], anchor="rm")
    draw.text((away_xl+4, ty3), "PSG",           font=FH(13), fill=C["off_white"], anchor="lm")
    draw.text((cx, ty3), "3  x  1", font=FH(26), fill=C["amber"], anchor="mm")
    # Recap row
    recap_y = body_y + 88
    # Divider line
    draw.line([(28, recap_y-4), (W-28, recap_y-4)], fill=C["green_lt"], width=1)
    draw.text((28, recap_y+4), "Seu palpite: 3 x 1", font=FB(11), fill=C["muted"], anchor="lm")
    pts_badge(draw, W-90, recap_y+4, "+3 pts", C["gold"])

    img.save(os.path.join(OUT, "04_predictions.png"))
    print("  04_predictions.png")


# ─────────────────────────────────────────────────────────────────────────────
# SCREEN 5 — Ranking
# ─────────────────────────────────────────────────────────────────────────────
def screen_ranking():
    img  = Image.new("RGB", (W, H), C["cream"])
    draw = ImageDraw.Draw(img)

    body_y = appbar_pool(draw, img, "Bolao da Galera", "UEFA Champions League",
                         ["JOGOS", "RANKING", "MEMBROS"], sel=1)
    body_y += 12

    entries = [
        (1, "R", "Rafael Dona",  47, True,  "3 placares exatos", C["gold"],   26),
        (2, "M", "Marcos Silva", 23, False, None,                 C["silver"], 20),
        (3, "A", "Ana Costa",    18, False, None,                 C["bronze"], 20),
        (4, "C", "Carlos",       12, False, None,                 C["muted_dk"], 18),
    ]

    for pos, init, name, pts, is_me, subtitle, pos_color, pos_sz in entries:
        rh = 66 if subtitle else 52
        mid = body_y + rh // 2

        if is_me:
            rr(draw, 16, body_y, W-16, body_y+rh, 10,
               fill=(245, 226, 190), outline=C["amber"], w=2)
        elif pos <= 3:
            rr(draw, 16, body_y, W-16, body_y+rh, 10, fill=(230, 240, 232))

        # Position (fixed 36px column)
        draw.text((28, mid), f"{pos}.", font=FH(pos_sz), fill=pos_color, anchor="lm")

        # Avatar
        _avatar(draw, 72, mid, 18, init)

        # Name + subtitle
        ny = mid - (7 if subtitle else 0)
        nf = FH(14) if is_me else FB(13)
        draw.text((100, ny), name, font=nf, fill=C["dark_text"], anchor="lm")
        if subtitle:
            draw.text((100, mid + 9), subtitle, font=FB(10), fill=C["muted_dk"], anchor="lm")

        # Points (right-aligned, stacked)
        draw.text((W-32, mid-5), str(pts), font=FH(24),
                  fill=C["amber"] if is_me else C["dark_text"], anchor="rm")
        draw.text((W-32, mid+11), "pts", font=FB(10), fill=C["muted_dk"], anchor="rm")

        body_y += rh + 8

    # ── Sticky footer — current user ─────────────────────────────────────────
    fy = H - 68
    draw.rectangle([0, fy - 1, W, H], fill=C["cream"])
    draw.line([(0, fy - 1), (W, fy - 1)], fill=C["divider"], width=1)
    rr(draw, 16, fy + 4, W - 16, fy + 54, 10,
       fill=(245, 226, 190), outline=C["amber"], w=2)
    _avatar(draw, 50, fy + 29, 16, "R")
    draw.text((74, fy + 21), "Rafael Dona", font=FH(13), fill=C["dark_text"], anchor="lm")
    draw.text((74, fy + 37), "Sua posicao", font=FB(10), fill=C["muted_dk"], anchor="lm")
    draw.text((W - 28, fy + 20), "1.", font=FH(22), fill=C["gold"], anchor="rm")
    draw.text((W - 28, fy + 40), "47 pts", font=FH(12), fill=C["amber"], anchor="rm")

    img.save(os.path.join(OUT, "05_ranking.png"))
    print("  05_ranking.png")


# ── Run ───────────────────────────────────────────────────────────────────────
print("Generating screenshots...")
screen_login()
screen_home()
screen_pool_detail()
screen_predictions()
screen_ranking()
print(f"\nDone. Saved to: {OUT}")
