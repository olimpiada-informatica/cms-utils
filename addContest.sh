#!/bin/bash
#
# USO: addContest <folder> [initTimeStamp] [durationInSecs]

# Añade un concurso al sistema. Se le debe pasar el directorio donde
# está la información (en formato italy_yaml). También admite
# la hora de inicio (en unix-time en segundos) y duración (en
# segundos) del concurso. En caso de no indicarse estas últimas,
# se cogerán del fichero del concurso. Si sólo se indica inicio,
# se creará un concurso de tres horas y media.

die() {
    echo $@ 2>&1
    exit 1
}

addContest () {

    pushd . > /dev/null
    cd "$1"
    # Parcheamos la hora de inicio y duración del concurso (if any)
    cp contest.yaml contest.yaml.orig
    if [ ! -z $2 ]; then
        local start=$2
        local end
        let end=$2+${3-12600}
        sed -i 's/start: [0-9]*/start: '$start'/' contest.yaml
        sed -i 's/stop: [0-9]*/stop: '$end'/' contest.yaml
    fi

    # En CMS 1.4 cmsImportContest requiere "users:" en el yaml
    grep -qe '^users:' contest.yaml || echo -e '\nusers: []' >> contest.yaml

    # Compilamos los posibles manager's/checker's que pueda haber en los
    # problemas interactivos
    for m in $(find \( -name manager.cpp -o -name checker.cpp \)); do
        echo "Compilando $m"
        pushd . > /dev/null
        cd $(dirname $m)
        g++ -o $(basename ${m%.cpp} ) $(basename $m)
        popd > /dev/null
    done

    # Importamos
    cmsImportContest -L italy_yaml -i .

    # Restauramos fichero de concurso
    mv contest.yaml.orig contest.yaml

    popd > /dev/null
}

[ -z "$1" ] && die "No se indicó ruta del concurso"

addContest "$@"
