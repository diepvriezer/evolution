module vis::Playground

import vis::Figure;
import vis::Render;
import IO;

data TreeFigure = item(loc path, int scale)
				| container(list[TreeFigure])
				| drawing(str caption, TreeFigure c);

data DrawItem = item(str text, int scale)
			  | itemSet(list[DrawItem] items);

Figure visItem(item(t, s)) = box(text(t, fontSize(15)), area(s));
Figure visItem(itemSet(items)) = treemap([ visItem(i) | i <- items], area(getScale(itemSet(items))));

int getScale(item(_, s)) = s;
int getScale(itemSet(items)) = (0 | it+getScale(i) | i <- items); 

public void renderMap(TreeFigure f) {
	
}

void run() {
	L = itemSet([item("a", 5), item("b", 3), item("c", 2), itemSet([item("d", 5), item("e", 1)])]);
	fig = box(visItem(L), fillColor("red"));
	println(fig);
	render(fig);
}