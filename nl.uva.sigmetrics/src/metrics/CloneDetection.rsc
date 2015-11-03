module metrics::CloneDetection

import util::IO;

import IO;
import List;
import Map;
import String;
import util::Math;

data DuplicateResult = dupres(real percentage, int totalSize, set[Line] lines);

@javaClass{nl.uva.sigmetrics.HashUtils}
public java int hashCode(str s);

@doc {
	Computes the duplicates in an ordered list of lines, given a list of lines
	and the size of the block. Note input lines are	assumed to be stripped and trimmed.
	
	The SIG model is somewhat unclear on the definition of what a % of code actually
	means. We've
	
	
	The duplication check algorithm is relatively simple:
	 - For each line:
	 	+ compute the hash of the block starting at that line
	 - Add these hashes in a map (hash -> [line index])
	 - Every hash with multiple matches indicates a block duplication
	 - Using the starting position of the block, create a set of all duplicated lines
	 
	 Using a set for duplicated lines takes care of overlap as well as blocks larger than
	 the minimum block size. It does however also mark the 'source' of a duplication as a
	 duplication, 
	 
	 One instance where this algorithm *does* fail is if the code contains exactly identical 
	 lines, repeated up to the block size. Suppose blockSize=2:
	 	print();
	 	print();
	 	print();
	 	
	 This marks all lines as duplicates, which is not likely to be the case. Come to think
	 of it, perhaps marking all lines
	  
}
public set[Line] findDuplicates(list[Line] lines, int minBlockSize = 6) {
	assert minBlockSize > 0 : "use a positive block size";
	assert lines != [] : "input lines may not be empty";
		
	// For each block, compute its hash and starting line number. 
	map[int, list[int]] hashLines = ();
	
	int nLines = size(lines);
	for (ix <- [0 .. nLines]) {
		Line line = lines[ix];
				
		// Add hashcode to map if within range.
		if (ix <= nLines - minBlockSize) {
			str block = (line.s | it + lines[ix + i].s | int i <- [0 .. minBlockSize]);
			int hash = hashCode(block);
			if (hash in hashLines) hashLines[hash] += ix;
			else hashLines[hash] = [ix];
		}
	}
			
	// Create the set of lines which are duplicated somewhere.
	set[int] dupes = {};
	for (dupLines <- [hashLines[h] | h <- domain(hashLines), size(hashLines[h]) > 1]) {
		for (ix <- dupLines) {
			dupes += { l | l <- [ix .. (ix + minBlockSize)] }; 
		}
	}
	
	return { lines[d] | d <- dupes };
}


@doc{ Test runner which operates on int lists to simplify testing. }
bool runTest(list[int] elements, set[int] expected, int minBlockSize = 6) {
	set[List] dupes = findDuplicates([ line("<i>", |file://unknown|, 0) | i <- elements ], minBlockSize=minBlockSize);
	return { toInt(s) | line(s, _, _) <- dupes } == expected;
}

test bool t1() = runTest([1,1,1,1], {1,1,1,1}, minBlockSize=1);
test bool t2() = runTest([1,2,3, 1,2,3, 1,2,3, 5,5,5], {1,2,3,1,2,3,1,2,3}, minBlockSize=3);
test bool t3() = runTest([1,1,1, 8, 1,1, 9, 3,3, 3,3], {1,1,1,1,1,3,3,3,3}, minBlockSize=2);
test bool t4() = runTest([1,1,1, 8, 1,1, 9, 3,3, 3,3], {}, minBlockSize=4);