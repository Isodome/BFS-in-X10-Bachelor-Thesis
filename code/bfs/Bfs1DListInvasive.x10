package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import parser.*;
import Bfs;


import invasic.*;

public class Bfs1DListInvasive extends BfsAlgorithm {

    private static val INF : Int = Bfs.INF;
    private transient var localAdjacency : Array[ArrayList[Int]](1);
    private var vertexCount: Int = 0;
    private var adj : DistArray[ArrayList[Int]](1);
    private var bfsDistance : DistArray[Int](1);
    private transient val claim : Claim;

    private transient var placeToPe : HashMap[Place, List[ProcessingElement]];
    private var sortedPlacesList : PlaceGroup;

    private var receiveBuffer : DistArray[Array[ArrayList[Int]]](1);
    private var sendBuffer : DistArray[Array[ArrayList[Int]]];
    private var current : DistArray[Array[ArrayList[Int]]];
    private var dTemp :DistArray[Array[Boolean]];

    private var currentBfsDepth : Int;

    public def this(list : List[ProcessingElement]) {
    	super();
    	this.claim = new Claim(list);
    }

    public def setVertexCount(vertexCount: Int) {
        this.vertexCount = vertexCount;
        localAdjacency = new Array[ArrayList[Int]](vertexCount, (i:Int)=>new ArrayList[Int]());
    }

    public def addEdge(from : Int, to : Int) {
        assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
            localAdjacency(from).add(to);
    }

