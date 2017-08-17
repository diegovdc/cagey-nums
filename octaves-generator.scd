s.boot;

//objetivo: ayudarme a mejorar la entonación de notas en la flauta. Hará sonar notas al azar dentro de una escala y yo podre tocar esa nota o un intervalo y asegurarme de que esté correctamente afinada

//random sine notes of a scale

//intervals

l = Sambda()


~scale = [2,1,1,1,2,2,2,1];//for 12TET the intervals in this array should add up to 12

~starting_midi_note = 69; //A440
~octaves_up = 1;
~octaves_down = 0;



{SinOsc.ar([60.midicps, 72.midicps])}.play;

l.reduceAccum(l.add(_,_), 69, ~scale);



(
~get_upper_octave_notes = {
	|starting_note, octaves, intervals|
	l.reduceAccum(
		l.add(_,_),
		starting_note,
		l.concat(l.repeat(octaves,intervals))
	)
};
~get_upper_octave_notes.(69, 2, ~scale);
);


(
~get_lower_octave_notes = {
	|starting_note, octaves, intervals|
	~get_upper_octave_notes.(starting_note - (octaves*12), octaves, intervals)
};
~get_lower_octave_notes.(69, 2, ~scale);
);


~midistofreqs = _.collect(_.midicps);

~freq_scale = l.concat([
	~midistofreqs.(~get_lower_octave_notes.(74, 1, ~scale)),
	~midistofreqs.(~get_upper_octave_notes.(74, 1, ~scale))
]);

~make_synth = {
	|freq|
	{SinOsc.ar([freq, freq*2], 0, 0.25)}
};
~synths = ~freq_scale.collect(~make_synth);

//activación y desactivación de los sintes
~active_synths = List[];

~play_synth = {
	|synths|
	var len, selected, playing;
	len = synths.size;
	selected = synths[len.rand];
	selected.postln;
	playing = selected.play(fadeTime:2);
	playing.postln;
	~active_synths.size.postln;
	playing;
};


~stop_synth = {
	|active_ss|
	var len, stopped;

	len = active_ss.size;
	if(len > 0, {
		"borrando".postln;
		stopped = active_ss.removeAt(len.rand);
		stopped.release;
	}, {});
	~active_synths.size.postln;
};


//manejo del tiempo
~continue = true;

//continuar o no la reproducción automática
~do_continue = {~continue = true};
~dont_continue = {~continue = false};

~automatic_playing = {
	|time|
	var playing;
	if(~continue == true,
		{
			SystemClock.sched(rrand(4,10), {
				"algo".postln;
				if(~active_synths.size > 1, {
				~stop_synth.(~active_synths);
					}, {})

			});
			SystemClock.sched(time, {
			playing = 	~play_synth.(~synths);
				~automatic_playing.(rrand(4,10));
				SystemClock.sched(1, {~active_synths.add(playing)});//evita que el nodo se agregue a la list antes de que se active en el servidor, y previene un bug donde la función de stop_synth podía intentar apagar un sinte que todavía no existe como nodo.
			});
		},
		{
			"recursive calls are disabled".postln

		}
	)
};
s.free(1018)
~active_synths = List[];
~automatic_playing.(4);
~play_synth.(~synths);
~stop_synth.(~active_synths)
~dont_continue.()
~active_synths;
{SinOsc.ar([69.midicps, 0])}.play;

a = Scale.phrygian.degreeToFreq(2, 60.midicps, 1);
b = Scale.phrygian.tuning_(\just).degreeToFreq(2, 60.midicps, 1);
s.sendMsg(\n_free, 1118)
n = s.nextNodeID;
