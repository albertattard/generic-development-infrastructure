#!/usr/bin/env bash
set -uo pipefail

FAILURES=0
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

log_section() {
    local title="${1}"
    printf '\n== %s ==\n' "${title}"
}

run_check() {
    local description="${1}"
    shift

    printf '[CHECK] %s\n' "${description}"
    if "$@"; then
        printf '[ OK ] %s\n' "${description}"
    else
        printf '[FAIL] %s\n' "${description}" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

run_bash_check() {
    local description="${1}"
    local script="${2}"

    run_check "${description}" bash -lc "${script}"
}

run_alias_check() {
    local description="${1}"
    local alias_name="${2}"
    local command="${3}"

    run_check "${description}" bash -lc "source \"\${HOME}/.bashrc\" && shopt -s expand_aliases && eval '${alias_name}' && ${command}"
}

require_opc_user() {
    if [[ "${USER}" != "opc" ]]; then
        echo "Run this script as the opc user." >&2
        exit 1
    fi
}

write_java_smoke_test() {
    cat <<'EOF' > "${TEMP_DIR}/Hello.java"
public final class Hello {
    public static void main(final String[] args) {
        System.out.println(System.getProperty("java.version"));
    }
}
EOF
}

require_opc_user
write_java_smoke_test

log_section 'Shell'
run_bash_check 'Bash startup loads SDKMAN' 'source "${HOME}/.bashrc" && type sdk >/dev/null'
run_bash_check 'SDKMAN reports a version' 'source "${HOME}/.bashrc" && sdk version'
run_bash_check 'Cargo environment is available' 'source "${HOME}/.bashrc" && test -f "${HOME}/.cargo/env"'

log_section 'Java'
run_bash_check 'Default Java is available' 'source "${HOME}/.bashrc" && java --version'
run_alias_check 'java8 alias works' 'java8' 'java -version'
run_alias_check 'java9 alias works' 'java9' 'java --version'
run_alias_check 'java10 alias works' 'java10' 'java --version'
run_alias_check 'java11 alias works' 'java11' 'java --version'
run_alias_check 'java12 alias works' 'java12' 'java --version'
run_alias_check 'java13 alias works' 'java13' 'java --version'
run_alias_check 'java14 alias works' 'java14' 'java --version'
run_alias_check 'java15 alias works' 'java15' 'java --version'
run_alias_check 'java16 alias works' 'java16' 'java --version'
run_alias_check 'java17 alias works' 'java17' 'java --version'
run_alias_check 'java18 alias works' 'java18' 'java --version'
run_alias_check 'java19 alias works' 'java19' 'java --version'
run_alias_check 'java20 alias works' 'java20' 'java --version'
run_alias_check 'java21 alias works' 'java21' 'java --version'
run_alias_check 'java22 alias works' 'java22' 'java --version'
run_alias_check 'java23 alias works' 'java23' 'java --version'
run_alias_check 'java24 alias works' 'java24' 'java --version'
run_alias_check 'java25 alias works' 'java25' 'java --version'
run_alias_check 'java26 alias works' 'java26' 'java --version'
run_alias_check 'graal25 alias exposes native-image' 'graal25' 'native-image --version'
run_check "Java smoke test compiles and runs" bash -lc "source \"\${HOME}/.bashrc\" && shopt -s expand_aliases && eval 'java25' && javac '${TEMP_DIR}/Hello.java' && java -cp '${TEMP_DIR}' Hello"

log_section 'Languages'
run_bash_check 'kotlin command works' 'source "${HOME}/.bashrc" && kotlin -version'
run_bash_check 'kotlinc command works' 'source "${HOME}/.bashrc" && kotlinc -version'
run_bash_check 'Python is installed' 'source "${HOME}/.bashrc" && python3 --version'
run_bash_check 'pip is installed' 'source "${HOME}/.bashrc" && pip3 --version'
run_bash_check 'Rust compiler is installed' 'source "${HOME}/.bashrc" && source "${HOME}/.cargo/env" && rustc --version'
run_bash_check 'Cargo is installed' 'source "${HOME}/.bashrc" && source "${HOME}/.cargo/env" && cargo --version'
run_bash_check 'rustup is installed' 'source "${HOME}/.bashrc" && source "${HOME}/.cargo/env" && rustup show active-toolchain'

log_section 'Build Tools'
run_bash_check 'GCC is installed' 'source "${HOME}/.bashrc" && gcc --version'
run_bash_check 'make is installed' 'source "${HOME}/.bashrc" && make --version'
run_bash_check 'Git is installed' 'source "${HOME}/.bashrc" && git --version'
run_bash_check 'patch is installed' 'source "${HOME}/.bashrc" && patch --version'

log_section 'Utilities'
run_bash_check 'hey is installed' 'source "${HOME}/.bashrc" && /usr/local/sbin/hey -n 1 -c 1 http://127.0.0.1:9 >/dev/null 2>&1; test -x /usr/local/sbin/hey'
run_bash_check 'JMeter is installed' 'source "${HOME}/.bashrc" && jmeter --version'
run_bash_check 'xq is installed' 'source "${HOME}/.bashrc" && /usr/local/bin/xq --version'
run_bash_check 'ripgrep is installed' 'source "${HOME}/.bashrc" && /usr/local/bin/rg --version'
run_bash_check 'gdb is installed' 'source "${HOME}/.bashrc" && gdb --version'
run_bash_check 'sw is installed' 'source "${HOME}/.bashrc" && test -x "${HOME}/.local/bin/sw"'
run_bash_check 'update_sw is installed' 'source "${HOME}/.bashrc" && test -x "${HOME}/.local/bin/update_sw"'

log_section 'Containers'
run_bash_check 'Podman is installed' 'source "${HOME}/.bashrc" && podman --version'
run_bash_check 'Docker compatibility command is installed' 'source "${HOME}/.bashrc" && docker --version'
run_bash_check 'Buildah is installed' 'source "${HOME}/.bashrc" && buildah --version'
run_bash_check 'Skopeo is installed' 'source "${HOME}/.bashrc" && skopeo --version'
run_bash_check 'podman-compose is installed' 'source "${HOME}/.bashrc" && podman-compose --version'

log_section 'Analysis'
run_bash_check 'dive is installed' 'source "${HOME}/.bashrc" && dive --version'
run_bash_check 'syft is installed' 'source "${HOME}/.bashrc" && syft --version'
run_bash_check 'grype is installed' 'source "${HOME}/.bashrc" && grype version'

log_section 'Services'
run_bash_check 'Ollama CLI is installed' 'source "${HOME}/.bashrc" && ollama --version'
run_bash_check 'Ollama service is active' 'source "${HOME}/.bashrc" && systemctl is-active --quiet ollama'

log_section 'Filesystem'
run_bash_check 'JDK installation directory exists' 'source "${HOME}/.bashrc" && test -d /usr/lib/jvm'
run_bash_check 'SDKMAN java current link exists' 'source "${HOME}/.bashrc" && test -L "${HOME}/.sdkman/candidates/java/current"'
run_bash_check 'SDKMAN kotlin current link exists' 'source "${HOME}/.bashrc" && test -L "${HOME}/.sdkman/candidates/kotlin/current"'

if (( FAILURES > 0 )); then
    printf '\nVerification completed with %d failure(s).\n' "${FAILURES}" >&2
    exit 1
fi

printf '\nVerification completed successfully.\n'
