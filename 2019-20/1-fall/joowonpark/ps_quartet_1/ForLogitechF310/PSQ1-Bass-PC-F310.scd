//PS Quartet No. 1
//Tenor - Logitech F310 (PC)
//PC Version
//Setup
//Set F310 to "X" Mode in the back of the controller
//Connect the controller before launching SuperCollider
//Performance
//Read the score in PS4 Dualshock configuration (i.e. triangle is Y button, circle is B button, etc)
//In reading the score, press "Back" instead of the trackpad to start/stop
//Press only the For L2R2, press only the LT. Do not use RT

//Joo Won Park (updated 9/10/2019)

HID.findAvailable;
HID.postAvailable;
~ps4 = HID.open( 1133, 49693 );//for pc Logitech F310
//~ps4 = HID.open( 1118, 654 );//for pc xbox 360 for Windows

~tempo=8.8;
~tonic = 52;

~transpose=0;
~transpose2=12.neg;
~onoff=0;
~onoffL1=1;
~onoffR1=1;
~onoffOp=1;
~onoffPower=0;
~beatvol=1;

//GUI
~wscale=1;//set to 1
~width=Window.screenBounds.width*~wscale*0.5;
~height=Window.screenBounds.height*~wscale;

(

~pswindow = Window("Left", Rect(0,0,~width,~height),border:false).front;
~pswindow.background = Color.black;

~pswindow2 = Window("Right", Rect(Window.screenBounds.width*0.5,0,~width,~height),border:false).front;
~pswindow2.background = Color.black;

~coor =Array.fill(8,{~width.rand});
~run=true; //Need this?
~bcolor=[[0.1,0.6,0.3],[0,1,0],[0.5,0.0,0.5],[0,1,1],[0,0,0],[1,1,0],[0.5,0.2,1],[0.5,0.5,0.0]];

~guifunc={

	Pen.width = 20;
	Pen.color = Color.cyan(1,0.7);
	Pen.line(~coor[0]@~coor[1], ~coor[2]@~coor[3]);
	Pen.stroke;

	Pen.color = Color.cyan(1,0.95);
	Pen.line(~coor[2]@~coor[3], ~coor[4]@~coor[5]);
	Pen.stroke;

	Pen.color = Color.cyan(1,1);
	Pen.line(~coor[4]@~coor[5], ~coor[6]@~coor[7]);
	Pen.stroke;

	~coor=[~coor[4],~coor[5],~width.rand,~height.rand,~width.rand,~height.rand,~width.rand,~height.rand];
};

~guifunc2={
	arg nothing;
	Pen.width = 20;

	Pen.color = Color.cyan(1,0.5);
	Pen.line(~coor[0]@~coor[1], ~coor[2]@~coor[3]);
	Pen.stroke;


	Pen.color = Color.cyan(1,0.8);
	Pen.line(~coor[2]@~coor[3], ~coor[4]@~coor[5]);
	Pen.stroke;

	/*Pen.color = Color.blue(1,1);
	Pen.line(~coor[4]@~coor[5], ~coor[6]@~coor[7]);
	Pen.stroke;*/
	~coor=[~coor[4],~coor[5],~width.rand,~height.rand,~width.rand,~height.rand,~width.rand,~height.rand];
};

~guifunc3={
	Pen.width = 30;
	Pen.color = Color.cyan(1,1);
	Pen.line(~coor[0]@~coor[1], ~coor[2]@~coor[3]);
	Pen.stroke;

	Pen.color = Color.cyan(1,0.5);
	Pen.line(~coor[2]@~coor[3], ~coor[4]@~coor[5]);
	Pen.stroke;

	Pen.color = Color.cyan(1,0.3);
	Pen.line(~coor[4]@~coor[5], ~coor[6]@~coor[7]);
	Pen.stroke;

	~coor=[~coor[4],~coor[5],~width.rand,~height.rand,~width.rand,~height.rand,~width.rand,~height.rand];
};

~guifunc4={
	Pen.width = 10;
	Pen.color = Color.cyan(1,0.2);
	Pen.line(~coor[0]@~coor[1], ~coor[2]@~coor[3]);
	Pen.stroke;

	Pen.color = Color.cyan(1,0.3);
	Pen.line(~coor[2]@~coor[3], ~coor[4]@~coor[5]);
	Pen.stroke;

	Pen.color = Color.cyan(1,0.2);
	Pen.line(~coor[4]@~coor[5], ~coor[6]@~coor[7]);
	Pen.stroke;

	~coor=[~coor[4],~coor[5],~width.rand,~height.rand,~width.rand,~height.rand,~width.rand,~height.rand];
};

~slowdownL=1;
~tempbeat=1/~tempo;
~routguiL=Routine({
	var slow;
	loop{
		{~pswindow.refresh}.defer;
/*		if (~slowdownL>0,
			{slow=~slowdownL},
			{slow=~tempbeat});*/
		(1/~tempo*~slowdownL).wait;
	}
});

~slowdownR=1;
~routguiR=Routine({
	var slow;
	loop{
		{~pswindow2.refresh}.defer;
		// if (~slowdownR>0,
		// 	{slow=~slowdownR},
		// {slow=~tempbeat});
		(1/~tempo*~slowdownR).wait;
	}
});


//WAIT FOR BOOTH
s.waitForBoot{
	SynthDef("Plucky",{
		arg vol, pulse,pitch,co=32767,vib=32767,break,rhythm,fade=0,master;
		var trigger, pluck,fpitch,coefficient,vibrato,slow,filter,source,mix;

		slow = LinExp.kr(break,32768,65408,0.0001,1.0);
		trigger = Impulse.ar(pulse-(pulse*slow))*rhythm;
		source= XFade2.ar(WhiteNoise.ar,PinkNoise.ar*2,Lag.kr(fade,1/(~tempo*4)));

		vibrato=LinLin.kr(vib,0.0,65534,-1,1)*(pitch.midicps*2.midiratio-pitch.midicps);
		coefficient= LinLin.kr(co,0,65534,0.0,0.9);
		//vibrato=LinLin.kr(vib,0.0,1.0,-1,1)*(pitch.midicps*2.midiratio-pitch.midicps);
		//coefficient= LinLin.kr(co,0,1,0.0,0.9);

		pluck =Pluck.ar(source,trigger,0.2,1/(pitch.midicps+vibrato),0.5,coefficient);
		filter=BPF.ar(pluck,pitch.midicps*6,0.1);//control with the trackpad?
		mix = pluck+(filter*3);
		Out.ar(0,mix.dup*vol*master);

	}).add;

	// SynthDef("Plucky2",{
	// 	arg vol, pulse,pitch,co=32767,vib=32767,break,rhythm,fade=0,master;
	// 	var trigger, pluck,fpitch,coefficient,vibrato,slow,filter,source,mix;
	//
	// 	slow = LinExp.kr(break,32678,128,0.0001,1.0);
	// 	trigger = Impulse.ar(pulse-(pulse*slow))*rhythm;
	// 	source= XFade2.ar(WhiteNoise.ar,PinkNoise.ar*2,Lag.kr(fade,1/(~tempo*4)));
	//
	// 	vibrato=LinLin.kr(vib,0.0,65534,-1,1)*(pitch.midicps*2.midiratio-pitch.midicps);
	// 	coefficient= LinLin.kr(co,0,65534,0.0,0.9);
	// 	//vibrato=LinLin.kr(vib,0.0,1.0,-1,1)*(pitch.midicps*2.midiratio-pitch.midicps);
	// 	//coefficient= LinLin.kr(co,0,1,0.0,0.9);
	//
	// 	pluck =Pluck.ar(source,trigger,0.2,1/(pitch.midicps+vibrato),0.5,coefficient);
	// 	filter=BPF.ar(pluck,pitch.midicps*6,0.1);//control with the trackpad?
	// 	mix = pluck+(filter*3);
	// 	Out.ar(0,mix.dup*vol*master);
	//
	// }).add;
	//
	// SynthDef("TheBeat",{
	// 	arg vol;
	// 	var sound,amp;
	//
	// 	sound = SinOsc.ar(~tonic.midicps/4)+SinOsc.ar(~tonic.midicps/3);
	// 	amp = Line.ar(vol,0.00001,1/~tempo*3,doneAction:2);
	// 	Out.ar(0,sound*amp.dup);
	// }).add;




	//D pad command pattern maker

	~command=List[8];
	~melodyL=List[8];
	~melodyR=List[8];

	~volvol=Array.interpolation(18,0.6,1.0);
	~rhy=[1,1,1];//~rhy=[1,0,1];

	~routL=Routine({
		var scale;
		scale=[7,9,10,12,0,2,4,5,0]; //last note is default
		loop{
			~melodyL.do{
				arg note;
				~tingL.set(\pitch,scale[note]+~tonic+~transpose,\vol,~volvol.choose,\rhythm,~rhy.choose);
				//color
				{~pswindow.background=Color.fromArray(~bcolor[note])}.defer;

				(1/~tempo).wait;}
		}
	});

	~routR=Routine({
		var scale;
		scale=[7,9,10,12,0,2,4,5,0]; //last note is default
		loop{
			~melodyR.do{
				arg note;
				~tingR.set(\pitch,scale[note]+~tonic+~transpose2,\vol,~volvol.choose,\rhythm,~rhy.choose);

				//color
				{~pswindow2.background=Color.fromArray(~bcolor[note])}.defer;

				(1/~tempo).wait;}
		}
	});

	~routBeat=Routine({
		loop{
			~thebeat=Synth("TheBeat",[\vol,~beatvol*1.2]);
			(1/~tempo*4).wait;
		}

	});
	~routBeatFade=Routine({
		var fade;
		40.do{
			arg count;
			fade= count.dbamp.neg*0.69;
			//fade.postln;
			~beatvol=fade.dbamp;
			if (count==38,{~routBeat.stop;"Beat Stopped".postln});
			(1/~tempo*10).wait;
		}

	});

	//~beatvol=1;~routBeat.reset;~routBeat.play;
	//	~routBeatFade.reset;~routBeatFade.play;

	//HID Connection
	SystemClock.sched(0.5,{
		(
			HIDFunc.element({
				arg one,bit ;
				var place;
				//changed 8 to 0 (release position)
				if (bit!=0,
					{~command.add(bit);
						~command.remove(8);
				});
			}, [5]);//direction pad

			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyL=~command;
						~command=List[8];
				});
			}, [8]);//square


			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyL=~command;
						~melodyR=~command;
						//~melodyR.postln;
						~command=List[8];
				});
			}, [6]);//X

			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyR=~command;
						//~melodyR.postln;
						~command=List[8];
				});
			}, [7]);//O

			//rhythm
			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoff==0,
							{~rhy=[1,0,0,1,0];"on".postln;~onoff=1},
							{~rhy=[1];"off".postln;~onoff=0});

				});
			}, [9]);//Tri


			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoffL1==0,
							{~tingL.set(\fade,-1);"white".postln;{~pswindow.drawFunc = ~guifunc}.defer;~onoffL1=1},
							{~tingL.set(\fade,1);"brown".postln;{~pswindow.drawFunc = ~guifunc2}.defer;~onoffL1=0});

				});

			}, [10]);//L1

			HIDFunc.element({
				arg one, bit;
				if (bit==1,
					{
						if (~onoffR1==0,
							{~tingR.set(\fade,-1);"white".postln;{~pswindow2.drawFunc = ~guifunc}.defer;~onoffR1=1},
							{~tingR.set(\fade,1);"brown".postln;{~pswindow2.drawFunc = ~guifunc2}.defer;~onoffR1=0});

				});

			}, [11]);//R1

	/*		HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoffOp==0,
							{~routBeatFade.reset;~routBeatFade.play;
								"Stop the beat".postln;~onoffOp=1},
							{~beatvol=1;~routBeat.reset;~routBeat.play;
								"Drop the beat".postln;{~pswindow2.drawFunc = ~guifunc2}.defer;~onoffOp=0

						});

				});

			}, [13]);//options*/

			//Dangerous if pressed twice : maybe a disappearing button?
			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoffPower==0,
							{
								{~pswindow.drawFunc = ~guifunc}.defer;

								~routguiL.reset;~routguiL.play;
								~routL.reset;~routL.play;

								~tingL.set(\master,0.9);
								~tingR.set(\master,0.9);

								{~pswindow2.drawFunc = ~guifunc}.defer;
								~routguiR.reset;~routguiR.play;
								~routR.reset;~routR.play;
								~onoffPower=1;
								"Start".postln;
							},
							{
								~routguiL.stop;
								~routL.stop;
								~routguiR.stop;
								~tingL.set(\master,0);
								~routR.stop;
								~onoffPower=0;
								~tingR.set(\master,0);
								//{~pswindow.close}.defer;

								//{~pswindow2.close}.defer;
								//~ps4.close;
								"Stop".postln;
						});

				});
			}, [12]);//share: start

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingL,4).value = bits;
			}, [1]); //joy L X

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingL,3).value = bits;
				if (one<0.3,{{~pswindow.drawFunc = ~guifunc3}.defer;});
				if (one==0.5,{{~pswindow.drawFunc = ~guifunc}.defer;});
				if (one>0.7,{{~pswindow.drawFunc = ~guifunc4}.defer;});
			}, [0]); //joy L Y

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingR,4).value = bits;


			}, [3]); //joy R X

			HIDFunc.element({
				arg one, bits;
				//one.postln;
				NodeControl(~tingR,3).value = bits;
				if (one<0.3,{{~pswindow2.drawFunc = ~guifunc3}.defer;});
				if (one==0.5,{{~pswindow2.drawFunc = ~guifunc}.defer;});
				if (one>0.7,{{~pswindow2.drawFunc = ~guifunc4}.defer;});
			}, [2]); //joy R Y


			HIDFunc.element({
				arg one, bits;
				//one.postln;


				NodeControl(~tingL,5).value = bits;
				NodeControl(~tingR,5).value = bits;


				~slowdownL=(0.25+( (bits-32768).abs/32768 )*5);
				~slowdownR=(0.25+( (bits-32768).abs/32768 )*5);


			}, [4]); //L2 cc... was #20 in wired mode

		/*	HIDFunc.element({
				arg one, bits;
				//one.postln;
				NodeControl(~tingR,5).value = one;
				~slowdownR=1-one;

			}, [20]); //R2 cc... was #21 in wired mod*/

			~melodyL=List[8];~melodyR=List[8];~onoff=0;

			//initial
			~tingL=Synth("Plucky",[\vol,0,\pulse,~tempo,\pitch,~tonic,\co,32767,\vib,32767,\rhythm,1,\fade,-1,\master,0.9]);
			~tingR=Synth("Plucky",[\vol,0,\pulse,~tempo,\pitch,~tonic,\co,32767,\vib,32767,\rhythm,1,\fade,1,\master,0.9]);


		);//start

	});//systemclock end


	CmdPeriod.doOnce({

		~pswindow.close;
		~pswindow2.close;
		//~ps4.close;

	});
}//end of waitforboot

)






