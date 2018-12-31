CageyNums {
	var <> activeSynths;
	var <> synths;
	var <> scaleNotes;
	var <> continue = true;

	*new {|scale, root, octaves|
		 ^super.new.init(scale, root, octaves)
	}

	init {|scale, root, octaves|
		var synths = CageyNums.makeSynths(CageyNums.buildFreqs(scale, root, octaves));
		this.synths = synths;
		this.scaleNotes = scale
		.degrees
		.collect(scale.degreeToFreq(_, root, 1))
		.cpsname
		.collect({|note| note.findRegexp("[A-Z|b|#]*")[0][1]});
		this.activeSynths = List [];
	}

	*buildFreqs {|scale, root, octaves|
		var degrees = (0..scale.degrees.size -1);
		^octaves.collect({|octave|
			degrees.collect({|degree|
				scale.degreeToFreq(degrees, root.midicps, octave)
			})
		}).flatten.flatten
	}

	*makeSynths {|freqs|
		^freqs.collect({|freq|
			{
				("Playing: "+freq.cpsname).postln;
				SinOsc.ar([freq, freq*2], 0, [0.25, 0.18])
			}
		})
	}

	playSynth {
		|synths|
		var len, selected, playing;
		len = synths.size;
		selected = synths[len.rand];
		playing = selected.play(fadeTime:2);
		this.activeSynths;
		^playing;
	}

	stopSynth {
		|active_synths|
		var len, stopped;
		len = active_synths.size;
		if(len > 0, {
			stopped = active_synths.removeAt(len.rand);
			stopped.release;
		}, {});
		^"active synths"+active_synths.size
	}

	doContinue {
		this.continue = true
	}

	dontContinue {
		this.continue = false
	}

	automaticPlaying
	{
		|time = 1|
		var playing;
		if(this.continue == true,
			{
				SystemClock.sched(rrand(4,10), {
					if(this.activeSynths.size > 1, {
						this.stopSynth(this.activeSynths);
					}, {})

				});
				SystemClock.sched(time, {
					playing = this.playSynth(this.synths);
					this.automaticPlaying(rrand(4,10));
					SystemClock.sched(1, {this.activeSynths.add(playing)});//evita que el nodo se agregue a la list antes de que se active en el servidor, y previene un bug donde la función de stop_synth podía intentar apagar un sinte que todavía no existe como nodo.
				});
			},
			{
				"autoplaying is disabled".postln

			}
		)
	}
}