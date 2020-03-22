/*
PQ Quartet No.2
by Joo Won Park
Ver 0.5 (7/3/2019)
----
joyosc hack by fdch to work in any architecture with 'joyosc'
fdch.github.io  - 2/29/2020
----
joyosc by danomatika: https://github.com/danomatika/joyosc
----
joystick & game controller hid device event to Open Sound Control daemon and associated tools
Copyright (c) Dan Wilcox 2007 - 2020
----

How to Run PSQ2
1. Connect Controller via USB
2. Open cmd or terminal and run 'joyosc' with default port (i.e. 8880)
3. Open this file in SuperCollider
4. Select Language->Evaluate File. Start the piece 2-3 after the screen goes black
5. To stop, press command+period and close the GUI window

NOTE: replaced R2 with R3 x-axis

*/

~defport=8880; // change joyosc port if necessary

// change joyosc path messages if necessary (but I doubt it will be)
~jbutton="/joyosc/devices/gc0/button";
~jaxis="/joyosc/devices/gc0/axis";


~key=57;
~beat=0.45;
~quarter=~beat;
~whole=~beat*4;
~sixple=~beat/6;
~triple=~beat/3;
~sixteen=~beat/4;
~eight=~beat/2;
~hhdur=~beat*0.5;

//joystic scale
~duratio=1;
~transpose=1;
~nimx=1;
~nimy=0;
~tscale=1;

//GUI
~dancetime=~sixteen;
~arcw=0.98;
~thickness=20;
~pcolor=1;
~pshape=1;
~pcircle=1;
~bcolor=1;
~wscale=1;//set to 1
~width=Window.screenBounds.width*~wscale;
~height=Window.screenBounds.height*~wscale;
~ps2window = Window("PS Quartet No.2", Rect(0,0,~width,~height),border:false).front;
~ps2window.background = Color(0,0,0);
//~ps2window.onClose_({s.quit});
//~ps2window.fullScreen;
~dance=Routine({
	var counter,thin;
	counter=0;
	loop{
		if (~pcircle==1,
			{thin=~arcw.rand},
			{thin=1.0});

		{~ps2window.drawFunc ={
			Pen.translate(~width*0.5+(20.rand2), ~height*0.5+(20.rand2));
			Pen.color = Color.gray(1,1);
			if (~pcolor==1,
				{Pen.fillColor = Color.gray(0.9,1)},
				{Pen.fillColor = Color(0.5.rand+0.5,0,0.7+0.3.rand)});


			Pen.addAnnularWedge(
				-100@0,
				rrand(10, ~thickness),
				rrand(10,~width*0.5),

				2pi.rand,
				2pi*thin
			);
			Pen.addAnnularWedge(
				0@0,
				rrand(10,~width*0.5),
				rrand(1, ~thickness),
				2pi*sin(counter),
				2pi*(1-thin)
			);
			if(~pshape==1,
				{Pen.perform([\fill, \fill].choose)},
				{Pen.perform([\stroke, \stroke].choose)},
			);
		}}.defer;
		{~ps2window.refresh}.defer;

		//waittime
		~dancetime.wait;
		counter=counter+0.3;
		//counter.postln;
	};

});


