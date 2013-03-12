package rubikcube
{
	import flash.display.*;
	import rubikcube.Rubik;
	import rubikcube.RubikSolver3x3x3;
	
    public class RubikAdaptor
    {
		public var rb:Rubik=null;
		public var rbs3:RubikSolver3x3x3=null;
		private var solved:Boolean=false;
		//--------------------------------------------------------------------------------------------------
		// PUBLIC FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		public function RubikAdaptor(rbo:Rubik=null)
		{
			rb=rbo;
			rbs3=new RubikSolver3x3x3();//rbso;
			rbs3.cubedata=rb2rbs();
		}
		
		public function test() : String
		{
			//if (!solved)
			var tt=rbs3.renderText();
			rbs3.cubedata=rb2rbs();
			//solved=false;
			return(tt+"\n"+rbs3.renderText());
		}
		
		public function solve(rboo:Rubik=null):Object
		{
			solved=true;
			if (rboo!=null)
				rb=rboo;
			if (rb.theCube.N != 3) 
				return({e:100,movs:[],msg:"Solver is Only for 3x3x3 Cube!"});
			//rbs3.cubedata=rb2rbs();
			var err=rbs3.solve();
			if (err>0) // error occured
			 return({e:err,movs:[],movs2:"",msg:"Error Occured!"});
			var s:String=rbs3.solution;
			var a:Array=rbs2rb(s);
			return({e:0,movs:a,movs2:s,msg:"Solved!"});
		}
		
		public function getFlatImage(width):Sprite
		{
			//rbs3.cubedata=rb2rbs();
			return(rbs3.getFlatImage(width));
		}
		//--------------------------------------------------------------------------------------------------
		// PRIVATE FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		private function col2str(c:int):String
		{
			var col=rb.theCube.colors;
			if (c==col.top) return("top");
			if (c==col.bottom) return("bot");
			if (c==col.left) return("lef");
			if (c==col.right) return("rig");
			if (c==col.front) return("fro");
			if (c==col.back) return("bac");
			return("");
		}
		
		private function col2str2(c:int):String
		{
			var col=rb.theCube.colors;
			// insert cube color codes as used on RubikSolver 3x3x3
			if (c==col.top) return("1");
			if (c==col.bottom) return("6");
			if (c==col.left) return("3");
			if (c==col.right) return("5");
			if (c==col.front) return("2");
			if (c==col.back) return("4");
			return("10000000");
		}
		
		//most probably correct transform
		public function rb2rbs():Object
		{
			var i:int,j:int;
			var N=rb.theCube.N;
			var sublength:int=1;
			var cubedata="";
			
			cubedata="u:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("top",i,N-1-j).color); //i,N-1-j
				}
			}
			 
			cubedata+="d:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("bottom",i,N-1-j).color); // i, N-1-j
				}
			}
			cubedata+="l:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("left",i,N-1-j).color); //i,N-1-j
				}
			}
			
			cubedata+="r:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("right",i,N-1-j).color); // i,N-1-j
				}
			}
			
			cubedata+="f:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("front",i,N-1-j).color); //i,N-1-j
				}
			}
			
			cubedata+="b:";
			for (i=0;i<N;i++)
			{
				for (j=0;j<N;j++)
				{
					cubedata+=col2str2(rb.getFaceColorAndIndex("back",i,N-1-j).color); //i,N-1-j
				}
			}
			//cubedata+="c:163524";//"c:163524";
			return({cubedata:cubedata, sublength:sublength});
		}
		
		// most probably correct
		private function rbs2rb(solutionstr:String):Array
		{
			var rot:Array=[];
			if (solutionstr==null || solutionstr=="") return(rot);
			var mov:Array=solutionstr.split(".");
			for (var i=0;i<mov.length-1;i++)
			{
				switch(mov[i].toUpperCase())
				{
					case "UL": //top left
								rot.push({axis:"y",row:2,angle:-1});
								break;							
					case "ML": //middle left
								rot.push({axis:"y",row:1,angle:-1});
								break;							
					case "DL": //bottom left
								rot.push({axis:"y",row:0,angle:-1});
								break;
					case "UR": //top right
								rot.push({axis:"y",row:2,angle:1});
								break;
					case "MR": //middle right
								rot.push({axis:"y",row:1,angle:1});
								break;							
					case "DR": //bottom right
								rot.push({axis:"y",row:0,angle:1});
								break;
					case "LU": //left up
								rot.push({axis:"x",row:2,angle:-1});
								break;
					case "MU": //middle up
								rot.push({axis:"x",row:1,angle:-1});
								break;
					case "RU": //right up
								rot.push({axis:"x",row:0,angle:-1});
								break;
					case "LD": //left down
								rot.push({axis:"x",row:2,angle:1});
								break;
					case "MD": //middle down
								rot.push({axis:"x",row:1,angle:1});
								break;
					case "RD": //right down
								rot.push({axis:"x",row:0,angle:1});
								break;
					case "FC": //front clockwise
								rot.push({axis:"z",row:2,angle:1});
								break;
					case "MC": //middle clockwise
								rot.push({axis:"z",row:1,angle:1});
								break;
					case "BC": //back clockwise
								rot.push({axis:"z",row:0,angle:1});
								break;
					case "FA": //front anti-clockwise
								rot.push({axis:"z",row:2,angle:-1});
								break;
					case "MA": //middle anti-clockwise
								rot.push({axis:"z",row:1,angle:-1});
								break;
					case "BA": //back anti-clockwise
								rot.push({axis:"z",row:0,angle:-1});
								break;
	//----------------------------------------------------------------------------------				
					case "CL": //cube left
								rot.push({axis:"y",row:0,angle:-1});
								rot.push({axis:"y",row:1,angle:-1});
								rot.push({axis:"y",row:2,angle:-1});
								break;
					case "CR": //cube right
								rot.push({axis:"y",row:0,angle:1});
								rot.push({axis:"y",row:1,angle:1});
								rot.push({axis:"y",row:2,angle:1});
								break;
					case "CU": //cube up
								rot.push({axis:"x",row:0,angle:-1});
								rot.push({axis:"x",row:1,angle:-1});
								rot.push({axis:"x",row:2,angle:-1});
								break;
					case "CD": //cube down
								rot.push({axis:"x",row:0,angle:1});
								rot.push({axis:"x",row:1,angle:1});
								rot.push({axis:"x",row:2,angle:1});
								break;
					case "CC": //cube clockwise
								rot.push({axis:"z",row:0,angle:1});
								rot.push({axis:"z",row:1,angle:1});
								rot.push({axis:"z",row:2,angle:1});
								break;
					case "CA": //cube anti-clockwise
								rot.push({axis:"z",row:0,angle:-1});
								rot.push({axis:"z",row:1,angle:-1});
								rot.push({axis:"z",row:2,angle:-1});
								break;
				}
			}
			return(rot);
		}
	} // end class
} // end package