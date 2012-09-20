package x10.array;

import x10.compiler.CompilerFlags;

import x10.util.List;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.lang.Math;
import x10.array.RectRegion;

import invasic.*;
public class InvasiveBlockDist extends PEDist {

    private val pg:PlaceGroup;
    private val pes:ArrayList[ProcessingElement] = new ArrayList[ProcessingElement]();
    private val sortedPlaceIndexOfPe:Array[Int];
    private val offsets: Array[Int](1);
    private val segments:Int;
    private val axis:Int;

    private transient var regionForHere:Region(this.rank);

    public def this(claim:Claim, region:Region) = this(claim,region, 0);

    public def this(claim: Claim, region:Region, axis:int) {
        super(region);
        this.axis = axis;
        segments = claim.processingElements().size();

        val amounts = new HashMap[Place,Int](segments*2);
        val tempPeList = claim.processingElements();
        tempPeList.sort( (x:ProcessingElement, y: ProcessingElement) => x.getPlace().id.compareTo(y.getPlace().id));
        

        for (p in tempPeList) {
            pes.add(p);
            val place = p.getPlace();
            val newCount = amounts.getOrElse(place, 0) + 1;
            amounts.put(place, newCount);
        }
        // Create PlaceGroup
        val temp = new ArrayList[Place]();
        temp.addAll(amounts.keySet());
        temp.sort( (x:Place, y: Place) => x.id.compareTo(y.id));
        pg = new SparsePlaceGroup(temp.toArray().sequence());

        var offset : Int = 0;
        var index  : Int = 0;
        offsets = new Array[Int](pg.size()+1, segments);
        for (place in pg) {
            offsets(index) = offset;
            val length = amounts.getOrThrow(place);
            offset += length;
            index++;
        }
        val localPg = pg;
        sortedPlaceIndexOfPe = new Array[Int](tempPeList.size(), (i:Int)=> localPg.indexOf(tempPeList(i).getPlace()));

    }

    public def places():PlaceGroup = pg;

    public def numPlaces():int = pg.numPlaces();

    public def regions():Sequence[Region(rank)] {
    	return new Array[Region(rank)](pg.numPlaces(), (i:int)=>regionForPlace(pg(i))).sequence();
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


    private def regionForPe(pe: ProcessingElement): Region{self.rank == this.rank} {
        val b = region.boundingBox();
        val min = b.min(axis);
        val max = b.max(axis);
        val numElems = max - min + 1;
        val blockSize = numElems/segments +1;
        val leftOver = numElems - segments*blockSize;
        val i = pes.indexOf(pe);
        val low = min + blockSize*i;
        val hi = Math.min(low + blockSize-1, max);

        if (region instanceof RectRegion) {
            // Optimize common case.
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
    /**
     * Computes the region for the given place
     *
     */
    private def regionForPlace(place:Place):Region{self.rank == this.rank} {
        val b = region.boundingBox();
        val min = b.min(axis);
        val max = b.max(axis);
        val numElems = max - min +1;
        val blockSize = numElems / segments + 1;
        val leftOver = numElems - segments * blockSize;
        val i = pg.indexOf(place);
        if(i == -1) {
            return Region.makeEmpty(rank);
        }
        val offsetFrom = offsets(i);
        val length     = offsets(i+1) - offsetFrom;
        
        val low = min + blockSize * offsetFrom;
        val hi =  Math.min( low + blockSize * length -1, max);
        
        if (region instanceof x10.array.RectRegion) {
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

    private def mapIndexToPlace(index:int):Place = mapIndexToPe(index).getPlace();

    private def mapIndexToPe(index:int):ProcessingElement = pes(mapIndexToPeIndex(index));

    private def mapIndexToPeIndex(index:int):Int {
        val bb  = region.boundingBox();
        val min = bb.min(axis);
        val max = bb.max(axis);
        val numElems = max - min + 1;
        val blockSize = numElems / segments + 1;
        val leftOver = numElems - segments*blockSize;
        val normalizedIndex = index-min;

        val nominalSegNum = normalizedIndex/blockSize;

        return nominalSegNum;
    }

    public def getSortedPlaceindexOfPoint(i0: Int) {
        val peIndex = mapIndexToPeIndex(i0);
        return sortedPlaceIndexOfPe(peIndex);
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
        if (!(thatObj instanceof InvasiveBlockDist)) return false;
        val that = thatObj as InvasiveBlockDist;
        return this.pg.equals(that.pg) && this.region.equals(that.region) && this.axis.equals(that.axis);
    }


    // invasic specific methods

    public def restriction(pe:ProcessingElement) : Dist(rank) {
        return null as Dist(rank);
        //return new WrappedDistPERestricted(this, pe);
    }

    public def get(pe : ProcessingElement) : Region(rank) {
        return regionForPe(pe); 
    }

    public def pes() : List[ProcessingElement] {
        return pes.clone();
    }

    public def peForIndex(pt:Point(rank)) : ProcessingElement {
        if (CompilerFlags.checkBounds() && !region.contains(pt)) raiseBoundsError(pt);
        return mapIndexToPe(pt(axis));

    }
    public def peForIndex(i0 : Int){rank==1} : ProcessingElement {
        if (CompilerFlags.checkBounds() && !region.contains(i0)) raiseBoundsError(i0);
        return mapIndexToPe(i0);
    }
    public def peForIndex(i0: Int, i1: int) {rank == 2} : ProcessingElement{
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1)) raiseBoundsError(i0,i1);
        switch(axis) {
            case 0: return mapIndexToPe(i0);
            case 1: return mapIndexToPe(i1);
            default: return null as ProcessingElement; // UNREACHABLE
        }
    }
    public def peForIndex(i0: Int, i1: int, i2: int) {rank == 3} : ProcessingElement{
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1, i2)) raiseBoundsError(i0,i1,i2);
        switch(axis) {
            case 0: return mapIndexToPe(i0);
            case 1: return mapIndexToPe(i1);
            case 2: return mapIndexToPe(i2);
            default: return null as ProcessingElement; // UNREACHABLE
        }
    }
    public def peForIndex(i0: Int, i1: int, i2: int, i3:int) {rank == 4} : ProcessingElement {
        if (CompilerFlags.checkBounds() && !region.contains(i0, i1, i2, i3)) raiseBoundsError(i0,i1,i2,i3);
        switch(axis) {
            case 0: return mapIndexToPe(i0);
            case 1: return mapIndexToPe(i1);
            case 2: return mapIndexToPe(i2);
            case 3: return mapIndexToPe(i3);
            default: return null as ProcessingElement; // UNREACHABLE
        }

    }

}
