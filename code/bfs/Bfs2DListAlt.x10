package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import Bfs;

public class Bfs2DListAlt extends BfsAlgorithm {


    private static val INF = Bfs.INF;
    private var vertexCount : Int = 0;
    private var adj : DistArray[Array[List[Int]]](1);
    private var grid : Grid;
    private var arrayPartSize : int;

    public def setVertexCount(n : Int) {
        this.vertexCount = n;
        adj = DistArray.make[Array[List[Int]]](Dist.makeUnique(), null as Array[List[Int]]);
        this.grid = Grid.make(adj.dist.places(), n);


        finish for (var i: int = 0; i< grid.rows; i++) {
            val myRow = i;
            for (var j: int = 0; j < grid.cols; j++){
                val myCol = j;
                val p = grid.getPlaceForGridPosition(i,j);
                at(p) async {
                    val minRowCoord = myRow * grid.rowSize;
                    val minColCoord = myCol * grid.colSize;

                    val maxRowCoord = x10.lang.Math.min(minRowCoord + grid.rowSize - 1, n-1);
                    val maxColCoord = x10.lang.Math.min(minColCoord + grid.colSize - 1, n-1);
                    adj(p.id) = new Array[List[Int]]( (minRowCoord..maxRowCoord), (p:Point) => new ArrayList[Int]());
                }
            }
        }
        var partSize : int = vertexCount / PlaceGroup.WORLD.size();
        if (partSize * PlaceGroup.WORLD.size() < vertexCount) {
            partSize++;
        }
        this.arrayPartSize = partSize;
    }

    public def addEdge(from : Int, to : Int) {
		assert (from < vertexCount && to < vertexCount) : "Vertex out of range";
		assert (from >= 0 && to >=0) : "Vertex out of range";
		val p : Place = grid(from,to);
		if (p == here) {
			atomic adj(here.id)(from).add(to);
		} else {
			at(p) {
				atomic adj(p.id)(from).add(to);
			}
		}

    }

