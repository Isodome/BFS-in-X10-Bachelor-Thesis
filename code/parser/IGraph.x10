package graph;

import x10.lang.*;

public interface IGraph {

	def getVertexCount() :Int;
	def getVertexIterator(v : Vertex) : Iterable[Int];
	
}
