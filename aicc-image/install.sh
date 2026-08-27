#!/bin/bash
# AICC 그림일기 스킬 원클릭 설치 스크립트 (macOS)
# 사용법: 터미널에 아래 한 줄을 붙여넣고 엔터
#   curl -fsSL https://raw.githubusercontent.com/henryoon0/aicc-image-skill/main/aicc-image/install.sh | bash
set -euo pipefail

REPO_TAR="https://github.com/henryoon0/aicc-image-skill/archive/refs/heads/main.tar.gz"
SKILL_DIR="$HOME/.claude/skills/aicc-image"

say()  { printf '\n\033[1m%s\033[0m\n' "$1"; }
note() { printf '  %s\n' "$1"; }

say "① 그림일기 스킬 내려받는 중..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
curl -fsSL "$REPO_TAR" | tar -xz -C "$TMP"
SRC=$(find "$TMP" -maxdepth 2 -type d -name "aicc-image" | head -1)
[[ -n "$SRC" && -f "$SRC/SKILL.md" ]] || { echo "다운로드한 파일에서 스킬을 찾지 못했습니다."; exit 1; }

mkdir -p "$HOME/.claude/skills"
if [[ -d "$SKILL_DIR" ]]; then
  BAK="$SKILL_DIR.bak-$(date +%Y%m%d%H%M%S)"
  note "기존 aicc-image 스킬을 발견해 백업합니다 → $BAK"
  mv "$SKILL_DIR" "$BAK"
fi
cp -R "$SRC" "$SKILL_DIR"
chmod +x "$SKILL_DIR/scripts/aicc-image.sh"
note "설치 위치: $SKILL_DIR ✔"

say "② Claude Code 확인"
if command -v claude >/dev/null 2>&1; then
  note "Claude Code 있음 ✔"
else
  note "터미널에서 claude 명령이 안 보여요. Claude 데스크톱 앱을 쓰신다면 괜찮습니다."
  note "둘 다 없다면 설치: https://claude.com/claude-code"
fi

say "③ codex (ChatGPT 그림 도구) 확인"
if command -v codex >/dev/null 2>&1; then
  note "codex 있음 ✔"
else
  if command -v npm >/dev/null 2>&1; then
    note "codex 설치 중... (1분 정도)"
    if ! npm install -g @openai/codex >/dev/null 2>&1; then
      note "권한 문제로 관리자 암호가 필요합니다. Mac 로그인 암호를 입력해 주세요."
      sudo npm install -g @openai/codex
    fi
    note "codex 설치 완료 ✔"
  elif command -v brew >/dev/null 2>&1; then
    note "Node.js 설치 중... (몇 분 걸릴 수 있어요)"
    brew install node >/dev/null
    npm install -g @openai/codex >/dev/null 2>&1 || sudo npm install -g @openai/codex
    note "codex 설치 완료 ✔"
  else
    note "Node.js 가 필요합니다. https://nodejs.org 에서 LTS 버전을 설치한 뒤,"
    note "이 명령을 한 번 더 실행해 주세요."
    exit 0
  fi
fi

say "④ ChatGPT 로그인 확인"
LOGIN=$(codex login status 2>&1 || true)
if [[ "$LOGIN" == *"ChatGPT"* ]]; then
  note "이미 로그인돼 있음 ✔"
else
  if [[ -e /dev/tty ]]; then
    note "브라우저가 열리면 ChatGPT 계정으로 로그인해 주세요."
    codex login </dev/tty >/dev/tty 2>&1 || {
      note "로그인이 완료되지 않았어요. 나중에 터미널에서 'codex login' 을 실행하면 됩니다."; }
  else
    note "터미널에서 'codex login' 을 실행해 ChatGPT 로 로그인해 주세요."
  fi
fi

say "🎉 설치 끝!"
note "Claude Code 를 열고 (이미 열려 있었다면 새 대화 시작) 이렇게 말해보세요:"
note "\"이 사진으로 그림일기 만들어줘\" + 사진 끌어다 놓기 + 일기 한두 문장"
