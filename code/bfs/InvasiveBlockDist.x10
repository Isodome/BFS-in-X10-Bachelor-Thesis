package bfs;

import x10.compiler.CompilerFlags;

import x10.util.HashMap;
import x10.lang.Math;
class InvasiveBlockDist extends InvasiveDist {

    private val pg:PlaceGroup;
    private val pes:Array[ProcessingElement];
    private val offsets: Array[Int](1);
    private val segments:Int;
    private val axis:Int = 0;

    private transient var regionForHere:Region(this.rank);

    def this(claim:Claim, region:Region) = this(claim,region, 0);

    def this(claim: Claim, region:Region, axis:int) {
        super(region);
        this.axis = axis;
        segments = claim.processingElements().size();
        pes = new Array[ProcessingElement](segments, null as ProcessingElement);
       
        val amounts = new HashMap[Place,Int](segments*2);
        val tempPeList = claim.processingElements();
        tempPeList.sort( (x:ProcessingElement, y: ProcessingElement) => x.getPlace().id.compareTo(y.getPlace().id));

        var idx : Int = 0;
        for (p in tempPeList) {
            pes(idx) = p;
            idx++;
            val place = p.getPlace();
            val newCount = amounts.getOrElse(place, 0) + 1;
            amounts.put(place, newCount);
        }
        // Create PlaceGroup
        val temp = new ArrayList[Place]();
        temp.addAll(amounts.keySet());
        pg = new SparsePlaceGroup(temp.toArray().sequence());

        var offset : Int = 0;
        var index  : Int = 0;
        offsets = new Array[Int](numPlaces()+1, 0);
        for (place in pg) {
            val length = offsets.getOrThrow(place);
            offsets(index) = offset;
            offset += length;
            index++;
        }
        offsets(index) = segments;
    }

    public def places():PlaceGroup = pg;

    public def numPlaces():int = pg.numPlaces();

    public def regions():Sequence[Region(rank)] {
        return new Array[Region(rank)](pg.numPlaces(), (i:int)=>blockRegionForPlace(pg(i))).sequence();
    }

    public def get(p:Place):Region(rank) {
        if(p == here) {
            if (regionForHere == null) {
                regionForHere = regionForPlace(here);    
            }
            return regionForHere;
        } else {
           return regionForPlace(p); 
        }
    }
    /**
     * Computes the region for the given place
     *
     */
    private def regionForPlace(place:Place):Regio{self.rank == this.rank} {
        val b = region.boundingBox();
        val min = b.min(axis);
        val max = b.max(axis);
        val numElems = max - min +1;
        val blockSize = numElems / segments + 1;
        val leftOver = numElems = segments * blockSize;
        val i = pg.indexOf(place);

        val offsetFrom = offset(i);
        val offsetTo   = offset(i+1);

        val low = min + blockSize * offsetFrom;
        val hi =  Math.min( min + blockSize * offsetTo, max);
        if (region instanceof RextRegion) {
            val newMin = new Array[Int](rank, (i:Int) => region.min(i));
            val newMax = new Array[Int](rank, (i:Int) => region.max(i));
            newMin(axis) = low;
            newMax(axis) = hi;
            return new RectRegion(newMin, newMax);
        } else if (region instanceof RectRegion1D) {
            return new RectRegion1D(low, hi) as Region(rank);
        } else {
            // General case handled via region algebra
            val r1 = Region.makeFull(axis);
            val r2 = low..hi;
            val r3 = Region.makeFull(region.rank-axis-1);
            return (r1.product(r2).product(r3) as Region(region.rank)).intersection(region);
        }

    }

    private def mapIndexToPlace(index:int):Place {
        val bb  = region.boundingBox();
        val min = bb.min(axis);
        val max = bb.max(axis);
        val numElems = max - min + 1;
        val blockSize = numElems / segments;
        val leftOver = numElems - sements*blockSize;
        val normalizedIndex = index-min;

        val nominalSegNum = normalizedIndex/(blockSize+1);

        return pes(nominalSegNum).getPlace();
    }


    public operator this(p:Place):Region(rank) = get(p);
    public operator this(pt:Point(rank)):Place {
    	if (CompilerFlags.checkBounds() && !region.contains(pt)) raiseBoundsError(pt);
        return mapIndexToPlace(pt(axis));
    }

