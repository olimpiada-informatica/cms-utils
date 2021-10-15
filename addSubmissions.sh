#!/bin/bash

# Uso: addSubmissions <idConcurso> <directorioCodigo> <tsContestStartInSecs>

# Hace envíos a un concurso leídos de un JSON
# En el JSON se incluye el momento (en tiempo de concurso en segundos)
# en el que se hace el envío. CMS no requiere simular el proceso,
# pues permite añadir envíos especificando el timestamp. Eso sí,
# el script necesita el TS de inicio del concurso para sumar el
# tiempo de concurso correspondiente

# Inspiración de uso de jq de
# https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/

die() {
    echo $@ 2>&1
    exit 1
}

addSubmissions () {

    readonly JSON_FILE=envios.json
    readonly contestId="$1"
    readonly contestFolder="$2"
    readonly contestStart="$3"

    for sub in $(cat "$JSON_FILE" | jq -r '.[] | @base64' ); do

        _getField() {
            echo ${sub} | base64 --decode | jq -r .${1}
        }

        local user="$(_getField user)"
        local task="$(_getField task)"
        local ts="$(_getField contesttime)"
        let ts=$contestStart+60*$ts
        local solFile="$contestFolder/$(_getField file)"

        echo $user - $task - $ts - $solFile
        cmsAddSubmission -t $ts -c $contestId -f "$task.%l:$solFile" $user $task
    done
}

[ -z "$1" ] && die "No se indicó ID del concurso"
[ -z "$2" ] && die "No se indicó el directorio raíz del código a enviar"
[ -z "$3" ] && die "No se indicó el timestamp del inicio del concurso (en segundos)"

addSubmissions "$@"
