#!/usr/bin/env bash
# Cài skill landing-page-workflow vào Hermes.
#
# Idempotent: chạy lại sau mỗi lần cập nhật đều an toàn.
#
# Usage:
#   ./install.sh                 # cài vào $HERMES_HOME/skills/
#   HERMES_HOME=/opt/data ./install.sh   # bản Docker

set -euo pipefail

SKILL_ID="landing-page-workflow"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Bản Docker chính thức dùng /opt/data, không phải ~/.hermes.
if [ -n "${HERMES_HOME:-}" ]; then
  HOME_DIR="$HERMES_HOME"
elif [ -d /opt/data ] && [ -f /opt/data/config.yaml ]; then
  HOME_DIR=/opt/data
else
  HOME_DIR="$HOME/.hermes"
fi

TARGET="$HOME_DIR/skills/$SKILL_ID"

echo "→ Cài $SKILL_ID vào $TARGET"
mkdir -p "$TARGET"
cp -R "$SRC_DIR/skills/$SKILL_ID/." "$TARGET/"

# Tap installer của Hermes không giữ exec bit (hạn chế upstream). Mọi script
# đều là Python stdlib nên `python3 scripts/<tên>` luôn chạy được, nhưng đặt
# lại cờ cho bản cài thủ công vẫn tiện hơn.
chmod +x "$TARGET"/scripts/* 2>/dev/null || true

echo "  ✓ SKILL.md, scripts/, references/"
echo ""
echo "Kiểm tra:"
echo "  hermes skills list | grep $SKILL_ID"
echo ""
echo "Chạy preflight trước khi bắt đầu dự án đầu tiên:"
echo "  python3 $TARGET/scripts/preflight"
