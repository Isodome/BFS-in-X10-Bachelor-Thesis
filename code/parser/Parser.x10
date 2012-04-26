package parser;
import parser.GraphStructure;

public interface Parser {
	def parse(gs :GraphStructure, filename :String): void;
}