    public def addEdge(from : Int, to : Array[Int]) {
        for (i in to) {
            localAdjacency(from).add(to(i));
        }
    }
    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >=0 && numberToCheck < vertexCount;
    }
    public def getNodeCount() : Int {
        return vertexCount; 
    }
    public def finished() : void {
        spreadData(claim);
        generateSortedPlacesListForClaim(claim);
    }

    private def spreadData(claim : Claim) :void {
        val dist = new InvasiveBlockDist(claim, 0..(vertexCount-1));
        adj = DistArray.make[ArrayList[Int]](dist, (i:Point) => new ArrayList[Int]());
        bfsDistance =  DistArray.make[Int](dist, INF);


        finish for (place in adj.dist.places()) async {
        	val myRegion = adj.dist.get(place);
        	val copyBuf = new Array[ArrayList[Int]](myRegion, (i:Point) => localAdjacency(i));
        	at(place) {
        		for (idx in myRegion) {
        			adj(idx) = copyBuf(idx);
        		}
        	}
        }
        localAdjacency = null; // feed to garbage collection
    }

    private def generateSortedPlacesListForClaim(val claim : Claim) {
        sortedPlacesList = bfsDistance.dist.places(); // the invasive distribution holds an sorted list!
        placeToPe =  new HashMap[Place,List[ProcessingElement]](sortedPlacesList.size());
        for (pe : ProcessingElement in claim.processingElements()) {
            var peListOfCurrentPlace : List[ProcessingElement] = placeToPe.getOrElse(pe.getPlace(), null as List[ProcessingElement]);
            if (peListOfCurrentPlace == null) {
                peListOfCurrentPlace = new ArrayList[ProcessingElement]();
                placeToPe.put(pe.getPlace(), peListOfCurrentPlace);
            }
            peListOfCurrentPlace.add(pe);
        }
    }

    public def run(start : Int) : Array[Int](1) {

        //say("Bfs1DListInvasive::Run()");
        receiveBuffer = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](sortedPlacesList.size(), (i:Int)=> new ArrayList[Int]()));
        sendBuffer    = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](sortedPlacesList.size(), (i:Int)=> new ArrayList[Int]()));
        dTemp         = DistArray.make[Array[Boolean]](Dist.makeUnique(), (i:Point) =>  new Array[Boolean](vertexCount, false) );

        current       = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), null as Array[ArrayList[Int]] );
        //say("1");
        finish for(place in placeToPe.keySet()) {
            val pesOnThatPlace = placeToPe.getOrThrow(place).size();
            async at(place) {        
                dTemp(here.id)(start) = true;
                current(here.id) = new Array[ArrayList[Int]](pesOnThatPlace, (i:Int)=> new ArrayList[Int]());
                if(bfsDistance.dist(start) == here) {
                    bfsDistance(start) = 0;
                    current(here.id)(0).add(start);
                }
            }
        }
        //say("2");

        val result_local : Array[Int](1) = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int](1)](result_local);

        currentBfsDepth = 1;
        var done:Boolean = false;
        while (!done) {
        	done = infect();
        	currentBfsDepth++;
            //say("3," + currentBfsDepth + " done:" + done);

        }
        //say("Algo done");
        // Copy place-local content of d in result array at place 0
        finish for (place in bfsDistance.dist.places()) async at(place) {
        	val localPortion = this.bfsDistance.getLocalPortion();
        	at(resultRef) {
        		val r :Array[Int] = resultRef();
	        	for (i : Point(1) in localPortion) {
	        		r(i) = localPortion(i);
	        	}
        	}
        }
        return result_local;
    }

    private def infect() : Boolean {


    	val result = new Array[Cell[Boolean]](placeToPe.keySet().size(), (i:Int)=> Cell.make[Boolean](false));

    	var startIndex : Int = 0;
    	var arrayIdx : Int = 0;

    	finish {
    		val globalClock = Clock.make();
    		for (place in placeToPe.keySet()) {
	    		val peListOfCurrentPlace = placeToPe.getOrThrow(place);
	    		val callback = new GlobalRef[Cell[Boolean]](result(arrayIdx));
	    		val startIndexForCurrentPlace = startIndex;
	    		async clocked(globalClock) {
	    			at(place) infectOnThisPlace(startIndexForCurrentPlace, peListOfCurrentPlace, callback, globalClock);
	    		}
	    		arrayIdx++;
	    		startIndex += peListOfCurrentPlace.size();
    		}
    		globalClock.drop();
    	}

    	return result.reduce( (a:Boolean, b:Cell[Boolean])=>{ return a && b(); }, true );
    }

    private def infectOnThisPlace(peStartIndexOfCurrentPlace: Int, peListOfCurrentPlace: List[ProcessingElement], callback: GlobalRef[Cell[Boolean]], globalClock: Clock) {
    	var idx : Int = 0;
    	var done : Boolean = true;
    	val peCount = peListOfCurrentPlace.size();
    	finish {
    		val teamClock = Clock.make();
    		for (pe in peListOfCurrentPlace) {
	    		val constIdx = idx;
	    		async  clocked (teamClock, globalClock){
	    			if (!iterate(new IncarnationID(peStartIndexOfCurrentPlace + constIdx, pe), constIdx, peCount, teamClock, globalClock)) {
	    				done = false;
	    			}
	    		}
	    		idx++;
	    	}
    		teamClock.drop();
    		globalClock.drop();
    	}

    	val constDone = done;
    	at(callback) {
    		callback()() = constDone;
    	}
    }


    private def getSubregion(localId:Int, localSum:Int, size: Int) :IntRange {
    	val blocksize = (size / localSum) + 1;
    	val min = localId * blocksize;
        val max = min + blocksize;
    	if (min < size) {
    		return new IntRange(min, Math.min(max, size));
    	} else {
    		return new IntRange(0,0);
    	}
    }

    private def iterate(id: IncarnationID, localId:Int, localSum:Int, teamClock:Clock, globalClock: Clock) : Boolean {

    	val current = this.current(here.id);
    	val dTemp = this.dTemp(here.id);
    	val sendBuffer = this.sendBuffer(here.id);
    	val receiveBuffer : Array[ArrayList[Int]] = receiveBuffer(here.id);

        val invasiveDist : InvasiveBlockDist = this.bfsDistance.dist as InvasiveBlockDist;

        val totalActiveElements = current.reduce( (a:Int, b:ArrayList[Int])=>{ return a + b.size(); }, 0);
    	val thisRegion = getSubregion(localId, localSum, totalActiveElements);
        var min : Int = thisRegion.min;
        val length = thisRegion.max - min;
        var listIndex : Int =0;
        //say("local:" + localId + " Min: " + min + ", length: " + length);
        for (var counter:Int = length; counter > 0; ) {
            while (min >= current(listIndex).size()) {
                min -= current(listIndex).size();
                listIndex++;
            }

            val upperBoundForThisList: Int = Math.min(current(listIndex).size(), min + counter);
            val elementsTakenFromThisList = upperBoundForThisList - min;
            counter -= elementsTakenFromThisList;

            for(var localCounter: Int=min; localCounter < upperBoundForThisList; localCounter++) {
                val from = current(listIndex)(localCounter);
                for (to in adj(from)) {
                    //say("reachable:" + to + " localid" + localId);
                    if (!dTemp(to)) {
                        val targetPlaceId =  invasiveDist.getSortedPlaceindexOfPoint(to);
                        atomic sendBuffer(targetPlaceId).add(to);
                        dTemp(to) = true;
                        //say("added to " + targetPlaceId + " what means " + sortedPlacesList(targetPlaceId));
                    }
                }
            }

            min = current(listIndex).size(); // This approach is never wrong!
        }
        teamClock.advance();
        current(localId).clear();

        

        // Phase 2: Pushing sending buffers to receive buffers
        val sourcePlace = here;
        val sourcePlaceId = bfsDistance.dist.places().indexOf(sourcePlace);
        //say("phase2 ");
        finish for (var targetPlaceId: Int = localId; targetPlaceId < sortedPlacesList.size(); targetPlaceId+=localSum) {

            val buffer : ArrayList[Int] = sendBuffer(targetPlaceId);
            //say("I'll push " + buffer + " to " + targetPlaceId);

            if (!buffer.isEmpty()) {
                if (targetPlaceId == sourcePlaceId) {
                    receiveBuffer(sourcePlaceId) = buffer;
                    sendBuffer(targetPlaceId) = new ArrayList[Int]();
                    //say("Pushed " + buffer + " from " + sourcePlaceId + " to " + targetPlaceId);
                } else {
                    val recBuffer = this.receiveBuffer; // prevent from using this-pointer in at()
                    val constTargetPlaceId = targetPlaceId;
                    async {
                        at (sortedPlacesList(constTargetPlaceId)) {
                            //say("Copied " + buffer + " from " + sourcePlaceId + " to " + constTargetPlaceId);
                            recBuffer(here.id)(sourcePlaceId) = buffer;
                        }
                        buffer.clear(); // only clean the local copy, even if targetPlace and sourcePlace are even!
                    }
                }
            }
        }

        globalClock.advance();
        // Phase 3: Update BFS distance and fille currents for next round
        //say("Phase 3");
        for (iBuf in receiveBuffer) {
        	if (iBuf(0) % localSum == localId) {
                //say(" receivebuffer is " + receiveBuffer(iBuf));
	            for (vertex in receiveBuffer(iBuf)) {
	                if (bfsDistance(vertex) == INF) {
	                	this.bfsDistance(vertex) = currentBfsDepth;
	                    current(localId).add(vertex);
	                }
	            }
	            receiveBuffer(iBuf).clear();
        	}
        }
        //say("current " + current(localId));
        return (current(localId).size() == 0); // Some PEs might return true, in case they return before another pe puts elements into the list.
    }


    static public def say(s:String) {
        x10.io.Console.OUT.println("["+here.id+"] "+s);
    }

}


