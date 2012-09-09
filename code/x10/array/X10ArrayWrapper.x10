package x10.array;

import x10.util.HashMap;

import invasic.Claim;

public class X10ArrayWrapper {
	/* distribute array (remote array) */
	public static def distributeArray[T](r:Region{rect==true}, claim:Claim){T haszero} {
		return distributeArray[T](r, claim.size());
	}

	public static def distributeArray[T](r:Region{rect==true}, n:int){T haszero} {
		val regions = splitRegion(r, n);
		val arrayMap = new HashMap[int, RemoteArray[T]]();
		for([i] in 0..(n-1)) {
			val arr = new RemoteArray[T](new Array[T](regions(i)));
			arrayMap.put(i, arr);
		}
		return arrayMap;
	}
	
	/* duplicate array (remote array) */
	public static def duplicateArray(r:Region{rect==true}, claim:Claim) {
		return duplicateArray(r, claim.size());
	}
	
	public static def duplicateArray(r:Region{rect==true}, n:int) {
		val arrayMap = new HashMap[int, RemoteArray[int]]();
		for([i] in 0..(n-1)) {
			val arr = new RemoteArray[int](new Array[int](r));
			arrayMap.put(i, arr);
		}
		return arrayMap;
	}

	public static def splitRegion(r:Region{rect==true}, n:int) {
		val array = new Array[Region{rect==true}](n);

		/* information about the region to partition */
		val b = r.boundingBox();
		val min = b.min(0);
		val max = b.max(0);
		val numElems = max - min + 1;
		/* calculate the partition size for all PEs */
		val blockSize = numElems/n;
		val leftOver = numElems - n*blockSize;
		
		for([i] in 0..(n-1)) {
			/* calculate the boundaries for the specific PE */
			val low = min + blockSize*i + (i< leftOver ? i : leftOver);
			val hi = low + blockSize + (i < leftOver ? 0 : -1);

			/* assume a rect region */
			val newMin = new Array[int](r.rank, (i:int) => r.min(i));
			val newMax = new Array[int](r.rank, (i:int) => r.max(i));
			newMin(0) = low;
			newMax(0) = hi;
			
			array(i) = new RectRegion(newMin, newMax);
		}
		
		return array;
	}
	
	public static def print1DArray(a:Array[int](1){rect==true}) {
		for([i] in a) {
			Console.OUT.printf("%5d ", a(i));
		}
		Console.OUT.println();
	}

	public static def print2DArray(a:Array[int](2){rect==true}) {
		for([i] in a.region.projection(0)) {
			for([j] in a.region.projection(1)) {
				Console.OUT.printf("%5d ", a(i,j));
			}
			Console.OUT.println();
		}
	}
}