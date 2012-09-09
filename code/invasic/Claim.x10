package invasic;

import x10.util.*;

public class Claim {

	private val list : List[ProcessingElement];

	public def this(list : List[ProcessingElement]) {
		this.list = list;
	}

	public def processingElements():List[ProcessingElement] = list;
	public def size():int = list.size();

	/** Returns a string representing this claim */
	public def toString():String = "(Claim "+size()+" PE)";

	/** Get a set of all places of the PEs in the claim */
	public def places():Set[Place] {
		val ps = new HashSet[Place]();
		for (pe in processingElements()) {
			ps.add(pe.getPlace());
		}
		return ps;
	}
}