s.waitForBoot{
	//bass drum
	SynthDef("Boom",{
		arg amp,freq,dur,modfreq;
		var sound, decay, ampmod,mix;
		decay=XLine.kr(amp,0.00001,dur,doneAction:2);
		sound = LFTri.ar(freq*decay);
		ampmod=LFTri.ar(modfreq*decay);
		mix = decay*sound*ampmod;
		Out.ar(0,mix.dup*amp*1.3);
	}).add;
	SynthDef("Boom2",{
		arg amp,freq,dur,filtfreq;
		var sound,sound2, decay, ampmod,mix;
		decay=XLine.kr(amp,0.00001,dur,doneAction:2);
		sound = LFTri.ar(freq*decay);
		sound2 = SinOscFB.ar(freq*2*decay);
		ampmod=LPF.ar(BrownNoise.ar,filtfreq);
		mix = decay*sound*ampmod+(sound2*decay);
		Out.ar(0,mix.dup*amp*1.3);
	}).add;

	//
	SynthDef("Basso",{
		arg vol,freq,dur,curve,pulse,gate=1;
		var sound,trig,ampenv,lfo,lfoenv,mix;
		sound = SinOsc.ar(freq);

		ampenv=Env.adsr(0.04,dur,Rand(0.05,0.15),dur*0.25,1,curve:curve);
		ampenv=EnvGen.kr(ampenv,gate,doneAction:2);

		lfoenv=Env.new([0.4,0.001,4],[~beat*3,~beat*16],'exponential');
		lfoenv=EnvGen.kr(lfoenv);

		lfo=SinOsc.ar(1/~beat*pulse,0.5pi,vol,vol)*lfoenv;
		mix = (sound*ampenv*(vol+lfo)).dup;
		Out.ar(0,mix);
	}).add;

	SynthDef("Basso2",{
		arg vol,freq,dur,curve,pulse,gate=1;
		var sound,trig,ampenv,lfo,lfoenv,mix;
		sound = SinOsc.ar(freq);

		//ampenv=Env.adsr(0.04,dur,Rand(0.05,0.15),dur*0.25,1,curve:curve);
		ampenv=Env.perc(0.001,~beat*dur);
		ampenv=EnvGen.kr(ampenv,doneAction:2);
		ampenv=Lag.kr(ampenv,0.01);

		mix = (sound*ampenv*(vol)).dup;
		Out.ar(0,mix);
	}).add;

	//hi hat
	SynthDef("Cheep",{
		arg amp,dur,filtfreq,panner;
		var sound,decay,position,mix;
		decay=XLine.kr(amp,0.00001,dur,doneAction:2);
		sound = WhiteNoise.ar(decay);
		sound = HPF.ar(sound,filtfreq+10);
		sound = HPF.ar(sound,filtfreq+10);
		position = Pan2.ar(sound,panner);
		//mix = position;
		mix=position.sum.dup;
		Out.ar(0,mix*amp);
	}).add;

	//snare
	SynthDef("DirtyHit",{
		arg vol,freq,dur;
		var sound,env,env2,dirt;
		env=XLine.kr(1,0.0001,dur,doneAction:2);
		env2=XLine.kr(1,0.0001,dur*0.3333);
		dirt = LFNoise0.ar(freq*Rand(5,9),env2);

		sound = LFTri.ar(freq*env+10);
		Out.ar(0,dirt.dup*sound*env*vol);
	}).add;

	//bell
	SynthDef("Click",{
		arg freq =60, amp=0.5,dur=0.5,pan=0,cut=200;
		var sound, sound2, lfo,mix,duration;
		sound = LFTri.ar(freq.midicps*2);
		sound = sound*(XLine.ar(1,0.00001,dur,doneAction:2));
		mix =Pan2.ar(sound,pan);

		Out.ar (0,mix*amp);
	}).add;

	//chord
	SynthDef("Chord",{
		arg freq,vol,dur,curve,gate=1;
		var sound,env,filter;
		sound = Saw.ar(freq)+(LFTri.ar(freq*0.5)*0.5);


		env = Env.adsr(dur,0,1,1,curve:curve);
		env = EnvGen.kr(env,gate,s.sampleRate*0.25,doneAction:2);

		filter = LPF.ar(sound,env);

		Out.ar(0,filter.dup*vol*3);
	}).load(s);


	//nim
	SynthDef("Nimo",{
		arg
		vol,origvol,lowvol,midvol,highvol,centerfreq,resonance,sourcevol,sourcevol2,sourcevol3,
		pulsefreq,delayt,decayt,delayvol,inputfilt,panner,control,lagger,schoose,dusty;

		var source,source2,source3,cf,reso,sound2,sound3,mix,delaytlag,delayvx;

		//source = PinkNoise.ar(sourcevol*0.3);
		source = Dust.ar(30+dusty);

		source2 = Impulse.ar(pulsefreq)*sourcevol2;

		source3 = SoundIn.ar(0,sourcevol3*2);
		source3 = source3*(SinOsc.ar((~key-12).midicps));
		source3 = LPF.ar(source3,30+(3000*inputfilt));
		source3=HPF.ar(source3,50);

		sound2 =source+source2+source3;

		cf = Lag.kr(centerfreq*100+20,lagger);
		reso = Lag.kr(resonance+0.02,lagger);
		delaytlag=Lag.kr(delayt,lagger);
		delayvx=Lag.kr(delayvol,lagger);
		sound3 = 0;

		13.do({
			sound2 =(sound2*origvol*1.5)+(sound3*delayvx);
			sound2 = sound2+(RLPF.ar(sound2,cf,reso*0.88)*lowvol);
			sound2 = MidEQ.ar(sound2,cf*10,reso,midvol*30-15);
			sound2 = sound2+(RHPF.ar(sound2,cf*100,reso*0.3)*highvol);
			sound2 = Clip.ar(sound2,-0.9,0.9);

			sound3 = sound2;
			sound3 = CombL.ar(sound3,0.2,0.0001+(delaytlag*0.1),decayt*0.5);
			sound3 = Fold.ar(sound3,-0.9,0.9);

		});

		mix = Pan2.ar(HPF.ar(sound2,100),panner);
		Out.ar(0,mix*vol*0.8);

	}).load(s);


	//Synth("DirtyHit",[\vol,0.8,\freq,1000+1000.rand,\dur,1.4])

	// ~beat=0.4;
	// ~sixple=~beat/6;
	// ~triple=~beat/3;
	// ~sixteen=~beat/4;
	// ~eight=~beat/2;
	// ~hhdur=~beat*0.5;


	//Tom functions
	~tomon={
		//~sust2=Synth("Basso",[\vol,0.15+0.3.rand,\freq,(~key-24+7).midicps,\dur,~beat*[3,4].choose,
		//	\curve,[-15,-10].choose,\pulse,[2,3,4].choose]);
		Synth("Boom",[\amp,0.4+0.5.rand,\freq,~key.midicps*2,\dur,~beat,\modfreq,50+20.rand2]);
		Synth("Boom2",[\amp,0.6+0.2.rand,\freq,(~key).midicps,\dur,~beat*[0.5,0.2].choose,\filtfreq,4000+4000.rand]);
	};
	~tomoff={
		//~sust2.release(~beat*0.125);
	};

	//BassDrum functions
	~bdshort={
		Synth("Basso2",[\vol,0.5+0.3.rand,\freq,(~key-12-5).midicps,\dur,[0.5,1,0.25].choose]);
		Synth("Boom",[\amp,0.2+0.5.rand,\freq,~key.midicps,\dur,~beat,\modfreq,50+20.rand2]);
		Synth("Boom2",[\amp,0.2+0.2.rand,\freq,~key.midicps,\dur,~beat*[0.125,0.125/2].choose,\filtfreq,4000+4000.rand]);
	};


	~bdon={
		~sust.release(0); //this posts error, but no worries
		~sust=Synth("Basso",[\vol,0.5+0.3.rand,\freq,(~key-24).midicps,\dur,~beat*[3,4].choose,
			\curve,[-16,-10].choose,\pulse,[2,3,4].choose]);
		Synth("Boom",[\amp,0.4+0.5.rand,\freq,~key.midicps,\dur,~beat,\modfreq,50+20.rand2]);
		Synth("Boom2",[\amp,0.6+0.2.rand,\freq,~key.midicps,\dur,~beat*[1,0.5].choose,\filtfreq,4000+4000.rand]);
	};
	~bdoff={
		~sust.release(~beat*0.125*0.5);
	};

	~bdrout6ple=Routine({
		loop{
			~bdshort.value;
			(~sixple*~tscale).wait;}
	});
	~bdrout3ple=Routine({
		loop{
			~bdshort.value;
			(~triple*~tscale).wait;}
	});
	~bdrout16=Routine({
		loop{
			~bdshort.value;
			(~sixteen*~tscale).wait;}
	});
	~bdrout8=Routine({
		loop{
			~bdshort.value;
			(~eight*~tscale).wait;}
	});

	~subdivl1=[~bdrout8,~bdrout16,~bdrout6ple,~bdrout3ple];
	~l1={
		arg onoff,which;
		if (onoff==0,{
			//"zero".postln;
			Synth("DirtyHit",[\vol,0.65+0.15.rand,\freq,800+2500.rand,\dur,1.0+1.5.rand]);
			~subdivl1[0].stop;
			~subdivl1[1].stop;
			~subdivl1[2].stop;
			~subdivl1[3].stop;
		});
		if (onoff==1,{
			~subdivl1[which].reset;~subdivl1[which].play
		});

	};

	//hihat
	~hhrout6ple=Routine({
		loop{
			~hh=Synth("Cheep",[\amp,0.3+0.4.rand,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~sixple*~tscale).wait;}
	});
	~hhrout3ple=Routine({
		loop{
			~hh=Synth("Cheep",[\amp,0.3+0.4.rand,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~triple*~tscale).wait;}
	});
	~hhrout16=Routine({
		loop{
			~hh=Synth("Cheep",[\amp,0.3+0.4.rand,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~sixteen*~tscale).wait;}
	});
	~hhrout8=Routine({
		loop{
			~hh=Synth("Cheep",[\amp,0.3+0.4.rand,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~eight*~tscale).wait;}
	});

	//
	~hhrout6plei=Routine({
		loop{
			~hh2=Synth("Cheep",[\amp,[0.5,0,0.6.rand,0.2+0.6.rand].choose,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~sixple*~tscale).wait;}
	});
	~hhrout3plei=Routine({
		loop{
			~hh2=Synth("Cheep",[\amp,[0.2,0.2,0.3,0,0.2+0.6.rand].choose,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~triple*~tscale).wait;}
	});
	~hhrout16i=Routine({
		loop{
			~hh2=Synth("Cheep",[\amp,[0.4,0,0.2+0.6.rand].choose,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~sixteen*~tscale).wait;}
	});
	~hhrout8i=Routine({
		loop{
			~hh2=Synth("Cheep",[\amp,[0.5,0,0.2+0.6.rand].choose,\dur,~hhdur*~duratio*~tscale,\filtfreq,(2000+1000.rand)*~transpose+100,\panner,1.0.rand2]);
			(~eight*~tscale).wait;}
	});

	//

	~pad={
		var scale;
		scale=[0,2,4,5,7,9,10].choose;
		~nim.set(\vol,0.1+0.3.rand,\lowvol,0.02+0.4.rand,\origvol,[0.7,0.5,0.8].choose,\midvol,0.2+0.6.rand,\highvol,0.2+0.3.rand,
			\pulsefreq,[1,2,4,20].choose/~beat,\lagger,~beat/2.0.rand,\dusty,30.rand,
			\delayt,1/((~key-24+scale).midicps),\centerfreq,10+(5.rand2),\decayt,2.0.rand*~nimy,\resonance,(0.1+0.7.rand)*~nimx)
	};
	~nimroutquarter=Routine({
		loop{
			~pad.value;
			(~quarter*~tscale).wait;}
	});
	~nimrouttriple=Routine({
		loop{
			~pad.value;
			(~triple*~tscale).wait;}
	});
	~nimrout16=Routine({
		loop{
			~pad.value;
			(~sixteen*~tscale).wait;}
	});
	~nimrout8=Routine({
		loop{
			~pad.value;
			(~eight*~tscale).wait;}
	});

	~subdiv=[~hhrout8,~hhrout16,~hhrout6ple,~hhrout3ple];
	~x={
		arg onoff,which;
		if (onoff==0,{
			//"zero".postln;
			Synth("DirtyHit",[\vol,0.65+0.15.rand,\freq,800+2500.rand,\dur,1.0+1.5.rand]);
			~subdiv[0].stop;
			~subdiv[1].stop;
			~subdiv[2].stop;
			~subdiv[3].stop;
		});
		if (onoff==1,{
			~subdiv[which].reset;~subdiv[which].play
		});

	};

	~improv=[~hhrout8i,~hhrout16i,~hhrout6plei,~hhrout3plei];
	~o={
		arg onoff,which;
		if (onoff==0,{
			//"zero".postln;
			Synth("DirtyHit",[\vol,0.65+0.15.rand,\freq,800+2500.rand,\dur,1.0+0.5.rand]);
			~improv[0].stop;
			~improv[1].stop;
			~improv[2].stop;
			~improv[3].stop;
		});
		if (onoff==1,{
			~improv[which].reset;~improv[which].play
		});

	};

	//tri
	~chordon={
		~pa.release(0);~pb.release(0);	~pc.release(0);~pd.release(0);~pe.release(0);~pf.release(0);	~pg.release(0);
		~pa=Synth("Chord",[\freq,(~key+0.2.rand+0).midicps,\vol,[0.05,0.03,0].choose,\dur,~beat*((1..20).choose),\curve,(3..6).choose]);
		~pb=Synth("Chord",[\freq,(~key+0.2.rand+5).midicps,\vol,[0.05,0.03,0].choose,\dur,~beat*((1..20).choose),\curve,(3..6).choose]);
		~pc=Synth("Chord",[\freq,(~key+0.2.rand+7).midicps,\vol,[0.05,0.03,0].choose,\dur,~beat*((1..20).choose),\curve,(3..6).choose]);
		~pd=Synth("Chord",[\freq,(~key+0.2.rand+12).midicps,\vol,[0.05,0.03,0].choose,\dur,~beat*((1..20).choose),\curve,(3..6).choose]);
		~pe=Synth("Chord",[\freq,(~key+0.2.rand+17).midicps,\vol,[0.01,0.03,0].choose,\dur,~beat*((3..20).choose),\curve,(3..6).choose]);
		~pf=Synth("Chord",[\freq,(~key+0.2.rand+19).midicps,\vol,[0.01,0.03,0].choose,\dur,~beat*((3..20).choose),\curve,(3..6).choose]);
		~pg=Synth("Chord",[\freq,(~key+0.2.rand+5).midicps,\vol,[0.05,0.03,0].choose,\dur,~beat*((3..20).choose),\curve,(3..6).choose]);

	};

	~chordoff={
		~pa.release(0.1.rand);~pb.release(0.1.rand);	~pc.release(0.1.rand);~pd.release(0.1.rand);~pe.release(0.1.rand);
		~pf.release(0.1.rand);	~pg.release(0.1.rand);
	};
	//NIMB control
	~nim=Synth("Nimo",[\vol,0.0,\origvol,0.8,\lowvol,0.5,\midvol,0.5,\highvol,0.5,\centerfreq,1,\resonance,0.8,\sourcevol,0.8,\sourcevol2,0.8,\sourcevol3,0.0,\pulsefreq,3,\delayt,0.02,\decayt,0.1,\delayvol,0.1,\panner,0,\lagger,2.0.rand,\dusty,40]);

	~improvnim=[~nimrout8,~nimrout16,~nimroutquarter,~nimrouttriple];
	~square={
		arg onoff,which;
		if (onoff==0,{
			//"zero".postln;
			Synth("DirtyHit",[\vol,0.65+0.15.rand,\freq,800+2500.rand,\dur,1.0+3.0.rand]);
			~nim.set(\vol,0);
			~improvnim[0].stop;
			~improvnim[1].stop;
			~improvnim[2].stop;
			~improvnim[3].stop;
		});
		if (onoff==1,{
			~improvnim[which].reset;~improvnim[which].play
		});

	};

	~rhy=1;
	~bdoff.value; //error prevention;


	CmdPeriod.doOnce({
		~ps2window.close;
		//~ps2window.close;
		//~ps2window2.close;
		//~ps4.close;

	});


  thisProcess.openUDPPort(~defport);

  ~janalogs= { |msg, time, addr, port|
      if(msg[0].asString.beginsWith(~jaxis)) {
      // msg.postln;
         if(msg[1].asString == "lefty") { //L3y
        var one=(msg[2]/32767*0.5)+0.5;
        ~duratio=(1-one).linlin(0,1,0.25,4);
        ~nimy=(1-one).linlin(0,1,0,4);
        ~arcw=one.linlin(0,1,0.2,01);
        };
        if(msg[1].asString == "leftx") { // L3x
        var one=(msg[2]/32767*0.5)+0.5;
        ~transpose=one.linlin(0,1,0,4);
        ~nimx=one.linlin(0,1,0.0001,1.8);
        ~thickness=one.linlin(0,1,2,300);
        };
        if(msg[1].asString == "righty") { // R3x
        var one=(msg[2]/32767*0.5)+0.5;
        ~tscale=one.linexp(0,1,1,5);

        };
        //if(msg[1].asString == "rightx") { };
      }
    };
   ~jbuttons= { |msg, time, addr, port|
      if(msg[0].asString.beginsWith(~jbutton)) {
      // msg.postln;
         if(msg[1].asString == "dpup") {
           if (msg[2]==1,{~rhy=1;~dancetime=~sixteen};);//up
        };
        if(msg[1].asString == "dpdown") {
          if (msg[2]==1,{~rhy=0;~dancetime=~eight};);//down
        };
        if(msg[1].asString == "dpleft") {
          if (msg[2]==1,{~rhy=2;~dancetime=~sixple};);//left
        };
        if(msg[1].asString == "dpright") {
          if (msg[2]==1,{~rhy=3;~dancetime=~triple};);//left
        };
        if(msg[1].asString == "x") { // SQUARE
           	if (msg[2]==1,
            {~square.value(1,~rhy);~dance.reset;~dance.play;~pcolor=2;~pshape=1}, {~square.value(0,~rhy);~dance.stop;~pcolor=1}
          )
        };
        if(msg[1].asString == "a") { // X
          if (msg[2]==1,
			{~x.value(1,~rhy);~dance.reset;~dance.play;~pshape=1},
			{~x.value(0,~rhy);~dance.stop;}
		);
        };
        if(msg[1].asString == "b") { // CIRCLE
          		if (msg[2]==1,
			{~o.value(1,~rhy);~dance.reset;~dance.play;~pshape=2},
			{~o.value(0,~rhy);~dance.stop;~pshape=1;}
		);
        };
        if(msg[1].asString == "y") { // TRIANGLE
          if (msg[2]==1,
            {~chordon.value(0);
				{~ps2window.background = Color(0.5.rand,0.8.rand,0.5+0.5.rand,1)}.defer;
			},
			{~chordoff.value(0);
				{~ps2window.background=Color.black}.defer
          })
        };
        if(msg[1].asString == "leftshoulder") { // L1
          		if (msg[2]==1,
			{~l1.value(1,~rhy);~dance.reset;~dance.play;~pcolor=1;~pshape=1;},
			{~l1.value(0,~rhy);~dance.stop}
		);
        };
       if(msg[1].asString == "rightshoulder") { // R1
          		if (msg[2]==1,
{~bdon.value;~dance.reset;~dance.play;~pcolor=1;~pshape=1;~pcircle=2;},
			{~bdoff.value;~dance.stop;~pcircle=1}
		);
        };

      }
    };

  thisProcess.addOSCRecvFunc(~jbuttons);
  thisProcess.addOSCRecvFunc(~janalogs);



};//end of waitForBoot

