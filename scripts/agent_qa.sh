#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${AGENT_QA_OUTPUT_DIR:-$ROOT/artifacts/agent-qa}"
TIMEOUT_SECONDS="${AGENT_QA_TIMEOUT_SECONDS:-900}"
GAME="${AGENT_QA_GAME:-$(basename "$ROOT")}"
SCENARIO="${AGENT_QA_SCENARIO:-}"
GODOT_BIN="${GODOT_BIN:-godot}"

if [[ -z "$SCENARIO" ]]; then
	case "$GAME" in
		market|market-of-ash) SCENARIO="qa/scenarios/market_ordinary_trade_round_trip.json" ;;
		pack|pack-the-keep) SCENARIO="qa/scenarios/pack_greywatch_three_wave.json" ;;
		long|the-long-march) SCENARIO="qa/scenarios/long_march_complete_journey.json" ;;
		*)
			echo "AGENT_QA_CONFIG_ERROR: no default scenario for $GAME" >&2
			exit 2
			;;
	esac
fi

cd "$ROOT"
exec python3 tools/agent_qa_runner.py \
	--game "$GAME" \
	--scenario "$SCENARIO" \
	--output "$OUTPUT_DIR" \
	--timeout "$TIMEOUT_SECONDS" \
	--godot "$GODOT_BIN"
