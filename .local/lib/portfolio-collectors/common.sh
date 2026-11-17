# shellcheck shell=bash  (sourced by the other scripts)
ENV_FILE=${PORTFOLIO_ENV:-$HOME/.config/portfolio-api.env}
[[ -r $ENV_FILE ]] && { set -a; . "$ENV_FILE"; set +a; }
: "${WRITE_TOKEN:?missing WRITE_TOKEN (set it in $ENV_FILE)}"
API_BASE=${API_BASE:-https://api.tommlyjumah.dev/portfolio}; API_BASE=${API_BASE%/}
STATE_DIR=${STATE_DIR:-$HOME/.local/share/portfolio-collectors}
mkdir -p "$STATE_DIR"

post() { # post <path> <json>
  curl -fsS -m 10 -H "Authorization: Bearer $WRITE_TOKEN" \
    -H 'Content-Type: application/json' -d "$2" "$API_BASE$1"
}
today() { TZ=UTC printf -v "$1" '%(%F)T' -1; }   # UTC date, matches API
