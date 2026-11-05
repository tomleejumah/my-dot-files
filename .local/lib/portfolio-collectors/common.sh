# source me
for f in "$HOME/.config/portfolio-api.env"; do [[ -r $f ]] && { set -a; . "$f"; set +a; }; done
: "${WRITE_TOKEN:?missing WRITE_TOKEN}"
API_BASE=${API_BASE:-https://api.tommlyjumah.dev/portfolio}; API_BASE=${API_BASE%/}
STATE_DIR=${STATE_DIR:-$HOME/.local/share/portfolio-collectors}
mkdir -p "$STATE_DIR"
post() { # path json
  curl -fsS -m 10 -H "Authorization: Bearer $WRITE_TOKEN" \
    -H 'Content-Type: application/json' -d "$2" "$API_BASE$1"
}
today() { TZ=UTC printf -v "$1" '%(%F)T' -1; }
