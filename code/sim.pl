use strict;
use Term::ANSIColor qw(:constants);
use File::Basename;
my @modes = qw(serial_list serial_matrix 1d_list 1d_matrix 2d_matrix 2d_list_alt);

my $bfs = "./bfs_start";
my $resultFolder = "simresults";

my $num_args = $#ARGV + 1;
if ($num_args < 1) {
	die "Usage: sim.pl <file> (startnode)";
}
my $file = @ARGV[0];
if (not (-e $file)) {
	die "Error! File '$file' does not exist";
}
my $basename = basename($file);
my $startnode = 0;
if ($num_args > 1) {
	$startnode = @ARGV[1];
}
# start magic

print GREEN, "creating folder 'sim_results':\n", RESET;
mkdir($resultFolder);

print GREEN, "Compiling program\n", RESET;
if (system("make", "cpp") != -0) {
	print RED, "make failed!\n", RESET;
	exit -1;
}

#############################
# Execute bfs with every algorithm
##############################
my @resultFiles;
for (@modes) { # current value in $_
	my $outputfile = $resultFolder."/".$basename."_".$_.".txt";	
	print GREEN, "Running simulation in $_ mode, starting from node $startnode \n", RESET;
    my $answer = system($bfs, "-alg", $_, "-o", $outputfile, "-start", $startnode, $file);
	if ($answer != 0){
        print $answer;
		print RED, "Simulation with graph $file and mode $_ failed\n", RESET;
		exit -1;
	}
	push(@resultFiles, $outputfile);
}

#############################
# Diff all results to guess the correctness
##############################
my $num_files = $#resultFiles; # note: num_files is the size of the array -1 !
my $failedDiffs = 0;
for (my $i = 0 ; $i < $num_files; $i++) {
	my $file1 = @resultFiles[$i];
	my $file2 = @resultFiles[$i+1];
	my $result = `diff  $file1 $file2`;  

	if (length($result) >0) {
		print RED "WARNING: ".$file1." and ".$file2." differ!\n", RESET;
		$failedDiffs++;
	}
}
if ($failedDiffs == 0) {
	print GREEN, "All diffs successful\n", RESET;
} else {
	print RED, $failedDiffs." diffs failed!\n", RESET;
}
