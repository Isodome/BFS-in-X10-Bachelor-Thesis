package x10.array;

import x10.compiler.CompilerFlags;
import x10.util.*;
import invasic.*;

public class InvasiveUniqueDist extends PEDist {

    private val pg:PlaceGroup;

    //list of all PEs, sorted by place.
    private val pes:ArrayList[ProcessingElement];

    // let p = pg(i), then offset(i) contains the index of the first PE at place p in the 'pes' list.
    private val offsets: Array[Int](1);

    private transient var regionForHere:Region(this.rank);

    public def this(claim: Claim) {
        // the region of a unique dist is always 0..{count of PEs}
        super(0..claim.processingElements().size());

        pes = new ArrayList[ProcessingElement]();
        val amounts = new HashMap[Place,Int](claim.processingElements().size()*2);
        val tempPeList = claim.processingElements();
        tempPeList.sort( (x:ProcessingElement, y: ProcessingElement) => x.getPlace().id.compareTo(y.getPlace().id));

        // Add every pe to the new list, count PEs per place in 'amounts'
        for (p in tempPeList) {
            pes.add(p);
            val place = p.getPlace();
            val newCount = amounts.getOrElse(place, 0) + 1;
            amounts.put(place, newCount);
        }

        // Create PlaceGroup
        val temp = new ArrayList[Place]();
        temp.addAll(amounts.keySet());
        pg = new SparsePlaceGroup(temp.toArray().sequence());

        // create offset array
        var offset : Int = 0;
        var index  : Int = 0;
        offsets = new Array[Int](pg.size()+1, 0); // offsets is one bigger than required for easier algorithm implementation
        for (place in pg) {
            offsets(index) = offset;
            val length = amounts.getOrThrow(place);
            offset += length;
            index++;
        }
        offsets(index) = pes.size();
    }

    public def places():PlaceGroup = pg;

    public def numPlaces():int = pg.numPlaces();

    public def regions(): Sequence[Region(rank)] {
        return new Array[Region(rank)](pg.size(), (i:Int):Region(rank)=>regionForPlace(pg(i))).sequence();
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

    public def regionForPe(pe:ProcessingElement): Region{self.rank == this.rank} {
        val i = pes.indexOf(pe);
        return (i..i);
    }
    
    public def regionForPlace(place:Place):Region{self.rank == this.rank} {
        val i = pg.indexOf(place);
        val offsetFrom = offset(i);
        val offsetTo = offset(i+1)-1;
        return (offsetFrom..offsetTo);
    }

    private def mapIndexToPlace(index:Int):Place = mapIndexToPe(index).getPlace();

    private def mapIndexToPe(index:Int) :ProcessingElement {
        return pes(index);
    }
    public operator this(p:Place):Region(rank) = get(p);

    public operator this(pt:Point(rank)):Place {
        if (CompilerFlags.checkBounds() && !region.contains(pt)) raiseBoundsError(pt);
        return mapIndexToPlace(pt(0));
    }

    public operator this(i0:int){rank==1}:Place {
        if (CompilerFlags.checkBounds() && !region.contains(i0)) raiseBoundsError(i0);
        return mapIndexToPlace(i0);
    }

    public def offset(pt:Point(rank)):int {
        if (CompilerFlags.checkBounds() && !(pt(0) >= 0 && pt(0) < pes.size())) {
            raiseBoundsError(pt);
        }
        return 0;
    }

    public def offset(i0:int){rank==1}:int {
        if (CompilerFlags.checkBounds() && !(i0 >= 0 && i0 < pes.size())) {
            raiseBoundsError(i0);
        }
        return 0;
    }

    // replicated from superclass to workaround xlC bug with using & itables
    // This code is completely unreachable
    public operator this(i0:int, i1:int){rank==2}:Place {
        throw new UnsupportedOperationException("operator(i0:int,i1:int)");
    }

    // replicated from superclass to workaround xlC bug with using & itables
    // This code is completely unreachable
    public operator this(i0:int, i1:int, i2:int){rank==3}:Place {
        throw new UnsupportedOperationException("operator(i0:int,i1:int,i2:int)");
    }

    // replicated from superclass to workaround xlC bug with using & itables
    // This code is completely unreachable
    public operator this(i0:int, i1:int, i2:int, i3:int){rank==4}:Place {
       throw new UnsupportedOperationException("operator(i0:int,i1:int,i2:int,i3:int)");
    }

    public def maxOffset():int = 0;

    public def restriction(r:Region(rank)):Dist(rank) {
        return new WrappedDistRegionRestricted(this,r);
    }
    public def restriction(p:Place):Dist(rank) {
        return new WrappedDistPlaceRestricted(this, p) as Dist(rank);
    }

    public def peForIndex(pt:Point(rank)) : ProcessingElement {
        if (CompilerFlags.checkBounds() && !region.contains(pt)) raiseBoundsError(pt);
        return mapIndexToPe(pt(0));

    }
    public def peForIndex(i0 : Int){rank==1} : ProcessingElement {
        if (CompilerFlags.checkBounds() && !region.contains(i0)) raiseBoundsError(i0);
        return mapIndexToPe(i0);
    }

    public def restriction(pe:ProcessingElement) :Dist(rank) {
        return new WrappedDistPERestricted(this, pe);
    }

    public def get(pe:ProcessingElement) :Region(rank) {
        return regionForPe(pe);
    }
    
    public def pes(): List[ProcessingElement] {
        return pes.clone();
    }

    public def equals(thatObj:Any):boolean {
        if (thatObj instanceof InvasiveUniqueDist) {
            val that = thatObj as InvasiveUniqueDist;
            return pes.equals(that.pes);
        } else {
            return super.equals(thatObj);
        }
    }

    public def getPoint(id:ProcessingElement) :Point(1) {
        val i = pes.indexOf(id);
        return Point.make(i);
    }
    
}
