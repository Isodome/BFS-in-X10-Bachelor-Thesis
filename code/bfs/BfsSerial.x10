package bfs;

import x10.util.*;

public class BfsSerial {
	
	private val INF : Int = Int.MAX_VALUE;
	
	public def this() {
	}
	
	public def bfs(adj :Array[Boolean](2), start : Int, n : Int) : Array[Int](1) {
		// assert adj is square

		var d : Array[Int](1) = new Array[Int]((1..n), INF);
		d([start]) = 0;

		var current : List[Int] = new ArrayList[Int]();
		var next : List[Int] = new ArrayList[Int]();

		current.add(start);

		var depth : Int = 1;

		while(!current.isEmpty()) {
			for (vertex in current) {
				for (var idx : Int = 1; idx <= n; idx++) {
					if (adj([vertex, idx]) && d([idx]) == INF) {
						next.add(idx);
						d([idx]) = depth;
					}
				}
			}
			depth++;
			current.clear();
			var tmpList : List[Int] = current;
			current = next;
			next = tmpList;
		}
		return d;
	}
}
