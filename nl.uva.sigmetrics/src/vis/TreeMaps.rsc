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

Figure toVis(f:file(l)) {
	if (f@area > 0) {
		return box(text("<l.file>, area <f@area>"), area(f@area), fillColor(arbColor()));
	}
	return size(area(0));
}
Figure toVis(d:folder(l, contents)) = toVis(contents, d@area, l);
Figure toVis(p:project(l, contents)) = toVis(contents, p@area, l);
Figure toVis(set[Resource] contents, int a, loc l) {
	set[Resource] rem = { r | r <- contents, r@area != 0 };
	if (a > 0 && rem != {} ) {
		return box(vcat([
				text("<l.path>, area <a>", vgap(10)),
				treemap([ toVis(r) | r <- rem])
			]), area(a), lineWidth(3), vgap(10));		
	}
	
	return space(area(0)); 
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