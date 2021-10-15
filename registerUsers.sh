#!/bin/bash

# Registra los usuarios en el sistema a partir de
# un fichero de JSON con el array de usuarios.

# Inspiración de uso de jq de
# https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/


registerUsers () {

    readonly JSON_FILE=${1-users.json}

    for user in $(cat "$JSON_FILE" | jq -r '.[] | @base64' ); do

        _getField() {
            echo ${user} | base64 --decode | jq -r .${1}
        }

        echo $(_getField nombre) - $(_getField apellidos)
        cmsAddUser -t Europe/Madrid -p "$(_getField pass)" "$(_getField nombre)" "$(_getField apellidos)" "$(_getField user)"
    done
}


registerUsers "$@"