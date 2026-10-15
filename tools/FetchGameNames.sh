#!/bin/sh
# =========================================================================
# ForeverCCG - fetch translated creature, spell and zone names (run outside the game, e.g. Git Bash)
#   sh tools/FetchGameNames.sh <cacheDir> [lua5.1 executable]
# Downloads Wowhead's tooltip (it carries the name) for every creature card's
# creature, every class spell card's spell and every zone, in English, German,
# French, Spanish, Chinese and Italian, then writes ../ForeverCCG_Languages/<code>_GameNames.lua (the language pack addon).
# Responses are kept in <cacheDir>, so a re-run only fetches what is new
# (e.g. after adding cards). One request per second, to go easy on Wowhead.
# =========================================================================
ADDON="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="${1:?usage: FetchGameNames.sh <cacheDir> [lua5.1]}"
LUA="${2:-lua5.1}"
SITES="en de fr es cn it"

# (Windows Lua ends lines with \r\n: drop the \r, or it ends up in paths and URLs)
list=$("$LUA" "$ADDON/tools/GameNames.lua" "$ADDON" ids | tr -d '\r') || exit 1
total=$(echo "$list" | wc -l)
n=0
echo "$list" | while read -r kind id; do
  n=$((n + 1))
  for site in $SITES; do
    # fvnpc / fvzone: WoW Forever's own creatures and dungeons, only on Wowhead's Forever pages
    case "$kind" in
      zone)   f="$CACHE/$site/zone-$id.json";   type=zone;  game=classic ;;
      spell)  f="$CACHE/$site/spell-$id.json";  type=spell; game=classic ;;
      fvnpc)  f="$CACHE/$site/fv-$id.json";     type=npc;   game=forever ;;
      fvzone) f="$CACHE/$site/fvzone-$id.json"; type=zone;  game=forever ;;
      # rtspell: a Classic spell rank retail lost, by its retail id (Italian only, see SpellIds.lua)
      rtspell) [ "$site" = it ] || continue
              f="$CACHE/$site/rtspell-$id.json"; type=spell; game=classic ;;
      *)      f="$CACHE/$site/$id.json";        type=npc;   game=classic ;;
    esac
    [ -s "$f" ] && continue
    mkdir -p "$CACHE/$site"
    # Classic has no Italian client: Italian Classic names come from the retail site
    case "$game/$site" in
      */en)       url="https://nether.wowhead.com/$game/tooltip/$type/$id" ;;
      classic/it) url="https://nether.wowhead.com/it/tooltip/$type/$id" ;;
      *)          url="https://nether.wowhead.com/$game/$site/tooltip/$type/$id" ;;
    esac
    code=$(curl -s -m 20 -o "$f.tmp" -w "%{http_code}" "$url")
    if [ "$code" = "200" ]; then mv "$f.tmp" "$f"; else echo "failed: $site $kind $id (HTTP $code)"; rm -f "$f.tmp"; fi
    sleep 1
  done
  [ $((n % 50)) -eq 0 ] && echo "fetched $n/$total"
done

"$LUA" "$ADDON/tools/GameNames.lua" "$ADDON" build "$CACHE"
