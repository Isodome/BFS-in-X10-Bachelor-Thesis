package parser;
/**
 * This interface is used by Graph Parsers to insert the edges into a arbitrary graph data structure. Hence, every graph representing data structure should implement GrahpStructure
 */
public interface GraphStructure {

	/**
	 * Sets the vertex count. If addEdge was called before, the callee should forget about 
	 * all edges he already knew.
	 *@param m the new number of vertices 
	 */
	public def setVertexCount(n: Int) : void;

	/**
	 * Tells the callee about a new edge he should add to the graph
	 *@param from the starting vertex of the new edge 
	 *@param to the target vertex of the new edge
	 */
	public def addEdge(from:Int, to:Int) : void;

    /**
     * Tells the calle about new edges he should add to the graph.    
     * Not  all edges starting at 'from' must be included
     *@param from the starting vertex of the new edge
     *@param to a list of target edges
     */
    public def addEdge(from:Int, to: Array[Int]) : void;

	/**
	 * Tells the callee, that the graph has finished parsing.
	 */
	public def finished() : void;

    public def checkStartNode(numberToCheck : Int) : boolean;
    public def getNodeCount() : Int;
}
