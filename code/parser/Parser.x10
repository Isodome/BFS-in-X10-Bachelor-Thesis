package parser;
abstract class Parser {
	abstract parse(gs :GraphStructure, filename :String){filename != null && gs != null};
}
