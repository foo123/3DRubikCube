package rubikcube
{
	import flash.display.*;
	// code adapted from C++ Cube Solver by Eric Dietz 2003-2005
    public class RubikSolver3x3x3 //  extends MovieClip
    {
		private static const N=3;
		private static const MOV=8;
		
		private var cub:Array=[
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ]
								];
		private var temp:Array=[
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ]
								];
		private var cubeinit:Boolean=false;
		private var mov:Array=new Array(MOV+1);
		private var fx:int,fy:int,fz:int;
		
		public var erval:int=0;
		public var errin:int=0;
		public var solution:String="";
		public var shorten:Boolean=false;
		public var localshorten:Boolean=false;
		public var centerfix:Boolean=true;
		public var ttt;
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		public function RubikSolver3x3x3(cubeobj:Object=null)
		{
			if (cubeobj!=null)
				cubedata=cubeobj;
		}
		
		public function set cubedata(cubed:Object):void
		{
			if (cubed!=null)
				insertCube(cubed);
		}
				
		public function renderText():String
		{
			var txtout="";
			if (errin>0) return('Not Correct input format!');
			
			txtout="\t\t\t\t"+cub[-1+2][2+2][1+2]+" "+cub[0+2][2+2][1+2]+" "+cub[1+2][2+2][1+2]+"\n";
			txtout+="\t\t\t\t"+cub[-1+2][2+2][0+2]+" "+cub[0+2][2+2][0+2]+" "+cub[1+2][2+2][0+2]+"\n";
			txtout+="\t\t\t\t"+cub[-1+2][2+2][-1+2]+" "+cub[0+2][2+2][-1+2]+" "+cub[1+2][2+2][-1+2]+"\n\n";
			
			txtout+=cub[-2+2][1+2][1+2]+" "+cub[-2+2][1+2][0+2]+" "+cub[-2+2][1+2][-1+2]+"\t\t";
			txtout+=cub[-1+2][1+2][-2+2]+" "+cub[0+2][1+2][-2+2]+" "+cub[1+2][1+2][-2+2]+"\t\t";
			txtout+=cub[2+2][1+2][-1+2]+" "+cub[2+2][1+2][0+2]+" "+cub[2+2][1+2][1+2]+"\t\t";
			txtout+=cub[1+2][1+2][2+2]+" "+cub[0+2][1+2][2+2]+" "+cub[-1+2][1+2][2+2]+"\n";
			
			txtout+=cub[-2+2][0+2][1+2]+" "+cub[-2+2][0+2][0+2]+" "+cub[-2+2][0+2][-1+2]+"\t\t";
			txtout+=cub[-1+2][0+2][-2+2]+" "+cub[0+2][0+2][-2+2]+" "+cub[1+2][0+2][-2+2]+"\t\t";
			txtout+=cub[2+2][0+2][-1+2]+" "+cub[2+2][0+2][0+2]+" "+cub[2+2][0+2][1+2]+"\t\t";
			txtout+=cub[1+2][0+2][2+2]+" "+cub[0+2][0+2][2+2]+" "+cub[-1+2][0+2][2+2]+"\n";
			
			txtout+=cub[-2+2][-1+2][1+2]+" "+cub[-2+2][-1+2][0+2]+" "+cub[-2+2][-1+2][-1+2]+"\t\t";
			txtout+=cub[-1+2][-1+2][-2+2]+" "+cub[0+2][-1+2][-2+2]+" "+cub[1+2][-1+2][-2+2]+"\t\t";
			txtout+=cub[2+2][-1+2][-1+2]+" "+cub[2+2][-1+2][0+2]+" "+cub[2+2][-1+2][1+2]+"\t\t";
			txtout+=cub[1+2][-1+2][2+2]+" "+cub[0+2][-1+2][2+2]+" "+cub[-1+2][-1+2][2+2]+"\n\n";
			
			txtout+="\t\t\t\t"+cub[-1+2][-2+2][-1+2]+" "+cub[0+2][-2+2][-1+2]+" "+cub[1+2][-2+2][-1+2]+"\n";
			txtout+="\t\t\t\t"+cub[-1+2][-2+2][0+2]+" "+cub[0+2][-2+2][0+2]+" "+cub[1+2][-2+2][0+2]+"\n";
			txtout+="\t\t\t\t"+cub[-1+2][-2+2][1+2]+" "+cub[0+2][-2+2][1+2]+" "+cub[1+2][-2+2][1+2]+"\n";
			
			return(txtout);
		}
		
		public function getFlatImage(width:int=-1):Sprite
		{
			var colors={'c1':0xFF00FF,'c6':0x00FF00,'c3':0xFFFF00,'c5':0x0000FF,'c2':0xFF0000,'c4':0x00FFFF}; // mutually complementary
			if (errin>0) return(new Sprite());
			var sp=new Sprite();
			var w:int=15;
			var h:int=15;
			var ds:int=8;
			var fd:int=15;
			var fw:int=3*(w+ds);
			var fh:int=3*(h+ds);
			var sq:Sprite;
			var i:int,j:int;
			var a:int,b:int;
			var obj;
			if (width>0)
			{
				var dsp:Number=ds/w;
				w=width/(4+4*dsp+3);
				h=w;
				ds=w*dsp;
				fd=w;
				fw=3*(w+ds);
				fh=3*(h+ds);
			}
			
			a=fw+fd;
			b=0;
			// top
			trace(cub[-1+2][2+2][1+2]);
			//txtout="\t\t\t\t"+cub[-1+2][2+2][1+2]+" "+cub[0+2][2+2][1+2]+" "+cub[1+2][2+2][1+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][2+2][1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][2+2][1+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][2+2][1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+="\t\t\t\t"+cub[-1+2][2+2][0+2]+" "+cub[0+2][2+2][0+2]+" "+cub[1+2][2+2][0+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][2+2][0+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][2+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][2+2][0+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+="\t\t\t\t"+cub[-1+2][2+2][-1+2]+" "+cub[0+2][2+2][-1+2]+" "+cub[1+2][2+2][-1+2]+"\n\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][2+2][-1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][2+2][-1+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][2+2][-1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			a=0;
			b=fh+fd;
			// left
			//txtout+=cub[-2+2][1+2][1+2]+" "+cub[-2+2][1+2][0+2]+" "+cub[-2+2][1+2][-1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-2+2][1+2][1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[-2+2][1+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-2+2][1+2][-1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[-2+2][0+2][1+2]+" "+cub[-2+2][0+2][0+2]+" "+cub[-2+2][0+2][-1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-2+2][0+2][1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[-2+2][0+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-2+2][0+2][-1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			//txtout+=cub[-2+2][-1+2][1+2]+" "+cub[-2+2][-1+2][0+2]+" "+cub[-2+2][-1+2][-1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-2+2][-1+2][1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[-2+2][-1+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-2+2][-1+2][-1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			a=fw+fd;
			b=fh+fd;
			// front
			//txtout+=cub[-1+2][1+2][-2+2]+" "+cub[0+2][1+2][-2+2]+" "+cub[1+2][1+2][-2+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-1+2][1+2][-2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][1+2][-2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][1+2][-2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[-1+2][0+2][-2+2]+" "+cub[0+2][0+2][-2+2]+" "+cub[1+2][0+2][-2+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-1+2][0+2][-2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][0+2][-2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][0+2][-2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[-1+2][-1+2][-2+2]+" "+cub[0+2][-1+2][-2+2]+" "+cub[1+2][-1+2][-2+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[-1+2][-1+2][-2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][-1+2][-2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][-1+2][-2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			a=2*(fw+fd);
			b=fh+fd;
			// right
			//txtout+=cub[2+2][1+2][-1+2]+" "+cub[2+2][1+2][0+2]+" "+cub[2+2][1+2][1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[2+2][1+2][-1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[2+2][1+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[2+2][1+2][1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[2+2][0+2][-1+2]+" "+cub[2+2][0+2][0+2]+" "+cub[2+2][0+2][1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[2+2][0+2][-1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[2+2][0+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[2+2][0+2][1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[2+2][-1+2][-1+2]+" "+cub[2+2][-1+2][0+2]+" "+cub[2+2][-1+2][1+2]+"\t\t";
			sq=makecolorsquare(colors['c'+cub[2+2][-1+2][-1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[2+2][-1+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[2+2][-1+2][1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			a=3*(fw+fd);
			b=fh+fd;
			// back
			//txtout+=cub[1+2][1+2][2+2]+" "+cub[0+2][1+2][2+2]+" "+cub[-1+2][1+2][2+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[1+2][1+2][2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][1+2][2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-1+2][1+2][2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[1+2][0+2][2+2]+" "+cub[0+2][0+2][2+2]+" "+cub[-1+2][0+2][2+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[1+2][0+2][2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][0+2][2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-1+2][0+2][2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+=cub[1+2][-1+2][2+2]+" "+cub[0+2][-1+2][2+2]+" "+cub[-1+2][-1+2][2+2]+"\n\n";
			sq=makecolorsquare(colors['c'+cub[1+2][-1+2][2+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][-1+2][2+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[-1+2][-1+2][2+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			a=fw+fd;
			b=2*(fh+fd);
			// bottom
			//txtout+="\t\t\t\t"+cub[-1+2][-2+2][-1+2]+" "+cub[0+2][-2+2][-1+2]+" "+cub[1+2][-2+2][-1+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][-2+2][-1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][-2+2][-1+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][-2+2][-1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=0*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+="\t\t\t\t"+cub[-1+2][-2+2][0+2]+" "+cub[0+2][-2+2][0+2]+" "+cub[1+2][-2+2][0+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][-2+2][0+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][-2+2][0+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][-2+2][0+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=1*(h+ds)+b;
			sp.addChild(sq);
			
			//txtout+="\t\t\t\t"+cub[-1+2][-2+2][1+2]+" "+cub[0+2][-2+2][1+2]+" "+cub[1+2][-2+2][1+2]+"\n";
			sq=makecolorsquare(colors['c'+cub[-1+2][-2+2][1+2]],w,h);
			sq.x=0*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
	 
			sq=makecolorsquare(colors['c'+cub[0+2][-2+2][1+2]],w,h);
			sq.x=1*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
			sq=makecolorsquare(colors['c'+cub[1+2][-2+2][1+2]],w,h);
			sq.x=2*(w+ds)+a;
			sq.y=2*(h+ds)+b;
			sp.addChild(sq);
			
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
		
		private function faces(cub1:Array):Array
		{
			var i,j;
			var fac:Array=[ [], [], [], [], [], [], [] ];
			  for (i=0;i<fac.length;i++)
			  for (j=0;j<2;j++)
				fac[i][j]=0;
			var cub2:Array=cp(cub1);	
			  // interpolate the cube...
			  fac[0][0] = 0;
			  fac[1][0] = cub1[0+2][2+2][0+2]; fac[2][0] = cub1[0+2][0+2][-2+2];
			  fac[3][0] = cub1[-2+2][0+2][0+2]; fac[4][0] = cub1[0+2][0+2][2+2];
			  fac[5][0] = cub1[2+2][0+2][0+2]; fac[6][0] = cub1[0+2][-2+2][0+2];
			  for (i = 0; i <= 6; i++) {
				fac[fac[i][0]][1] = i;
			  }
			  // apply interpolation
			  for (i = -1; i <= 1; i++) {
				for (j = -1; j <= 1; j++) {
				  cub2[i+2][2+2][j+2] = fac[cub2[i+2][2+2][j+2]][1];
				  cub2[i+2][j+2][-2+2] = fac[cub2[i+2][j+2][-2+2]][1];
				  cub2[-2+2][i+2][j+2] = fac[cub2[-2+2][i+2][j+2]][1];
				  cub2[i+2][j+2][2+2] = fac[cub2[i+2][j+2][2+2]][1];
				  cub2[2+2][i+2][j+2] = fac[cub2[2+2][i+2][j+2]][1];
				  cub2[i+2][-2+2][j+2] = fac[cub2[i+2][-2+2][j+2]][1];
				}
			  }
			  return(cub2);
		}
		
		private function buffer(cub1:Array):Array
		{
			var i,j,k;
			var rub:Array=[
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ]
							];
			  //resetCube(rub);
			  // buffer the cube so we can interpolate it to a specific color arrangement to check for edges and corners...
			  for (i = -2; i <= 2; i++) {
				for (j = -2; j <= 2; j++) {
				  for (k = -2; k <= 2; k++) {
					rub[i+2][j+2][k+2] = cub1[i+2][j+2][k+2];
				  }
				}
			  }
			  return(rub);
		}
		
		public function solve():int
		{
			var rub:Array=[
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ],
							[ [], [], [], [], [] ]
							];
			var mvs:Array=new Array(MOV+1);
			var fac:Array=[ [], [], [], [], [], [], [] ];
			var m:int=-1,n:int;
			var s:String="",t:String="",p:String="";
			var i:int,j:int,k:int,q:int;
			
  // make sure cube was initialized
  if (!cubeinit) return 1;
  // make sure that the cube has the proper cubelets...
  cubeinit = false;
  // check that all the centers are present
  for (i = 1; i <= 6; i++) {
    if (findcenter(i) == 0) {
      erval = 1; return erval;
    }
  }
  // buffer the cube so we can interpolate it to a specific color arrangement to check for edges and corners...
  for (i = -2; i <= 2; i++) {
    for (j = -2; j <= 2; j++) {
      for (k = -2; k <= 2; k++) {
        rub[i+2][j+2][k+2] = cub[i+2][j+2][k+2];
      }
    }
  }
  //rub=buffer(cub);
  
  // interpolate the cube...
  fac[0][0] = 0;
  fac[1][0] = cub[0+2][2+2][0+2]; fac[2][0] = cub[0+2][0+2][-2+2];
  fac[3][0] = cub[-2+2][0+2][0+2]; fac[4][0] = cub[0+2][0+2][2+2];
  fac[5][0] = cub[2+2][0+2][0+2]; fac[6][0] = cub[0+2][-2+2][0+2];
  for (i = 0; i <= 6; i++) {
    fac[fac[i][0]][1] = i;
  }
  // apply interpolation
  for (i = -1; i <= 1; i++) {
    for (j = -1; j <= 1; j++) {
      cub[i+2][2+2][j+2] = fac[cub[i+2][2+2][j+2]][1];
      cub[i+2][j+2][-2+2] = fac[cub[i+2][j+2][-2+2]][1];
      cub[-2+2][i+2][j+2] = fac[cub[-2+2][i+2][j+2]][1];
      cub[i+2][j+2][2+2] = fac[cub[i+2][j+2][2+2]][1];
      cub[2+2][i+2][j+2] = fac[cub[2+2][i+2][j+2]][1];
      cub[i+2][-2+2][j+2] = fac[cub[i+2][-2+2][j+2]][1];
    }
  }
  
  //var cub2=buffer(cub);
  //cub=faces(cub);
  // check that all edges and corners are present
  for (i = 1; i <= 4; i++) {
    j = 1;
    if (i < 4) j = i + 1;
    if (findedge(1, i + 1) == 0 ||
     findedge(6, i + 1) == 0 ||
     findedge(i + 1, j + 1) == 0 ||
     findcorner(1, i + 1, j + 1) == 0 ||
     findcorner(6, i + 1, j + 1) == 0) {
      m = 0;
    }
  }
  
  // return cube to pre-interpolated status
  for (i = -2; i <= 2; i++) {
    for (j = -2; j <= 2; j++) {
      for (k = -2; k <= 2; k++) {
        cub[i+2][j+2][k+2] = rub[i+2][j+2][k+2];
      }
    }
  }
  //cub=buffer(rub);
  
  // if any flags went off during checking then return error 1 (improper cubelets)
  if (m == 0) { erval = 1; return erval; }
  cubeinit = true;
  // cube seems to have ok cubelets, so try to solve it...
  for (i = 1; i <= MOV; i++) mvs[i] = 0;
  // try to solve the cube from each possible starting orientation (to find the fastest solution)...
  for (q = 1; q <= 24; q++) {
    // buffer old cube
    for (i = -2; i <= 2; i++) {
      for (j = -2; j <= 2; j++) {
        for (k = -2; k <= 2; k++) {
          rub[i+2][j+2][k+2] = cub[i+2][j+2][k+2];
        }
      }
    }
	//rub=buffer(cub);
    
	// interpolate so that centers are in order...
    fac[0][0] = 0;
    fac[1][0] = cub[0+2][2+2][0+2]; fac[2][0] = cub[0+2][0+2][-2+2];
    fac[3][0] = cub[-2+2][0+2][0+2]; fac[4][0] = cub[0+2][0+2][2+2];
    fac[5][0] = cub[2+2][0+2][0+2]; fac[6][0] = cub[0+2][-2+2][0+2];
    for (i = 0; i <= 6; i++) {
      fac[fac[i][0]][1] = i;
    }
    // apply interpolation
    for (i = -1; i <= 1; i++) {
      for (j = -1; j <= 1; j++) {
        cub[i+2][2+2][j+2] = fac[cub[i+2][2+2][j+2]][1];
        cub[i+2][j+2][-2+2] = fac[cub[i+2][j+2][-2+2]][1];
        cub[-2+2][i+2][j+2] = fac[cub[-2+2][i+2][j+2]][1];
        cub[i+2][j+2][2+2] = fac[cub[i+2][j+2][2+2]][1];
        cub[2+2][i+2][j+2] = fac[cub[2+2][i+2][j+2]][1];
        cub[i+2][-2+2][j+2] = fac[cub[i+2][-2+2][j+2]][1];
      }
    }
	//cub2=buffer(cub)
	//cub=faces(cub);
    // if we dont care about centers, we can imply their orientation liberally
    if (!centerfix) {
      cub[0+2][1+2][0+2] = 0;
      cub[0+2][0+2][-1+2] = 0;
      cub[-1+2][0+2][0+2] = 0;
      cub[0+2][0+2][1+2] = 0;
      cub[1+2][0+2][0+2] = 0;
      cub[0+2][-1+2][0+2] = 0;
    }
    // solve the cube...
	t = topedges();
    //trace("topedges "+t);
    var t2 = topcorners();
    //trace("topcorners "+t2);
    t2 = middleedges();
    //trace("middleedges "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 4; }
    t2 = bottomedgesorient();
    //trace("bottomedgesorient "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 5; }
    t2 = bottomedgesposition();
    //trace("bottomedgesposition "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 2; }
    t2 = bottomcornersposition();
    //trace("bottomcornersposition "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 6; }
    t2 = bottomcornersorient();
    //trace("bottomcornersorient "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 7; }
    t2 = centersrotate();
    //trace("centersrotate "+t2);
    t+=t2;
    if (!cubeinit && erval == 0) { erval = 3; }
    // errors above:
    // 2-nondescript parity, 3-center orientation, 4-backward centers or corners,
    // 5-edge flip parity, 6-edge swap parity, 7-corner rotation parity
    if (shorten) {
      mov[0] = -1; t = concise(p + t); mov[0] = 0;
    }
    t = efficient(t);
    n = t.length / 3;
    // if this was shortest solution found so far, run with it...
    if (n < m || m < 0) {
      m = n; s = t;
      for (i = 1; i <= MOV; i++) {
        mvs[i] = mov[i];
      }
      // if we dont care about centers, apply the implied orientations
      if (!centerfix) {
        rub[0+2][1+2][0+2] = (4 - cub[0+2][1+2][0+2]) % 4;
        rub[0+2][0+2][-1+2] = (4 - cub[0+2][0+2][-1+2]) % 4;
        rub[-1+2][0+2][0+2] = (4 - cub[-1+2][0+2][0+2]) % 4;
        rub[0+2][0+2][1+2] = (4 - cub[0+2][0+2][1+2]) % 4;
        rub[1+2][0+2][0+2] = (4 - cub[1+2][0+2][0+2]) % 4;
        rub[0+2][-1+2][0+2] = (4 - cub[0+2][-1+2][0+2]) % 4;
      }
    }
    /*// restore old (pre-interpolated) cube
    for (i = -2; i <= 2; i++) {
      for (j = -2; j <= 2; j++) {
        for (k = -2; k <= 2; k++) {
          cub[i+2][j+2][k+2] = rub[i+2][j+2][k+2];
        }
      }
    }*/
	cub=buffer(rub);
    // rotate to next orientation and try again to see if we get a shorter solution
    if (q % 4 == 0) {
      p += "CU."; XCU();
    }
    else {
      p += "CL."; XCL();
    }
    if (q == 12) {
      p = "CU.CU.CR."; XCU(); XCU(); XCR();
    }
    else if (q == 24) {
      XCD(); XCD(); XCR();
    }
  }
  // set mov array...
  for (i = 1; i <= MOV; i++) {
    mov[i] = mvs[i];
  }
  // return error if one was found
  if (!cubeinit) return erval;
  mov[0] = m;
  // set solution and return...
  solution = s;
  return 0;
		}
		//--------------------------------------------------------------------------------------------------
		// PRIVATE FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		private function insertCube(cubed:Object):void
		{
			var min=0,max=0;
			var u:int,d:int,l:int,r:int,f:int,b:int,c:int;
			var cm:String;
			var i:int,j:int;
			
			var sublength:int=cubed.sublength;
			var cubedata:String=cubed.cubedata.toLowerCase();
			var s2:int=(int)(sublength*0.5);
			var sN:int=N*N*sublength;
			//var sublength:int=2;
			//var cubedata="u:000102030405060708d:091011121314151617l:181920212223242526r:272829303132333435f:363738394041424344b:454647484950515253";
			/*var foo:Array=[
							"<u,11>",
							"<u,12>",
							"<u,13>",
							"<u,21>",
							"<u,22>",
							"<u,23>",
							"<u,31>",
							"<u,32>",
							"<u,33>",
							"<d,11>",
							"<d,12>",
							"<d,13>",
							"<d,21>",
							"<d,22>",
							"<d,23>",
							"<d,31>",
							"<d,32>",
							"<d,33>",
							"<l,11>",
							"<l,12>",
							"<l,13>",
							"<l,21>",
							"<l,22>",
							"<l,23>",
							"<l,31>",
							"<l,32>",
							"<l,33>",
							"<r,11>",
							"<r,12>",
							"<r,13>",
							"<r,21>",
							"<r,22>",
							"<r,23>",
							"<r,31>",
							"<r,32>",
							"<r,33>",
							"<f,11>",
							"<f,12>",
							"<f,13>",
							"<f,21>",
							"<f,22>",
							"<f,23>",
							"<f,31>",
							"<f,32>",
							"<f,33>",
							"<b,11>",
							"<b,12>",
							"<b,13>",
							"<b,21>",
							"<b,22>",
							"<b,23>",
							"<b,31>",
							"<b,32>",
							"<b,33>"
							];*/
			resetCube(cub);
			//cubedata=cubedata.toLowerCase();
			u=cubedata.search("u:");
			d=cubedata.search("d:");
			l=cubedata.search("l:");
			r=cubedata.search("r:");
			f=cubedata.search("f:");
			b=cubedata.search("b:");
			c=cubedata.search("c:");
			if (u<min) min=u;
			if (u>max) max=u;
			if (d<min) min=d;
			if (d>max) max=d;
			if (l<min) min=l;
			if (l>max) max=l;
			if (r<min) min=r;
			if (r>max) max=r;
			if (f<min) min=f;
			if (f>max) max=f;
			if (b<min) min=b;
			if (b>max) max=b;
			if (min<0 || max>cubedata.length-sublength*N*N-2 || c>cubedata.length-6-2)
			{
				errin=1;
				return;
			}
			cm=cubedata.substr(u+2,sublength*N*N);
			cm+=cubedata.substr(l+2,sublength*N*N);
			cm+=cubedata.substr(f+2,sublength*N*N);
			cm+=cubedata.substr(r+2,sublength*N*N);
			cm+=cubedata.substr(b+2,sublength*N*N);
			cm+=cubedata.substr(d+2,sublength*N*N);
			if (c>=0)
				cm+=cubedata.substr(c+2,6);
			cubeinit=false;
			if (cm.length<sublength*N*N*6)
			{
				errin=1;
				return;
			}
			for (i=-1;i<=1;i++)
			{
				for (j=-1;j<=1;j++)
				{
					/*cub[j+2][2+2][-i+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1,sublength))];
					cub[-2+2][-i+2][-j+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1+sublength*N*N,sublength))];
					cub[j+2][-i+2][-2+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1+2*sublength*N*N,sublength))];
					cub[2+2][-i+2][j+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1+3*sublength*N*N,sublength))];
					cub[-j+2][-i+2][2+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1+4*sublength*N*N,sublength))];
					cub[j+2][-2+2][i+2]=foo[(int)(cm.substr(sublength*i*3+sublength*j+sublength*N*N/2-1+5*sublength*N*N,sublength))];*/
					
					cub[j+2][2+2][-i+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2,sublength));
					cub[-2+2][-i+2][-j+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2+sN,sublength));
					cub[j+2][-i+2][-2+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2+2*sN,sublength));
					cub[2+2][-i+2][j+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2+3*sN,sublength));
					cub[-j+2][-i+2][2+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2+4*sN,sublength));
					cub[j+2][-2+2][i+2]=int(cm.substr(sublength*i*3+sublength*j+sN/2-s2+5*sN,sublength));
				}
			}
			cubeinit=true;
			cm=cm.substr(sublength*N*N*6,cm.length-sublength*N*N*6);
			centerfix=false;
			if (cm.length>=6)
			{
				centerfix=true;
				for (i=0;i<=0;i++)
				{
					for (j=0;j<=0;j++)
					{
						cub[j+2][1+2][-i+2]=cm.charCodeAt(i*1+j+0)-48;
						cub[-1+2][-i+2][-j+2]=cm.charCodeAt(i*1+j+1)-48;
						cub[j+2][-i+2][-1+2]=cm.charCodeAt(i*1+j+2)-48;
						cub[1+2][-i+2][j+2]=cm.charCodeAt(i*1+j+3)-48;
						cub[-j+2][-i+2][1+2]=cm.charCodeAt(i*1+j+4)-48;
						cub[j+2][-1+2][i+2]=cm.charCodeAt(i*1+j+5)-48;
					}
				}
				cm=cm.substr(6,cm.length-6);
			}		
		}
		
		private function findedge(a:int,b:int):int
		{
			var f:int=0;
			var x:int,y:int,z:int;
			var i:int,j:int;
			
			fx=0; fy=0; fz=0;
  for (i = -1; i <= 1; i = i + 2) {
    for (j = -1; j <= 1; j = j + 2) {
      x = cub[i*2+2][j+2][0+2];
      y = cub[i+2][j*2+2][0+2];
      if      (x == a && y == b) {
        f = i * 1; fx = i * 2; fy = j; return f;
      }
      else if (y == a && x == b) {
        f = j * 2; fx = i; fy = j * 2; return f;
      }
      x = cub[i*2+2][0+2][j+2];
      z = cub[i+2][0+2][j*2+2];
      if      (x == a && z == b) {
        f = i * 1; fx = i * 2; fz = j; return f;
      }
      else if (z == a && x == b) {
        f = j * 3; fx = i; fz = j * 2; return f;
      }
      y = cub[0+2][i*2+2][j+2];
      z = cub[0+2][i+2][j*2+2];
      if      (y == a && z == b) {
        f = i * 2; fy = i * 2; fz = j; return f;
      }
      else if (z == a && y == b) {
        f = j * 3; fy = i; fz = j * 2; return f;
      }
    }
  }
  return f;
		}
		
		private function findcorner(a:int,b:int,c:int):int
		{
			var f:int=0;
			var x:int,y:int,z:int;
			var i:int,j:int,k:int;
			
			fx=0; fy=0; fz=0;
  for (i = -1; i <= 1; i = i + 2) {
    for (j = -1; j <= 1; j = j + 2) {
      for (k = -1; k <= 1; k = k + 2) {
        x = cub[i*2+2][j+2][k+2];
        y = cub[i+2][j*2+2][k+2];
        z = cub[i+2][j+2][k*2+2];
        if      (x == a && (y == b || y == c) && (z == b || z == c)) {
          f = i * 1; fx = i * 2; fy = j; fz = k; return f;
        }
        else if (y == a && (x == b || x == c) && (z == b || z == c)) {
          f = j * 2; fx = i; fy = j * 2; fz = k; return f;
        }
        else if (z == a && (x == b || x == c) && (y == b || y == c)) {
          f = k * 3; fx = i; fy = j; fz = k * 2; return f;
        }
      }
    }
  }
  return f;
		}
		
		private function findcenter(a:int):int
		{
			var f:int=0;
			var x:int,y:int,z:int;
			var i:int;
			
			fx=0; fy=0; fz=0;
  for (i = -1; i <= 1; i = i + 2) {
    x = cub[i*2+2][0+2][0+2];
    y = cub[0+2][i*2+2][0+2];
    z = cub[0+2][0+2][i*2+2];
    if      (x == a) {
      f = i * 1; fx = i * 2; return f;
    }
    else if (y == a) {
      f = i * 2; fy = i * 2; return f;
    }
    else if (z == a) {
      f = i * 3; fz = i * 2; return f;
    }
  }
  return f;
		}
		
		private function topedges():String
		{
			var s:String="", a:String="";
			var b:int=0,m:int=0;
			var e:int,f:int,f1:int;
			var i:int,j:int,k:int;
			
  if (!cubeinit) return s;
  while (!(findedge(1, 2) == 2 && findedge(2, 1) == -3 &&
   findedge(1, 3) == 2 && findedge(3, 1) == -1 &&
   findedge(1, 4) == 2 && findedge(4, 1) == 3 &&
   findedge(1, 5) == 2 && findedge(5, 1) == 1)) {
    for (i = 2; i <= b; i++) CR();
    if (b > 0) { s += "CR."; CR(); }
    b++; if (b > 4) b = 1;
    switch (b) {
      case 1: e = 2; break;
      case 2: e = 3; break;
      case 3: e = 4; break;
      case 4: e = 5; break;
    }
    f = findedge(1, e); f1 = findedge(e, 1);
    switch (f) {
      case 2:
        switch (f1) {
          case 3:
            s += "BC.BC.DL.DL.FC.FC.";
            BC(); BC(); DL(); DL(); FC(); FC(); break;
          case -1:
            s += "LD.LD.DR.FC.FC.";
            LD(); LD(); DR(); FC(); FC(); break;
          case 1:
            s += "RD.RD.DL.FC.FC.";
            RD(); RD(); DL(); FC(); FC(); break;
        }
        break;
      case -2:
        switch (f1) {
          case 3:
            s += "DL.DL.";
            DL(); DL(); break;
          case -1:
            s += "DR.";
            DR(); break;
          case 1:
            s += "DL.";
            DL(); break;
        }
        s += "FC.FC.";
        FC(); FC();
        break;
      case 1:
        switch (f1) {
          case -3:
            s += "FA.";
            FA(); break;
          case 3:
            s += "RU.RU.FA.RD.RD.";
            RU(); RU(); FA(); RD(); RD(); break;
          case -2:
            s += "RU.FA.RD.";
            RU(); FA(); RD(); break;
          case 2:
            s += "RD.FA.";
            RD(); FA(); break;
        }
        break;
      case -1:
        switch (f1) {
          case -3:
            s += "FC.";
            FC(); break;
          case 3:
            s += "LU.LU.FC.LD.LD.";
            LU(); LU(); FC(); LD(); LD(); break;
          case -2:
            s += "LU.FC.LD.";
            LU(); FC(); LD(); break;
          case 2:
            s += "LD.FC.";
            LD(); FC(); break;
        }
        break;
      case 3:
        switch (f1) {
          case -2:
            s += "DL.RU.FA.RD.";
            DL(); RU(); FA(); RD(); break;
          case 2:
            s += "BC.BC.DL.RU.FA.RD.";
            BC(); BC(); DL(); RU(); FA(); RD(); break;
          case -1:
            s += "LU.DR.FC.FC.LD.";
            LU(); DR(); FC(); FC(); LD(); break;
          case 1:
            s += "RU.DL.FC.FC.RD.";
            RU(); DL(); FC(); FC(); RD(); break;
        }
        break;
      case -3:
        switch (f1) {
          case -2:
            s += "DR.RU.FA.RD.";
            DR(); RU(); FA(); RD(); break;
          case 2:
            s += "FC.RD.DL.FC.FC.RU.";
            FC(); RD(); DL(); FC(); FC(); RU(); break;
          case -1:
            s += "LD.DR.FC.FC.LU.";
            LD(); DR(); FC(); FC(); LU(); break;
          case 1:
            s += "RD.DL.FC.FC.RU.";
            RD(); DL(); FC(); FC(); RU(); break;
        }
        break;
    }
    switch (b) {
      case 1: a = ""; break;
      case 2: a = "CL."; CL(); break;
      case 3: a = "CL.CL."; CL(); CL(); break;
      case 4: a = "CR."; CR(); break;
    }
    m++; if (m > 255) { cubeinit = false; s = ""; return s; }
  }
  s += a;
  if (shorten && localshorten) s = concise(s);
  mov[1] = s.length / 3;
  return (s);
		}
		
		private function topcorners():String
		{
			var s:String="",a:String="";
			var b:int=0,m:int=0;
			var c:int,c1:int,f:int,f1:int,f2:int,i:int;
			
  if (!cubeinit) return (s);
  while (!(findcorner(1, 2, 5) == 2 && findcorner(2, 1, 5) == -3 &&
   findcorner(1, 3, 2) == 2 && findcorner(3, 1, 2) == -1 &&
   findcorner(1, 4, 3) == 2 && findcorner(4, 1, 3) == 3 &&
   findcorner(1, 5, 4) == 2 && findcorner(5, 1, 4) == 1)) {
    for (i = 2; i <= b; i++) CR();
    if (b > 0) { s += "CR."; CR(); }
    b++; if (b > 4) b = 1;
    switch (b) {
      case 1: c = 2; c1 = 5; break;
      case 2: c = 3; c1 = 2; break;
      case 3: c = 4; c1 = 3; break;
      case 4: c = 5; c1 = 4; break;
    }
    f = findcorner(1, c, c1); f1 = findcorner(c, 1, c1); f2 = findcorner(c1, 1, c);
    switch (f) {
      case 2:
        switch (f1) {
          case 3:
            s += "BA.DL.BC.DR.RD.DR.RU.";
            BA(); DL(); BC(); DR(); RD(); DR(); RU(); break;
          case -1:
            s += "LD.DR.LU.RD.DL.RU.";
            LD(); DR(); LU(); RD(); DL(); RU(); break;
          case 1:
            s += "BC.DL.BA.FC.DR.FA.";
            BC(); DL(); BA(); FC(); DR(); FA(); break;
        }
        break;
      case -2:
        switch (f1) {
          case -3:
            s += "DR.";
            DR(); break;
          case 3:
            s += "DL.";
            DL(); break;
          case -1:
            s += "DL.DL.";
            DL(); DL(); break;
        }
        s += "FC.DL.FA.DR.RD.DR.RU.";
        FC(); DL(); FA(); DR(); RD(); DR(); RU();
        break;
      case 1:
        switch (f1) {
          case -3:
            s += "RD.DL.RU.";
            RD(); DL(); RU(); break;
          case 3:
            s += "RU.DR.RD.DR.RD.DR.RU.";
            RU(); DR(); RD(); DR(); RD(); DR(); RU(); break;
          case -2:
            s += "DL.FC.DR.FA.";
            DL(); FC(); DR(); FA(); break;
          case 2:
            s += "RD.DL.RU.DR.RD.DL.RU.";
            RD(); DL(); RU(); DR(); RD(); DL(); RU(); break;
        }
        break;
      case -1:
        switch (f1) {
          case -3:
            s += "LD.DR.LU.FC.DR.FA.";
            LD(); DR(); LU(); FC(); DR(); FA(); break;
          case 3:
            s += "DL.FC.DL.FA.";
            DL(); FC(); DL(); FA(); break;
          case -2:
            s += "RD.DR.RU.";
            RD(); DR(); RU(); break;
          case 2:
            s += "LU.DL.LD.FC.DL.FA.";
            LU(); DL(); LD(); FC(); DL(); FA(); break;
        }
        break;
      case 3:
        switch (f1) {
          case -2:
            s += "DR.RD.DR.RU.";
            DR(); RD(); DR(); RU(); break;
          case 2:
            s += "BC.FC.DL.BA.FA.";
            BC(); FC(); DL(); BA(); FA(); break;
          case -1:
            s += "BA.DR.BC.RD.DR.RU.";
            BA(); DR(); BC(); RD(); DR(); RU(); break;
          case 1:
            s += "FC.DL.FA.";
            FC(); DL(); FA(); break;
        }
        break;
      case -3:
        switch (f1) {
          case -2:
            s += "FC.DR.FA.";
            FC(); DR(); FA(); break;
          case 2:
            s += "FA.DL.FC.DL.FC.DL.FA.";
            FA(); DL(); FC(); DL(); FC(); DL(); FA(); break;
          case -1:
            s += "DR.RD.DL.RU.";
            DR(); RD(); DL(); RU(); break;
          case 1:
            s += "FC.DR.FA.DL.FC.DR.FA.";
            FC(); DR(); FA(); DL(); FC(); DR(); FA(); break;
        }
        break;
    }
    switch (b) {
      case 1: a = ""; break;
      case 2: a = "CL."; CL(); break;
      case 3: a = "CL.CL."; CL(); CL(); break;
      case 4: a = "CR."; CR(); break;
    }
    m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
  }
  s += a;
  if (shorten && localshorten) s = concise(s);
  mov[2] = s.length / 3;
  return (s);
		}
		
		private function middleedges():String
		{
			var s:String="", a:String="";
			var b:int=0,m:int=0;
			var e:int,e1:int,f:int,f1:int,i:int;
			
  if (!cubeinit) return (s);
  while (!(findedge(2, 5) == -3 && findedge(5, 2) == 1 &&
   findedge(3, 2) == -1 && findedge(2, 3) == -3 &&
   findedge(4, 3) == 3 && findedge(3, 4) == -1 &&
   findedge(5, 4) == 1 && findedge(4, 5) == 3)) {
    for (i = 2; i <= b; i++) CR();
    if (b > 0) { s += "CR."; CR(); }
    b++; if (b > 4) b = 1;
    switch (b) {
      case 1: e = 2; e1 = 5; break;
      case 2: e = 3; e1 = 2; break;
      case 3: e = 4; e1 = 3; break;
      case 4: e = 5; e1 = 4; break;
    }
    a = "";
    f = findedge(e, e1); f1 = findedge(e1, e);
    while (!(f == -2 || f1 == -2)) {
      if (f == -1 && f1 == -3) { a = "CR."; CR(); }
      if (f == -1 && f1 == 3) { a = "CL.CL."; CL(); CL(); }
      if (f == 1 && f1 == 3) { a = "CL."; CL(); }
      if (f == -3 && f1 == -1) { a = "CR."; CR(); }
      if (f == 3 && f1 == -1) { a = "CL.CL."; CL(); CL(); }
      if (f == 3 && f1 == 1) { a = "CL."; CL(); }
      s += a; s += "RD.DR.RU.DR.FC.DL.FA.";
      RD(); DR(); RU(); DR(); FC(); DL(); FA();
      if (a == "CL.") { s += "CR."; CR(); }
      if (a == "CL.CL.") { s += "CR.CR."; CR(); CR(); }
      if (a == "CR.") { s += "CL."; CL(); }
      a = "";
      f = findedge(e,  e1); f1 = findedge(e1, e);
    }
    if (f == -2) {
      switch (f1) {
        case -3:
          s += "DL.DL."; DL(); DL(); break;
        case -1:
          s += "DL."; DL(); break;
        case 1:
          s += "DR."; DR(); break;
      }
      s += "FC.DL.FA.DL.RD.DR.RU.";
      FC(); DL(); FA(); DL(); RD(); DR(); RU();
    }
    else if (f1 == -2) {
      switch (f) {
        case -3:
          s += "DL."; DL(); break;
        case 3:
          s += "DR."; DR(); break;
        case 1:
          s += "DL.DL."; DL(); DL(); break;
      }
      s += "RD.DR.RU.DR.FC.DL.FA.";
      RD(); DR(); RU(); DR(); FC(); DL(); FA();
    }
    switch (b) {
      case 1: a = ""; break;
      case 2: a = "CL."; CL(); break;
      case 3: a = "CL.CL."; CL(); CL(); break;
      case 4: a = "CR."; CR(); break;
    }
    m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
  }
  s += a;
  if (shorten && localshorten) s = concise(s);
  mov[3] = s.length / 3;
  return (s);
		}
		
		private function bottomedgesorient():String
		{
			var s:String="";
			var a:int=0,m:int=0;
			var b:int,r:int,i:int;
			var eo:Array=new Array(4);
			
  if (!cubeinit) return s;
  while (a != 4) {
    eo[0] = cub[0+2][-2+2][-1+2];
    eo[1] = cub[-1+2][-2+2][0+2];
    eo[2] = cub[0+2][-2+2][1+2];
    eo[3] = cub[1+2][-2+2][0+2];
    a = 0; r = 0;
    for (i = 0; i <= 3; i++) {
      b = i + 1; if (b > 3) b = 0;
      if (eo[i] == 6) {
        a++;
        if (eo[b] == 6) r = i;
      }
    }
    if (a == 0) {
      s += "RD.BC.DL.BA.DR.RU.";
      RD(); BC(); DL(); BA(); DR(); RU();
    }
    else if (a == 2) {
      switch (r) {
        case 1:
          s += "CR."; CR(); break;
        case 2:
          s += "CL.CL."; CL(); CL(); break;
        case 3:
          s += "CL."; CL(); break;
      }
      s += "RD.DL.BC.DR.BA.RU.";
      RD(); DL(); BC(); DR(); BA(); RU();
      switch (r) {
        case 1:
          s += "CL."; CL(); break;
        case 2:
          s += "CR.CR."; CR(); CR(); break;
        case 3:
          s += "CR."; CR(); break;
      }
    }
    m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
  }
  if (shorten && localshorten) s = concise(s);
  mov[4] = s.length / 3;
  return (s);
		}
		
		private function bottomedgesposition():String
		{
			var s:String="";
			var a:int=0,m:int=0,t:int=0;
			var b:int,l:int,i:int;
			var ep:Array=[ [], [], [], [] ];
			
  if (!cubeinit) return s;
  while (a != 4) {
    ep[0][0] = cub[0+2][0+2][-2+2]; ep[0][1] = cub[0+2][-1+2][-2+2];
    ep[1][0] = cub[-2+2][0+2][0+2]; ep[1][1] = cub[-2+2][-1+2][0+2];
    ep[2][0] = cub[0+2][0+2][2+2]; ep[2][1] = cub[0+2][-1+2][2+2];
    ep[3][0] = cub[2+2][0+2][0+2]; ep[3][1] = cub[2+2][-1+2][0+2];
    a = 0; l = 0;
    for (i = 0; i <= 3; i++) {
      b = i - 1; if (b < 0) b = 3;
      if (ep[i][0] == ep[i][1]) {
        a++;
      }
      else {
        if (ep[b][0] != ep[b][1]) l = i;
      }
    }
    if (a < 2) {
      t++; if (t > 3) t = 0;
      DL();
    }
    else {
      switch (t) {
        case 1:
          s += "DL."; break;
        case 2:
          s += "DL.DL."; break;
        case 3:
          s += "DR."; break;
      }
      t = 0;
    }
    if (a == 2) {
      switch (l) {
        case 1:
          s += "CR."; CR(); break;
        case 2:
          s += "CL.CL."; CL(); CL(); break;
        case 3:
          s += "CL."; CL(); break;
      }
      s += "RD.DL.DL.RU.DR.RD.DR.RU.";
      RD(); DL(); DL(); RU(); DR(); RD(); DR(); RU();
      switch (l) {
        case 1:
          s += "CL."; CL(); break;
        case 2:
          s += "CR.CR."; CR(); CR(); break;
        case 3:
          s += "CR."; CR(); break;
      }
    }
    m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
  }
  if (shorten && localshorten) s = concise(s);
  mov[5] = s.length / 3;
  return (s);
		}
		
		private function bottomcornersposition():String
		{
			var s:String="";
			var a:int=0,m:int=0;
			var l:int,i:int;
			var cp:Array=[ [], [], [], [] ];
			
  if (!cubeinit) return s;
  while (a != 4) {
    cp[0][0] = findcorner(6, 2, 3); cp[0][1] = (fx < 0 && fy < 0 && fz < 0);
    cp[1][0] = findcorner(6, 3, 4); cp[1][1] = (fx < 0 && fy < 0 && fz > 0);
    cp[2][0] = findcorner(6, 4, 5); cp[2][1] = (fx > 0 && fy < 0 && fz > 0);
    cp[3][0] = findcorner(6, 5, 2); cp[3][1] = (fx > 0 && fy < 0 && fz < 0);
    a = 0; l = 0;
    for (i = 0; i <= 3; i++) {
      if (cp[i][1] == 1) {
        a++; l = i;
      }
    }
    if (a < 4) {
      switch (l) {
        case 1:
          s += "CR."; CR(); break;
        case 2:
          s += "CL.CL."; CL(); CL(); break;
        case 3:
          s += "CL."; CL(); break;
      }
      s += "RD.DR.LD.DL.RU.DR.LU.DL.";
      RD(); DR(); LD(); DL(); RU(); DR(); LU(); DL();
      switch (l) {
        case 1:
          s += "CL."; CL(); break;
        case 2:
          s += "CR.CR."; CR(); CR(); break;
        case 3:
          s += "CR."; CR(); break;
      }
      m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
    }
  }
  if (shorten && localshorten) s = concise(s);
  mov[6] = s.length / 3;
  return (s);
		}
		
		private function bottomcornersorient():String
		{
			var s:String="";
			var a:int=-1,m:int=0;
			var b:int,b1:int,b2:int,d:int,r:int,i:int;
			var co:Array=new Array(4);
			
  if (!cubeinit) return s;
  while (a != 0) {
    co[0] = findcorner(6, 2, 5);
    co[1] = findcorner(6, 3, 2);
    co[2] = findcorner(6, 4, 3);
    co[3] = findcorner(6, 5, 4);
    a = 0; r = 0; d = 0;
    for (i = 0; i <= 3; i++) {
      if (co[i] != -2) a++;
    }
    if (a > 0) {
      for (i = 0; i <= 3; i++) {
        b = i + 2; if (b > 3) b = b - 4;
        b1 = i - 1; if (b1 < 0) b1 = 3;
        b2 = i + 1; if (b2 > 3) b2 = 0;
        if (co[i] != -2) {
          switch (a) {
            case 2:
              if (co[b1] != -2) r = i;
              if (co[b] != -2 && (co[i] == 1 || co[i] == -1)) {
                d = 1; if (i == 0) r = 0; else r = i - 1;
              }
              break;
            case 3:
              if (co[b1] != -2 && co[b2] != -2) r = i;
              break;
            case 4:
              if (co[i] == 1 && co[b1] == 1 && i < 2) r = i;
              break;
          }
        }
      }
      switch (r) {
        case 1:
          s += "CR."; CR(); break;
        case 2:
          s += "CL.CL."; CL(); CL(); break;
        case 3:
          s += "CL."; CL(); break;
      }
      if (a == 4) {
        s += "RD.DL.DL.RU.DR.RD.DR.RU.";
        s += "LD.DR.DR.LU.DL.LD.";
        s += "DR.LU.DL.LD.DL.LU.";
        s += "RD.DL.DL.RU.DR.RD.DR.RU.";
        RD(); DL(); DL(); RU(); DR(); RD(); DR(); RU();
        LD(); DR(); DR(); LU(); DL(); LD();
        DR(); LU(); DL(); LD(); DL(); LU();
        RD(); DL(); DL(); RU(); DR(); RD(); DR(); RU();
      }
      else if (a == 3 && cub[2+2][-1+2][-1+2] == 6) {
        s += "FC.DR.DR.FA.DL.FC.DL.FA.";
        s += "BC.DL.DL.BA.DR.BC.DR.BA.";
        FC(); DR(); DR(); FA(); DL(); FC(); DL(); FA();
        BC(); DL(); DL(); BA(); DR(); BC(); DR(); BA();
      }
      else if (a == 2 && d == 0 && cub[1+2][-1+2][-2+2] == 6) {
        s += "LD.DR.LU.DR.LD.DL.DL.LU.";
        s += "RD.DL.RU.DL.RD.DR.DR.RU.";
        LD(); DR(); LU(); DR(); LD(); DL(); DL(); LU();
        RD(); DL(); RU(); DL(); RD(); DR(); DR(); RU();
      }
      else {
        s += "RD.DL.DL.RU.DR.RD.DR.RU.";
        s += "LD.DR.DR.LU.DL.LD.DL.LU.";
        RD(); DL(); DL(); RU(); DR(); RD(); DR(); RU();
        LD(); DR(); DR(); LU(); DL(); LD(); DL(); LU();
      }
      switch (r) {
        case 1:
          s += "CL."; CL(); break;
        case 2:
          s += "CR.CR."; CR(); CR(); break;
        case 3:
          s += "CR."; CR(); break;
      }
      m++; if (m > 255) { cubeinit = false; s = ""; return (s); }
    }
  }
  if (shorten && localshorten) s = concise(s);
  mov[7] = s.length / 3;
  return s;
		}
		
		private function centersrotate():String
		{
			var s:String="";
			var a:int=0;
			var b:int,c:int,d:int,p:int,q:int;
			
  if (!cubeinit) return s;
  mov[8] = 0;
  if (!centerfix) return s;
  for (q = 1; q <= 6; q++) {
    a += cub[0+2][1+2][0+2];
    if (q % 2 == 0) XCU(); else XCA();
  }
  if (a % 2 != 0) { cubeinit = false; s = ""; return s; }
  for (q = 1; q <= 6; q++) {
    b = cub[0+2][1+2][0+2];
    switch (b) {
      case 2:
        // top = 2
        s += "UL.RU.LD.UR.UR.RD.LU.";
        s += "UL.RU.LD.UR.UR.RD.LU.";
        UL(); RU(); LD(); UR(); UR(); RD(); LU();
        UL(); RU(); LD(); UR(); UR(); RD(); LU();
        break;
      case 1:
        d = 0;
        for (p = 1; p <= 4; p++) {
          if (d == 0) {
            c = cub[-1+2][0+2][0+2];
            if (c == 3) {
              // top = 1, left = 3
              s += "MD.MR.MU.UL.MD.ML.MU.UR.";
              MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
              d = 1;
            }
          }
          s += "CL."; XCL();
        }
        if (d == 0) {
          for (p = 1; p <= 4; p++) {
            if (d == 0) {
              c = cub[-1+2][0+2][0+2];
              if (c == 1) {
                // top = 1, left = 1
                s += "CC.";
                s += "UL.RU.LD.UR.UR.RD.LU.";
                s += "UL.RU.LD.UR.UR.RD.LU.";
                s += "CA.";
                s += "MD.MR.MU.UL.MD.ML.MU.UR.";
                CC();
                UL(); RU(); LD(); UR(); UR(); RD(); LU();
                UL(); RU(); LD(); UR(); UR(); RD(); LU();
                CA();
                MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
                d = 1;
              }
            }
            s += "CL."; XCL();
          }
        }
        if (d == 0) {
          c = cub[0+2][-1+2][0+2];
          switch (c) {
            case 3:
              // top = 1, bottom = 3
              s += "CC.";
              s += "MD.MR.MU.UL.MD.ML.MU.UR.";
              s += "CA.";
              s += "MD.MR.MU.UL.MD.ML.MU.UR.";
              CC();
              MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
              CA();
              MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
              break;
            case 1:
              // top = 1, bottom = 1
              s += "CC.CC.";
              s += "UL.RU.LD.UR.UR.RD.LU.";
              s += "UL.RU.LD.UR.UR.RD.LU.";
              s += "CA.";
              s += "MD.MR.MU.UL.MD.ML.MU.UR.";
              s += "CA.";
              s += "MD.MR.MU.UL.MD.ML.MU.UR.";
              CC(); CC();
              UL(); RU(); LD(); UR(); UR(); RD(); LU();
              UL(); RU(); LD(); UR(); UR(); RD(); LU();
              CA();
              MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
              CA();
              MD(); MR(); MU(); UL(); MD(); ML(); MU(); UR();
              break;
          }
        }
        break;
      case 3:
        d = 0;
        for (p = 1; p <= 4; p++) {
          if (d == 0) {
            c = cub[1+2][0+2][0+2];
            if (c == 1) {
              // top = 3, right = 1
              s += "MD.ML.MU.UR.MD.MR.MU.UL.";
              MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
              d = 1;
            }
          }
          s += "CL."; XCL();
        }
        if (d == 0) {
          for (p = 1; p <= 4; p++) {
            if (d == 0) {
              c = cub[1+2][0+2][0+2];
              if (c == 3) {
                // top = 3, right = 3
                s += "CA.";
                s += "UL.RU.LD.UR.UR.RD.LU.";
                s += "UL.RU.LD.UR.UR.RD.LU.";
                s += "CC.";
                s += "MD.ML.MU.UR.MD.MR.MU.UL.";
                CA();
                UL(); RU(); LD(); UR(); UR(); RD(); LU();
                UL(); RU(); LD(); UR(); UR(); RD(); LU();
                CC();
                MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
                d = 1;
              }
            }
            s += "CL."; XCL();
          }
        }
        if (d == 0) {
          c = cub[0+2][-1+2][0+2];
          switch (c) {
            case 1:
              // top = 3, bottom = 1
              s += "CA.";
              s += "MD.ML.MU.UR.MD.MR.MU.UL.";
              s += "CC.";
              s += "MD.ML.MU.UR.MD.MR.MU.UL.";
              CA();
              MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
              CC();
              MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
              break;
            case 3:
              // top = 3, bottom = 3
              s += "CA.CA.";
              s += "UL.RU.LD.UR.UR.RD.LU.";
              s += "UL.RU.LD.UR.UR.RD.LU.";
              s += "CC.";
              s += "MD.ML.MU.UR.MD.MR.MU.UL.";
              s += "CC.";
              s += "MD.ML.MU.UR.MD.MR.MU.UL.";
              CA(); CA();
              UL(); RU(); LD(); UR(); UR(); RD(); LU();
              UL(); RU(); LD(); UR(); UR(); RD(); LU();
              CC();
              MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
              CC();
              MD(); ML(); MU(); UR(); MD(); MR(); MU(); UL();
              break;
          }
        }
        break;
    }    
    if (q % 2 == 0) {
      s += "CU."; XCU();
    }
    else {
      s += "CA."; XCA();
    }
  }
  if (shorten && localshorten) s = concise(s);
  mov[8] = s.length / 3;
  return (s);
		}
		
		private function concise(a:String):String
		{
  // initialize stuff
  var i:int,j:int,k:int;
  var s:String = a; 
  var t:String= "";
  var s1:String = "", s2:String= "",s3:String  = "";
  var t1:String = "", t2:String = "", t3:String = "";
  var zz:String = "", yy:String = "", xx:String = "";
  var ww:String = "", vv:String = "", uu:String = "";
  var mm:String = "", ll:String = "", kk:String = "";
  var jj:String = "", ii:String = "", hh:String = "";
  var b:int, c:int, g:int, h:Array=new Array(2), mvs:Array=new Array(MOV+1);
  if (mov[0] == -1) {
    mvs[0] = 0;
    for (i = 1; i <= MOV; i++) {
      mvs[i] = 0;
      for (j = 1; j <= i; j++) mvs[i] += mov[j];
    }
  }
  // part 1: remove middle, and whole cube moves by interpolating them
  // part 1a - getting rid of middle slice moves
  for (i = 1; i <= s.length / 3; i++) {
    s1 = s.substr(i * 3 - 3, 1);
    s2 = s.substr(i * 3 - 2, 1);
    if (s1 == "M") {
      if      (s2 == "U") { t += "CU.LD.RD."; }
      else if (s2 == "D") { t += "CD.LU.RU."; }
      else if (s2 == "L") { t += "CL.UR.DR."; }
      else if (s2 == "R") { t += "CR.UL.DL."; }
      else if (s2 == "C") { t += "CC.FA.BA."; }
      else if (s2 == "A") { t += "CA.FC.BC."; }
    }
    else {
      t += s1; t += s2; t += ".";
    }
  }
  s = t;
  // part 1b - interpolating whole cube moves
  c = 1;
  while (c <= s.length / 3) {
    s1 = s.substr(c * 3 - 3, 1);
    s2 = s.substr(c * 3 - 2, 1);
    if (s1 == "C") {
      zz = "U"; yy = "D"; xx = "L"; ww = "R"; vv = "F"; uu = "B";
      mm = "L"; ll = "R"; kk = "U"; jj = "D"; ii = "C"; hh = "A";
      if      (s2 == "U") {
        zz = "F"; yy = "B"; vv = "D"; uu = "U";
        mm = "C"; ll = "A"; ii = "R"; hh = "L";
      }
      else if (s2 == "D") {
        zz = "B"; yy = "F"; vv = "U"; uu = "D";
        mm = "A"; ll = "C"; ii = "L"; hh = "R";
      }
      else if (s2 == "L") {
        xx = "F"; ww = "B"; vv = "R"; uu = "L";
        kk = "A"; jj = "C"; ii = "U"; hh = "D";
      }
      else if (s2 == "R") {
        xx = "B"; ww = "F"; vv = "L"; uu = "R";
        kk = "C"; jj = "A"; ii = "D"; hh = "U";
      }
      else if (s2 == "C") {
        xx = "D"; ww = "U"; zz = "L"; yy = "R";
        kk = "L"; jj = "R"; mm = "D"; ll = "U";
      }
      else if (s2 == "A") {
        xx = "U"; ww = "D"; zz = "R"; yy = "L";
        kk = "R"; jj = "L"; mm = "U"; ll = "D";
      }
      t = "";
      for (i = c + 1; i <= s.length / 3; i++) {
        t1 = s.substr(i * 3 - 3, 1);
        t2 = s.substr(i * 3 - 2, 1);
        if      (t1 == "U") { t += zz; }
        else if (t1 == "D") { t += yy; }
        else if (t1 == "L") { t += xx; }
        else if (t1 == "R") { t += ww; }
        else if (t1 == "F") { t += vv; }
        else if (t1 == "B") { t += uu; }
        else if (t1 == "C") { t += "C"; }
        if      (t2 == "L") { t += mm; }
        else if (t2 == "R") { t += ll; }
        else if (t2 == "U") { t += kk; }
        else if (t2 == "D") { t += jj; }
        else if (t2 == "C") { t += ii; }
        else if (t2 == "A") { t += hh; }
        t += ".";
      }
      c--;
      s = s.substr(0, c * 3); s += t;
    }
    c++;
  }
  // parts 2-4 are nested in this while, so that it will keep stripping out
  // moves until it goes through an entire cycle without stripping anything.
  g = 1;
  while (g > 0) {
    g = 0;
    // part 2: unshuffle possible opposite face groups, e.g., "UL.DR.UR.DL." to "UL.UR.DR.DL."
    // this will make it much easier to identify redundancies like "top left, top right" later on
    b = 0;
    while (b <= s.length / 3 - 1 && s.length / 3 > 0) {
      s1 = s.substr(b * 3, 2);
      t1 = s1.substr(0, 1);
      if      (t1 == "U") { t3 = "D"; }
      else if (t1 == "D") { t3 = "U"; }
      else if (t1 == "L") { t3 = "R"; }
      else if (t1 == "R") { t3 = "L"; }
      else if (t1 == "F") { t3 = "B"; }
      else if (t1 == "B") { t3 = "F"; }
      c = 0;
      s2 = s.substr(b * 3 + 3, 2);
      t2 = s2.substr(0, 1);
      while ((t2 == t1 || t2 == t3) && c <= s.length / 3 - b - 2 && s != "") {
        if (t2 == t1 && c > 0) {
          t = s.substr(0, b * 3 + 3);
          t += s.substr(b * 3 + c * 3 + 3, 3);
          t += s.substr(b * 3 + 3, c * 3);
          t += s.substr(b * 3 + c * 3 + 6, s.length - (b * 3 + c * 3 + 6));
          s = t;
          c = s.length / 3;
        }
        else if (t2 == t3) {
          c++;
        }
        else {
          c = s.length / 3;
        }
        if (c < s.length / 3) {
          s2 = s.substr(b * 3 + c * 3 + 3, 2);
          t2 = s2.substr(0, 1);
        }
      }
      b++;
    }
    // part 3: change things like "top left, top left, top left" to simply "top right"
    b = 0;
    while (b <= s.length / 3 - 2 && s.length / 3 >= 3) {
      s1 = s.substr(b * 3, 2);
      s2 = s.substr(b * 3 + 3, 2);
      s3 = s.substr(b * 3 + 6, 2);
      t1 = s1.substr(0, 1);
      t2 = s1.substr(1, 1);
      if (s1 == s2 && s2 == s3) {
        if      (t2 == "L") { t3 = "R"; }
        else if (t2 == "R") { t3 = "L"; }
        else if (t2 == "U") { t3 = "D"; }
        else if (t2 == "D") { t3 = "U"; }
        else if (t2 == "C") { t3 = "A"; }
        else if (t2 == "A") { t3 = "C"; }
        g = 1;
        t = s.substr(0, b * 3);
        t += t1 + t3 + ".";
        t += s.substr(b * 3 + 9, s.length - (b * 3 + 9));
        // change the mov[] array if necessary
        if (mov[0] == -1) {
          h[0] = 0; h[1] = 0;
          for (i = 1; i <= MOV; i++) {
            for (k = 0; k <= 1; k++) {
              if ((b+k+2) <= mvs[i] && (b+k+2) > mvs[i-1] && h[k] == 0) {
                mov[i]--; h[k] = 1;
                for (j = i; j <= MOV; j++) mvs[j]--;
              }
            }
          }
        }
        //
        s = t;
        b = b - 3; if (b < -1) b = -1;
      }
      b++;
    }
    // part 4: remove explicit redundancies like "top left, top right"
    b = 0;
    while (b <= s.length / 3 - 2 && s.length / 3 >= 2) {
      t1 = s.substr(b * 3, 1);
      t2 = s.substr(b * 3 + 3, 1);
      s1 = s.substr(b * 3 + 1, 1);
      s2 = s.substr(b * 3 + 4, 1);
      if ((t1 == t2) &&
       ((s1 == "L" && s2 == "R") ||
       (s1 == "R" && s2 == "L") ||
       (s1 == "U" && s2 == "D") ||
       (s1 == "D" && s2 == "U") ||
       (s1 == "C" && s2 == "A") ||
       (s1 == "A" && s2 == "C"))) {
        g = 1;
        t = s.substr(0, b * 3);
        t += s.substr(b * 3 + 6, s.length - (b * 3 + 6));
        // change the mov[] array if necessary
        if (mov[0] == -1) {
          h[0] = 0; h[1] = 0;
          for (i = 1; i <= MOV; i++) {
            for (k = 0; k <= 1; k++) {
              if ((b+k+1) <= mvs[i] && (b+k+1) > mvs[i-1] && h[k] == 0) {
                mov[i]--; h[k] = 1;
                for (j = i; j <= MOV; j++) mvs[j]--;
              }
            }
          }
        }
        //
        s = t;
        b = b - 2; if (b < -1) b = -1;
      }
      b++;
    }
    // ok now it will run again if necessary, and then return the new concise string.
  }
  return s;
		}
		
		private function efficient(s:String):String
		{
			return(s);
		}
		
		private function ctemp():void
		{
			var i:int,j:int,k:int;
			temp=[
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ]
								];
			for (i=0;i<=N+1;i++)
				for (j=0;j<=N+1;j++)
					for (k=0;k<=N+1;k++)
						temp[i][j][k]=cub[i][j][k];
		}
		
		public function cp(cub1:Array):Array
		{
			var i:int,j:int,k:int;
			var temp1:Array=[
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ],
								[ [], [], [], [], [] ]
								];
			//resetCube(temp1);
			for (i=0;i<=N+1;i++)
				for (j=0;j<=N+1;j++)
					for (k=0;k<=N+1;k++)
						temp1[i][j][k]=cub1[i][j][k];
			return(temp1);
		}
		
		public function resetCube(cub:Array):void
		{
			var i:int,j:int,k:int;
			solution="";
			for (i=0;i<=MOV;i++)
				mov[i]=0;
			
			for (i=0;i<=N+1;i++)
			{
				for (j=0;j<=N+1;j++)
				{
					for (k=0;k<=N+1;k++)
					{
						if (!(i-2==0 && j-2==0 && k-2==0))
						cub[i][j][k]=0;
					}
				}
			}
			
			for (i=1;i<=N;i++)
			{
				for (j=1;j<=N;j++)
				{
					cub[i][N+1][j]=1;
					cub[i][j][0]=2;
					cub[0][i][j]=3;
					cub[i][j][N+1]=4;
					cub[N+1][i][j]=5;
					cub[i][0][j]=6;
				}
			}
			cubeinit=true;
			erval=0;
		}
		
		public function UL():void { myXML(N); }
		public function UR():void { XMR(N); }
		public function DL():void { myXML(1); }
		public function DR():void { XMR(1); }
		public function LU():void { XMU(1); }
		public function LD():void { XMD(1); }
		public function RU():void { XMU(N); }
		public function RD():void { XMD(N); }
		public function FC():void { XMC(1); }
		public function FA():void { XMA(1); }
		public function BC():void { XMC(N); }
		public function BA():void { XMA(N); }
		public function ML():void { myXML(2); }
		public function MR():void { XMR(2); }
		public function MU():void { XMU(2); }
		public function MD():void { XMD(2); }
		public function MC():void { XMC(2); }
		public function MA():void { XMA(2); }
		
		public function CL():void { for (var i=1;i<=N;i++) myXML(i); }
		public function CR():void { for (var i=1;i<=N;i++) XMR(i); }
		public function CU():void { for (var i=1;i<=N;i++) XMU(i); }
		public function CD():void { for (var i=1;i<=N;i++) XMD(i); }
		public function CC():void { for (var i=1;i<=N;i++) XMC(i); }
		public function CA():void { for (var i=1;i<=N;i++) XMA(i); }
		
		public function XCL():void { for (var i=1;i<=N;i++) myXML(i,false); }
		public function XCR():void { for (var i=1;i<=N;i++) XMR(i,false); }
		public function XCU():void { for (var i=1;i<=N;i++) XMU(i,false); }
		public function XCD():void { for (var i=1;i<=N;i++) XMD(i,false); }
		public function XCC():void { for (var i=1;i<=N;i++) XMC(i,false); }
		public function XCA():void { for (var i=1;i<=N;i++) XMA(i,false); }
				
		public function myXML(a:int,n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[i][0][j] = temp[N+1-j][0][i];
    else if (a == N)
      for (j = 1; j <= N; j++)
        cub[i][N+1][j] = temp[N+1-j][N+1][i];
    cub[i][a][0]   = temp[N+1][a][i];
    cub[i][a][N+1] = temp[0][a][i];
    cub[0][a][i]   = temp[N+1-i][a][0];
    cub[N+1][a][i] = temp[N+1-i][a][N+1];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][1][j] = temp[N+1-j][1][i];
        if (n) {
          cub[i][1][j]--;
          if (cub[i][1][j] < 0) cub[i][1][j] += 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][N][j] = temp[N+1-j][N][i];
        if (n) {
          cub[i][N][j]++;
          if (cub[i][N][j] > 3) cub[i][N][j] -= 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[i][a][1] = temp[N][a][i];
      cub[i][a][N] = temp[1][a][i];
      cub[1][a][i] = temp[N+1-i][a][1];
      cub[N][a][i] = temp[N+1-i][a][N];
    }
  }
  return (true);
		}
		
		public function XMR(a:int,n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[i][0][j] = temp[j][0][N+1-i];
    else if (a == N)
      for (j = 1; j <= N; j++)
        cub[i][N+1][j] = temp[j][N+1][N+1-i];
    cub[i][a][0]   = temp[0][a][N+1-i];
    cub[i][a][N+1] = temp[N+1][a][N+1-i];
    cub[0][a][i]   = temp[i][a][N+1];
    cub[N+1][a][i] = temp[i][a][0];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][1][j] = temp[j][1][N+1-i];
        if (n) {
          cub[i][1][j]++;
          if (cub[i][1][j] > 3) cub[i][1][j] -= 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][N][j] = temp[j][N][N+1-i];
        if (n) {
          cub[i][N][j]--;
          if (cub[i][N][j] < 0) cub[i][N][j] += 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[i][a][1] = temp[1][a][N+1-i];
      cub[i][a][N] = temp[N][a][N+1-i];
      cub[1][a][i] = temp[i][a][N];
      cub[N][a][i] = temp[i][a][1];
    }
  }
  return (true);
		}
		
		public function XMU(a:int, n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[0][i][j] = temp[0][j][N+1-i];
    if (a == N)
      for (j = 1; j <= N; j++)
        cub[N+1][i][j] = temp[N+1][j][N+1-i];
    cub[a][i][0]   = temp[a][0][N+1-i];
    cub[a][i][N+1] = temp[a][N+1][N+1-i];
    cub[a][0][i]   = temp[a][i][N+1];
    cub[a][N+1][i] = temp[a][i][0];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[1][i][j] = temp[1][j][N+1-i];
        if (n) {
          cub[1][i][j]--;
          if (cub[1][i][j] < 0) cub[1][i][j] += 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[N][i][j] = temp[N][j][N+1-i];
        if (n) {
          cub[N][i][j]++;
          if (cub[N][i][j] > 3) cub[N][i][j] -= 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[a][i][1] = temp[a][1][N+1-i];
      cub[a][i][N] = temp[a][N][N+1-i];
      cub[a][1][i] = temp[a][i][N];
      cub[a][N][i] = temp[a][i][1];
    }
  }
  return (true);
		}
		
		public function XMD(a:int, n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[0][i][j] = temp[0][N+1-j][i];
    if (a == N)
      for (j = 1; j <= N; j++)
        cub[N+1][i][j] = temp[N+1][N+1-j][i];
    cub[a][i][0]   = temp[a][N+1][i];
    cub[a][i][N+1] = temp[a][0][i];
    cub[a][0][i]   = temp[a][N+1-i][0];
    cub[a][N+1][i] = temp[a][N+1-i][N+1];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[1][i][j] = temp[1][N+1-j][i];
        if (n) {
          cub[1][i][j]++;
          if (cub[1][i][j] > 3) cub[1][i][j] -= 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[N][i][j] = temp[N][N+1-j][i];
        if (n) {
          cub[N][i][j]--;
          if (cub[N][i][j] < 0) cub[N][i][j] += 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[a][i][1] = temp[a][N][i];
      cub[a][i][N] = temp[a][1][i];
      cub[a][1][i] = temp[a][N+1-i][1];
      cub[a][N][i] = temp[a][N+1-i][N];
    }
  }
  return (true);
		}
		
		public function XMC(a:int, n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[i][j][0] = temp[N+1-j][i][0];
    if (a == N)
      for (j = 1; j <= N; j++)
        cub[i][j][N+1] = temp[N+1-j][i][N+1];
    cub[i][0][a]   = temp[N+1][i][a];
    cub[i][N+1][a] = temp[0][i][a];
    cub[0][i][a]   = temp[N+1-i][0][a];
    cub[N+1][i][a] = temp[N+1-i][N+1][a];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][j][1] = temp[N+1-j][i][1];
        if (n) {
          cub[i][j][1]++;
          if (cub[i][j][1] > 3) cub[i][j][1] -= 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][j][N] = temp[N+1-j][i][N];
        if (n) {
          cub[i][j][N]--;
          if (cub[i][j][N] < 0) cub[i][j][N] += 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[i][1][a] = temp[N][i][a];
      cub[i][N][a] = temp[1][i][a];
      cub[1][i][a] = temp[N+1-i][1][a];
      cub[N][i][a] = temp[N+1-i][N][a];
    }
  }
  return (true);
		}

		public function XMA(a:int, n:Boolean=true):Boolean
		{
			var i:int,j:int;
			
  if (a < 1 || a > N) return (false);
  ctemp();
  for (i = 1; i <= N; i++) {
    if (a == 1)
      for (j = 1; j <= N; j++)
        cub[i][j][0] = temp[j][N+1-i][0];
    if (a == N)
      for (j = 1; j <= N; j++)
        cub[i][j][N+1] = temp[j][N+1-i][N+1];
    cub[i][0][a]   = temp[0][N+1-i][a];
    cub[i][N+1][a] = temp[N+1][N+1-i][a];
    cub[0][i][a]   = temp[i][N+1][a];
    cub[N+1][i][a] = temp[i][0][a];
  }
  if (a == 1) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][j][1] = temp[j][N+1-i][1];
        if (n) {
          cub[i][j][1]--;
          if (cub[i][j][1] < 0) cub[i][j][1] += 4;
        }
      }
    }
  }
  else if (a == N) {
    for (i = 2; i <= N-1; i++) {
      for (j = 2; j <= N-1; j++) {
        cub[i][j][N] = temp[j][N+1-i][N];
        if (n) {
          cub[i][j][N]++;
          if (cub[i][j][N] > 3) cub[i][j][N] -= 4;
        }
      }
    }
  }
  else {
    for (i = 2; i <= N-1; i++) {
      cub[i][1][a] = temp[1][N+1-i][a];
      cub[i][N][a] = temp[N][N+1-i][a];
      cub[1][i][a] = temp[i][N][a];
      cub[N][i][a] = temp[i][1][a];
    }
  }
  return (true);
		}

		/*public function solve():Array
		{
			var algorithm_table:Array=[
									"top",
									"left",
									"front",
									"right",
									"back",
									"bottom"
									];
			
			var path:Array=[];
			var next=0;
			for (var i=0;i<cubed.length;i++)
			{
				var color=cubed[next].color;
				if (cubed[next].color!=cubed[next].pos)
				{
					for (var k=0; k<color.length; k++)
					{
						var c=(int)color.charAt(k);
						path.push({axis:"",type:algorithm_table[c], angle:-1});
					}
				}
				else
				{
					cubed.done=true;
					next=getNext();
				}
			}
			
			function getNext():int
			{
				var done=false;
				var k=0;
				while (!done && k<=cubed.length)
				{
					next=(next+1)%cubed.length;
					if (cubed[next].done==false)
						done=true;
					k++;
				}
				if (done==false) return(-1);
				return(next);
			}
		}*/
	} // end class
} // end package