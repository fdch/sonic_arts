//PS Quartet No. 1
//Alto - For Mac - Logitech FS310

//Set Up: Put FS310 to "D" mode in the backside of the joystick before connecting to the computer

// When interpreting the score,  you must:
// 1. Read the score in PS4 Dualshock configuration (i.e., the triangle is Y button, the circle is B button, etc.)
// 2. Press the "Back" button for  trackpad  start/stop the piece
// 3. Press the Right JOYSTICK for  L2 R2
// 4. Ignore "R" joystick notations. The Right Joystick is a substitute for L2R2
//
// Joo Won Park


HID.findAvailable;
//HID.postAvailable;
~ps4 = HID.open( 1133, 49686); //for Mac Logitech F310

~tempo=8.8;
~tonic = 52;

~transpose=0;
~transpose2=12;
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
		if (~slowdownL>=0,
			{slow=~slowdownL},
			{slow=~tempbeat});
		(1/~tempo).wait; //tradeoff
		//(1/~tempo/slow).wait;
	}
});

~slowdownR=1;
~routguiR=Routine({
	var slow;
	loop{
		{~pswindow2.refresh}.defer;
		if (~slowdownR>=0,
			{slow=~slowdownR},
			{slow=~tempbeat});
		(1/~tempo).wait//tradeoff;
		//(1/~tempo/slow).wait;
	}
});


//WAIT FOR BOOTH
s.waitForBoot{
	SynthDef("Plucky",{
		arg vol, pulse,pitch,co,vib,break,rhythm,fade=0,master;
		var trigger, pluck,fpitch,coefficient,vibrato,slow,filter,source,mix;

		slow = LinExp.kr(break,0,1.0,0.0001,1.0);
		trigger = Impulse.ar(pulse-(pulse*slow))*rhythm;
		source= XFade2.ar(WhiteNoise.ar,PinkNoise.ar*2,Lag.kr(fade,1/(~tempo*4)));

		vibrato=LinLin.kr(vib,0.0,1.0,-1,1)*(pitch.midicps*2.midiratio-pitch.midicps);
		coefficient= LinLin.kr(co,0,1,0.0,0.9);

		pluck =Pluck.ar(source,trigger,0.2,1/(pitch.midicps+vibrato),0.5,coefficient);
		filter=BPF.ar(pluck,pitch.midicps*6,0.1);//control with the trackpad?
		mix = pluck+(filter*3);
		Out.ar(0,mix.dup*vol*master);

	}).add;

	SynthDef("TheBeat",{
		arg vol;
		var sound,amp;

		sound = SinOsc.ar(~tonic.midicps/4)+SinOsc.ar(~tonic.midicps/3);
		amp = Line.ar(vol,0.00001,1/~tempo*3,doneAction:2);
		Out.ar(0,sound*amp.dup);
	}).add;


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
				if (bit!=8,
					{~command.add(bit);
						~command.remove(8);
				});
			}, [17]);//direction pad

			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyL=~command;
						~command=List[8];
				});
			}, [0]);//square


			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyL=~command;
						~melodyR=~command;
						//~melodyR.postln;
						~command=List[8];
				});
			}, [1]);//X

			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						~melodyR=~command;
						//~melodyR.postln;
						~command=List[8];
				});
			}, [2]);//O

			//rhythm
			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoff==0,
							{~rhy=[1,0,0,1,0];"on".postln;~onoff=1},
							{~rhy=[1];"off".postln;~onoff=0});

				});
			}, [3]);//Tri


			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoffL1==0,
							{~tingL.set(\fade,-1);"white".postln;{~pswindow.drawFunc = ~guifunc}.defer;~onoffL1=1},
							{~tingL.set(\fade,1);"brown".postln;{~pswindow.drawFunc = ~guifunc2}.defer;~onoffL1=0});

				});

			}, [4]);//L1

			HIDFunc.element({
				arg one, bit;

				if (bit==1,
					{
						if (~onoffR1==0,
							{~tingR.set(\fade,-1);"white".postln;{~pswindow2.drawFunc = ~guifunc}.defer;~onoffR1=1},
							{~tingR.set(\fade,1);"brown".postln;{~pswindow2.drawFunc = ~guifunc2}.defer;~onoffR1=0});

				});

			}, [5]);//R1

			HIDFunc.element({
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

			}, [9]);//options

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
			}, [8]);//trackpad: start

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingL,4).value = one;
			}, [13]); //joy L X

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingL,3).value = one;
				if (one<0.3,{{~pswindow.drawFunc = ~guifunc3}.defer;});
				if (one==0.5,{{~pswindow.drawFunc = ~guifunc}.defer;});
				if (one>0.7,{{~pswindow.drawFunc = ~guifunc4}.defer;});
			}, [14]); //joy L Y

			HIDFunc.element({
				arg one, bits;
				NodeControl(~tingR,4).value = one;


			}, [13]); //joy R X

			HIDFunc.element({
				arg one, bits;
				//one.postln;
				NodeControl(~tingR,3).value = one;
				if (one<0.3,{{~pswindow2.drawFunc = ~guifunc3}.defer;});
				if (one==0.5,{{~pswindow2.drawFunc = ~guifunc}.defer;});
				if (one>0.7,{{~pswindow2.drawFunc = ~guifunc4}.defer;});
			}, [14]); //joy R Y


			HIDFunc.element({
				arg one, bits;
				//one.postln;
				NodeControl(~tingL,5).value = one;
				~slowdownL=3-one;
			}, [16]); //L2 cc... was #20 in wired mode

			HIDFunc.element({
				arg one, bits;
				//one.postln;
				NodeControl(~tingR,5).value = one;
				~slowdownR=3-one;

			}, [16]); //R2 cc... was #21 in wired mod
			~melodyL=List[8];~melodyR=List[8];~onoff=0;

			//initial
			~tingL=Synth("Plucky",[\vol,0,\pulse,~tempo,\pitch,~tonic,\co,0.5,\vib,0.5,\rhythm,1,\fade,-1,\master,0.9]);
			~tingR=Synth("Plucky",[\vol,0,\pulse,~tempo,\pitch,~tonic,\co,0.5,\vib,0.5,\rhythm,1,\fade,1,\master,0.9]);


		);//start

	});//systemclock end


	CmdPeriod.doOnce({

		~pswindow.close;
		~pswindow2.close;
		//~ps4.close;

	});
}//end of waitforboot

)