    public operator this(i0:int){rank==1}:Place {
        if (CompilerFlags.checkBounds() && !region.contains(i0)) raiseBoundsError(i0);
        return mapIndexToPlace(i0);
    }

    public operator this(i0:int, i1:int){rank==2}:Place {
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1)) raiseBoundsError(i0,i1);
        switch(axis) {
        case 0: return mapIndexToPlace(i0);
        case 1: return mapIndexToPlace(i1);
        default: return here; // UNREACHABLE
        }
    }

    public operator this(i0:int, i1:int, i2:int){rank==3}:Place {
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1, i2)) raiseBoundsError(i0,i1,i2);
        switch(axis) {
        case 0: return mapIndexToPlace(i0);
        case 1: return mapIndexToPlace(i1);
        case 2: return mapIndexToPlace(i2);
        default: return here; // UNREACHABLE
        }
    }

    public operator this(i0:int, i1:int, i2:int, i3:int){rank==4}:Place {
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1, i2, i3)) raiseBoundsError(i0,i1,i2,i3);
        switch(axis) {
        case 0: return mapIndexToPlace(i0);
        case 1: return mapIndexToPlace(i1);
        case 2: return mapIndexToPlace(i2);
        case 3: return mapIndexToPlace(i3);
        default: return here; // UNREACHABLE
        }
    }

        public def offset(pt:Point(rank)):int {
        val r = get(here);
        val offset = r.indexOf(pt);
        if (offset == -1) {
            if (CompilerFlags.checkBounds() && !region.contains(pt)) raiseBoundsError(pt);
            if (CompilerFlags.checkPlace()) raisePlaceError(pt);
        }
        return offset;
    }


    public def offset(i0:int){rank==1}:int {
        val r = get(here);
        val offset = r.indexOf(i0);
        if (offset == -1) {
            if (CompilerFlags.checkBounds() && !region.contains(i0)) raiseBoundsError(i0);
            if (CompilerFlags.checkPlace()) raisePlaceError(i0);
        }
        return offset;
    }

    public def offset(i0:int, i1:int){rank==2}:int {
        val r = get(here);
        val offset = r.indexOf(i0,i1);
        if (offset == -1) {
            if (CompilerFlags.checkBounds() && !region.contains(i0,i1)) raiseBoundsError(i0,i1);
            if (CompilerFlags.checkPlace()) raisePlaceError(i0,i1);
        }
        return offset;
    }

    public def offset(i0:int, i1:int, i2:int){rank==3}:int {
        val r = get(here);
        val offset = r.indexOf(i0,i1,i2);
        if (offset == -1) {
            if (CompilerFlags.checkBounds() && !region.contains(i0,i1,i2)) raiseBoundsError(i0,i1,i2);
            if (CompilerFlags.checkPlace()) raisePlaceError(i0,i1,i2);
        }
        return offset;
    }

    public def offset(i0:int, i1:int, i2:int, i3:int){rank==4}:int {
        val r = get(here);
        val offset = r.indexOf(i0,i1,i2,i3);
        if (offset == -1) {
            if (CompilerFlags.checkBounds() && !region.contains(i0,i1,i2,i3)) raiseBoundsError(i0,i1,i2,i3);
            if (CompilerFlags.checkPlace()) raisePlaceError(i0,i1,i2,i3);
        }
        return offset;
    }

    public def maxOffset() {
        val r = get(here);
        return r.size()-1;
    }
        
    public def restriction(r:Region(rank)):Dist(rank) {
        return new WrappedDistRegionRestricted(this, r) as Dist(rank); // TODO: cast should not be needed
    }

    public def restriction(p:Place):Dist(rank) {
        return new WrappedDistPlaceRestricted(this, p) as Dist(rank); // TODO: cast should not be needed
    }


    public def equals(thatObj:Any):boolean {
        if (this == thatObj) return true;
        if (!(thatObj instanceof InvasiveDist)) return false;
        val that = thatObj as InvasiveDist;
        return this.pg.equals(that.pg) && this.region.equals(that.region) && this.axis.equals(that.axis);
    }
}
