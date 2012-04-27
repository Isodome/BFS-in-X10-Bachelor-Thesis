package parser;
import x10.io.FileReader;
import x10.io.IOException;

public class SGraphParser implements Parser {

	public def fillGraphInDataStructure(gs :GraphStructure, filename :String) : void {

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
					try{
						val from : Int = Int.parse(a(0) );
						for (var i : Int = 1; i < a.size() && a.region.contains(i); i++) {
							val to: Int = Int.parse(a(i));
							gs.addEdge(from,to);
						}
					} catch (nfe : NumberFormatException) {
						continue;
					}

				} else {
					//print error "Unparsable Line"
					break;
				}

			}

		} catch (eof : x10.io.EOFException) {
			//done
		} finally {
			if (!vertexCountRead) {
				throw new IOException();
			}
		}
	}
}
