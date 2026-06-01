"""
Generate Banca do Palpite app screenshot mockups.
Matches the exact Flutter design system: colors, fonts, layouts.
"""

from PIL import Image, ImageDraw, ImageFont
import os, math

OUT = r"C:\Users\gu150\banca_do_palpite\docs\screenshots"
os.makedirs(OUT, exist_ok=True)

# ── Design tokens ────────────────────────────────────────────────────────────
W, H = 390, 844
CREAM     = (245, 238, 220)
GREEN     = (18,  72,  50)
GREEN_MID = (30, 100,  68)
GREEN_LT  = (45, 130,  85)
AMBER     = (220, 140,  20)
AMBER_LT  = (240, 170,  50)
OFF_WHITE = (252, 248, 238)
MUTED     = (122, 154, 122)
MUTED_DK  = (138, 138, 122)
DARK_TEXT = ( 22,  30,  22)
INPUT_FILL= (237, 228, 204)
DIVIDER   = (212, 201, 168)
LIVE_RED  = (180,  55,  40)
GOLD      = (255, 215,   0)
SILVER    = (176, 176, 176)
BRONZE    = (205, 127,  50)

APPBAR_H = 56
TAB_H    = 48

# ── Font helpers ─────────────────────────────────────────────────────────────
def font(size, bold=False):
    """Load a system font that supports the characters we need."""
    candidates_bold = [
        r"C:\Windows\Fonts\arialbd.ttf",
        r"C:\Windows\Fonts\Arial Bold.ttf",
        r"C:\Windows\Fonts\calibrib.ttf",
    ]
    candidates_regular = [
        r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\Arial.ttf",
        r"C:\Windows\Fonts\calibri.ttf",
        r"C:\Windows\Fonts\segoeui.ttf",
    ]
    candidates = candidates_bold if bold else candidates_regular
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()

F_HEADING = lambda s: font(s, bold=True)
F_BODY    = lambda s: font(s, bold=False)

# ── Drawing primitives ────────────────────────────────────────────────────────
def rounded_rect(draw, x0, y0, x1, y1, r, fill=None, outline=None, width=1):
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r,
                            fill=fill, outline=outline, width=width)

def hexagon(draw, cx, cy, size, fill, outline=None):
    pts = []
    for i in range(6):
        a = math.radians(60 * i - 30)
        pts.append((cx + size * math.cos(a), cy + size * math.sin(a)))
    draw.polygon(pts, fill=fill, outline=outline)

def draw_hex_logo(draw, cx, cy, hex_r=18):
    """Draw the B hexagon logo."""
    hexagon(draw, cx, cy, hex_r, AMBER)
    draw.text((cx, cy), "B", font=F_HEADING(int(hex_r * 0.9)),
              fill=GREEN, anchor="mm")

