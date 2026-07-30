# PixelPet

Codex CLI의 활동 상태를 픽셀 아트 캐릭터로 보여주는 macOS 데스크톱
컴패니언입니다.

## 로컬 테스트용 앱 만들기

### 준비 사항

- macOS
- Xcode

프로젝트 루트에서 다음 명령을 실행합니다.

```sh
./scripts/package-local.sh
```

빌드가 완료되면 `dist/`에 아래 파일이 생성됩니다.

- `PixelPet-<version>.zip`
- `PixelPet-<version>.dmg`

DMG를 열고 PixelPet을 Applications 폴더로 드래그하면 됩니다.

이 패키지는 Apple Developer 인증서로 서명하거나 공증하지 않은 로컬 테스트
빌드입니다. macOS에서 실행을 차단하면 Finder에서 앱을 Control-클릭한 뒤
`열기`를 선택하세요.

Xcode가 기본 위치가 아닌 곳에 설치되어 있다면 다음처럼 실행할 수 있습니다.

```sh
DEVELOPER_DIR="/Xcode가/설치된/경로/Xcode.app/Contents/Developer" \
  ./scripts/package-local.sh
```
