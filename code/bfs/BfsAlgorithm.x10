package bfs;
import parser.GraphStructure;

import invasic.*;

public abstract class BfsAlgorithm implements GraphStructure {


    public def runClassic(start : Int) {
        run(start);
    }

    public def run (start : Int, homeClaim : Claim) {

       val ilet = (id:IncarnationID) => {
            run(start);
       }
       homeClaim.infect(ilet);
    }

	public abstract def run(start : Int) : Array[Int](1);
}
