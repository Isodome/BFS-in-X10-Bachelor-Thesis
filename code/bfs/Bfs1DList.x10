package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import parser.*;
import Bfs;


public class Bfs1DList extends BfsAlgorithm {

    private static val INF : Int = Bfs.INF;
    private var vertexCount: Int = 0;
    private var adjacency : DistArray[Array[ArrayList[Int]]](1);
	private var arrayPartSize : Int;


    public def setVertexCount(n: Int) {
        this.vertexCount = n;
		var partSize : int = vertexCount / PlaceGroup.WORLD.size();
        if (partSize * PlaceGroup.WORLD.size() < vertexCount) {
            partSize++;
        }
        this.arrayPartSize = partSize;
        
        val a = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), null as Array[ArrayList[Int]]);

		val constPartSize = partSize;
        finish for (place in PlaceGroup.WORLD) async at (place) {
			val minRowCoord = place.id * constPartSize;	
			val maxRowCoord = x10.lang.Math.min(minRowCoord + constPartSize-1, n-1);

			a(here.id) = new Array[ArrayList[Int]]( (minRowCoord..maxRowCoord), (p:Point) => new ArrayList[Int]());
        }

		adjacency = a;
        
    }

    public def addEdge(from : Int, to : Int) {
        assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
        val targetPlace = PlaceGroup.WORLD(from/arrayPartSize);
        if (targetPlace == here) {
        	atomic adjacency(here.id)(from).add(to);
        } else {
            async at (targetPlace) {
                atomic adjacency(here.id)(from).add(to);
            }
        }
    }

    public def addEdge(from : Int, to : Array[Int]) {
     val targetPlace = PlaceGroup.WORLD(from/arrayPartSize);
        if (targetPlace == here) {
        	 atomic {
                for (i in to) {
                    adjacency(here.id)(from).add(to(i));
                }
            }
        } else {
			async at(targetPlace) {
				atomic {
					for (i in to) {
						adjacency(here.id)(from).add(to(i));
					}
				}
			}
		}
    }

    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >=0 && numberToCheck < vertexCount;
    }
    public def getNodeCount() : Int {
        return vertexCount; 
    }

    public def finished() : void {
        // not required
    }

    public def run(start : Int) : Array[Int](1) { 

        val d = DistArray.make[Array[Int]](Dist.makeUnique(), null as Array[Int]);
        finish for (place in PlaceGroup.WORLD) async at (place) {
            val arrayFrom = this.arrayPartSize * place.id;
            val arrayTo   = x10.lang.Math.min(arrayFrom + this.arrayPartSize-1, vertexCount - 1);
            d(place.id) = new Array[Int]( arrayFrom..arrayTo, INF);
        }

        val recBuffers : DistArray[Array[ArrayList[Int]]](1) = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](Place.places().size(), new ArrayList[Int]()));

        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val adj = this.adjacency;

        /*delete the following when clocks are finally working */
        val isAt = new Array[Place](Place.places().size(), (i:Int) => new Place(i));
        val team = new Team(isAt);

        finish {
            for (place in PlaceGroup.WORLD) async  at (place)  {

                var done : Boolean = false;
                var depth : Int = 1;
                val dTemp = new Array[Boolean](vertexCount, false);
                var current : ArrayList[Int] = new ArrayList[Int]();
                val sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());
                val sourcePlace = here.id;
                if (start / arrayPartSize == here.id) {
                    d(here.id)(start) = 0;
                    current.add(start);
                }

                while(!done) {
                    // Sort reachable vertices by owning place
                    for (from in current) {
            			val currentList = adj(here.id)(from);
            			val currentSize = currentList.size();
            			for (var i:Int = 0; i< currentSize; i++) {
                			val to = currentList(i);
                            if (!dTemp(to)) {
                                sendBuffer(to / arrayPartSize).add(to);
                                dTemp(to) = true;
                            }
                        }
                    }

                    current.clear();
                    finish for( targetPlace in PlaceGroup.WORLD) {
                        val buffer : ArrayList[Int] = sendBuffer(targetPlace.id);
                        if (!buffer.isEmpty()) {
                            if (targetPlace == here) {
                                recBuffers(here.id)(here.id) = buffer;
                                sendBuffer(here.id) = new ArrayList[Int]();
                            } else {
								async at(targetPlace) {
									recBuffers(here.id)(sourcePlace) = buffer;
								}
								buffer.clear(); // only clear the local copy, even if targetPlace and sourcePlace are even!
                            }
                        }
                    }
                    team.barrier(here.id);

                    val receiveBuffers : Array[ArrayList[Int]] = recBuffers(here.id);
                    for (iBuf in receiveBuffers) {
                    	val curBuffer = receiveBuffers(iBuf);
                    	val curBufSize = curBuffer.size();
                    	for (var i:int = 0; i< curBufSize; i++) {
                    		val vertex = curBuffer(i);
                            if (d(here.id)(vertex) == INF) {
                                d(here.id)(vertex) = depth;
                                current.add(vertex);
                            }
                        }
                    }
                    done = current.size() == 0;
                    val res = team.allreduce(here.id, done ? 1 : 0 , Team.MUL);
                    done = (res == 1);

                    depth++;
                }

                // Copy place-local content of d in result array at place 0
                val localPortion = d(here.id);
                finish at(resultRef) async {
                    val r :Array[Int] = resultRef();
                    for (i in localPortion) {
                        r(i) = localPortion(i);
                    }
                }

            }}

        return result_local;
    }


    static public def say(s:String) {
        atomic{
            x10.io.Console.OUT.println(s);
        }
    }

}

