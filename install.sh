#!/bin/sh
set -e

# バイナリファイルをダウンロードしてインストールする
execute() {
  adjust_bindir
  tmpdir=$(mktemp -d)
  http_download "${tmpdir}/${TARBALL}" "${TARBALL_URL}"
  srcdir="${tmpdir}"
  (cd "${tmpdir}" && untar "${TARBALL}")
  test ! -d "${BINDIR}" && install -d "${BINDIR}"
  install "${srcdir}/${NAME}/${BINNAME}" "${BINDIR}/"
  echo "installed ${BINDIR}/${BINNAME}"
  rm -rf "${tmpdir}"
}

# 実行中のシステムのOS名を取得する
get_os_name() {
  local os_name=$(uname -s)
  if [ "$os_name" = "Darwin" ]; then
    echo "macOS"
  else
    echo "$os_name" | tr '[:upper:]' '[:lower:]'
  fi
}

# GitHub のリリースタグからバージョン情報を取得する
tag_to_version() {
  if [ -z "${TAG}" ]; then
    echo "checking GitHub for latest tag"
  else
    echo "checking GitHub for tag '${TAG}'"
  fi
  REALTAG=$(github_release "$OWNER/$REPO" "${TAG}") && true
  if test -z "$REALTAG"; then
    echo "unable to find '${TAG}' - use 'latest' or see https://github.com/${PREFIX}/releases for details"
    exit 1
  fi

  TAG="$REALTAG"
  VERSION=${TAG#v}
}

# 指定されたコマンドが存在するかどうかを確認する
is_command() {
  command -v "$1" >/dev/null
}

# 実行中のシステムのアーキテクチャを確認する
uname_arch() {
  arch=$(uname -m)
  case $arch in
  x86_64) arch="amd64" ;;
  x86) arch="386" ;;
  i686) arch="386" ;;
  i386) arch="386" ;;
  aarch64) arch="arm64" ;;
  esac
  echo ${arch}
}

# サポートされているアーキテクチャかどうかを確認する
uname_arch_check() {
  arch=$(uname_arch)
  case "$arch" in
  386) return 0 ;;
  amd64) return 0 ;;
  arm64) return 0 ;;
  *)
    echo "$arch architecture is not supported by this script."
    exit 1
    ;;
  esac
}

# アーカイブを解凍する
untar() {
  tarball=$1
  case "${tarball}" in
  *.tar.gz | *.tgz) tar --no-same-owner -xzf "${tarball}" ;;
  *.tar) tar --no-same-owner -xf "${tarball}" ;;
  *)
    echo "untar unknown archive format for ${tarball}"
    return 1
    ;;
  esac
}

# curl でファイルをダウンロードする
http_download_curl() {
  local_file=$1
  source_url=$2
  header=$3
  if [ -z "$header" ]; then
    code=$(curl -w '%{http_code}' -sL -# -o "$local_file" "$source_url")
  else
    code=$(curl -w '%{http_code}' -sL -# -H "$header" -o "$local_file" "$source_url")
  fi
  if [ "$code" != "200" ]; then
    echo "http_download_curl received HTTP status $code"
    return 1
  fi
  return 0
}

# wget でファイルをダウンロードする関数
http_download_wget() {
  local_file=$1
  source_url=$2
  header=$3
  if [ -z "$header" ]; then
    wget -q -O "$local_file" "$source_url"
  else
    wget -q --header "$header" -O "$local_file" "$source_url"
  fi
}

# ファイルをHTTP経由でダウンロードする
http_download() {
  echo "Download $2"
  if is_command curl; then
    http_download_curl "$@"
    return
  elif is_command wget; then
    http_download_wget "$@"
    return
  fi
  echo "unable to find wget or curl"
  return 1
}

# 指定したURLからデータを取得し、その内容を標準出力に表示する
http_copy() {
  tmp=$(mktemp)
  http_download "${tmp}" "$1" "$2" || return 1
  body=$(cat "$tmp")
  rm -f "${tmp}"
  echo "$body"
}

# GitHub の Releases からバージョンを取得する
github_release() {
  owner_repo=$1
  version=$2
  test -z "$version" && version="latest"
  giturl="https://github.com/${owner_repo}/releases/${version}"
  json=$(http_copy "$giturl" "Accept:application/json")
  test -z "$json" && return 1
  version=$(echo "$json" | tr -s '\n' ' ' | sed 's/.*"tag_name":"//' | sed 's/".*//')
  test -z "$version" && return 1
  echo "$version"
}

# インストール先のディレクトリパスを設定する
adjust_bindir() {
  if [ -n "$BINDIR" ]; then
    return
  fi

  if [ -d ~/.local/bin ] && [ -w ~/.local/bin ]; then
    BINDIR=~/.local/bin
  elif [ -d ~/bin ] && [ -w ~/bin ]; then
    BINDIR=~/bin
  elif [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then
    BINDIR=/usr/local/bin
  else
    echo "Error: No writable directory found for installation."
    echo "Please ensure you have write access to one of the following directories: ~/.local/bin, ~/bin, /usr/local/bin, or explicitly set the BINDIR environment variable."
    exit 1
  fi
}

OWNER=CloudAutomator
REPO="cli"

BINNAME="ca"
FORMAT=tar.gz
OS=$(get_os_name)
ARCH=$(uname_arch)
PREFIX="$OWNER/$REPO"
PLATFORM="${OS}/${ARCH}"
GITHUB_DOWNLOAD=https://github.com/${OWNER}/${REPO}/releases/download

uname_arch_check "$ARCH"

tag_to_version

echo "found version: ${VERSION} for ${TAG}/${OS}/${ARCH}"

NAME=${BINNAME}_v${VERSION}_${OS}_${ARCH}
TARBALL=${NAME}.${FORMAT}
TARBALL_URL=${GITHUB_DOWNLOAD}/${TAG}/${TARBALL}

execute
