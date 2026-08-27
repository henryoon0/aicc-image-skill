# AICC 그림일기 스킬 설치 안내 (왕초보용)

사진 1장과 짧은 일기를 주면 "여행 기록 포스터"(왼쪽 사진 + 오른쪽 도장·일기 페이지)로
만들어주는 도구입니다. ChatGPT 유료 구독만 있으면 되고, 별도 결제는 없습니다.

## 준비물 2가지

1. **ChatGPT 유료 구독** (Plus 이상)
2. **Claude Code** — 터미널 버전 또는 Mac용 Claude 데스크톱 앱
   - ⚠️ claude.ai 웹사이트나 휴대폰 Claude 앱에서는 이 스킬이 돌지 않습니다.
     내 컴퓨터에서 프로그램을 실행해야 해서, 꼭 컴퓨터의 Claude Code 로 해주세요.

## 설치 방법 1 (제일 쉬움: 터미널에 한 줄 복붙)

Mac 에서 **터미널** 앱을 열고(⌘+스페이스 → "터미널" 검색), 아래 한 줄을
통째로 복사해 붙여넣고 엔터를 누르세요. 내려받기부터 설치, ChatGPT 로그인까지
순서대로 안내해 줍니다.

```
curl -fsSL https://raw.githubusercontent.com/henryoon0/aicc-image-skill/main/aicc-image/install.sh | bash
```

끝나면 Claude Code 에서 새 대화를 열고 "그림일기 만들어줘"라고 말하면 됩니다.

## 설치 방법 2 (zip 을 받았다면: Claude 에게 시키기)

1. 받은 `aicc-image.zip` 파일을 컴퓨터에 저장합니다 (압축 풀 필요 없음).
2. Claude Code 를 엽니다.
3. zip 파일을 대화창에 끌어다 놓고, 이렇게 말합니다.

   > 이 zip 을 압축 풀어서 ~/.claude/skills/aicc-image 로 설치해줘.
   > 설치되면 폴더 안에 SKILL.md 가 있는지 확인해줘.

4. **새 대화를 시작**하고 "그림일기 만들어줘"라고 말해보세요.
   나머지(설치 확인, ChatGPT 로그인 안내)는 스킬이 알아서 안내합니다.

## 설치 (직접 하는 방법)

압축을 풀어 나온 `aicc-image` 폴더를 아래 위치로 옮기면 끝입니다.

```
~/.claude/skills/aicc-image
```

터미널로 하려면, zip 이 있는 폴더에서:

```
mkdir -p ~/.claude/skills && unzip -o aicc-image.zip -d ~/.claude/skills
```

## 사용법

Claude Code 새 대화에서:

- "이 사진으로 그림일기 만들어줘" + 사진 파일 끌어다 놓기 + 일기 한두 문장
- "이 그림들이 날짜순으로 쌓이는 일기장 앱 만들어줘"

한 장에 2~5분 걸립니다. 처음 1번은 ChatGPT 로그인(`codex login`)을 안내받게 됩니다.

## 안 될 때

- 뭐라고 뜨든, 그 메시지를 그대로 Claude 에게 보여주고 "고쳐줘"라고 하면 됩니다.
- "로그인돼 있지 않습니다" → 입력창에 `! codex login` 입력 후 브라우저에서 로그인.
- 스킬이 반응 안 함 → 새 대화를 시작해 보세요. 그래도 안 되면
  "~/.claude/skills/aicc-image 폴더에 SKILL.md 가 있는지 확인해줘"라고 물어보세요.
