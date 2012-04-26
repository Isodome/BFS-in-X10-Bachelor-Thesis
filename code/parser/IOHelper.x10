package parser;

import x10.io.*;
public class IOHelper {
	
	/**
	 * Skips all rows before th "#" and counts them. Returns the number of rows before the "#"
	 */
	private static def readTGFEdges(reader :FileReader) : Int {
		var sum:Int = 0;
		while (!reader.readLine().trim().equals("#")) {
			sum++;
		}
		return sum;
	}
	
	public static def getFileReader(val file:String ) :FileReader {
		val I = new File(file);
		if (!I.exists()) {
			throw new FileNotFoundException();
		}
		return  new FileReader(I);	
	}
	
	
	public static def makeMatrixFromTGF(val file: String, datastructure : Int) :Array[Boolean](2) {
		reader: FileReader  =  getFileReader(file);
		val edgeCount = readTGFEdges(reader);
		val r  = Region.makeRectangular([1,1], [edgeCount, edgeCount]);
		var adj : Array[Boolean](2) = new Array[Boolean](r, false);

		try{
			while(true) {
				val line : String = reader.readLine();
				val a = line.split(" ");
				
				if (a.size >= 2) {
					try{
						val p  = Point.make(Int.parse(a(0)),Int.parse(a(1)));	
						adj(p) = true;
						
					} catch (nfe : NumberFormatException) {
						//print error "bad numbers"
					}
						
				} else {
					//print error "Unparsable Line"
					break;
				}
				 
			}
			
		} catch (eof: x10.io.EOFException) {
			//done
		} finally {
			if(reader != null) {
				reader.close();
			}
		}

		 
		
		return adj;
	}			

}
