/**
*******************************************************************************
* \file PEDist.x10
*
* \brief Implementation of class PEDist
*
* \attention  Copyright (C) 2010-2011 by University of Erlangen-Nuremberg,
*             Chair for Hardware-Software-Co-Design, Germany.
*             All rights reserved.
*
* \author Sascha Roloff
*
*******************************************************************************
*/
package x10.array;

import x10.util.List;
import invasic.ProcessingElement;

public abstract class PEDist extends Dist {
	protected def this(region:Region) {
		super(region);
	}

	abstract public def restriction(pe: ProcessingElement): Dist(rank);
	abstract public def get(pe: ProcessingElement): Region(rank);
	abstract public def pes():List[ProcessingElement];

	abstract public def peForIndex(pt:Point(rank)) : ProcessingElement;
	abstract public def peForIndex(i0 : Int){rank==1} : ProcessingElement;
	public def peForIndex(i0: Int, i1: int) {rank == 2} : ProcessingElement = peForIndex(Point.make(i0,i1));
	public def peForIndex(i0: Int, i1: int, i2: int) {rank == 3} : ProcessingElement = peForIndex(Point.make(i0, i1, i2));
	public def peForIndex(i0: Int, i1: int, i2: int, i3:int) {rank == 4} : ProcessingElement = peForIndex(Point.make(i0, i1, i2, i3));

	public operator this | (pe: ProcessingElement): Dist(rank) = restriction(pe);
	public operator this(pe: ProcessingElement): Region(rank) = get(pe);

	public def toString():String {
		var s:String = "PEDist(";
		var first:boolean = true;
		for (pe:ProcessingElement in pes()) {
			if (!first) s += ",";
			s +=  "" + get(pe) + "->" + pe;
			first = false;
		}
		s += ")";
		return s;
	}
}
public type PEDist(r:Int) = PEDist{self.rank==r};
public type PEDist(r:Region) = PEDist{self.region==r};
public type PEDist(d:Dist) = PEDist{self==d};

/* vim: set noexpandtab */
