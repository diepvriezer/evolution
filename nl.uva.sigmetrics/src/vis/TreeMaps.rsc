module vis::TreeMaps

import metrics::SIG;

import IO;
import vis::Figure;
import vis::Render;
import util::Resources;
import util::Math;

anno loc		Resource@src;
anno str		Resource@txt;
anno int		Resource@area;

Figure toVis(f:file(l)) = box(area(f@area), fillColor(arbColor()));
Figure toVis(d:folder(l, contents)) = toVis(contents, d@area, l);
Figure toVis(p:project(l, contents)) = toVis(contents, p@area, l);
Figure toVis(set[Resource] contents, int a, loc l) {
	return box(vcat(
		[ text(l.path), treemap([ toVis(r) | r <- contents]) ]
	));
}

void renderResource(Resource r) {
	render(toVis(r));
}

// Annotate lines of code.
Resource annoLoc(map[loc, FileInfo] info, f:file(l)) {
	f@area = l in info ? info[l].lines : 0;
	return f;
}
Resource annoLoc(map[loc, FileInfo] info, d:folder(l,contents)) {
	d.contents = annoLoc(info, contents);
	d@area = (0 | it + r@area | r <- d.contents);
	return d;
}
Resource annoLoc(map[loc, FileInfo] info, p:project(l,contents)) {
	p.contents = annoLoc(info, contents);
	p@area = (0 | it + r@area | r <- p.contents);
	return p;
}
set[Resource] annoLoc(map[loc, FileInfo] info, set[Resource] rs) = { annoLoc(info, r) | r <- rs };