    public def addEdge(from : Int, to : Array[Int]) {

		val cols = grid.getPlacesForRow(from / grid.rowSize);
		val buffer = new Array[ArrayList[Int]](cols.size(), (i:Int)=> new ArrayList[Int]());
		for (i in to) {
			buffer(to(i) / grid.colSize).add(to(i));
		}
		for (i in buffer) {
			if (!buffer(i).isEmpty()) {
				at (cols(i(0))) {
					for (j in buffer(i)) {
						addEdge(from, j);
					}
				}
			}
		}
    }
    public def getNodeCount() : Int {
        return vertexCount; 
    }
    public def finished() : void {

    }

    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >= 0  && numberToCheck < vertexCount;
    }

    public def run(start : Int) : Array[Int](1) {

        val d = DistArray.make[Array[Int]](Dist.makeUnique(), null as Array[Int]);
        //val fTransposed = DistArray.make[Array[Boolean]]( Dist.makeUnique(), null as Array[Boolean]);
        val fTransposed = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), null as Array[ArrayList[Int]]);
        //val t = DistArray.make[ArrayList[Int]](Dist.makeUnique(), null as ArrayList[Int]);
        val t = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), null as Array[ArrayList[Int]]);
        val t_tmp = DistArray.make[List[Int]](Dist.makeUnique(), null as List[Int]); 

        finish for (place in PlaceGroup.WORLD) async at (place) {
            val arrayFrom = this.arrayPartSize * place.id;
            val arrayTo   = x10.lang.Math.min(arrayFrom + this.arrayPartSize-1, vertexCount - 1);
            d(place.id) = new Array[Int]( arrayFrom..arrayTo, INF);
            t_tmp(place.id) = new ArrayList[Int]();
            t(place.id) = new Array[ArrayList[Int]](grid.places().size(), (i:int) => new ArrayList[Int]());
            fTransposed(place.id) = new Array[ArrayList[Int]](grid.places().size(), (i:Int) => new ArrayList[Int]());
        }

        // Array to collect all results in Place 0 after calculation
        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val isAt = new Array[Place](Place.places().size(), (i:Int) => new Place(i));
        val team = new Team(isAt);
        //addTiminig("Global init done");
        finish {
            for (place in d.dist.places()) at (place) {
                async {
					val dTemp = new Array[Boolean](vertexCount, false);
                    val emptyList = new ArrayList[Int]();
                    
                    val sendBuf = new Array[ArrayList[Int]](grid.rows, (i:Int) => new ArrayList[Int]());
                    val sendBufGlobal =  new Array[ArrayList[Int]](grid.places().size(), (i:Int) => new ArrayList[int]());
                    var depth : Int = 0;

                    val myPointInGrid = grid.getMyPosition();
                    val rowFrom = myPointInGrid(0) * grid.rowSize;
                    val colFrom = myPointInGrid(1) * grid.colSize;
                    val rowTo = x10.lang.Math.min(rowFrom + grid.rowSize - 1, vertexCount-1);
                    val colTo = x10.lang.Math.min(colFrom + grid.colSize - 1, vertexCount-1);

                    //fTransposed(here.id) = new Array[Boolean]((colFrom..colTo), false);
                    var done :Boolean  = false;
                    
                    if (d.dist(start / this.arrayPartSize) == here) {
                        d(here.id)(start) = 0;
                        dTemp(start) = true;
                        val rowNum = start / grid.rowSize;
                        sendBuf(rowNum).add(start);
                    }
                    //addTiminig("Local init done");
                    while (!done) {
                        depth++;
                        // Phase 1: Transpose f


                        // Phase 2: communication
                        val sender = here.id;
                        finish for (rowNum in sendBuf) {
                            val buffer = sendBuf(rowNum);
                            if (buffer.isEmpty()) {
                                continue;
                            }
                            for (p in grid.getPlacesForRow(rowNum(0))) {
                                if (p.id == here.id) {
                                    fTransposed(here.id)(here.id) = buffer;
                                } else {
                                    val senderId = here.id;
                                    async at(p) {
                                        fTransposed(here.id)(senderId) = buffer;
                                    }
                                }
                            }
                            sendBuf(rowNum) = new ArrayList[Int]();
                        }
                        //addTiminig("Iteration " + depth + " Communication 1");

                        team.barrier(here.id);
                        // phase 3 and 4: Local Matrix multiplication
                        val fTransLocal : Array[ArrayList[Int]] = fTransposed(here.id);
                        for (j in fTransLocal) {
                            val curList : ArrayList[Int] = fTransLocal(j);
                            for (i in curList) {
                            	for (to in adj(here.id)(i)) {
                            		if (dTemp(to) == false) {
                            			t_tmp(here.id).add(to);
                            			dTemp(to) = true;
                            		}
                            	}
                                //t_tmp(here.id).addAll(adj(here.id)(i));
                                adj(here.id)(i) = emptyList;
                            }
                            if(!curList.isEmpty()) {
                                curList.clear();
                            }
                        }

                        //addTiminig("Iteration " + depth + " multiply");

                        //Phase 5: merge information per row
                        for (item in t_tmp(here.id)) {
                            val ownerId = item / this.arrayPartSize;
                            sendBufGlobal(ownerId).add(item);
                        }
                        t_tmp(here.id).clear();

                        finish for (p in grid.places()) async {
                            val senderId = here.id; 
                            if (!sendBufGlobal(p.id).isEmpty()) {
                                if (p.id == here.id) {
                                    t(here.id)(senderId) = sendBufGlobal(senderId);
                                    sendBufGlobal(p.id) = new ArrayList[Int]();
                                } else {
                                    val tempBuf = sendBufGlobal(p.id);
                                    at(p) {
                                        t(here.id)(senderId) = tempBuf;
                                    }
                                    sendBufGlobal(p.id).clear();
                                }
                            }
                        }
                        team.barrier(here.id);
                        //addTiminig("Iteration " + depth + " Kommunikation2");

                        //Phase 4: update d locally
                        done = true;
                        for (senderPlace in t(here.id)) {
                            for (item in t(here.id)(senderPlace)) {
                                if(d(here.id)(item) == INF) {
                                    d(here.id)(item) = depth;
                                    val rowNum = item / grid.rowSize;
                            		sendBuf(rowNum).add(item);;
                                    done = false;
                                }
                            }
                            t(here.id)(senderPlace).clear();
                        }
                        //addTiminig("Iteration " + depth + " Update");

                        val res = team.allreduce(here.id, done ? 1 : 0 , Team.MUL);
                        done = (res == 1);
                        //addTiminig("Iteration " + depth + " allreduce");
                    }

                    // Copy local content of d in result array at place 0
                    val localPortion = d(here.id);
                    at(resultRef) async {
                        val r  = resultRef();
                        for (i : Point in localPortion) {
                            r(i) = localPortion(i);
                        }
                    }


                }}}
        //addTiminig("Copy back and finish");

        return result_local;
    }

    private static def findRowCount(numPlaces:int) : int {
        val sqrtD = Math.sqrt(numPlaces as Double) + 0.5; // in case the sqrt is an Integer, add 0.5 to get the correct result after rounding up; 
        var rows : int = sqrtD as int;
        while (numPlaces % rows != 0 && rows > 1) {
            rows--;
        }
        return Math.max(1, rows);
    }
    static public def say(s:String) {
        if (here.id ==0) {
            x10.io.Console.OUT.println(s);
        }
    }

}
