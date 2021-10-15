#!/bin/bash
#
# USO: registerParticipations.sh <id concurso> [<users.json>]

# Registra la participación en el concurso cuyo id se pasa en $1
# de todos los usuarios del fichero $2. Si no se indica fichero
# de usuarios, se utiliza users.json

# Inspiración de uso de jq de
# https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/

die() {
    echo $@ 2>&1
    exit 1
}

registerParticipation () {
    
    readonly JSON_FILE=${2-users.json}

    for user in $(cat "$JSON_FILE" | jq -r '.[] | @base64' ); do

        _getField() {
            echo ${user} | base64 --decode | jq -r .${1}
        }

        local hidden=""
        if [ $(_getField hidden) == "true" ]; then
           hidden="--hidden"
        fi

        echo $(_getField nombre) - $(_getField apellidos) - $hidden
        cmsAddParticipation -c $1 -t "$(_getField team)" $hidden "$(_getField user)"
    done
}

[ -z "$1" ] && die "No se indicó ID del concurso"


registerParticipation "$@"