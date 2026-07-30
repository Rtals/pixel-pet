#!/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROJECT_PATH="${PROJECT_DIR}/PixelPet.xcodeproj"
readonly SCHEME="PixelPet"
readonly APP_NAME="PixelPet"
readonly DIST_DIR="${PROJECT_DIR}/dist"

developer_dir="${DEVELOPER_DIR:-}"
if [[ -z "${developer_dir}" ]]; then
    active_developer_dir="$(xcode-select -p 2>/dev/null || true)"
    if [[ "${active_developer_dir}" == *".app/Contents/Developer" ]]; then
        developer_dir="${active_developer_dir}"
    elif [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
        developer_dir="/Applications/Xcode.app/Contents/Developer"
    else
        echo "오류: Xcode를 찾을 수 없습니다." >&2
        echo "App Store에서 Xcode를 설치한 뒤 다시 실행하세요." >&2
        exit 1
    fi
fi

if [[ ! -x "${developer_dir}/usr/bin/xcodebuild" ]]; then
    echo "오류: 유효하지 않은 DEVELOPER_DIR입니다: ${developer_dir}" >&2
    exit 1
fi

readonly WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pixelpet-package.XXXXXX")"
readonly DERIVED_DATA_DIR="${WORK_DIR}/DerivedData"
readonly STAGING_DIR="${WORK_DIR}/dmg"
readonly APP_PATH="${DERIVED_DATA_DIR}/Build/Products/Release/${APP_NAME}.app"
readonly LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

cleanup() {
    if [[ -d "${APP_PATH}" ]]; then
        "${LSREGISTER}" -u "${APP_PATH}" >/dev/null 2>&1 || true
    fi
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

echo "PixelPet Release 빌드를 생성합니다..."
DEVELOPER_DIR="${developer_dir}" "${developer_dir}/usr/bin/xcodebuild" \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -derivedDataPath "${DERIVED_DATA_DIR}" \
    CODE_SIGNING_ALLOWED=NO \
    build

if [[ ! -d "${APP_PATH}" ]]; then
    echo "오류: 빌드된 앱을 찾을 수 없습니다: ${APP_PATH}" >&2
    exit 1
fi

echo "로컬 실행용 임시 서명을 적용합니다..."
/usr/bin/codesign --force --sign - "${APP_PATH}"
/usr/bin/codesign --verify --strict "${APP_PATH}"

readonly INFO_PLIST="${APP_PATH}/Contents/Info.plist"
version="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFO_PLIST}")"
readonly ARCHIVE_NAME="${APP_NAME}-${version}"
readonly ZIP_PATH="${DIST_DIR}/${ARCHIVE_NAME}.zip"
readonly DMG_PATH="${DIST_DIR}/${ARCHIVE_NAME}.dmg"

/bin/mkdir -p "${DIST_DIR}" "${STAGING_DIR}"
/bin/rm -f "${ZIP_PATH}" "${DMG_PATH}"

echo "ZIP 파일을 생성합니다..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

echo "DMG 파일을 생성합니다..."
/bin/cp -R "${APP_PATH}" "${STAGING_DIR}/"
/bin/ln -s /Applications "${STAGING_DIR}/Applications"
/usr/bin/hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -format UDZO \
    -ov \
    "${DMG_PATH}"

echo
echo "완료:"
echo "  ${ZIP_PATH}"
echo "  ${DMG_PATH}"
echo
echo "이 빌드는 Apple 공증을 받지 않은 로컬 테스트용입니다."
