import graph.*;
import bfs.*;

public class Bfs{
	/**
	 * The main method for the Hello class
	 */
	public static def main(Array[String]) {
		val a : Array[Boolean](2) = Graph.makeMatrixFromTGF("test.tgf");
		x10.io.Console.OUT.println(a.toString());
		for (i in a) {
			x10.io.Console.OUT.println(i(0) + " " + i(1) + " is " + a(i));
		}

		var algo : BfsSerial = new BfsSerial();

		var d : Array[Int](1) = algo.bfs(a, 1, 6);
		for (r in d) {
			x10.io.Console.OUT.println(r(0) + "  "+ d(r));
		}
	}
}
