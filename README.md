# Scripts útiles de gestión de CMS

Este proyecto contiene scripts bash útiles para administrar usuarios y concursos de una instancia de CMS. Puede ser cómodo que estos scripts sean instalados en un directorio que esté en el PATH (como `/usr/local/bin`).

La mayoría de ellos trabajan con ficheros de entrada en formato JSON que contiene, por ejemplo, la lista de participantes o de regiones. La forma más fácil de conseguir esos JSON es utilizar una hoja de cálculo a modo de base de datos que, utilizando fórmulas, genere el JSON.

Un ejemplo puede verse [aquí](https://docs.google.com/spreadsheets/d/1DNZ4kaNdbEPauDCkgZ28x01FDKPuLsbMpns1tRb0k-o/) aunque las fórmulas que generan el JSON no aguantarían nombres extraños (con comillas, por ejemplo).

Típicamente, con la ayuda de una hoja de cálculo como la anterior, se consigue una "base de datos" en disco para ser utilizada por los distintos scripts. En el directorio podríamos tener:

1. Un fichero `teams.json` con la información de las regiones (o "equipos olímpicos").
1. Un fichero `users.json` con la información de los usuarios. Incluye también los datos de acceso (usuario y contraseña), así como el equipo al que pertenecen.
1. Un directorio `flags` con las banderas de cada región (o los logos de los centros educativos, etc.). Por cada región hay un fichero con el mismo nombre que el campo `id` del JSON.
1. Un directorio `faces` con las fotos de los participantes. Los nombres en este caso deberán coincidir con el campo `user` del JSON. El aspect ratio de esas imágenes debe ser 2:3 (dos de ancho por tres de alto).
1. Un fichero llamado logo (y la extensión apropiada) con el logo del concurso (tamaño recomendado, 200x160).

Las imágenes anteriores serán utilizadas en el momento de configurar el ranking de CMS
(script `addRankingImages.sh`) y se soportan extensiones .png, .jpg, .gif y
.bmp.

## `registerTeams.sh`

Útil para registrar equipos en CMS. La semántica de esos equipos dependerá de la competición concreta. En unos casos representará países (IOI) en otros regionales/comunidades autónomcas (OIE) o incluso centros educativos (para regionales).

**OJO**: el significado de *equipo* aquí es distinto del que se utiliza en competiciones universitarias. Aquí utilizamos el término de equipo en el sentido "equipo olímpico español" pero cada equipo tiene luego asociados los participantes/usuarios individuales que compiten. En el caso de competiciones universitarias en donde la participación suele hacerse en grupo, un equipo equivale a esa agrupación que participa como una unidad indivisible.

El script recibe como parámetro el JSON con la información de los equipos.

```bash
# Ejemplo de uso
$ ls
faces flags logo.png teams.json users.json
$ registerTeams.sh teams.json
```

## `registerUsers.sh`

Equivalente al anterior, útil para registrar participantes en CMS.

El script recibe como parámetro el JSON con la información de cada participante, aunque el equipo al que pertenece *es ignorado* pues la asociación equipo-participante en CMS está vinculada a la existencia de un concurso.

```bash
# Ejemplo de uso
$ ls
faces flags logo.png teams.json users.json
$ registerTeams.sh teams.json
```

## `addContest.sh`

CMS viene con una utilidad para importar concursos como [éste](https://github.com/olimpiada-informatica/cms-ejemplo-concurso) que puede lanzarse con `cmsImportContest`.

El script `addContest.sh` no es más que una pequeña "extensión" de esa herramienta que permite importar concursos en [formato italiano](https://cms.readthedocs.io/en/latest/External%20contest%20formats.html) sobreescribiendo la hora de inicio y duración del concurso que se indica en sus ficheros. Además, antes de importarlo compila las posibles aplicaciones de evaluación (*managers* y *checkers* de las tareas), de forma que los ejecutables pertenezcan a la plataforma donde está CMS.

Los parámetros del script son:

1. Directorio donde está el concurso (y el fichero `contest.yaml`)
1. [Opcional] Timestamp/unix-time (en segundos) con el momento de inicio del concurso. Si no se especifica se utiliz el de `contest.yaml`
1. [Opcional] Duración (en segundos) del concurso. Si se indicó el parámetro anterior pero no la duración, se establecerá en tres horas y media.

```bash
# Ejemplo de uso. Concurso que comienza inmediatamente con una duración de 10 minutos
$ ls
MiConcurso
$ ls MiConcurso/
A-cuadrados_libreta  B-histograma  C-minimo  contest.yaml  D-muelles  E-tablero_hermoso  README.md
$ addContest.sh MiConcurso/ $(date +%s) 600
```

## `registerParticipations.sh`

En CMS el alta de equipos y participantes es independiente de los concursos. Una vez registrados los primeros y dado de alta el último se debe registrar la participación de los usuarios concretos y asociarlos, en ese momento, al equipo/regional/centro educativo al que representan.

El script `registerParticipations.sh` se encarga de hacerlo a partir de la lista de participantes en JSON. El formato del JSON es el mismo que el utilizado por `registerUsers.sh`.

Los parámetros son:

1. Id numérico del concurso (se ve, por ejemplo, en la URL de la página de administración de CMS donde se muestran sus propiedades).
1. [Opcional] Fichero JSON con la información de los participantes. Si no se especifica, se asume `users.json`

## `addSubmissions.sh`

Permite realizar pruebas de funcionamiento en una instalación de CMS simulando los envíos a un concurso. Para eso es necesario tener acceso a los ficheros de código que se quiere enviar, así como a un JSON con la lista de envíos. El JSON debe ser compatible con los participantes dados de alta en el concurso y con sus tareas. También tiene información sobre el momento del concurso en el que se hace cada envío (es decir, el tiempo en el JSON es relativo al momento de inicio del concurso).

El JSON puede crearse previamente en una hoja de cálculo con fórmulas como [se hace aquí](https://docs.google.com/spreadsheets/d/1DNZ4kaNdbEPauDCkgZ28x01FDKPuLsbMpns1tRb0k-o/).

El script hace todos los envíos seguidos de forma que se acumularán en CMS uno detrás de otro y se lanzará la evaluación de todos ellos como si hubieran llegado seguidos. La "hora de concurso" de cada envío, pues, no se utiliza en la ejecución sino que es usada por CMS en las gráficas que se muestran en los rankings.

Los parámetros son:

1. Id numérico del concurso en el que hacer los envíos (se ve, por ejemplo, en la URL de la página de administración de CMS donde se muestran sus propiedades).
1. Directorio raíz con el código fuente de los envíos. Los ficheros de código referenciados en el JSON son relativos a ese directorio
1. Hora de inicio del concurso. El script sumará a esa hora el tiempo de concurso especificado en el JSON.

## `addRankingImages.sh`

Permite añadir cómodamente al directorio de datos del servidor de rankings (RWS)
las imágenes asociadas al concurso, en concreto su logo, banderas de los equipos
y fotos de los participantes.

Recibe como primer parámetro el directorio destino (directorio de datos del RWS)
y como segundo parámetro (opcional) el directorio con las imágenes siguiendo
la estructura explicada más arriba: fichero con el logo y directorios `flags`
y `faces`.

```bash
# Ejemplo de uso
$ ls
faces  flags  logo.png  teams.json  users.json
$ ls flags/
GRI.png  HOG.jpg  SLY.png  VIL.png
$ ls faces/
draco.png  dumbledore.jpg  ginny.png  hagrid.png  harry.jpg  hermione.png  lucius.png  mcgonagall.jpg  ojoloco.png  ron.jpg  snape.png  voldemort.png
$ addRankingImages.sh /var/local/lib/cms/ranking/
```
