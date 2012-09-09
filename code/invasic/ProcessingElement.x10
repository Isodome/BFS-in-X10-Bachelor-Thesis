package invasic;


/** A processing element executes i-lets and represents a hardware core */
public class ProcessingElement {
	private val place:Place;

	public def this(placeNumber:Int) {
		this.place = new Place(placeNumber);
	}

	/** Returns place of the PE */
	public def getPlace() = place;

	// public def equals(pe:Any) {
	// 	val pe1 = pe as ProcessingElement;
	// 	return pr == pe1.pr;
	//}
}