module vis::TreeMaps

import metrics::SIG;

import IO;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Resources;
import util::Math;
import util::Editors;

anno int Resource @ _loc;

Resource annotateResourceTree(Resource resourceTree, map[loc, FileInfo] info) {
	return visit(resourceTree) {
		case p:project(l, rs) => { p@_loc = (0 | it + r@_loc | r <- rs); }
		case f:folder(l, rs) => { f@_loc = (0 | it + r@_loc | r <- rs); }
		case f:file(l) => { f@_loc = info[l].lines; }
	}
}

public list[Color] colorScale = colorSteps(color("Green"), color("Red"), 100);

Figure resourceTreeToTreeMap(f:file(l), int tloc) = box(popup("\<<l.file>\>\n<f@_loc> loc"), area(f@_loc), colorGrade(toReal(f@_loc) / tloc), goToSource(l));
Figure resourceTreeToTreeMap(f:folder(l,rs), int tloc) = box(vcat([text(l.file),treemap([resourceTreeToTreeMap(r, tloc) | r <- rs], area(f@_loc))]),area(f@_loc));
Figure resourceTreeToTreeMap(p:project(l,rs)) = treemap([resourceTreeToTreeMap(r, p@_loc) | r <- rs], area(p@_loc));

public FProperty popup(str S) {
	 return mouseOver(box(text(S), fillColor("lightyellow"),
	 grow(1.2),resizable(false)));
}

public FProperty colorGrade(real p) {
	return fillColor(colorScale[round(nroot(p, 4) * 99)]);
}

public FProperty goToSource(loc l) {
	return onMouseUp(bool (int butnr, map[KeyModifier,bool] modifiers) { edit(l,[]); return true;});
}