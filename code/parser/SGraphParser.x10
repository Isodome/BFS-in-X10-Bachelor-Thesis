package parser;
import x10.io.*;
import x10.util.ArrayBuilder;

public class SGraphParser implements Parser {

	public def fillGraphInDataStructure (gs : parser.GraphStructure, filename :String) : void {

		var vertexCountRead : Boolean = false;

		try {
			// read first line and take value as vertexcount
			val reader = IOHelper.getFileReader(filename);
			var line : String = reader.readLine();
			try{
				val vertexCount = Int.parse(line.trim());
				gs.setVertexCount(vertexCount);
			} catch (nfe : NumberFormatException) {
				throw new IOException();
			}
			vertexCountRead = true;

			// Read Edges

			while(true) {
				line = reader.readLine();
				val a = line.split(" ");

                if (a.size >= 2) {
                    val to = new ArrayBuilder[Int]();
                    val from : Int = Int.parse(a(0) );
                    for (var i : Int = 1; i < a.size && a.region.contains(i); i++) {
                        to.add(Int.parse(a(i)));
                    }
                    gs.addEdge(from, to.result());

                } else {
                    //print error "Unparsable Line"
					break;
				}

			}

		} catch (eof : x10.io.EOFException) {
			gs.finished();
        } catch (nfe : NumberFormatException) {
           
        } finally {
            if (!vertexCountRead) {
				throw new IOException();
			}
		}
	}
}
