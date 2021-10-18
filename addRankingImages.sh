#!/bin/bash
#
# USO: addRankingImages.sh rankingFolder [sourceFolder]

# Añade al directorio con los datos de un ranking las imágenes
# del concurso (logo del concurso, banderas/logos de centros y
# fotos de participantes).
#
# Recibe el directorio de datos del servidor de rankings (RWS)
# y (opcionalmente) el directorio que contiene las imágenes (si
# no se indica se usa el directorio actual).
#
# Se espera que el directorio fuente tenga:
#    - Un fichero logo.{png,jpg} con el logo del concurso
#    - Un directorio flags con las "banderas" de los equipos
#    - Un directorio faces con las fotos de los participantes
# (mejor en aspect ratio 2:3)

die() {
    echo $@ 2>&1
    exit 1
}

addRankingImages () {

    local srcDir=${2-.}

    mkdir -p "$1"
    if compgen -G "$srcDir/logo.*" > /dev/null; then
	    cp "$srcDir"/logo.* "$1"
	else
		echo Logo no encontrado
	fi
    
    mkdir -p "$1/faces"
	if compgen -G "$srcDir/faces/*" > /dev/null; then
		cp "$srcDir/faces"/* "$1/faces"
    else
		echo Fotos de equipos no encontradas
	fi

    mkdir -p "$1/flags"
	if compgen -G "$srcDir/flags/*" > /dev/null; then
		cp "$srcDir/flags"/* "$1/flags"
	else
		echo Banderas no encontradas
	fi
}

[ -z "$1" ] && die "No se indicó la ruta de los datos del RWS"

addRankingImages "$@"
