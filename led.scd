//(1)belaサーバー開始
(
   Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
   s.initTree;
   s.startAliveThread;
)


//sound test
(
SynthDef("sinsource", {
	var sn, amp, out;
	sn = SoundIn.ar(0);
	amp = In.kr(~ctrlBus, 1);
	out = sn * amp;
	//Poll.kr(Impulse.kr(1),amp,\in);
	Out.ar(0, out.dup);
}).add;
)

Synth(\led)
Synth(\sinsource)
s.sendMsg("/n_free", 67109865);

//sound test
(
SynthDef("sinsource", {
	var sn, out;
	var freq, hasFreq, amp;
	sn = SoundIn.ar(0);
	# freq, hasFreq = Pitch.kr(sn);
	freq = Lag.kr(freq, 0.1);
	amp = Amplitude.kr(sn, 0.05, 0.05);
	out = Mix(SinOsc.ar([freq, freq*0.8, freq*1.5],0,amp * hasFreq * 0.7));
	Out.ar(0, out.dup);
}).add;
)

{SinOsc.ar(440,0,0.1)}.play



//new control bus
~ctrlBus = Bus.control(s, 1);
~ctrlBus.free

(
SynthDef(\led,{

	var in, r, g, b;
	in = AnalogIn.kr(7);
    r = in.clip(0.0,0.5)*2;
	g = (0.5 - in).abs*2;
	b = 1 - ((in - 0.5)*2).clip(0,1);

	//out to led
	DigitalOut.ar( 8, LFPulse.ar( freq:(44100/32), width: r));
	DigitalOut.ar( 7, LFPulse.ar( freq:(44100/32), width: b));
	DigitalOut.ar( 9, LFPulse.ar( freq:(44100/32), width: g));

	//out to control bus
	Out.kr( ~ctrlBus, in );

}).add;
)

(
SynthDef(\sound,{
	var in,out;
	in = SoundIn.ar(0);
	out = Clip.ar(in*3,0,0.7);
	out = out * In.kr(~ctrlBus, 1);
	Out.ar(0, out);
}).add;
)




(
SynthDef("led_perc",{
	var in, r, g, b;
	//var sn, freq, hadFreq, amp, out;

	in = AnalogIn.kr(7);
    r = in.clip(0.0,0.5)*2;
	g = (0.5 - in).abs*2;
	b = 1 - ((in - 0.5)*2).clip(0,1);

	DigitalOut.ar( 8, LFPulse.ar( freq:(44100/32), width: r));
	DigitalOut.ar( 7, LFPulse.ar( freq:(44100/32), width: b));
	DigitalOut.ar( 9, LFPulse.ar( freq:(44100/32), width: g));

	//out to control bus
	//Out.kr( ~ctrlBus, in );
	//Poll.kr(Impulse.kr(1), in, \in);

	/*
	//sound
	sn = SoundIn.ar(0);
	# freq, hasFreq = Pitch.kr(sn);
	freq = Lag.kr(freq, 0.1);
	amp = Amplitude.kr(sn, 0.05, 0.05);
	out = LFPulse.ar(freq, 0, 0.5, amp);
	*/


}).add;
)


(
SynthDef(\clap,{ |in=0|
	var source, mod, hi, env, out;
	source = WhiteNoise.ar;
	//in = AnalogIn.kr(7);
	//hi = in*2000 + 500;
	mod = Mix(BBandPass.ar( source, Array.rand( 100, 500, 2000 ), 0.01));
	env = EnvGen.kr( Env.perc(0.01, 0.1), in);
	out = mod * env;
	out = Clip.ar(out,-0.8, 0.8);
	Out.ar(0, out.dup);
}).add;
)

y = Synth(\led_perc);
x = Synth(\clap);
x.set(\in, ~ctrlBus.asMap);

x.free;
y.free;


(
SynthDef(\clap,{ |in=0|
	var source, mod, hi, env, out;
	in = AnalogIn.kr(7);
	source = WhiteNoise.ar;
	mod = Mix(BBandPass.ar( source, Array.rand( 100, 500, 2000 ), 0.01));
	env = EnvGen.kr( Env.perc(0.01, 0.1), in);
	out = mod * env * 0.5;
	Out.ar(0, out.dup);
}).add;
)






(
SynthDef("led_sn",{
	var sn, freq, freq2, hasFreq, amp, out;
	var in, r, g, b;

	//leds
	in = AnalogIn.kr(7);
    r = in.clip(0.0,0.5)*2;
	g = (0.5 - in).abs*2;
	b = 1 - ((in - 0.5)*2).clip(0,1);

	DigitalOut.ar( 8, LFPulse.ar( freq:(44100/32), width: r));
	DigitalOut.ar( 7, LFPulse.ar( freq:(44100/32), width: b));
	DigitalOut.ar( 9, LFPulse.ar( freq:(44100/32), width: g));

	sn = SoundIn.ar(0);
	# freq, hasFreq = Pitch.kr(sn);
	freq = Lag.kr(freq, 0.1);
	freq2 = freq*(in.trunc(0.1)+1);

	Poll.kr(Impulse.kr(1), in, \glo);
	amp = Amplitude.kr(sn, 0.05, 0.05);
	out = Mix(SinOsc.ar([sn, freq2*1.2], 0, amp));
	Out.ar(0, out);

}).add;
)


Synth("pitch")

Synth("led")


s.sendMsg("/n_free", 67109866);



s.boot
s.quit
