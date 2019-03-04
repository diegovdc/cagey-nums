//objetivo: ayudarme a mejorar la entonación de notas en la flauta. Hará sonar notas al azar dentro de una escala y yo podre tocar esa nota o un intervalo y asegurarme de que esté correctamente afinada

s.boot // inicia el servidor
Scale.directory //muestra opciones de escala i.e. major, minor, pelog, etc
Tuning.directory // muestra opciones de afinación

(// crea un reproductor
a = CageyNums(
	scale: Scale.major, // la afinación \just es opcional, si la quitas te da ET12
	// ET12 = temperamento igual :D
	root: 60, // nota midi, puedes usar "C4".namemidi en lugar de 60
	octaves: (-1..2) // generar octavas arriba y abajo de root i.e de C3 - B5
);
)

a.scaleNotes // te de los nombres de las notas que va a tocar
a.automaticPlaying // reproduce

//tocando pelog y mayor :p



a.dontContinue // detiene la reproducción

a.stopSynth(a.activeSynths)

a.activeSynths
