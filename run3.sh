set -euo pipefail

MODEL="Qwen/Qwen2.5-Coder-1.5B-Instruct"
HOST="127.0.0.1"
PORT="8000"
READY_TIMEOUT_SECONDS="${READY_TIMEOUT_SECONDS:-600}"

uv venv
source .venv/bin/activate
uv pip install vllm --torch-backend auto

cleanup() {
    if [[ -n "${VLLM_PID:-}" ]] && kill -0 "${VLLM_PID}" 2>/dev/null; then
        kill "${VLLM_PID}" 2>/dev/null || true
        wait "${VLLM_PID}" 2>/dev/null || true
    fi
    if [[ -n "${RESPONSE_FILE:-}" && -f "${RESPONSE_FILE}" ]]; then
        rm -f "${RESPONSE_FILE}"
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

vllm serve "${MODEL}" --host "${HOST}" --port "${PORT}" &
VLLM_PID="$!"

deadline=$((SECONDS + READY_TIMEOUT_SECONDS))
until curl -fsS "http://${HOST}:${PORT}/v1/models" >/dev/null 2>&1; do
    if ! kill -0 "${VLLM_PID}" 2>/dev/null; then
        echo "vLLM server exited before becoming ready" >&2
        exit 1
    fi

    if (( SECONDS >= deadline )); then
        echo "Timed out waiting for vLLM server to become ready" >&2
        exit 1
    fi

    sleep 5
done

RESPONSE_FILE="$(mktemp)"
curl -fsS "http://${HOST}:${PORT}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-Coder-1.5B-Instruct",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Which is the largest planet in the solar system?"}
        ]
    }' \
    -o "${RESPONSE_FILE}"

cat "${RESPONSE_FILE}"
