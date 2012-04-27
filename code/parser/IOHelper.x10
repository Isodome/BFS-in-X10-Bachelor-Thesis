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

	public static def print (a : Array[String]) : void {

			for (i in a) {
				x10.io.Console.OUT.println (i(0).toString() + "\t: " + a(i).toString());
			}
	}

	public static def print(s : String) {
		x10.io.Console.OUT.println(s);
	}
	public static def print(i : Int) {
		print(i.toString());
	}
}
