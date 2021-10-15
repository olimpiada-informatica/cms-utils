#!/bin/bash

# Registra equipos / regiones / instituciones en el sistema
# a partir de un fichero de JSON con el array de equipos.
# Por cada uno, el ID y el nombre.

# Inspiración de uso de jq de
# https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/

registerTeams () {

    readonly JSON_FILE=${1-teams.json}

    for team in $(cat "$JSON_FILE" | jq -r '.[] | @base64' ); do

        _getField() {
            echo ${team} | base64 --decode | jq -r .${1}
        }

        echo $(_getField id) - $(_getField name)
        cmsAddTeam  "$(_getField id)" "$(_getField name)"
    done
}


registerTeams "$@"