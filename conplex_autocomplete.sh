#!/bin/bash

_conplex_completion() {
    local cur prev prev2 commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    prev2="${COMP_WORDS[COMP_CWORD-2]}"
    commands="list load unload help"

    # Completing the first argument (commands)
    if [[ $COMP_CWORD -eq 1 ]]; then
        mapfile -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
        return 0
    fi

    # Completing the first value after 'load' (environment name)
    if [[ "$prev" == "load" ]]; then
        local tsv_file=$CONPLEX_ENVS_FILE
        if [[ -f "$tsv_file" ]]; then
            local options
            options=$(cut -f1 "$tsv_file" | sort -u)
            mapfile -t COMPREPLY < <(compgen -W "$options" -- "$cur")
        fi
        return 0
    fi

    # Completing the second value after 'load' (version), based on previous environment
    if [[ "$prev2" == "load" ]]; then
        local tsv_file=$CONPLEX_ENVS_FILE
        local env_name="$prev"
        if [[ -f "$tsv_file" ]]; then
            local versions
            versions=$(awk -F'\t' -v env="$env_name" '$1 == env {print $2}' "$tsv_file" | sort -u)
            mapfile -t COMPREPLY < <(compgen -W "$versions" -- "$cur")
        fi
        return 0
    fi

    # Autocomplete for `list <env>`
    if [[ "$prev" == "list" ]]; then
        if [[ -f "$CONPLEX_ENVS_FILE" ]]; then
            local options
            options=$(cut -f1 "$CONPLEX_ENVS_FILE" | sort -u)
            mapfile -t COMPREPLY < <(compgen -W "$options" -- "$cur")
        fi
        return 0
    fi

    return 0
}
complete -F _conplex_completion conplex
