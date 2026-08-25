import os
from PIL import Image, ImageDraw, ImageFont

# 出力ディレクトリ
os.makedirs("screenshots/1284x2778", exist_ok=True)
os.makedirs("screenshots/1242x2688", exist_ok=True)
os.makedirs("screenshots/1290x2796", exist_ok=True)

FONT_BOLD = "/System/Library/Fonts/Hiragino Sans GB.ttc"
if not os.path.exists(FONT_BOLD):
    FONT_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
if not os.path.exists(FONT_BOLD):
    FONT_BOLD = "/System/Library/Fonts/HelveticaNeue.ttc"

FONT_REGULAR = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"
if not os.path.exists(FONT_REGULAR):
    FONT_REGULAR = FONT_BOLD

def create_screenshot(title_main, title_sub, screen_type, filename_base):
    # ベース高解像度 (1284 x 2778)
    W, H = 1284, 2778
    img = Image.new("RGBA", (W, H), (9, 10, 15, 255))
    draw = ImageDraw.Draw(img)

    # 1. 背景グラデーション
    for y in range(H):
        ratio = y / H
        r = int(9 + (18 - 9) * ratio)
        g = int(10 + (24 - 10) * ratio)
        b = int(15 + (42 - 15) * ratio)
        draw.line([(0, y), (W, y)], fill=(r, g, b, 255))

    # 光のアクセント円
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    if screen_type in [1, 3]:
        glow_draw.ellipse([-200, 200, 800, 1200], fill=(0, 240, 255, 30))
        glow_draw.ellipse([600, 1400, 1500, 2300], fill=(16, 185, 129, 25))
    else:
        glow_draw.ellipse([500, 300, 1500, 1300], fill=(0, 240, 255, 25))
        glow_draw.ellipse([-200, 1600, 700, 2500], fill=(16, 185, 129, 20))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    try:
        font_badge = ImageFont.truetype(FONT_BOLD, 40)
        font_title = ImageFont.truetype(FONT_BOLD, 72)
        font_sub = ImageFont.truetype(FONT_REGULAR, 38)
    except:
        font_badge = ImageFont.load_default()
        font_title = ImageFont.load_default()
        font_sub = ImageFont.load_default()

    # バッジ
    badge_text = "Clickflow  •  ポケット誤操作防止"
    badge_bbox = draw.textbbox((0, 0), badge_text, font=font_badge)
    badge_w = badge_bbox[2] - badge_bbox[0] + 60
    badge_h = badge_bbox[3] - badge_bbox[1] + 30
    badge_x = (W - badge_w) // 2
    badge_y = 160

    draw.rounded_rectangle([badge_x, badge_y, badge_x + badge_w, badge_y + badge_h], radius=25, fill=(0, 240, 255, 35), outline=(0, 240, 255, 120), width=3)
    draw.text((badge_x + 30, badge_y + 12), badge_text, font=font_badge, fill=(0, 240, 255, 255))

    # メインタイトル
    title_bbox = draw.textbbox((0, 0), title_main, font=font_title)
    title_w = title_bbox[2] - title_bbox[0]
    draw.text(((W - title_w) // 2, 280), title_main, font=font_title, fill=(255, 255, 255, 255))

    # サブタイトル
    sub_bbox = draw.textbbox((0, 0), title_sub, font=font_sub)
    sub_w = sub_bbox[2] - sub_bbox[0]
    draw.text(((W - sub_w) // 2, 380), title_sub, font=font_sub, fill=(160, 175, 200, 255))

    # 3. iPhoneモックアップ枠
    phone_x = 120
    phone_y = 500
    phone_w = W - 240 # 1044
    phone_h = 2400
    phone_r = 75

    draw.rounded_rectangle([phone_x - 10, phone_y - 10, phone_x + phone_w + 10, phone_y + phone_h + 10], radius=phone_r + 10, fill=(35, 40, 55, 255), outline=(70, 85, 115, 255), width=4)
    draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_w, phone_y + phone_h], radius=phone_r, fill=(10, 12, 18, 255))

    # Dynamic Island
    island_w, island_h = 280, 75
    island_x = phone_x + (phone_w - island_w) // 2
    draw.rounded_rectangle([island_x, phone_y + 35, island_x + island_w, phone_y + 35 + island_h], radius=38, fill=(0, 0, 0, 255))

    try:
        font_ui_h1 = ImageFont.truetype(FONT_BOLD, 52)
        font_ui_body = ImageFont.truetype(FONT_REGULAR, 35)
        font_ui_bold = ImageFont.truetype(FONT_BOLD, 37)
        font_ui_large = ImageFont.truetype(FONT_BOLD, 62)
    except:
        font_ui_h1 = ImageFont.load_default()
        font_ui_body = ImageFont.load_default()
        font_ui_bold = ImageFont.load_default()
        font_ui_large = ImageFont.load_default()

    content_top = phone_y + 180

    if screen_type == 1:
        # メイン画面 (HomeView)
        draw.text((phone_x + 80, content_top), "Clickflow", font=font_ui_h1, fill=(255, 255, 255, 255))
        draw.text((phone_x + 80, content_top + 70), "ポケット誤操作防止 ＆ 音量連携", font=font_ui_body, fill=(140, 150, 170, 255))

        card_y = content_top + 180
        card_h = 360
        draw.rounded_rectangle([phone_x + 60, card_y, phone_x + phone_w - 60, card_y + card_h], radius=40, fill=(20, 25, 40, 200), outline=(0, 240, 255, 120), width=3)
        draw.ellipse([phone_x + 110, card_y + 80, phone_x + 150, card_y + 120], fill=(0, 240, 255, 255))
        draw.text((phone_x + 175, card_y + 70), "ポケットガード監視中", font=font_ui_bold, fill=(0, 240, 255, 255))
        draw.text((phone_x + 110, card_y + 150), "端末を画面下向きにポケットへ入れると、\n自動で全画面ロックが作動します。", font=font_ui_body, fill=(200, 210, 230, 255))

        toggle_x = phone_x + phone_w - 220
        toggle_y = card_y + 70
        draw.rounded_rectangle([toggle_x, toggle_y, toggle_x + 120, toggle_y + 65], radius=33, fill=(0, 240, 255, 255))
        draw.ellipse([toggle_x + 60, toggle_y + 5, toggle_x + 115, toggle_y + 60], fill=(255, 255, 255, 255))

        cmd_y = card_y + card_h + 50
        draw.rounded_rectangle([phone_x + 60, cmd_y, phone_x + phone_w - 60, cmd_y + 320], radius=40, fill=(20, 25, 40, 180), outline=(255, 255, 255, 30), width=2)
        draw.text((phone_x + 110, cmd_y + 50), "音量ボタンコマンド", font=font_ui_bold, fill=(255, 255, 255, 255))
        draw.text((phone_x + 110, cmd_y + 120), "▲ 音量上げる : 音声メモ作成", font=font_ui_body, fill=(16, 185, 129, 255))
        draw.text((phone_x + 110, cmd_y + 190), "▼ 音量下げる : タイマースタート", font=font_ui_body, fill=(0, 240, 255, 255))

    elif screen_type == 2:
        # ポケットガード画面 (OLED True Black)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_w, phone_y + phone_h], radius=phone_r, fill=(0, 0, 0, 255))
        center_y = phone_y + 650
        draw.ellipse([phone_x + phone_w//2 - 120, center_y - 120, phone_x + phone_w//2 + 120, center_y + 120], outline=(0, 240, 255, 200), width=6)
        draw.text((phone_x + phone_w//2 - 70, center_y - 45), "LOCK", font=font_ui_bold, fill=(0, 240, 255, 255))
        draw.text((phone_x + 160, center_y + 180), "ポケットガード作動中", font=font_ui_large, fill=(255, 255, 255, 255))
        draw.text((phone_x + 210, center_y + 280), "画面を3秒間長押しで解除", font=font_ui_body, fill=(140, 150, 170, 255))

    elif screen_type == 3:
        # 音量ショートカット設定
        draw.text((phone_x + 80, content_top), "設定 ＆ コマンド", font=font_ui_h1, fill=(255, 255, 255, 255))
        draw.text((phone_x + 80, content_top + 70), "音量ボタンにショートカットを割り当て", font=font_ui_body, fill=(140, 150, 170, 255))

        card_y = content_top + 180
        draw.rounded_rectangle([phone_x + 60, card_y, phone_x + phone_w - 60, card_y + 240], radius=35, fill=(20, 25, 40, 200), outline=(16, 185, 129, 100), width=2)
        draw.text((phone_x + 100, card_y + 45), "音量 ▲ ボタン (Up)", font=font_ui_bold, fill=(16, 185, 129, 255))
        draw.text((phone_x + 100, card_y + 120), "実行: 「ChatGPT 音声対話」", font=font_ui_body, fill=(255, 255, 255, 255))

        card2_y = card_y + 280
        draw.rounded_rectangle([phone_x + 60, card2_y, phone_x + phone_w - 60, card2_y + 240], radius=35, fill=(20, 25, 40, 200), outline=(0, 240, 255, 100), width=2)
        draw.text((phone_x + 100, card2_y + 45), "音量 ▼ ボタン (Down)", font=font_ui_bold, fill=(0, 240, 255, 255))
        draw.text((phone_x + 100, card2_y + 120), "実行: 「クイックリマインダー」", font=font_ui_body, fill=(255, 255, 255, 255))

        feat_y = card2_y + 300
        draw.rounded_rectangle([phone_x + 60, feat_y, phone_x + phone_w - 60, feat_y + 200], radius=35, fill=(10, 30, 45, 180), outline=(0, 240, 255, 60), width=2)
        draw.text((phone_x + 100, feat_y + 45), "音量自動復元機能", font=font_ui_bold, fill=(0, 240, 255, 255))
        draw.text((phone_x + 100, feat_y + 110), "ボタン押下前の音量を記憶し、常に自動復元します。", font=font_ui_body, fill=(180, 195, 215, 255))

    elif screen_type == 4:
        # セキュリティ
        draw.text((phone_x + 80, content_top), "安心のプライバシー設計", font=font_ui_h1, fill=(255, 255, 255, 255))
        draw.text((phone_x + 80, content_top + 70), "完全ローカル・オフライン動作", font=font_ui_body, fill=(140, 150, 170, 255))

        items = [
            ("端末内ローカル処理", "センサー情報は端末外に一切送信されません"),
            ("広告・トラッキング ゼロ", "アナリティクスやトラッキングSDK非搭載"),
            ("バックグラウンド自動復帰", "アプリが終了しても次回起動時に自動再開"),
            ("バッテリー超省電力", "OLEDディスプレイに最適化されたTrue Black")
        ]

        item_y = content_top + 180
        for title, desc in items:
            draw.rounded_rectangle([phone_x + 60, item_y, phone_x + phone_w - 60, item_y + 170], radius=30, fill=(20, 25, 40, 180), outline=(255, 255, 255, 30), width=2)
            draw.ellipse([phone_x + 95, item_y + 65, phone_x + 125, item_y + 95], fill=(16, 185, 129, 255))
            draw.text((phone_x + 145, item_y + 40), title, font=font_ui_bold, fill=(255, 255, 255, 255))
            draw.text((phone_x + 145, item_y + 95), desc, font=font_ui_body, fill=(150, 165, 185, 255))
            item_y += 205

    # RGB 24bitに変換 (アルファなし、App Store Connect 厳格準拠)
    rgb_img_1284 = img.convert("RGB")
    path_1284 = f"screenshots/1284x2778/{filename_base}.png"
    rgb_img_1284.save(path_1284, "PNG")

    # 1242 x 2688 (iPhone 6.5インチ)
    rgb_img_1242 = rgb_img_1284.resize((1242, 2688), Image.Resampling.LANCZOS)
    path_1242 = f"screenshots/1242x2688/{filename_base}.png"
    rgb_img_1242.save(path_1242, "PNG")

    # 1290 x 2796 (iPhone 6.7インチ)
    rgb_img_1290 = rgb_img_1284.resize((1290, 2796), Image.Resampling.LANCZOS)
    path_1290 = f"screenshots/1290x2796/{filename_base}.png"
    rgb_img_1290.save(path_1290, "PNG")

    print(f"Generated 1284x2778, 1242x2688, 1290x2796 for {filename_base}")

create_screenshot("ポケット内の誤操作をゼロに", "画面下向きを検知して自動で全画面ロック", 1, "01_home_guard")
create_screenshot("OLED True Black 保護", "有機ELに最適化された完全ブラック画面で省電力", 2, "02_active_guard")
create_screenshot("音量ボタンでショートカット即起動", "画面を見ずに日常のタスク・メモを素早く実行", 3, "03_volume_command")
create_screenshot("完全ローカル・プライバシー保護", "外部送信なし・個人情報収集ゼロの安全設計", 4, "04_privacy_security")
