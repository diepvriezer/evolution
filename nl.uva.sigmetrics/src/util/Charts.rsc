module util::Charts

import Prelude;
import vis::Figure;
import vis::Render;
import util::Math;

data Axis = axis(str name, num max);
data Series = series(str name, list[num] values, Color col=arbColor());

@doc { She ain't pretty but she works. Mainly missing axis.. }
Figure barChart(Axis y, list[Series] series, str title="Chart 1") {

	bars = hcat([ figSeries(s, y.max) | s <- series], hgap(20));
	ax = vcat([box(figVertAxis(y), vshrink(0.99)), box(fillColor("white"))], vgap(20), hshrink(0.05));
	
	chart = box(hcat([ax, bars]),
		fillColor("white"), shrink(0.9),
		std(lineColor("white")), std(fillColor("white")), std(fontSize(20)));
	
	
	canvas = vcat([text(""), text(title, fontSize(35)), box(chart, shrink(0.9))], vgap(30));
	return canvas;
}

private Figure figVertAxis(Axis ax) {
	return text(ax.name, textAngle(270));
}

private Figure figSeries(Series s, num yMax) {
	n = size(s.values);
	cols = colorSteps(s.col, color("white"), n);
	
	bars = for (int i <- [0..n]) {
		val = s.values[i];
		if (val >= yMax) {
			append(box(fillColor(cols[i]), bottom()));
		} else {
			// Insert padding box, then vcat them to add up to 1...
			h = 1.0 / (yMax / val);
			pad = box(vshrink(1.0 - h));
			append vcat([pad, box(vshrink(h), fillColor(cols[i]), bottom())]);
		}
	}
	
	combined = hcat(bars, hgap(5), vshrink(0.99)); 
	
	return vcat([combined, text(s.name)], vgap(20));
}

void testIt() {
	y = axis("Risk percentage", 100);
	x1 = series("low", [20, 10, 5]);
	x2 = series("medium", [40]);
	x3 = series("high", [80]);
	x4 = series("very high", [60, 100]);
	
	f = barChart(y, [x1,x2,x3,x4], title="Test chart");
	// render(pack([f,f,f,f])); doing this will crash eclipse :D no size args.
	render(f);
}