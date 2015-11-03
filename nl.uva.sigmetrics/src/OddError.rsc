module OddError

import util::Resources;

data BTree = lf() | nd(BTree l, BTree r);

Resource res = root();

void thisBreaks() {
	visit(root()) {
		case z:file(x) => z
	}
}

void thisBreaks2() {
	visit(res) {
		case /z:file(_) => z
		default: ;
	}
}

void thisDoesnt2() {
	visit(res) {
		case /z:file(_) => z
		default: return;
	}
}

void thisDoesnt3() {
	visit(res) {
		case Resource z:file(_) => z
	}
}

void thisDoesnt() {
	tree = nd(lf(), lf()); 
	visit(tree) {
		case /z:nd(_,_) => z
		default:; // optional, works either way.
	}
}