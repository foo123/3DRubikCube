package rubikcube
{
    // flash
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// Smart GTween
	import com.gskinner.motion.GTween;
	import fl.motion.easing.Exponential;
	    
	// papervision3D
	import org.papervision3d.*;
    import org.papervision3d.core.proto.*;
    import org.papervision3d.core.math.*;
    import org.papervision3d.core.geom.renderables.*;
    import org.papervision3d.view.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.events.*;
	
	import rubikcube.RubikEvent;
	import rubikcube.RubikAdaptor;
	
    public class Rubik extends BasicView
    {
        private var side:Number=100;
		private var N:uint=3;
		private var dsp:Number=0.3;
		private var colors={inside:0x2c2c2c,top:0xFF00FF,bottom:0x00FF00,left:0xFFFF00,right:0x0000FF,front:0xFF0000,back:0x00FFFF}; // mutually complementary colors
		private var rubik:Object=null;
		private var ras:RubikAdaptor=null;
		
		private var undolist:Array=[];
		private var undo_in_action:Boolean=false;
		private var undolist_length=200;
		
		private static const RA=Math.PI*0.5;
		private var onemore=0;
		private var rad=0;
		private var rotation_in_progress:Boolean=false;
		
		public function Rubik(w,h, NN:uint=3, rside:Number=100, rdsp:Number=0.3, rcolors:Object=null)
        {
            this.N=NN;
			this.side=rside;
			this.dsp=rdsp;
			if (rcolors!=null)
				this.colors=rcolors;
			
			super(w, h, false, true);
			camera.ortho = false;
			camera.zoom = 100;
			camera.focus=100;			
			rad=camera.focus*(camera.zoom*0.5);
			setCameraRot("x",Math.PI/6);
			setCameraRot("y",Math.PI/4);
			rubik=createRubik(N,side,dsp,colors);
			ras=new RubikAdaptor(this);
			//ras.rb=this;
			show();
        }// end function

		//----------------------------------------------------------------------------------------
        // PUBLIC FUNCTIONS
		//----------------------------------------------------------------------------------------
		/*public function testsolver():String
		{
			ras.rb=this;
			return(ras.test());
		}*/
		
		public function solve():Object
		{
			var obj=ras.solve(/*this*/);
			if (obj.e>0)
				return(obj)
			else
			{
				var m=obj.movs;
				for (var i=0;i<m.length;i++)
				 setRotation(m[i]);
			}
			return(obj);
		}
		
		public function get theCube() : Object
		{
			return(this.rubik);
		}
		
		public function set theCube(o:Object):void
		{
			if (o==null)
			{
				destroyRubik();
			}
		}
		
		public function set cameraRadius(r:Number):void
		{
			if (r>0)
				this.rad=r;
		}
		
		public function get cameraRadius():Number
		{
			return(this.rad);
		}
		
		public function undo():String
		{
			var undoaction:Object=null;
			if (!rotation_in_progress)
			{
				if (undolist.length>0)
				{
					undo_in_action=true;
					undoaction=undolist.pop();
					if (undoaction.param!=null)
						undoaction.func(undoaction.param);
					else
						undoaction.func();
					undo_in_action=false;
					return(undoaction.actiontype);
				}
			}
			return("");
		}
		
		public function rotate(params:Object) : void
		{
			if (rubik==null) return;
			if (rotation_in_progress) return;
			
			var duration=2;
			var axis=params.axis;
			var row:int=params.row;
			if (params.duration!=null) duration=params.duration;
			var angle:int=params.angle;
			
			if (duration <=0) return;
			if (angle==0) return;
			var ind=getCubletsIndex(axis,row);
			if (ind==null) return; 			
			
			axis=axis.charAt(0);
			axis=axis.toLowerCase();
			
			var rb=this;
			var obj:Array=[];
			var g:GTween;
			
			for (var k=0;k<ind.length;k++)
			{
				obj[k]={cubelet:rubik.cubelets[ind[k]], axis:axis, angle:0, prevangle:0};
				g=new GTween(obj[k],Math.abs(angle)*duration,{angle:angle*RA},{ease:Exponential.easeInOut});
				g.onInit=onInit;
				g.onChange=onChange;
				g.onComplete=onComplete;
			}
			params.angle=-angle;
			addhistory({func:rotate, param:params, actiontype:"rotate"});
			return;
			
			function onInit(g:GTween):void
			{
				rotation_in_progress=true;
			}
			
			function onComplete(g:GTween):void
			{
				var count=rubik.N*rubik.N;
				onemore++;
				if (onemore>=count)
				{
					rotation_in_progress=false;
					onemore=0;
					switch(axis)
					{
					 case 'y':
						switch(row)
						{
							case 0:
								switch(angle)
								{
								 case 1: ras.rbs3.DR();
										break;
								 case -1:ras.rbs3.DL();
										break;
								}
								break;
							case 1:
								switch(angle)
								{
								 case 1: ras.rbs3.MR();
										break;
								 case -1:ras.rbs3.ML();
										break;
								}
								break;
							case 2:
								switch(angle)
								{
								 case 1: ras.rbs3.UR();
										break;
								 case -1:ras.rbs3.UL();
										break;
								}
								break;
						}
						break;
					 case 'x':
						switch(row)
						{
							case 0:
								switch(angle)
								{
								 case 1: ras.rbs3.RD();
										break;
								 case -1:ras.rbs3.RU();
										break;
								}
								break;
							case 1:
								switch(angle)
								{
								 case 1: ras.rbs3.MD();
										break;
								 case -1:ras.rbs3.MU();
										break;
								}
								break;
							case 2:
								switch(angle)
								{
								 case 1: ras.rbs3.LD();
										break;
								 case -1:ras.rbs3.LU();
										break;
								}
								break;
						}
						break;
					 case 'z':
						switch(row)
						{
							case 0:
								switch(angle)
								{
								 case 1: ras.rbs3.BC();
										break;
								 case -1:ras.rbs3.BA();
										break;
								}
								break;
							case 1:
								switch(angle)
								{
								 case 1: ras.rbs3.MC();
										break;
								 case -1:ras.rbs3.MA();
										break;
								}
								break;
							case 2:
								switch(angle)
								{
								 case 1: ras.rbs3.FC();
										break;
								 case -1:ras.rbs3.FA();
										break;
								}
								break;
						}
						break;
					}
					rb.dispatchEvent(new RubikEvent(RubikEvent.ROTATION_COMPLETE));
				}
			}
			
			function onChange(g:GTween):void
			{
				var m:Matrix3D=null;
				switch(g.target.axis)
				{
					case "x":
							//m=Matrix3D.rotationMatrix(0,1,0,angle);
							m=Matrix3D.rotationX(g.target.angle-g.target.prevangle);
							break;
					case "y":
							//m=Matrix3D.rotationMatrix(0,1,0,angle);
							m=Matrix3D.rotationY(g.target.angle-g.target.prevangle);
							break;
							
					case "z":
							//m=Matrix3D.rotationMatrix(0,1,0,angle);
							m=Matrix3D.rotationZ(g.target.angle-g.target.prevangle);
							break;
					default: return; break;
				}
				g.target.cubelet.transform=Matrix3D.multiply(m,g.target.cubelet.transform);
				g.target.prevangle=g.target.angle;
			}			
		}
		
		public function setRubikColors(params:Object):void
		{
			if (rubik==null) return;
			if (rotation_in_progress) return;
			
			var colorsobj=params.colors;
			var faces:Array=null;
			var i,j;
			var cclone={front:colors.front, back:colors.back, top:colors.top, bottom:colors.bottom, left:colors.left, right:colors.right, inside:colors.inside};
			var cclone2={front:colors.front, back:colors.back, top:colors.top, bottom:colors.bottom, left:colors.left, right:colors.right, inside:colors.inside};
			var n:String,m:String;
			var allow:Boolean=true;
			
			// don't allow 2 identical colors on different faces
			for (n in colorsobj)
				cclone2[n] = colorsobj[n];
			for (n in cclone2)
			 for (m in cclone2)
				if (cclone2[n]==cclone2[m] && n!=m)
					allow=false;
			
			if (!allow) return;
			
			if (colorsobj!=null)
			{
				for (i=0;i<rubik.cubelets.length;i++)
				{
					if (colorsobj.top!=null)
					{
						faces=getFacesByColor(i,cclone.top);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.top;
						colors.top=colorsobj.top;
					}
					if (colorsobj.bottom!=null)
					{
						faces=getFacesByColor(i,cclone.bottom);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.bottom;
						colors.bottom=colorsobj.bottom;
					}
					if (colorsobj.left!=null)
					{
						faces=getFacesByColor(i,cclone.left);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.left;
						colors.left=colorsobj.left;
					}
					if (colorsobj.right!=null)
					{
						faces=getFacesByColor(i,cclone.right);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.right;
						colors.right=colorsobj.right;
					}
					if (colorsobj.front!=null)
					{
						faces=getFacesByColor(i,cclone.front);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.front;
						colors.front=colorsobj.front;
					}
					if (colorsobj.back!=null)
					{
						faces=getFacesByColor(i,cclone.back);
						for (j=0;j<faces.length;j++)
							if (faces[j].name!="inside")
								faces[j].fillColor=colorsobj.back;
						colors.back=colorsobj.back;
					}
					if (colorsobj.inside!=null)
					{
						faces=getFacesByName(i,"inside"); // this take by name so to avoid mixed ups
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.inside;
						colors.inside=colorsobj.inside;
					}
				}
				rubik.colors=colors;
				params.colors=cclone;
				addhistory({func:setRubikColors, param:params, actiontype:"setRubikColors"});
			}
		}
		
		/*
		public function setRubikColors(params:Object):void
		{
			if (rubik==null) return;
			if (rotation_in_progress) return;
			
			var colorsobj=params.colors;
			var faces:Array=null;
			var i,j;
			
			var cclone={front:colors.front, back:colors.back, top:colors.top, bottom:colors.bottom, left:colors.left, right:colors.right, inside:colors.inside};
			
			if (colorsobj!=null)
			{
				for (i=0;i<rubik.cubelets.length;i++)
				{
					if (colorsobj.top!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"top");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.top;
						colors.top=colorsobj.top;
					}
					if (colorsobj.bottom!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"bottom");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.bottom;
						colors.bottom=colorsobj.bottom;
					}
					if (colorsobj.left!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"left");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.left;
						colors.left=colorsobj.left;
					}
					if (colorsobj.right!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"right");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.right;
						colors.right=colorsobj.right;
					}
					if (colorsobj.front!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"front");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.front;
						colors.front=colorsobj.front;
					}
					if (colorsobj.back!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"back");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.back;
						colors.back=colorsobj.back;
					}
					if (colorsobj.inside!=null)
					{
						faces=getFacesByName(rubik.cubelets[i],"inside");
						for (j=0;j<faces.length;j++)
							faces[j].fillColor=colorsobj.inside;
						colors.inside=colorsobj.inside;
					}
				}
				rubik.colors=colors;
				if (!undo_in_action)
				{
					params.colors=cclone;
					undolist.push({func:setRubikColors, param:params, actiontype:"setRubikColors"});
				}
			}
		}
		*/
		public function getFlatImage(width:int=-1):Sprite
		{
			//ras.rb=this;
			return(ras.getFlatImage(width));
			
			var sp=new Sprite();
			if (rubik==null || rotation_in_progress) return(sp);
			var N=rubik.N;
			var w:int=15;
			var h:int=15;
			var ds:int=8;
			var fd:int=15;
			var fw:int=N*(w+ds);
			var fh:int=N*(h+ds);
			var sq:Sprite;
			var i:int,j:int;
			var a:int,b:int;
			var obj;
			if (width>0)
			{
				var dsp:Number=ds/w;
				w=width/(4+4*dsp+N);
				h=w;
				ds=w*dsp;
				fd=w;
				fw=N*(w+ds);
				fh=N*(h+ds);
			}
			
			a=fw+fd;
			b=0;
			// top
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("top",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			 
			a=0;
			b=fh+fd;
			// left
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("left",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			
			a=fw+fd;
			b=fh+fd;
			// front
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("front",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			
			a=2*(fw+fd);
			b=fh+fd;
			// right
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("right",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			
			a=3*(fw+fd);
			b=fh+fd;
			// back
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("back",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			
			a=fw+fd;
			b=2*(fh+fd);
			// bottom
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					obj=getFaceColorAndIndex("bottom",j,N-1-i);
					sq=makecolorsquare(obj.color,w,h);
					sq.x=i*(w+ds)+a;
					sq.y=j*(h+ds)+b;
					sq.name=obj.index;
					sq.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,flatfacedblclicked);
					sp.addChild(sq);
				}
			}
			return(sp);
			
			function makecolorsquare(c:int,w:int,h:int):Sprite
			{
				var sq=new Sprite();
				sq.graphics.beginFill(c); //white
				sq.graphics.lineStyle(0, c);
				sq.graphics.drawRoundRect(0, 0, w, h, 9);
				sq.graphics.endFill();
				sq.buttonMode=true;
				sq.doubleClickEnabled=true;
				return(sq);
			}
		}
		
		private function flatfacedblclicked(e:Event):void
		{
			//trace("double clicked");
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_DOUBLE_CLICK,(int)(e.target.name),{name:"flat",xx:0,yy:0,zz:0},{name:"flat",xx:0,yy:0,zz:0}));
		}
		
		/*private function getCol(ii:String,jj:String,kk:String):String
		{
			var o,i;
			var res:Array;
			var cubes=rubik.cubelets;
			var iin=0
			var jjn=0;
			var kkn=0;
			var colii=[];
			var coljj=[];
			var colkk=[];
			for (i=0;i<cubes.length;i++)
			{
				var obj=getCubeletFacesAsSeen(i);
				iin=0
				jjn=0;
				kkn=0;
				colii=[];
				coljj=[];
				colkk=[];
				
				for (o in obj.faceseenas)
				{
					if (obj.faceseenas[o]==ii)
					{
						iin++;
						colii.push(obj.seencolor[ii]);
					}
					if (obj.faceseenas[o]==jj)
					{
						jjn++;
						coljj.push(obj.seencolor[jj]);
					}
					if (obj.faceseenas[o]==kk)
					{
						kkn++;
						colkk.push(obj.seencolor[kk]);
					}
				}
				
				if (ii!='none' && jj!='none' && kk!='none')
				{
					if (iin==1 && jjn==1 && kkn==1)
					{
						break;
					}
				}
				else if (ii=='none' && jj!='none' && kk!='none')
				{
					if (iin==0 && jjn==1 && kkn==1)
					{
						break;
					}
				}
				else if (ii=='none' && jj=='none' && kk!='none')
				{
					if (iin==0 && jjn==0 && kkn==1)
					{
						break;
					}
				}
			}
			var answer:String="";
			if (iin==1)
			{
				if (colii[0]==colors.top) answer+="top,";
				if (colii[0]==colors.bottom) answer+="bottom,";
				if (colii[0]==colors.back) answer+="back,";
				if (colii[0]==colors.front) answer+="front,";
				if (colii[0]==colors.left) answer+="left,";
				if (colii[0]==colors.right) answer+="right,";
			}
			else if (iin==0) answer+="none,";			
			if (jjn==1)
			{
				if (coljj[0]==colors.top) answer+="top,";
				if (coljj[0]==colors.bottom) answer+="bottom,";
				if (coljj[0]==colors.back) answer+="back,";
				if (coljj[0]==colors.front) answer+="front,";
				if (coljj[0]==colors.left) answer+="left,";
				if (coljj[0]==colors.right) answer+="right,";
			}
			else if (jjn==0) answer+="none,";			
			if (kkn==1)
			{
				if (colkk[0]==colors.top) answer+="top";
				if (colkk[0]==colors.bottom) answer+="bottom";
				if (colkk[0]==colors.back) answer+="back";
				if (colkk[0]==colors.front) answer+="front";
				if (colkk[0]==colors.left) answer+="left";
				if (colkk[0]==colors.right) answer+="right";
			}
			else if (kkn==0) answer+="none";
			
			return(answer);			
		}*/
		
		public function getFaceColorAndIndex(seenface:String,ii:int,jj:int):Object
		{
			if (rubik==null || rotation_in_progress) return(NaN);
			
			var i:int;
			var res:Array;
			var cubes=rubik.cubelets;
			for (i=0;i<cubes.length;i++)
			{
				var obj=getCubeletFacesAsSeen(i);
				var cubeletseenas=getCubeletSeenCoords(i);
				
				if (obj.seencolor[seenface]!=null && obj.seencolor[seenface]!=undefined)
				{
					switch(seenface)
					{
						case "top":
										if (cubeletseenas.xx==jj && cubeletseenas.zz==ii)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
						case "bottom":
										if (cubeletseenas.xx==jj && cubeletseenas.zz==rubik.N-1-ii)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
						case "left":
										if (cubeletseenas.yy==rubik.N-1-ii && cubeletseenas.zz==rubik.N-1-jj)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
						case "right":
										if (cubeletseenas.yy==rubik.N-1-ii && cubeletseenas.zz==jj)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
						case "front":
										if (cubeletseenas.xx==jj && cubeletseenas.yy==rubik.N-1-ii)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
						case "back":
										if (cubeletseenas.xx==rubik.N-1-jj && cubeletseenas.yy==rubik.N-1-ii)
										return({color:obj.seencolor[seenface],index:rubik.faces.indexOf(obj.mat[seenface])});
										break;
					}
				}
			}
			return({});
		}
				
		/*public function setCubeletFaceColor(params:Object):void
		{
			if (rubik==null || rotation_in_progress) return;
			
			var c:Cube=rubik.cubelets[params.cubeletindex] as Cube;
			var f:String=params.face as String;
			var col:int=params.color;
			
			var faces:Array=c.geometry.faces;
			var mat:ColorMaterial=null;
			var face:Triangle3D=null;
			var matname:String="";
			var undocol:int;
			
			for (var i=0;i<faces.length;i=i+2) // skip second triangle
			{
				face=faces[i];
				mat=face.material as ColorMaterial;
				matname=mat.name;
				if (matname==f)
				{
					undocol=mat.fillColor;
					mat.fillColor=col;
				}
			}
			if (!undo_in_action)
			{
				params.color=undocol;
				undolist.push({func:setCubeletFaceColor, param:params, actiontype:"setCubeletFaceColor"});
			}
		}*/
		
		public function setCubeletFaceColor(params:Object):void
		{
			if (rubik==null || rotation_in_progress) return;
			
			var col:int=params.color;
			var mat:ColorMaterial=rubik.faces[params.faceindex] as ColorMaterial;
			var undocol:int=mat.fillColor;
			
			mat.fillColor=col;
			
			params.color=undocol;
			addhistory({func:setCubeletFaceColor, param:params, actiontype:"setCubeletFaceColor"});
		}
		
		public function getCubeletFacesAsSeen(cubeletindex:int) : Object
		{
			if (rubik==null || rotation_in_progress) return(null);
			
			var c:Cube=rubik.cubelets[cubeletindex];
			var faces:Array=c.geometry.faces;
			var m:Matrix3D=c.transform;
			var n:Number3D=null;
			var mat:ColorMaterial=null;
			var face:Triangle3D=null;
			var matname:String="";
			var r1:Array=[],r2:Array=[],r3=[],r4=[];
			for (var i=0;i<faces.length;i=i+2) // skip second triangle
			{
				face=faces[i];
				n=face.faceNormal.clone(); 	// get face normal
				Matrix3D.multiplyVector3x3( m, n ); // compute transformed normal of face (as seen)
				mat=face.material as ColorMaterial;
				matname=mat.name;
				if (matname.toLowerCase()=="inside")
				{
					/*continue*/;
					r1["inside"]=mat.fillColor;
					r2[matname]="inside";
					r3["inside"]=matname;
					r4["inside"]=mat;
				}
				else
				{
				if (eq(n,new Number3D(0,1,0))) // face seen as top
				{
					r1["top"]=mat.fillColor;
					r2[matname]="top";
					r3["top"]=matname;
					r4["top"]=mat;
				}
				if (eq(n,new Number3D(0,-1,0))) // face seen as bottom
				{
					r1["bottom"]=mat.fillColor;
					r2[matname]="bottom";
					r3["bottom"]=matname;
					r4["bottom"]=mat;
				}
				if (eq(n,new Number3D(0,0,1))) // face seen as front
				{
					r1["front"]=mat.fillColor;
					r2[matname]="front";
					r3["front"]=matname;
					r4["front"]=mat;
				}
				if (eq(n,new Number3D(0,0,-1))) // face seen as back
				{
					r1["back"]=mat.fillColor;
					r2[matname]="back";
					r3["back"]=matname;
					r4["back"]=mat;
				}
			// take left-right opposite due to papervision 3d left-right definition on cube etc..??
				if (eq(n,new Number3D(1,0,0))) // face seen as right
				{
					r1["left"]=mat.fillColor;
					r2[matname]="left";
					r3["left"]=matname;
					r4["left"]=mat;
				}
				if (eq(n,new Number3D(-1,0,0))) // face seen as left
				{
					r1["right"]=mat.fillColor;
					r2[matname]="right";
					r3["right"]=matname;
					r4["right"]=mat;
				}
				}
			}
			return({seencolor:r1, faceseenas:r2, invfaceseenas:r3, mat:r4});
			
			function eq(a:Number3D,b:Number3D) : Boolean
			{
				var delta:Number=0;
				var aa=new Number3D(Math.round(a.x),Math.round(a.y),Math.round(a.z));
				var bb=new Number3D(Math.round(b.x),Math.round(b.y),Math.round(b.z));
				
				if (Math.abs(aa.x-bb.x)<=delta && Math.abs(aa.y-bb.y)<=delta && Math.abs(aa.z-bb.z)<=delta)
					return(true);
				return(false);
			}
		}
		
		/*public function mysolve():void
		{
			var algorithm_table:Array;
			var ord:Array=['top','left','front','right','back','bottom','none'];
			var path:Array=[];
			var next=0;
			var epoch=0;
			var i,j,k,newi,newj,newk;
			var done:Boolean;
			done=false;
			while (!done)
			{
				done=true;
				epoch++;
				trace(epoch+" epoch Started..");
				i=0;
				var moves=0;
				while (++moves<=54 && i<=6)
				{
					//moves++;
					trace(moves);
					if (ord[i]!='none' && ord[j]=='none') j=(j+1) % ord.length;
					if (ord[i]=='top' && ord[j]=='bottom') j=(j+1) % ord.length;
					if (ord[i]=='left' && ord[j]=='right') j=(j+1) % ord.length;
					if (ord[i]=='front' && ord[j]=='back') j=(j+1) % ord.length;
					if (ord[j]=='top' && ord[k]=='bottom') k=(k+1) % ord.length-1;
					if (ord[j]=='left' && ord[k]=='right') k=(k+1) % ord.length-1;
					if (ord[j]=='front' && ord[k]=='back') k=(k+1) % ord.length-1;
					if (ord[i]==ord[j])  j=(j+1) % ord.length;
					if (ord[j]==ord[k]) k=(k+1) % ord.length-1;
					
					col=getCol(ord[i],ord[j],ord[k]);
					var pos=ord[i]+","+ord[j]+","+ord[k];
					trace(pos);
					if (col==pos)
					{
						if (k==5)
						{
							if ((j==6 && i==6) || (i<6 && j==5))
							{
								i++;
								j=(i+1)%ord.length;
							}
							else 
							{
								j=(j+1)%ord.length;
							}
							k=(j+1)%ord.length-1;
						}
						else
							k=(k+1)%ord.length-1;
					}
					else
					{
						done=false;
						var fa=col.split(",");
						newi=ord.indexOf(fa[0]);
						newj=ord.indexOf(fa[1]);
						newk=ord.indexOf(fa[2]);
						if (!checkijk(newi,newj,newk)) 
						{
							trace("Cube not colored properly");
							done=true;
							i=7;
						}
						else
						{
						 doRotation(i,j,k);
						 i=newi;
						 j=newj;
						 k=newk;
						}
					}
				}
				trace(epoch+" epoch Ended.");
			}
		}*/
		
		public function getCubletsIndex(axis:String, row:uint) : Array
		{
			if (rubik==null) return([]);
			if (rotation_in_progress) return([]);
			
			var a:Array=[], b:Array, result:Array=[];
			
			if (row<0 || row>=rubik.N) return([]);
			
			axis=axis.charAt(0);
			axis=axis.toLowerCase();
			
			for (var i=0;i<rubik.cubelets.length;i++)
			{
				switch(axis)
				{
				case "y":
						a[i]=rubik.cubelets[i].y;
						break;
				case "x":
						a[i]=rubik.cubelets[i].x;
						break;
				case "z":
						a[i]=rubik.cubelets[i].z;
						break;
				default:return(null); break;
				}
			}
			
			b=a.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
			for (i=0;i<rubik.N*rubik.N;i++)
				result[i]=b[row*rubik.N*rubik.N+i];
			return(result);
		}
		
		public function setRotation(params:Object) : void
		{
			if (rubik==null || rotation_in_progress) return;
			
			var axis=params.axis;
			var angle:int=params.angle;
			var row:int=params.row;
			
			if (angle==0) return;
			var ind=getCubletsIndex(axis,row);
			if (ind==null) return; 			
			
			var rangle:Number=angle*RA;
			
			axis=axis.charAt(0);
			axis=axis.toLowerCase();
			
			var m:Matrix3D=null;
			m=null;
			switch(axis)
			{
				case "x":
						//m=Matrix3D.rotationMatrix(0,1,0,angle);
						m=Matrix3D.rotationX(rangle);
						break;
				case "y":
						//m=Matrix3D.rotationMatrix(0,1,0,angle);
						m=Matrix3D.rotationY(rangle);
						break;
						
				case "z":
						//m=Matrix3D.rotationMatrix(0,1,0,angle);
						m=Matrix3D.rotationZ(rangle);
						break;
				default: return; break;
			}
			
			for (var k=0;k<ind.length;k++)
			{
				var target=rubik.cubelets[ind[k]];
				target.transform=Matrix3D.multiply(m,target.transform);
			}
			switch(axis)
			{
			 case 'y':
				switch(row)
				{
					case 0:
						switch(angle)
						{
						 case 1: ras.rbs3.DR();
								break;
						 case -1:ras.rbs3.DL();
								break;
						}
						break;
					case 1:
						switch(angle)
						{
						 case 1: ras.rbs3.MR();
								break;
						 case -1:ras.rbs3.ML();
								break;
						}
						break;
					case 2:
						switch(angle)
						{
						 case 1: ras.rbs3.UR();
								break;
						 case -1:ras.rbs3.UL();
								break;
						}
						break;
				}
				break;
			 case 'x':
				switch(row)
				{
					case 0:
						switch(angle)
						{
						 case 1: ras.rbs3.RD();
								break;
						 case -1:ras.rbs3.RU();
								break;
						}
						break;
					case 1:
						switch(angle)
						{
						 case 1: ras.rbs3.MD();
								break;
						 case -1:ras.rbs3.MU();
								break;
						}
						break;
					case 2:
						switch(angle)
						{
						 case 1: ras.rbs3.LD();
								break;
						 case -1:ras.rbs3.LU();
								break;
						}
						break;
				}
				break;
			 case 'z':
				switch(row)
				{
					case 0:
						switch(angle)
						{
						 case 1: ras.rbs3.BC();
								break;
						 case -1:ras.rbs3.BA();
								break;
						}
						break;
					case 1:
						switch(angle)
						{
						 case 1: ras.rbs3.MC();
								break;
						 case -1:ras.rbs3.MA();
								break;
						}
						break;
					case 2:
						switch(angle)
						{
						 case 1: ras.rbs3.FC();
								break;
						 case -1:ras.rbs3.FA();
								break;
						}
						break;
				}
				break;
			}
			params.angle=-angle;
			params.duration=2;
			addhistory({func:rotate, param:params, actiontype:"setRotation"});
			return;		
		}
		
		public function scramble(nsteps:int=-1):void
		{
			if (rotation_in_progress) return;
			
			var axes:Array=["x", "y", "z"];
			var angles:Array=[-1, 1];
			var N:uint=rubik.N;
			var k:int=0;
			
			if (nsteps<=0) nsteps=intRandRange(1,100);
			
			for (k=0; k<nsteps; k++)
			{
				var axis=axes[intRandRange(0,2)];
				var row=intRandRange(0,N-1);
				var angle=angles[intRandRange(0,3)];
				setRotation({axis:axis,row:row,angle:angle});
			}
			return;
			
			function intRandRange(a,b) : int
			{
				return(Math.round(Math.random()*(b-a)+a));
			}
		}
		
		public function destroy():void
		{
			destroyRubik();
			return;
		}
		
		public function setCameraRot(axis:String="x", angle:Number=0):String
		{
			var look:String="";
			angle=angle % (2*Math.PI);
			if (angle>Math.PI) angle=angle-2*Math.PI;
			if (angle<-Math.PI) angle=angle+2*Math.PI;
			axis=axis.charAt(0);
			axis=axis.toLowerCase();
			// take left-right opposite due to papervision 3d left-right definition on cube etc..??
			switch(axis)
			{
			case "x":
					camera.y=Math.sin(angle) * rad;
					camera.z=Math.cos(angle) * rad;
					if (inrange(angle,-Math.PI/4,Math.PI/4) || angle==Math.PI/4)
						look="front";
					if (inrange(angle,-3*Math.PI/4,-Math.PI/4) || angle==-Math.PI/4)
						look="bottom";
					if (inrange(angle,3*Math.PI/4,5*Math.PI/4) || inrange(angle,-5*Math.PI/4,-3*Math.PI/4)  || angle==-Math.PI/4 || angle==5*Math.PI/4)
						look="back";
					if (inrange(angle,Math.PI/4,3*Math.PI/4) || angle==3*Math.PI/4)
						look="top";
					break;
			case "y":
					camera.x=Math.sin(angle) * rad;
					camera.z=Math.cos(angle) * rad;
					if (inrange(angle,-Math.PI/4,Math.PI/4) || angle==Math.PI/4)
						look="front";
					if (inrange(angle,-3*Math.PI/4,-Math.PI/4) || angle==-Math.PI/4)
						look="right";
					if (inrange(angle,3*Math.PI/4,5*Math.PI/4) || inrange(angle,-5*Math.PI/4,-3*Math.PI/4)  || angle==-Math.PI/4 || angle==5*Math.PI/4)
						look="back";
					if (inrange(angle,Math.PI/4,3*Math.PI/4) || angle==3*Math.PI/4)
						look="left";
					break;
			case "z":
					camera.x=Math.sin(angle) * rad;
					camera.y=Math.cos(angle) * rad;
					break;
			}
			return(look);
			
			function inrange(t:Number,a:Number,b:Number):Boolean
			{
				if (t>a && t<b) return(true);
				return(false);
			}
		}
		
		//---------------------------------------------------------------------------------------------
		//   PRIVATE FUNCTIONS
		//---------------------------------------------------------------------------------------------
				
		private function addhistory(actionobj:Object):void
		{
			if (!undo_in_action)
			{
				while (undolist.length>=undolist_length) {var foo:Object=undolist.shift();}
				undolist.push(actionobj);
			}
		}
		
		private function getFacesByColor(cubeletindex:int,col:int):Array
		{
			if (rubik==null) return([]);
			var c:Cube=rubik.cubelets[cubeletindex] as Cube;
			var result:Array=[];
			var faces:Array=c.geometry.faces;
			var mat:ColorMaterial=null;
			
			for (var i=0;i<faces.length;i=i+2) // skip second triangle
			{
				mat=faces[i].material as ColorMaterial;
				if (mat.fillColor==col)
				{
					result.push(mat);
				}
			}
			return(result);
		}
		
		private function getFacesByName(cubeletindex:int,f:String):Array
		{
			if (rubik==null) return([]);
			
			var result:Array=[];
			var c:Cube=rubik.cubelets[cubeletindex] as Cube;
			var faces:Array=c.geometry.faces;
			var mat:ColorMaterial=null;
			
			for (var i=0;i<faces.length;i=i+2) // skip second triangle
			{
				mat=faces[i].material as ColorMaterial;
				if (mat.name==f)
				{
					result.push(mat);
				}
			}
			return(result);
		}
		
		private function getCubeletSeenCoords(cubeletindex:int):Object
		{
			if (rubik==null || rotation_in_progress) return(null);
			var c:Cube=rubik.cubelets[cubeletindex] as Cube;
			var cubeletseenas={xx:Math.round((c.x+rubik.side/2-rubik.cubeletside/2)/(rubik.cubeletside*(1+rubik.dsp))),
								yy:Math.round((c.y+rubik.side/2-rubik.cubeletside/2)/(rubik.cubeletside*(1+rubik.dsp))),
								zz:Math.round((c.z+rubik.side/2-rubik.cubeletside/2)/(rubik.cubeletside*(1+rubik.dsp)))};
			return(cubeletseenas);
		}
		
		private function destroyRubik():void
		{
			if (rubik==null) return;
			var cub:Cube = null;
			for (var i=0; i<rubik.cubelets.length;i++)
			{
				
				cub=rubik.cubelets[i];
				cub.removeEventListener(InteractiveScene3DEvent.OBJECT_CLICK,cubeletclicked);
				cub.removeEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK,cubeletdblclicked);
				//cub.removeEventListener(InteractiveScene3DEvent.OBJECT_OVER,cubeletover);
				//cub.removeEventListener(InteractiveScene3DEvent.OBJECT_OUT,cubeletout);
				scene.removeChild(cub);
				cub.materials.getMaterialByName("top").destroy();
				cub.materials.getMaterialByName("bottom").destroy();
				cub.materials.getMaterialByName("front").destroy();
				cub.materials.getMaterialByName("back").destroy();
				cub.materials.getMaterialByName("left").destroy();
				cub.materials.getMaterialByName("right").destroy();
				cub.material.destroy();
				cub.destroy();
				rubik.cubelets[i]=null;
				cub=null;
			}
			stopRendering();
			viewport.destroy();
			viewport=null;
			rubik=null;
			return;
		}
		
		private function show():void
		{
			if (rubik!=null)
			{
				for (var i=0;i<rubik.cubelets.length;i++)
					scene.addChild(rubik.cubelets[i] as Cube);			
				startRendering();
			}
		}
		
		private function createRubik(N,side,dsp,colors) : Object
        {
            var cubelets = [], faces=[] ;
            var xx,yy,zz;
			//var dsp=0.3;
			var Nz=N,Nx=N,Ny=N;
			var sidex=side, sidey=side, sidez=side;
			var cubletsidex=sidex/(Nx+(Nx-1)*dsp);
			var cubletsidey=sidey/(Ny+(Ny-1)*dsp);
			var cubletsidez=sidez/(Nz+(Nz-1)*dsp);
			var cm:ColorMaterial=null;
			
			Papervision3D.useRIGHTHANDED=false;
			Papervision3D.useDEGREES=false;
			
			// build cublets
			for (zz=0;zz<Nz;zz++)
			{
				for (xx=0;xx<Nx;xx++)
				{
					for (yy=0;yy<Ny;yy++)
					{						
						var materialsList = new MaterialsList();
						// color internal faces not interactive, alpha=1 (start with all..)
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "bottom");
						faces.push(cm);
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "top");
						faces.push(cm);
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "left");
						faces.push(cm);
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "right");
						faces.push(cm);
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "front");
						faces.push(cm);
						cm=new ColorMaterial(colors.inside,1,false);
						cm.name="inside";
						materialsList.addMaterial(cm, "back");
						faces.push(cm);
						
						// color external faces interactive, alpha=1
						if (yy==0)
						{
							cm=materialsList.getMaterialByName("bottom");
							cm.name="bottom";
							cm.interactive=true;
							cm.fillColor=colors.bottom;
						}
						if (yy==Ny-1)
						{
							cm=materialsList.getMaterialByName("top");
							cm.name="top";
							cm.interactive=true;
							cm.fillColor=colors.top;
						}
						// take left-right opposite due to papervision 3d left-right definition on cube etc..??
						if (xx==Nx-1)
						{
							cm=materialsList.getMaterialByName("right");
							cm.name="left";
							cm.interactive=true;
							cm.fillColor=colors.left;
						}
						if (xx==0)
						{
							cm=materialsList.getMaterialByName("left");
							cm.name="right";
							cm.interactive=true;
							cm.fillColor=colors.right;
						}
						if (zz==Nz-1)
						{
							cm=materialsList.getMaterialByName("front");
							cm.name="front";
							cm.interactive=true;
							cm.fillColor=colors.front;
						}
						if (zz==0)
						{
							cm=materialsList.getMaterialByName("back");
							cm.name="back";
							cm.interactive=true;
							cm.fillColor=colors.back;
						}
						
						// new cublet
						var cubelet = new Cube(materialsList, cubletsidex,cubletsidez,cubletsidey);
						
						// position it centered
						cubelet.x = (cubletsidex+dsp*cubletsidex)*xx -sidex/2 +cubletsidex/2;
						cubelet.y = (cubletsidey+dsp*cubletsidey)*yy -sidey/2 +cubletsidey/2;
						cubelet.z = ((cubletsidez+dsp*cubletsidez)*zz -sidez/2 +cubletsidez/2);
						cubelet.extra={xx:xx,yy:yy,zz:zz,transform:cubelet.transform};
						
						// add click event listener
						cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK,cubeletclicked); // works
						cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK,cubeletdblclicked); // works
						cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS,cubeletpressed); // works
						cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE,cubeletreleased); // works
						cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE,cubeletmove); // works
						//cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_OVER,cubeletover); // works
						//cubelet.addEventListener(InteractiveScene3DEvent.OBJECT_OUT,cubeletout); // works
						// add it to list along with info about its relative position in RubikCube
						cubelets.push(cubelet);
					}
				}
			}
            return( {N:N, colors:colors, cubelets:cubelets, faces:faces, side:sidex, cubeletside:cubletsidex, dsp:dsp} );
        } // end function
		
		private function cubeletout(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_OUT, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_OUT,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
		
		private function cubeletover(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_OVER, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_OVER,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
		
		private function cubeletclicked(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_CLICK, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_CLICK,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
		
		private function cubeletmove(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var ray:Number3D = camera.unproject(/*viewport.containerSprite.mouseX*/this.mouseX, /*viewport.containerSprite.mouseY*/this.mouseY);
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			//var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			//var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.MOUSE_MOVE, targetcubelet, /*cubeletorig*/{ray:ray}, /*cubeletseenas*/{ray:ray}));
		}
		
		private function cubeletpressed(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_PRESS, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_PRESS,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
		
		private function cubeletreleased(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_RELEASE, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_PRESS,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
		
		private function cubeletdblclicked(e:InteractiveScene3DEvent):void
		{
			if (rubik==null || rotation_in_progress) return;
			var cub=e.renderHitData.displayObject3D;
			var targetcubelet=rubik.cubelets.indexOf(cub);
			var mat=e.renderHitData.material as ColorMaterial;
			var targetface=rubik.faces.indexOf(mat);
			var cubeletorig={xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz};
			var cubeletseenas=getCubeletSeenCoords(targetcubelet);
			var f:Object=getCubeletFacesAsSeen(targetcubelet);
			this.dispatchEvent(new RubikEvent(RubikEvent.CUBELET_DOUBLE_CLICK, targetcubelet, {name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));
			this.dispatchEvent(new RubikEvent(RubikEvent.FACE_DOUBLE_CLICK,targetface,{name:mat.name,xx:cub.extra.xx,yy:cub.extra.yy,zz:cub.extra.zz},{name:f.faceseenas[mat.name],xx:cubeletseenas.xx,yy:cubeletseenas.yy,zz:cubeletseenas.zz}));			
		}
    } // end class
}  // end package
