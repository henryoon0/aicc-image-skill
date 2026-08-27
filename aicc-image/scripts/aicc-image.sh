#!/bin/bash
# aicc-image 러너 — ChatGPT 구독(codex exec 내장 image_gen)으로
# 일상 사진 1장 + 날짜 + 일기를 "러버 스탬프 여행 기록 포스터"로 변환한다.
# API 키 불필요. 인증은 `codex login`(ChatGPT sign-in) 1회로 끝.
#
# usage:
#   aicc-image.sh --photo <사진파일> --out <결과.png> --date "2026년 8월 27일" --diary "일기 본문" [--timeout 600]
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TEMPLATE_FILE="$SCRIPT_DIR/../references/prompt-template.txt"

PHOTO=""
OUT=""
DATE_TEXT=""
DIARY_TEXT=""
TIMEOUT_SEC=600

while [[ $# -gt 0 ]]; do
  case "$1" in
    --photo)   PHOTO="$2"; shift 2 ;;
    --out)     OUT="$2"; shift 2 ;;
    --date)    DATE_TEXT="$2"; shift 2 ;;
    --diary)   DIARY_TEXT="$2"; shift 2 ;;
    --timeout) TIMEOUT_SEC="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

[[ -n "$PHOTO" && -n "$OUT" && -n "$DATE_TEXT" && -n "$DIARY_TEXT" ]] || {
  echo "usage: aicc-image.sh --photo 사진 --out 결과.png --date '날짜' --diary '일기 본문'" >&2; exit 2; }
[[ -f "$PHOTO" ]] || { echo "사진 파일이 없습니다: $PHOTO" >&2; exit 2; }
[[ -f "$TEMPLATE_FILE" ]] || { echo "프롬프트 템플릿이 없습니다: $TEMPLATE_FILE (스킬 폴더가 통째로 복사됐는지 확인)" >&2; exit 2; }

# 1) codex 설치 확인
if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI 가 설치돼 있지 않습니다. 'npm install -g @openai/codex' 로 설치해 주세요." >&2
  exit 5
fi

# 2) 인증: ChatGPT 로그인만 허용 (API 키 과금 경로 차단)
LOGIN=$(codex login status 2>&1 || true)
if [[ "$LOGIN" != *"ChatGPT"* ]]; then
  echo "codex 가 ChatGPT 로 로그인돼 있지 않습니다. 터미널에서 'codex login' 을 실행해 주세요." >&2
  echo "(현재 상태: $LOGIN)" >&2
  exit 3
fi

# 3) 템플릿에 날짜·일기 파싱 (bash 치환은 여러 줄 일기도 안전)
TEMPLATE=$(cat "$TEMPLATE_FILE")
PROMPT=${TEMPLATE//'{{DATE}}'/$DATE_TEXT}
PROMPT=${PROMPT//'{{DIARY}}'/$DIARY_TEXT}

OUT_DIR=$(cd "$(dirname "$OUT")" 2>/dev/null && pwd) || { mkdir -p "$(dirname "$OUT")"; OUT_DIR=$(cd "$(dirname "$OUT")" && pwd); }
OUT_NAME=$(basename "$OUT")

# 4) 생성: 사진을 -i 로 첨부, 프롬프트는 stdin. OPENAI_API_KEY 를 지워 구독 경로만 남긴다.
env -u OPENAI_API_KEY timeout "$TIMEOUT_SEC" codex exec \
  --skip-git-repo-check --ephemeral --ignore-user-config --color never \
  -s workspace-write -c 'approval_policy="never"' -C "$OUT_DIR" \
  -i "$PHOTO" - <<EOF
Use your built-in image_gen tool to produce exactly one image, then save it as a PNG file
named ${OUT_NAME} in the current working directory. Aspect ratio: 4:3 landscape.
Do not call any external API. After saving, print the absolute file path.
BEGIN USER PROMPT
${PROMPT}
END USER PROMPT
EOF

# 5) 검증: 파일이 실제로 생겼는지 (50KB 미만이면 실패로 간주)
FULL="$OUT_DIR/$OUT_NAME"
SIZE=$(stat -f%z "$FULL" 2>/dev/null || stat -c%s "$FULL" 2>/dev/null || echo 0)
if [[ "$SIZE" -lt 51200 ]]; then
  echo "FAILED: $FULL 이 만들어지지 않았거나 비정상적으로 작습니다 (${SIZE} bytes)" >&2
  exit 4
fi
echo "OK $FULL (${SIZE} bytes)"
