package rubikcube
{
    // flash
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	
	// Number3D etc..
	import org.papervision3d.core.math.*;
	
	
	import rubikcube.RubikEvent;
	import rubikcube.Rubik;
	
    public class Main extends Sprite
    {
        private var lang:Array=[];
		
		private var side:Number=90;
		private var dsp:Number=0.3;
		private var N:uint=3;
		private var colors={inside:0x2c2c2c,top:0xFF00FF,bottom:0x00FF00,left:0xFFFF00,right:0x0000FF,front:0xFF0000,back:0x00FFFF}; // mutually complementary colors
		private var cube:Object=null;
		private var rb:Rubik=null;
		private var w=300,h=300;
		private var navigate:Boolean=false, locked:Boolean=true;
		
		private var mx=-1,my=-1;
		private var tst=0;
		private var msgtxt2="";
		private var l:String="gr";
		private var t:String;
		private var axisar=["X","Y","Z"];
		private var axis:int=0;
		private var rrow:int=0;
		private var prevclick:int=-1;
		private var mousemove:Boolean=false;
		private var mouse_path:Array;
		private var pressed_cub:Object=null,released_cub=null;
		private var movemode:Boolean=true;
		
		public function Main()
        {
			lang["gr"]=[];
			lang["gr"]["test"]="Τεστ";
			lang["gr"]["new"]="Νέο";
			lang["gr"]["scramble"]="Μείξη";
			lang["gr"]["undo"]="Αναίρεση";
			lang["gr"]["solve"]="Λύση";
			lang["gr"]["lookat"]="Βλέπετε : ";
			lang["gr"]["front"]="Μπροστά";
			lang["gr"]["back"]="Πίοω";
			lang["gr"]["top"]="Πάνω";
			lang["gr"]["bottom"]="Κάτω";
			lang["gr"]["left"]="Αριστερά";
			lang["gr"]["right"]="Δεξιά";
			lang["gr"]["cuberotmsg"]="Πατήστε για να περιστρέψετε τον Κύβο";
			lang["gr"]["rot"]="Περιστροφή\nΠλευράς";
			lang["gr"]["sidetip"]="Σύρετε το ποντίκι σας\n με πατημένο το κουμπί\n πάνω απο γραμμή ή στήλη \nγια να περιστρέψετε πλευρές";
			lang["gr"]["colortip"]="Διπλό ΚΛΙΚ σε πλευρά για να αλλάξετε το χρώμα\nΚΛΙΚ ΕΔΩ αφού τελειώσετε";
			lang["gr"]["colortip2"]="Κάντε ΚΛΙΚ εδώ για να αλλάξετε χρώμα στους κυβίσκους.";
			lang["gr"]["about"]="Πληροφορίες";
			lang["gr"]["view"]="Όψη";
			lang["gr"]["abouttxt"]="<font color='#ff0000' size='22'>3D Κύβος του Rubik Προβολή & Επίλυση</font><br><font color='#ff00ff' size='12'>version 0.7 από Νίκος Μ. (nikosms0@gmail.com)</font><br><font color='#999999' size='18'><p>Γραφικά, 3D προγραμματισμός και τροποποίηση κώδικα από Νίκος Μ.</p><p>Χρησιμοποιήθηκαν:<br><li>PaperVision3D Engine, Beta 2.0</li><li>GTween Tween Engine από Grant Skinner</li><li>3x3x3 Cube Solver προσαρμόστηκε απο το C++ Cube Solver από Eric Dietz (root@wrongway.org)</li><br></p><br><p>Απολάυστε τις συμμετρίες και τα μαθηματικά του Κύβου του Rubik σε ένα τρισδιάστατο κόσμο..</p></font";
			
			lang["en"]=[];
			lang["en"]["test"]="Test";
			lang["en"]["new"]="New";
			lang["en"]["scramble"]="Scramble";
			lang["en"]["undo"]="Undo";
			lang["en"]["solve"]="Solve";
			lang["en"]["lookat"]="You are looking at : ";
			lang["en"]["front"]="Front";
			lang["en"]["back"]="Back";
			lang["en"]["top"]="Top";
			lang["en"]["bottom"]="Bottom";
			lang["en"]["left"]="Left";
			lang["en"]["right"]="Right";
			lang["en"]["cuberotmsg"]="Click to rotate Cube";
			lang["en"]["rot"]="Rotate\nSide";
			lang["en"]["sidetip"]="Drag your mouse \nover row or column with button pressed \nto rotate sides";
			lang["en"]["colortip"]="Double Click on face to change its color.\nClick HERE when all done.";
			lang["en"]["colortip2"]="CLICK here to change color to cubelets";
			lang["en"]["about"]="About";
			lang["en"]["view"]="View";
			lang["en"]["abouttxt"]="<font color='#ff0000' size='22'>3D Rubik Cube Viewer & Solver</font><br><font color='#ff00ff' size='12'>version 0.7 by Nikos Μ. (nikosms0@gmail.com)</font><br><font color='#999999' size='18'><p>Graphics, 3D programming and code adaptation by Nikos M.</p><p>Tools used:<br><li>PaperVision3D Engine, Beta 2.0</li><li>GTween Tween Engine by Grant Skinner</li><li>3x3x3 Cube Solver adapted from C++ Cube Solver by Eric Dietz (root@wrongway.org)</li><br></p><br><p>Enjoy the symmetries and mathematics of the Rubik Cube in a 3D World..</p></font>";
			l="en";
			
			super();
			setlang();
			setColorPickerColors();
			frontcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			backcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			topcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			bottomcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			leftcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			rightcolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			insidecolorpicker.addEventListener(ColorPickerEvent.CHANGE, changecolor);
			cubeletcolorpicker.showTextField=false;
			cubeletcolorpicker.opaqueBackground = 0x000000;
			
			about.visible=false;
			cover22.visible=false;
			newcube();
			
			
			//sidec.axistxt.text=axisar[axis];
			
			navig.buttonMode=true;
			navig.addEventListener(MouseEvent.MOUSE_OVER,navin);
			navig.addEventListener(MouseEvent.MOUSE_OUT,navout);
			navig.addEventListener(MouseEvent.CLICK,lock);
			//testbt.addEventListener(MouseEvent.CLICK,test);
			//testbt2.addEventListener(MouseEvent.CLICK,test2);
			//sidec.r1bt.addEventListener(MouseEvent.CLICK,r1);
			//sidec.r2bt.addEventListener(MouseEvent.CLICK,r2);
			solvebt.addEventListener(MouseEvent.CLICK,solve);
			scramblebt.addEventListener(MouseEvent.CLICK,scr);
			newbt.addEventListener(MouseEvent.CLICK,newcube);
			undobt.addEventListener(MouseEvent.CLICK,undoevent);
			aboutbt.addEventListener(MouseEvent.CLICK,abouth);
			enbt.addEventListener(MouseEvent.CLICK,chooselang);
			grbt.addEventListener(MouseEvent.CLICK,chooselang);
			colorbt1.buttonMode=true;
			colorbt1.mouseChildren=false;
			//colorbt1.useHandCursor=true;
			colorbt1.addEventListener(MouseEvent.CLICK,changemode);
			addEventListener(Event.ENTER_FRAME,onmove);
        }// end function

		//---------------------------------------------------------------------------------------------
		//   PRIVATE FUNCTIONS
		//---------------------------------------------------------------------------------------------
		
		private function changemode(e:Event)
		{
			movemode=!movemode;
			if (movemode)
			{
				rb.removeEventListener(RubikEvent.FACE_DOUBLE_CLICK,rubikfacedblclicked);
				rb.addEventListener(RubikEvent.CUBELET_PRESS,rubikcubeletpressed);
				rb.addEventListener(RubikEvent.CUBELET_RELEASE,rubikcubeletreleased);
				colorbt1.colormsg.text=lang[l]["colortip2"];
				sidemsg2.text=lang[l]["sidetip"];
			}
			else
			{
				rb.addEventListener(RubikEvent.FACE_DOUBLE_CLICK,rubikfacedblclicked);
				rb.removeEventListener(RubikEvent.CUBELET_PRESS,rubikcubeletpressed);
				rb.removeEventListener(RubikEvent.CUBELET_RELEASE,rubikcubeletreleased);
				colorbt1.colormsg.text=lang[l]["colortip"];
				sidemsg2.text="";
			}

		}
		
		private function newcube(e:Event=null)
		{
			if (rb!=null)
			{
				removeChild(rb);
				rb.destroy();
			}
			rb=new Rubik(w,h,N,side,dsp,colors);
			rb.setCameraRot("x",Math.PI/10);
			t=rb.setCameraRot("y",Math.PI/5);
			
			mx=((Math.PI/5)*navig.width/2)/Math.PI+navig.width/2+navig.x;
			my=((Math.PI/10)*navig.height/2)/Math.PI+navig.height/2+navig.y;
			cross.mouseEnabled=false;
			cross.x=mx-cross.width/2;
			cross.y=my-cross.height/2;
			
			msg.autoSize = TextFieldAutoSize.LEFT;
			msg.text=lang[l]["lookat"]+lang[l][t]+" "+lang[l]["view"];
			msg2.autoSize = TextFieldAutoSize.LEFT;
			msg2.text="";
			//rb.addEventListener(RubikEvent.CUBELET_CLICK,rubikcubeletclicked);
			rb.addEventListener(RubikEvent.CUBELET_PRESS,rubikcubeletpressed);
			rb.addEventListener(RubikEvent.CUBELET_RELEASE,rubikcubeletreleased);
			//rb.addEventListener(RubikEvent.MOUSE_MOVE,rubikmousemove);
			//rb.addEventListener(RubikEvent.FACE_CLICK,rubikfaceclicked);
			//rb.addEventListener(RubikEvent.FACE_DOUBLE_CLICK,rubikfacedblclicked);
			rb.addEventListener(RubikEvent.ROTATION_COMPLETE,updateflat);

			//rb.x=(stage.stageWidth-w)/2;
			//rb.y=(stage.stageHeight-h)/2;
			rb.x=100;
			rb.y=100;
			//rb.buttonMode=true;
			//rb.useHandCursor=true;
			addChild(rb);
			flat();
		}
		
		private function flat():void
		{
			var sp=rb.getFlatImage(70);
			if (flati.numChildren>0) flati.removeChildAt(0);
			flati.addChild(sp);
			//ttt.text=rb.testsolver();
		}
						
		private function updateflat(e:RubikEvent):void
		{
			flat();
		}
		
		private function abouth(e:MouseEvent):void
		{
			// go into about mode
			about.abouttxti.abouttxt.htmlText=lang[l]["abouttxt"];
			rb.visible=false;
			cover22.visible=true;
			// create the mask for reflection  
			var masker = new Shape();
			var mat=new Matrix();
			mat.createGradientBox(500,500,Math.PI/2);
			// fade gradually
			masker.graphics.beginGradientFill("linear",[0, 0, 0, 0],[0, 1, 1, 0],[0, 0.2*255, 0.8*255, 255],mat);
			masker.graphics.drawRect(0,0,500,500);
			masker.graphics.endFill();
			masker.name="masker";
			masker.x = about.x;
			masker.y = about.y;
			masker.cacheAsBitmap=true;
			about.cacheAsBitmap=true;
			about.abouttxti.cacheAsBitmap=true;
			about.mask=masker;
			addChild(masker);
			// play animation
			about.visible=true;
			about.gotoAndPlay(1);
			// check finished
			this.addEventListener(Event.ENTER_FRAME,checktimeout);
		}
		
		private function checktimeout(e:Event):void
		{
			if (about.currentFrame>=about.totalFrames)
			{
				this.removeEventListener(Event.ENTER_FRAME,checktimeout);
				// return to normal mode
				about.stop();
				removeChild(getChildByName("masker"));
				cover22.visible=false;
				about.visible=false;
				rb.visible=true;
			}
		}
		
		private function setlang():void
		{
			rotcubemsg.text=lang[l]["cuberotmsg"];
			//sidemsg.text=lang[l]["rot"];
			//sidemsg.autoSize = TextFieldAutoSize.CENTER;
			sidemsg2.text=lang[l]["sidetip"];
			sidemsg2.autoSize = TextFieldAutoSize.RIGHT;
			if (movemode)
			colorbt1.colormsg.text=lang[l]["colortip2"];
			else
			colorbt1.colormsg.text=lang[l]["colortip"];
			colorbt1.colormsg.autoSize = TextFieldAutoSize.LEFT;
			aboutmsg.text=lang[l]["about"];
			aboutmsg.autoSize = TextFieldAutoSize.LEFT;
			testmsg.autoSize = TextFieldAutoSize.LEFT;
			testmsg.text=lang[l]["test"];
			solvemsg.autoSize = TextFieldAutoSize.LEFT;
			solvemsg.text=lang[l]["solve"];
			undomsg.autoSize = TextFieldAutoSize.RIGHT;
			undomsg.text=lang[l]["undo"];
			scramblemsg.autoSize = TextFieldAutoSize.RIGHT;
			scramblemsg.text=lang[l]["scramble"];
			newmsg.autoSize = TextFieldAutoSize.RIGHT;
			newmsg.text=lang[l]["new"];
			msg.text=lang[l]["lookat"]+lang[l][t]+" "+lang[l]["view"];
		}
		
		private function chooselang(e:MouseEvent):void
		{
			if (e.target==enbt)
				l="en";
			else l="gr";
			setlang();
		}
		
		private function setColorPickerColors():void
		{
			frontcolorpicker.selectedColor=colors.front;
			backcolorpicker.selectedColor=colors.back;
			topcolorpicker.selectedColor=colors.top;
			bottomcolorpicker.selectedColor=colors.bottom;
			leftcolorpicker.selectedColor=colors.left;
			rightcolorpicker.selectedColor=colors.right;
			insidecolorpicker.selectedColor=colors.inside;
			cubeletcolorpicker.colors=[	colors.front, 
										colors.back,
										colors.top,
										colors.bottom,
										colors.left,
										colors.right ];
			cubeletcolorpicker.selectedColor=cubeletcolorpicker.colors[0];
		}
		
		private function changecolor(e:ColorPickerEvent):void
		{
			var colorsobj;
			var t=e.target.name;
			
			if (t=="frontcolorpicker")
				colorsobj={front:e.color};
			if (t=="backcolorpicker")
				colorsobj={back:e.color};
			if (t=="topcolorpicker")
				colorsobj={top:e.color};
			if (t=="bottomcolorpicker")
				colorsobj={bottom:e.color};
			if (t=="leftcolorpicker")
				colorsobj={left:e.color};
			if (t=="rightcolorpicker")
				colorsobj={right:e.color};
			if (t=="insidecolorpicker")
				colorsobj={inside:e.color};
			
			rb.setRubikColors({colors:colorsobj});
			setColorPickerColors();
			flat();
			return;
		}
		
		private function undoevent(e:MouseEvent):void
		{
			var res:String=rb.undo();
			if (res=="setRubikColors")
			{
				setColorPickerColors();
			}
			flat();
		}
		
		private function scr(e:MouseEvent):void
		{
			rb.scramble(10);
			flat();
		}
		
		private function navin(e:MouseEvent):void
		{
			navigate=true;
		}
                
		private function navout(e:MouseEvent):void
		{
			navigate=false;
		}
                
		private function lock(e:MouseEvent):void
		{
			locked=!locked;
		}
		
		private function onmove(e:Event):void
		{
			var a1=false, a2=false;

			if (navigate && !locked)
			{
					if (Math.abs(mouseX-mx) > Math.abs(mouseY-my))
					{
						a1=true;
						t=rb.setCameraRot("y",((mouseX-navig.x)-navig.width/2)*Math.PI/(navig.width/2));
					}
					else if (Math.abs(mouseX-mx) < Math.abs(mouseY-my))
					{
						a2=true;
						t=rb.setCameraRot("x",((mouseY-navig.y)-navig.height/2)*Math.PI/(navig.height/2));
					}
					mx=mouseX;
					my=mouseY;
					cross.x=mx-cross.width/2;
					cross.y=my-cross.height/2;
			}
			if (a1)
			{
				msg.text=lang[l]["lookat"]+lang[l][t]+" "+lang[l]["view"];
			}
			if (a2)
			{
				msg.text=lang[l]["lookat"]+lang[l][t]+" "+lang[l]["view"];
			}
		}
		
		private function solve(e:MouseEvent):void
		{
			ttt2.text="Solving..";
			var obj=rb.solve();
			ttt2.text="Solving Done.";
			if (obj.e>0)
				ttt2.text="Error Solving!"+obj.e;
			else
				ttt2.text="Solved OK!"+obj.e;
			ttt.text=obj.movs2;
			flat();
		}
		
		/*private function test2(e:MouseEvent):void
		{
			ttt.text=rb.testsolver();
		}*/
		
		/*private function r1(e:MouseEvent):void
		{
			rb.rotate({axis:axisar[axis],row:rrow,angle:1,duration:2});
		}
		
		private function r2(e:MouseEvent):void
		{
			rb.rotate({axis:axisar[axis],row:rrow,angle:-1,duration:2});
		}*/
		
		/*private function test(e:MouseEvent):void
		{
			var rangle:int=1;
			var duration:Number=2;
			
				switch (tst)
				{
				case 3:
						rb.rotate({axis:"y",row:0,angle:rangle,duration:duration});
						break;
				case 4:
						rb.rotate({axis:"y",row:1,angle:rangle,duration:duration});
						break;
				case 5:
						rb.rotate({axis:"y",row:2,angle:rangle,duration:duration});
						break;
				case 0:
						rb.rotate({axis:"x",row:0,angle:rangle,duration:duration});
						break;
				case 1:
						rb.rotate({axis:"x",row:1,angle:rangle,duration:duration});
						break;
				case 2:
						rb.rotate({axis:"x",row:2,angle:rangle,duration:duration});
						break;
				case 6:
						rb.rotate({axis:"z",row:0,angle:rangle,duration:duration});
						break;
				case 7:
						rb.rotate({axis:"z",row:1,angle:rangle,duration:duration});
						break;
				case 8:
						rb.rotate({axis:"z",row:2,angle:rangle,duration:duration});
						break;
				default: break;
				}
			tst++;
			if (tst>=9) tst=0;
		}*/
		
		private function rubikcubeletpressed(e:RubikEvent):void
		{
			pressed_cub=e;
			msgtxt2=pressed_cub.seenas.name+" Cubelet xx:"+e.original.xx+" yy:"+e.original.yy+" zz:"+e.original.zz+
						" seen xx:"+e.seenas.xx+" yy:"+e.seenas.yy+" zz:"+e.seenas.zz;
			msg2.text=msgtxt2;
			mousemove=true;
			mouse_path=new Array();
			rb.addEventListener(RubikEvent.MOUSE_MOVE,rubikmousemove);
		}
		
		private function rubikcubeletreleased(e:RubikEvent):void
		{
			function range(what:int,min:int,max:int)
			{
				if (what>min && what<max) return true;
				return false;
			}
			released_cub=e;
			msgtxt2=released_cub.seenas.name+" Cubelet xx:"+e.original.xx+" yy:"+e.original.yy+" zz:"+e.original.zz+
						" seen xx:"+e.seenas.xx+" yy:"+e.seenas.yy+" zz:"+e.seenas.zz;
			msg2.text=msgtxt2;
			rb.removeEventListener(RubikEvent.MOUSE_MOVE,rubikmousemove);
			mousemove=false;
			if (mouse_path.length<3) return;
			var N=rb.theCube.N;
			var prev_ray=mouse_path[0];
			var mid_ray=mouse_path[Math.round(mouse_path.length/2)];
			var now_ray=mouse_path[mouse_path.length-1];
			var cameraPosition:Number3D = new Number3D(rb.camera.x, rb.camera.y, rb.camera.z);
			prev_ray=Number3D.add(prev_ray,cameraPosition);
			mid_ray=Number3D.add(mid_ray,cameraPosition);
			now_ray=Number3D.add(now_ray,cameraPosition);
			//var dir = Math.atan2(Number3D.cross(Number3D.sub(now_ray,mid_ray),Number3D.sub(mid_ray,prev_ray)).modulo , Number3D.dot(Number3D.sub(now_ray,mid_ray),Number3D.sub(mid_ray,prev_ray)));
			var angle=-1;
			//trace(dir);
			var nn=Number3D.sub(now_ray,prev_ray);
			//if (dir>0) angle=-angle; 
			if (pressed_cub.seenas.name==released_cub.seenas.name)
			{
				switch(pressed_cub.seenas.name)
				{
					case 'right':
					case 'left':
						//if (pressed_cub.seenas.yy==1 && released_cub.seenas.yy==1)
						if (range(pressed_cub.seenas.yy,0,N-1) && range(released_cub.seenas.yy,0,N-1))
						{
							if (nn.z>0) angle=-angle;
							if (pressed_cub.seenas.name=='right') angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.zz==1 && released_cub.seenas.zz==1)
						else if (range(pressed_cub.seenas.zz,0,N-1) && range(released_cub.seenas.zz,0,N-1))
						{
							if (nn.x<0) angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.yy==2 && released_cub.seenas.yy==2)
						else if (pressed_cub.seenas.yy==N-1 && released_cub.seenas.yy==N-1)
						{
							if (nn.z>0) angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:angle,duration:2});
						}
						else if (pressed_cub.seenas.yy==0 && released_cub.seenas.yy==0)
						{
							if (nn.z>0) angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:-angle,duration:2});
						}
						else if (pressed_cub.seenas.zz==0 && released_cub.seenas.zz==0)
						{
							if (nn.y>0) angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.zz==2 && released_cub.seenas.zz==2)
						else if (pressed_cub.seenas.zz==N-1 && released_cub.seenas.zz==N-1)
						{
							if (nn.y>0) angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:-angle,duration:2});
						}
						break;
					case 'top':
					case 'bottom':
						//if (pressed_cub.seenas.zz==1 && released_cub.seenas.zz==1)
						if (range(pressed_cub.seenas.zz,0,N-1) && range(released_cub.seenas.zz,0,N-1))
						{
							if (nn.x>0) angle=-angle;
							if (pressed_cub.seenas.name=='top') angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.xx==1 && released_cub.seenas.xx==1)
						else if (range(pressed_cub.seenas.xx,0,N-1) && range(released_cub.seenas.xx,0,N-1))
						{
							if (nn.z<0) angle=-angle;
							if (pressed_cub.seenas.name=='bottom') angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:-angle,duration:2});
						}
						//else if (pressed_cub.seenas.zz==2 && released_cub.seenas.zz==2)
						else if (pressed_cub.seenas.zz==N-1 && released_cub.seenas.zz==N-1)
						{
							if (nn.x>0) angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:-angle,duration:2});
						}
						else if (pressed_cub.seenas.zz==0 && released_cub.seenas.zz==0)
						{
							if (nn.x>0) angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.xx==2 && released_cub.seenas.xx==2)
						else if (pressed_cub.seenas.xx==N-1 && released_cub.seenas.xx==N-1)
						{
							if (nn.z>0) angle=-angle;
							//if (pressed_cub.seenas.name=='bottom') angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:angle,duration:2});
						}
						else if (pressed_cub.seenas.xx==0 && released_cub.seenas.xx==0)
						{
							if (nn.z>0) angle=-angle;
							//if (pressed_cub.seenas.name=='bottom') angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:-angle,duration:2});
						}
						break;
					case 'back':
					case 'front':
						//if (pressed_cub.seenas.yy==1 && released_cub.seenas.yy==1)
						if (range(pressed_cub.seenas.yy,0,N-1) && range(released_cub.seenas.yy,0,N-1))
						{
							if (nn.x>0) angle=-angle;
							if (pressed_cub.seenas.name=='back') angle=-angle;
							rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:-angle,duration:2});
						}
						//else if (pressed_cub.seenas.xx==1 && released_cub.seenas.xx==1)
						else if (range(pressed_cub.seenas.xx,0,N-1) && range(released_cub.seenas.xx,0,N-1))
						{
							if (nn.y<0) angle=-angle;
							if (pressed_cub.seenas.name=='back') angle=-angle;
							rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.yy==2 && released_cub.seenas.yy==2)
						else if (pressed_cub.seenas.yy==N-1 && released_cub.seenas.yy==N-1)
						{
							if (nn.x>0) angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:-angle,duration:2});
						}
						else if (pressed_cub.seenas.yy==0 && released_cub.seenas.yy==0)
						{
							if (nn.x>0) angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:angle,duration:2});
						}
						//else if (pressed_cub.seenas.xx==2 && released_cub.seenas.xx==2)
						else if (pressed_cub.seenas.xx==N-1 && released_cub.seenas.xx==N-1)
						{
							if (nn.y<0) angle=-angle;
							//if (pressed_cub.seenas.name=='back') angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:-angle,duration:2});
						}
						else if (pressed_cub.seenas.xx==0 && released_cub.seenas.xx==0)
						{
							if (nn.y<0) angle=-angle;
							//if (pressed_cub.seenas.name=='back') angle=-angle;
							rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:angle,duration:2});
						}
						break;
				}
			}
			/*var cameraPosition:Number3D = new Number3D(rb.camera.x, rb.camera.y, rb.camera.z);
			var prev_point=Number3D.add(prev_ray,cameraPosition);
			var mid_point=Number3D.add(mid_ray,cameraPosition);
			var now_point=Number3D.add(now_ray,cameraPosition);
			var plane=Plane3D.fromThreePoints(prev_ray,mid_ray,now_ray);
			//var rot1_ray=plane.normal;
			var rot1_ray:Number3D=Number3D.sub(now_ray,mid_ray);			
			rot1_ray.normalize();
			var rot2_ray:Number3D=Number3D.sub(mid_ray,prev_ray);			
			rot2_ray.normalize();
			//trace(rot_ray.toString());
			//var rot_ray:Number3D=now_ray;
			// find out which rotation is implied
			var axis1=new Array(6);
			var axis2=new Array(6);
			var v=new Array(6);
			var vseen=new Array(6);
			// x?
			v[0]=new Number3D(1,0,0);
			vseen[0]=v[0].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[0]);
			vseen[0].normalize();
			axis1[0]=Number3D.sub(rot1_ray,v[0]);
			axis1[0]=axis1[0].modulo;
			axis2[0]=Number3D.sub(rot2_ray,v[0]);
			axis2[0]=axis2[0].modulo;
			// -x?
			v[1]=new Number3D(-1,0,0);
			vseen[1]=v[1].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[1]);
			vseen[1].normalize();
			axis1[1]=Number3D.sub(rot1_ray,v[1]);
			axis1[1]=axis1[1].modulo;
			axis2[1]=Number3D.sub(rot2_ray,v[1]);
			axis2[1]=axis2[1].modulo;
			// y?
			v[2]=new Number3D(0,1,0);
			vseen[2]=v[2].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[2]);
			vseen[2].normalize();
			axis1[2]=Number3D.sub(rot1_ray,v[2]);
			axis1[2]=axis1[2].modulo;
			axis2[2]=Number3D.sub(rot2_ray,v[2]);
			axis2[2]=axis2[2].modulo;
			// -y?
			v[3]=new Number3D(0,-1,0);
			vseen[3]=v[3].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[3]);
			vseen[3].normalize();
			axis1[3]=Number3D.sub(rot1_ray,v[3]);
			axis1[3]=axis1[3].modulo;
			axis2[3]=Number3D.sub(rot2_ray,v[3]);
			axis2[3]=axis2[3].modulo;
			// z?
			v[4]=new Number3D(0,0,1);
			vseen[4]=v[4].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[4]);
			vseen[4].normalize();
			axis1[4]=Number3D.sub(rot1_ray,v[4]);
			axis1[4]=axis1[4].modulo;
			axis2[4]=Number3D.sub(rot2_ray,v[4]);
			axis2[4]=axis2[4].modulo;
			// -z?
			v[5]=new Number3D(0,0,-1);
			vseen[5]=v[5].clone();
			Matrix3D.multiplyVector(rb.camera.transform,vseen[5]);
			vseen[5].normalize();
			axis1[5]=Number3D.sub(rot1_ray,v[5]);
			axis1[5]=axis1[5].modulo;
			axis2[5]=Number3D.sub(rot2_ray,v[5]);
			axis2[5]=axis2[5].modulo;
			//trace(vseen);
			//trace(axis);
			axis1=axis1.sort(Array.RETURNINDEXEDARRAY); // find min distance
			axis2=axis2.sort(Array.RETURNINDEXEDARRAY); // find min distance
			trace(axis1[0],axis2[0]);
			switch(axis1[0])
			{
				case 0:
						rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:-1,duration:2});
						break;
				case 1:
						rb.rotate({axis:"x",row:pressed_cub.seenas.xx,angle:1,duration:2});
						break;
				case 2:
						rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:1,duration:2});
						break;
				case 3:
						rb.rotate({axis:"y",row:pressed_cub.seenas.yy,angle:-1,duration:2});
						break;
				case 4:
						rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:-1,duration:2});
						break;
				case 5:
						rb.rotate({axis:"z",row:pressed_cub.seenas.zz,angle:1,duration:2});
						break;
			}*/
		}
		
		private function rubikmousemove(e:RubikEvent):void
		{
			mouse_path.push(e.seenas.ray);
		}

		/*private function rubikcubeletclicked(e:RubikEvent):void
		{
			msgtxt2="Cubelet xx:"+e.original.xx+" yy:"+e.original.yy+" zz:"+e.original.zz+
						" seen xx:"+e.seenas.xx+" yy:"+e.seenas.yy+" zz:"+e.seenas.zz;
			msg2.text=msgtxt2;
			if (e.targetid==prevclick)
				axis=(axis+1)%axisar.length;
			switch(axisar[axis])
			{
				case "X":	rrow=e.seenas.xx;
							break;
				case "Y":	rrow=e.seenas.yy;
							break;
				case "Z":	rrow=e.seenas.zz;
							break;
			}
			//sidec.axistxt.text=axisar[axis];
			prevclick=e.targetid;
			
		}
		
		private function rubikfaceclicked(e:RubikEvent):void
		{
			msgtxt2+=" "+lang[l][e.original.name]+" seen as "+lang[l][e.seenas.name];
			msg2.text=msgtxt2;
		}*/		
		
		private function rubikfacedblclicked(e:RubikEvent):void
		{
			var col=cubeletcolorpicker.selectedColor;
			rb.setCubeletFaceColor({faceindex:e.targetid,color:col});
			flat();
		}		
    } // end class
}  // end package