def appbar(draw, title, back=True, icons_right=None):
    """Draw the standard green app bar."""
    draw.rectangle([0, 0, W, APPBAR_H], fill=GREEN)
    x = 16
    if back:
        draw.text((x, APPBAR_H // 2), "←", font=F_HEADING(20),
                  fill=OFF_WHITE, anchor="lm")
        x = 48
    draw.text((x, APPBAR_H // 2), title, font=F_HEADING(20),
              fill=OFF_WHITE, anchor="lm")
    if icons_right:
        rx = W - 16
        for icon in reversed(icons_right):
            draw.text((rx, APPBAR_H // 2), icon, font=F_BODY(18),
                      fill=OFF_WHITE, anchor="rm")
            rx -= 36

def tabbar(draw, tabs, selected, top=APPBAR_H):
    """Draw a tab bar on a green background."""
    draw.rectangle([0, top, W, top + TAB_H], fill=GREEN)
    n = len(tabs)
    tw = W // n
    for i, label in enumerate(tabs):
        cx = i * tw + tw // 2
        cy = top + TAB_H // 2
        active = (i == selected)
        color = AMBER if active else MUTED
        draw.text((cx, cy), label, font=F_HEADING(14),
                  fill=color, anchor="mm")
        if active:
            draw.rectangle([i * tw + 4, top + TAB_H - 3,
                            (i + 1) * tw - 4, top + TAB_H],
                           fill=AMBER)

def input_field(draw, x, y, w, h, label, icon="", value=""):
    """Draw an input field."""
    rounded_rect(draw, x, y, x + w, y + h, 10, fill=INPUT_FILL)
    if icon:
        draw.text((x + 14, y + h // 2), icon, font=F_BODY(14),
                  fill=GREEN_LT, anchor="lm")
        draw.text((x + 34, y + h // 2), label if not value else value,
                  font=F_BODY(14),
                  fill=MUTED_DK if not value else DARK_TEXT, anchor="lm")
    else:
        draw.text((x + 14, y + h // 2), label if not value else value,
                  font=F_BODY(14),
                  fill=MUTED_DK if not value else DARK_TEXT, anchor="lm")

def card_shadow(img, x0, y0, x1, y1, r=14):
    """Draw a subtle drop shadow behind a card."""
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([x0 + 2, y0 + 3, x1 + 2, y1 + 3], radius=r,
                          fill=(0, 0, 0, 30))
    img.paste(shadow, mask=shadow)

def match_row(draw, cx, home, away, score_home=None, score_away=None, sep="×"):
    """Draw a teams row with optional score."""
    mid = cx
    if score_home is not None:
        score_txt = f"{score_home}  {sep}  {score_away}"
        draw.text((mid, 0), score_txt, font=F_HEADING(28),
                  fill=AMBER, anchor="mm")  # placeholder; caller positions
    draw.text((mid - 60, 0), home, font=F_HEADING(15),
              fill=OFF_WHITE, anchor="rm")
    draw.text((mid + 60, 0), away, font=F_HEADING(15),
              fill=OFF_WHITE, anchor="lm")

def circle_avatar(draw, cx, cy, r, initial, bg=GREEN, fg=AMBER):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=bg)
    draw.text((cx, cy), initial, font=F_HEADING(int(r * 1.0)),
              fill=fg, anchor="mm")

# ── SCREEN 1: Login ───────────────────────────────────────────────────────────
def screen_login():
    img = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    appbar(draw, "ENTRAR", back=True)

    y = APPBAR_H + 40
    # Logo
    draw_hex_logo(draw, W // 2, y + 32, hex_r=32)
    y += 88

    # Title
    draw.text((24, y), "Bem-vindo de volta!", font=F_HEADING(26),
              fill=DARK_TEXT, anchor="lm")
    y += 34
    draw.text((24, y), "Entre para ver seus bolões.", font=F_BODY(14),
              fill=MUTED_DK, anchor="lm")
    y += 40

    # Inputs
    input_field(draw, 20, y, W - 40, 52, "Email", icon="✉")
    y += 64
    input_field(draw, 20, y, W - 40, 52, "Senha", icon="🔒")
    # eye icon
    draw.text((W - 32, y + 26), "👁", font=F_BODY(14),
              fill=MUTED_DK, anchor="mm")
    y += 64

    # Forgot password
    draw.text((W - 20, y), "Esqueci minha senha", font=F_BODY(12),
              fill=AMBER, anchor="rm")
    y += 28

    # ENTRAR button
    rounded_rect(draw, 20, y, W - 20, y + 52, 12, fill=AMBER)
    draw.text((W // 2, y + 26), "ENTRAR", font=F_HEADING(16),
              fill=GREEN, anchor="mm")
    y += 68

    # Sign up link
    txt = "Ainda não tem conta?  "
    w1 = draw.textlength(txt, font=F_BODY(13))
    total_w = w1 + draw.textlength("Criar conta", font=F_BODY(13))
    x0 = (W - total_w) // 2
    draw.text((x0, y), txt, font=F_BODY(13), fill=MUTED_DK, anchor="lm")
    draw.text((x0 + w1, y), "Criar conta", font=F_BODY(13),
              fill=AMBER, anchor="lm")

    img.save(os.path.join(OUT, "01_login.png"))
    print("✓ 01_login.png")

# ── SCREEN 2: Home ────────────────────────────────────────────────────────────
def screen_home():
    img = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    # Custom app bar with logo
    draw.rectangle([0, 0, W, APPBAR_H], fill=GREEN)
    draw_hex_logo(draw, 28, APPBAR_H // 2, hex_r=14)
    draw.text((48, APPBAR_H // 2 - 6), "BANCA DO",
              font=F_BODY(9), fill=OFF_WHITE, anchor="lm")
    draw.text((48, APPBAR_H // 2 + 6), "PALPITE",
              font=F_HEADING(14), fill=AMBER, anchor="lm")
    draw.text((W - 20, APPBAR_H // 2), "👤", font=F_BODY(18),
              fill=OFF_WHITE, anchor="rm")

    y = APPBAR_H + 24
    draw.text((20, y), "Olá, Rafael! 👋", font=F_HEADING(26),
              fill=DARK_TEXT, anchor="lm")
    y += 40

    # Action buttons
    bw = (W - 52) // 2
    rounded_rect(draw, 20, y, 20 + bw, y + 44, 12, fill=AMBER)
    draw.text((20 + bw // 2, y + 22), "+ CRIAR BOLÃO",
              font=F_HEADING(12), fill=GREEN, anchor="mm")

    rounded_rect(draw, 20 + bw + 12, y, W - 20, y + 44, 12,
                 fill=None, outline=GREEN, width=2)
    draw.text((20 + bw + 12 + bw // 2, y + 22), "ENTRAR",
              font=F_HEADING(12), fill=GREEN, anchor="mm")
    y += 60

    # Pool cards
    pools = [
        ("Bolão da Galera",  "UEFA Champions League", "8", "6"),
        ("Champions 2024",   "Champions League",       "5", "8"),
        ("Copa do Brasil",   "Copa do Brasil",         "4", "4"),
    ]
    for name, comp, members, matches in pools:
        card_shadow(img, 20, y, W - 20, y + 80)
        rounded_rect(draw, 20, y, W - 20, y + 80, 14, fill=GREEN)

        # Competition logo square
        rounded_rect(draw, 32, y + 18, 76, y + 62, 8, fill=GREEN_MID)
        draw.text((54, y + 40), "🏆", font=F_BODY(18), fill=AMBER, anchor="mm")

        # Text
        tx = 88
        draw.text((tx, y + 24), name, font=F_HEADING(16),
                  fill=OFF_WHITE, anchor="lm")
        draw.text((tx, y + 42), comp, font=F_BODY(11),
                  fill=MUTED, anchor="lm")

        # Chips
        cy2 = y + 60
        draw.text((tx, cy2), f"👥 {members}", font=F_BODY(11),
                  fill=MUTED, anchor="lm")
        draw.text((tx + 70, cy2), f"⚽ {matches} jogos", font=F_BODY(11),
                  fill=MUTED, anchor="lm")

        # Chevron
        draw.text((W - 32, y + 40), "›", font=F_HEADING(22),
                  fill=MUTED, anchor="mm")
        y += 96

    img.save(os.path.join(OUT, "02_home.png"))
    print("✓ 02_home.png")

# ── SCREEN 3: Pool Detail ─────────────────────────────────────────────────────
def screen_pool_detail():
    img = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    # Extended app bar
    ext = APPBAR_H + 50
    draw.rectangle([0, 0, W, ext], fill=GREEN)
    draw.text((48, 20), "←", font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((W - 80, 20), "⚙", font=F_BODY(18), fill=OFF_WHITE, anchor="lm")
    draw.text((W - 44, 20), "↑", font=F_BODY(18), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 10), "Bolão da Galera",
              font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 32), "UEFA Champions League",
              font=F_BODY(11), fill=MUTED, anchor="lm")

    tabbar(draw, ["JOGOS", "RANKING", "MEMBROS"], selected=0, top=ext)
    body_y = ext + TAB_H + 16

    matches = [
        ("live",      "Real Madrid",     "Barcelona",    2, 1, "45'"),
        ("scheduled", "Manchester City", "Arsenal",      None, None, "21:00"),
        ("finished",  "Bayern Munich",   "PSG",          3, 1, "Encerrado"),
    ]

    for status, home, away, sh, sa, label in matches:
        card_h = 90
        card_shadow(img, 16, body_y, W - 16, body_y + card_h)
        is_live = status == "live"
        rounded_rect(draw, 16, body_y, W - 16, body_y + card_h, 12,
                     fill=GREEN,
                     outline=LIVE_RED if is_live else None,
                     width=2 if is_live else 0)

        # Status row
        if is_live:
            rounded_rect(draw, 28, body_y + 10, 120, body_y + 26, 4,
                         fill=LIVE_RED)
            draw.text((74, body_y + 18), f"● AO VIVO  {label}",
                      font=F_HEADING(10), fill=OFF_WHITE, anchor="mm")
        else:
            draw.text((28, body_y + 18), label, font=F_BODY(10),
                      fill=MUTED, anchor="lm")

        # Teams row
        mid_y = body_y + 58
        if sh is not None:
            score = f"{sh}  ×  {sa}"
            draw.text((W // 2, mid_y), score, font=F_HEADING(26),
                      fill=AMBER, anchor="mm")
        else:
            draw.text((W // 2, mid_y), "×", font=F_HEADING(20),
                      fill=MUTED, anchor="mm")

        draw.text((W // 2 - 70, mid_y), home, font=F_HEADING(14),
                  fill=OFF_WHITE, anchor="rm")
        draw.text((W // 2 + 70, mid_y), away, font=F_HEADING(14),
                  fill=OFF_WHITE, anchor="lm")

        body_y += card_h + 12

    img.save(os.path.join(OUT, "03_pool_detail.png"))
    print("✓ 03_pool_detail.png")

# ── SCREEN 4: Predictions ─────────────────────────────────────────────────────
def screen_predictions():
    img = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    ext = APPBAR_H + 50
    draw.rectangle([0, 0, W, ext], fill=GREEN)
    draw.text((16, 20), "←", font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 10), "Bolão da Galera",
              font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 32), "UEFA Champions League",
              font=F_BODY(11), fill=MUTED, anchor="lm")

    tabbar(draw, ["JOGOS", "RANKING", "MEMBROS"], selected=0, top=ext)
    body_y = ext + TAB_H + 16

    # Date header
    draw.text((20, body_y + 6), "14/06", font=F_HEADING(13),
              fill=MUTED_DK, anchor="lm")
    body_y += 28

    # Card 1 — user typing a score (2 × 1)
    card_h = 100
    card_shadow(img, 16, body_y, W - 16, body_y + card_h)
    rounded_rect(draw, 16, body_y, W - 16, body_y + card_h, 12, fill=GREEN)

    draw.text((28, body_y + 14), "21:00", font=F_BODY(10), fill=MUTED, anchor="lm")
    draw.text((W - 28, body_y + 14), "salvando...", font=F_BODY(10),
              fill=AMBER, anchor="rm")

    mid_y = body_y + 62
    draw.text((W // 2 - 68, mid_y), "Manchester City",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W // 2 + 68, mid_y), "Arsenal",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="lm")

    # Score inputs (focused, amber border)
    box_x1, box_x2 = W // 2 - 50, W // 2 + 6
    for bx, val in [(box_x1, "2"), (box_x2, "1")]:
        rounded_rect(draw, bx, mid_y - 22, bx + 44, mid_y + 22, 8,
                     fill=GREEN_MID, outline=AMBER, width=2)
        draw.text((bx + 22, mid_y), val, font=F_HEADING(22),
                  fill=AMBER, anchor="mm")
    draw.text((W // 2 - 3, mid_y), "×", font=F_HEADING(16),
              fill=MUTED, anchor="mm")
    body_y += card_h + 10

    # Card 2 — empty inputs
    card_h2 = 100
    card_shadow(img, 16, body_y, W - 16, body_y + card_h2)
    rounded_rect(draw, 16, body_y, W - 16, body_y + card_h2, 12, fill=GREEN)
    draw.text((28, body_y + 14), "14/06  18:45",
              font=F_BODY(10), fill=MUTED, anchor="lm")

    mid_y2 = body_y + 62
    draw.text((W // 2 - 68, mid_y2), "Real Madrid",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W // 2 + 68, mid_y2), "Atlético",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="lm")
    for bx in [W // 2 - 50, W // 2 + 6]:
        rounded_rect(draw, bx, mid_y2 - 22, bx + 44, mid_y2 + 22, 8,
                     fill=GREEN_MID, outline=GREEN_LT, width=1)
    draw.text((W // 2 - 3, mid_y2), "×", font=F_HEADING(16),
              fill=MUTED, anchor="mm")
    body_y += card_h2 + 10

    # Card 3 — locked / finished
    card_h3 = 110
    card_shadow(img, 16, body_y, W - 16, body_y + card_h3)
    rounded_rect(draw, 16, body_y, W - 16, body_y + card_h3, 12, fill=GREEN)

    draw.text((W - 28, body_y + 14), "🔒 encerrado",
              font=F_BODY(10), fill=MUTED, anchor="rm")

    mid_y3 = body_y + 56
    draw.text((W // 2 - 60, mid_y3), "Bayern Munich",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="rm")
    draw.text((W // 2 + 60, mid_y3), "PSG",
              font=F_HEADING(13), fill=OFF_WHITE, anchor="lm")
    draw.text((W // 2, mid_y3), "3  ×  1", font=F_HEADING(28),
              fill=AMBER, anchor="mm")

    # Recap row
    recap_y = body_y + 85
    draw.text((28, recap_y), "Seu palpite: 3 × 1",
              font=F_BODY(11), fill=MUTED, anchor="lm")

    # +3 pts badge (gold)
    badge_x = W - 28
    badge_txt = "+3 pts 🎯"
    bw2 = int(draw.textlength(badge_txt, font=F_HEADING(12))) + 16
    rounded_rect(draw, badge_x - bw2, recap_y - 8,
                 badge_x, recap_y + 10, 4,
                 fill=None, outline=GOLD, width=1)
    draw.text((badge_x - bw2 // 2, recap_y + 1), badge_txt,
              font=F_HEADING(11), fill=GOLD, anchor="mm")

    img.save(os.path.join(OUT, "04_predictions.png"))
    print("✓ 04_predictions.png")

# ── SCREEN 5: Ranking ────────────────────────────────────────────────────────
def screen_ranking():
    img = Image.new("RGB", (W, H), CREAM)
    draw = ImageDraw.Draw(img)

    ext = APPBAR_H + 50
    draw.rectangle([0, 0, W, ext], fill=GREEN)
    draw.text((16, 20), "←", font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 10), "Bolão da Galera",
              font=F_HEADING(20), fill=OFF_WHITE, anchor="lm")
    draw.text((16, APPBAR_H + 32), "UEFA Champions League",
              font=F_BODY(11), fill=MUTED, anchor="lm")

    tabbar(draw, ["JOGOS", "RANKING", "MEMBROS"], selected=1, top=ext)
    body_y = ext + TAB_H + 12

    entries = [
        (1, "R", "Rafael Doná",  47, True,  "3 placares exatos 🎯", GOLD,   26),
        (2, "M", "Marcos Silva", 23, False, "",                      SILVER, 20),
        (3, "A", "Ana Costa",    18, False, "",                      BRONZE, 20),
        (4, "C", "Carlos",       12, False, "",                      MUTED_DK, 18),
    ]

    for pos, initial, name, pts, is_me, subtitle, pos_color, pos_size in entries:
        row_h = 64 if subtitle else 52
        bg = (*AMBER, 20) if is_me else None
        border = AMBER if is_me else None

        # Row background
        if is_me:
            rounded_rect(draw, 16, body_y, W - 16, body_y + row_h, 10,
                         fill=(245, 226, 190), outline=AMBER, width=2)
        else:
            rounded_rect(draw, 16, body_y, W - 16, body_y + row_h, 10,
                         fill=None, outline=None)

        mid_r = body_y + row_h // 2

        # Position number
        draw.text((30, mid_r), f"{pos}°", font=F_HEADING(pos_size),
                  fill=pos_color, anchor="lm")

        # Avatar
        circle_avatar(draw, 75, mid_r, 18, initial)

        # Name
        name_y = mid_r - (8 if subtitle else 0)
        draw.text((102, name_y), name,
                  font=F_HEADING(14) if is_me else F_BODY(13),
                  fill=DARK_TEXT, anchor="lm")
        if subtitle:
            draw.text((102, mid_r + 10), subtitle,
                      font=F_BODY(10), fill=MUTED_DK, anchor="lm")

        # Points
        draw.text((W - 48, mid_r - 4), str(pts),
                  font=F_HEADING(26),
                  fill=AMBER if is_me else DARK_TEXT, anchor="rm")
        draw.text((W - 26, mid_r + 8), "pts",
                  font=F_BODY(10), fill=MUTED_DK, anchor="rm")

        body_y += row_h + 8

    # Sticky footer for current user
    footer_y = H - 72
    draw.rectangle([0, footer_y - 1, W, H], fill=CREAM)
    draw.line([(0, footer_y - 1), (W, footer_y - 1)], fill=DIVIDER, width=1)
    rounded_rect(draw, 16, footer_y + 4, W - 16, footer_y + 56, 10,
                 fill=(245, 226, 190), outline=AMBER, width=2)
    circle_avatar(draw, 55, footer_y + 30, 16, "R")
    draw.text((80, footer_y + 22), "Rafael Doná", font=F_HEADING(13),
              fill=DARK_TEXT, anchor="lm")
    draw.text((80, footer_y + 38), "Sua posição", font=F_BODY(10),
              fill=MUTED_DK, anchor="lm")
    draw.text((W - 32, footer_y + 24), "1°", font=F_HEADING(24),
              fill=GOLD, anchor="rm")
    draw.text((W - 32, footer_y + 44), "47 pts", font=F_BODY(11),
              fill=AMBER, anchor="rm")

    img.save(os.path.join(OUT, "05_ranking.png"))
    print("✓ 05_ranking.png")

# ── Run all ──────────────────────────────────────────────────────────────────
screen_login()
screen_home()
screen_pool_detail()
screen_predictions()
screen_ranking()
print(f"\nAll screenshots saved to: {OUT}")
