package parser;
import x10.io.*;
import x10.util.*;

public class SGraphParser implements Parser {

	private static val bufferSize : Int = 50;

	public def fillGraphInDataStructure (gs : parser.GraphStructure, filename :String) : void {
		finish {
			var vertexCountRead : Boolean = false;
			var reader : FileReader = null as FileReader;
			var localBuffer : ArrayList[String] = new ArrayList[String](bufferSize);

			try {
				// read first line and take value as vertexcount
				reader = IOHelper.getFileReader(filename);

				var line : String = reader.readLine();
				val vertexCount = Int.parse(line.trim());
				gs.setVertexCount(vertexCount);
				vertexCountRead = true;
				// Read Edges

				while(true) {
					line = reader.readLine();
					localBuffer.add(line);

					if (localBuffer.size() == bufferSize) {
						val constBuf = localBuffer;
						async doWork(constBuf, gs);
						localBuffer = new ArrayList[String](bufferSize);
					}
				}

			} catch (eof : x10.io.EOFException) {
				
	        } 
			doWork(localBuffer, gs);

        	if (reader != null) {
				reader.close();
			}
            if (!vertexCountRead) {
				throw new IOException("Seems like vertex count hasn't been read");
			}
		}
		gs.finished();
	}

	private def doWork(localBuffer : ArrayList[String], gs: GraphStructure) {
		
		for (element in localBuffer) {
			val a = element.split(" ");

	        if (a.size >= 2) {
	            val to = new ArrayBuilder[Int]();
	            val from : Int = Int.parse(a(0) );
	            for (var i : Int = 1; i < a.size && a.region.contains(i); i++) {
	                to.add(Int.parse(a(i)));
	            }
	            gs.addEdge(from, to.result());

	        }
		}
	}
	private def print(s:String) {
		//x10.io.Console.OUT.println(s);
	}

}
