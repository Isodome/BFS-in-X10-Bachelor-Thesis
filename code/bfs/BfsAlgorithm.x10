package bfs;
import parser.GraphStructure;
import x10.util.*;

public abstract class BfsAlgorithm implements GraphStructure {

	private var timing: List[Pair[Long, String]];
	private var timings: GlobalRef[ArrayList[Pair[Long, String]]];
	private var lastTime: GlobalRef[Cell[Long]];



	protected def addTiminig(event_name : String) {
		if (here.id == 0){
			val now = System.currentTimeMillis();
			
			val newEvent = new Pair[Long, String](now-lastTime()(), event_name);
			timings().add(newEvent);
			lastTime()() = System.currentTimeMillis();
		}
	}

	public def run(start:Int, emptyList: ArrayList[Pair[Long,String]]) {
		timings = new GlobalRef[ArrayList[Pair[Long, String]]](emptyList);
		val timeCell = new Cell[Long](System.currentTimeMillis());
		lastTime = new GlobalRef[Cell[Long]](timeCell);
		timings().add(new Pair[Long, String](0, "Start"));
		return run(start);
	}

	public abstract def run(start : Int) : Array[Int](1);
}
