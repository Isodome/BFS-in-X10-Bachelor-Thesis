package bfs;

import x10.array.PlaceGroup;
import x10.lang.*;
import x10.util.ArrayBuilder;

public class Grid {


    public val rows : Int;
    public val cols : Int;
    private val pg : PlaceGroup;
    private transient var myPoint : Point(2);
    private val n : Int;

    public val rowSize : Int;
    public val colSize : Int;

    private var placesByRow : Array[PlaceGroup];
    private var placesByCol : Array[PlaceGroup];

    private def this (rows : Int, cols : Int, pg : PlaceGroup, n : int ) {
        // saving attributes
        this.rows = rows;
        this.cols = cols;
        this.pg = pg;
        this.n=n;

        // calculating the width of each column and the height of each row
        var colSize : Int = n / cols;
        if (colSize * cols < n) {
            colSize++;
        }

        var rowSize : Int = n / rows;
        if (rowSize * rows < n) {
            rowSize++;
        }

        this.rowSize = rowSize;
        this.colSize = colSize;

        // generate Placegroups per row and col
    }

    private def fillPlaceGroups() {

        val rowPlacesTemp = new Array[ArrayBuilder[Place]](rows, (i:Int) => new ArrayBuilder[Place]());
        val colPlacesTemp = new Array[ArrayBuilder[Place]](cols, (i:Int) => new ArrayBuilder[Place]());
        for (var i:int = 0; i< rows; i++) {
            for (var j:int = 0; j< cols; j++) {
                val pl = getPlaceForGridPosition(i,j);
                rowPlacesTemp(i).add(pl);
                colPlacesTemp(j).add(pl);
            }
        }

        placesByRow = new Array[PlaceGroup](rows, (i:Int)=> new SparsePlaceGroup(rowPlacesTemp(i).result().sequence() ));
        placesByCol = new Array[PlaceGroup](cols, (i:Int)=> new SparsePlaceGroup(colPlacesTemp(i).result().sequence() ));

    }

    public static def make(rows : Int, cols : Int, pg : PlaceGroup, n : int) : Grid {
        if (rows * cols != pg.size()) {
            throw new IllegalArgumentException("Number of Places does not equal rows * cols");
        }
        val g = new Grid(rows, cols, pg, n);
        g.fillPlaceGroups();
        return g;
    }

    public static def make (pg: PlaceGroup, n: int) {
        val rows = findRowCount(pg.size());
        Console.OUT.println(rows + "x"+ pg.size()/rows + " chosen (" + rows + " rows, " + pg.size()/rows + " columns)");
        return make(rows, pg.size()/rows, pg, n);
    }

    private static def findRowCount(numPlaces:int) : int {
        val sqrtD = Math.sqrt(numPlaces as Double) + 0.5; // in case the sqrt is an Integer, add 0.5 to get the correct result after rounding up; 
        var rows : int = sqrtD as int;
        while (numPlaces % rows != 0 && rows > 1) {
            rows--;
        }
        return Math.max(1, rows);
    }


    public def getPlaceForGridPosition(i0:int, i1:int) : Place {
        val index : Int = getPlaceIDForGridPosition(i0,i1);
        return pg(index);
    }

    public def getPlaceIDForGridPosition(i0:int, i1:int) :int {
        return i0 * cols + i1;
    }

    public operator this(i0:int, i1:int) : Place {
        return getPlaceForGridPosition(i0/ rowSize, i1 / colSize);
    }

    public def places() : PlaceGroup {
        return pg;
    }
    public def getMyPosition() : Point {
        val idx = pg.indexOf(here);
         
        return Point.make(getRowForGroupIndex(idx), getColumnForGroupIndex(idx));
    }

    public def getPlacesForRow(val i:int) : PlaceGroup {
        return this.placesByRow(i);
    }

    public def getPlacesForColumn(val i:int) : PlaceGroup {
        return this.placesByCol(i);
    }
    public def getColumnForPlace(val p:Place) : Int {
        return p.id % cols;
    }
    public def getRowForPlace(val p:Place) : Int {
        return p.id / cols;
    }

    private def getColumnForGroupIndex(i:Int) :Int {
        return i % cols;
    }
    private def getRowForGroupIndex(i:Int) :Int {
        return i / cols;
    }
}
