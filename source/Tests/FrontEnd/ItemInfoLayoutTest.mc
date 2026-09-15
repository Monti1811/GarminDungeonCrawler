import Toybox.Test;
import Toybox.Lang;

(:test)
function itemInfoLayout_noOverlap_240x240(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 240, 240);
}

(:test)
function itemInfoLayout_noOverlap_260x260(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 260, 260);
}

(:test)
function itemInfoLayout_noOverlap_280x280(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 280, 280);
}

(:test)
function itemInfoLayout_noOverlap_360x360(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 360, 360);
}

(:test)
function itemInfoLayout_noOverlap_416x416(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 416, 416);
}

(:test)
function itemInfoLayout_noOverlap_454x454(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 454, 454);
}

(:test)
function itemInfoLayout_noOverlap_466x466(logger as Test.Logger) as Boolean {
	return checkItemInfoLayout(logger, 466, 466);
}

(:test)
function itemInfoLayout_rectCappedAt360(logger as Test.Logger) as Boolean {
	var view = new DCItemInfoValuesView(new Item());
	var layout = view.computeLayout(466, 466);
	var expected_h = layout[:attr_row_dist] * 4 + 5;
	logger.debug("Rect: w=" + layout[:rect_w] + " h=" + layout[:rect_h] + " expected_h=" + expected_h);
	Test.assert(layout[:rect_w] <= 175);
	Test.assert(layout[:rect_h] == expected_h);
	return true;
}

(:test)
function itemInfoLayout_lckCentered_466x466(logger as Test.Logger) as Boolean {
	return checkLckCentered(logger, 466, 466);
}

(:test)
function itemInfoLayout_lckCentered_360x360(logger as Test.Logger) as Boolean {
	return checkLckCentered(logger, 360, 360);
}

(:test)
function itemInfoLayout_lckCentered_240x240(logger as Test.Logger) as Boolean {
	return checkLckCentered(logger, 240, 240);
}

(:test)
function itemInfoLayout_rightColumnInsideRect_466x466(logger as Test.Logger) as Boolean {
	return checkRightColumnInsideRect(logger, 466, 466);
}

(:test)
function itemInfoLayout_rightColumnInsideRect_360x360(logger as Test.Logger) as Boolean {
	return checkRightColumnInsideRect(logger, 360, 360);
}

(:test)
function itemInfoLayout_rightColumnInsideRect_240x240(logger as Test.Logger) as Boolean {
	return checkRightColumnInsideRect(logger, 240, 240);
}

// --- helpers ---

function checkItemInfoLayout(logger as Test.Logger, screen_w as Number, screen_h as Number) as Boolean {
	logger.debug("=== Testing layout for " + screen_w + "x" + screen_h + " ===");

	var view = new DCItemInfoValuesView(new Item());
	var layout = view.computeLayout(screen_w, screen_h);

	var rect_x = layout[:rect_x];
	var rect_y = layout[:rect_y];
	var rect_w = layout[:rect_w];
	var rect_h = layout[:rect_h];
	var attr_base_y = layout[:attr_base_y];
	var attr_row_dist = layout[:attr_row_dist];
	var attr_x_left = layout[:attr_x_left];
	var attr_x_right = layout[:attr_x_right];
	var common_base_y = layout[:common_base_y];
	var distance_lines = layout[:distance_lines];

	logger.debug("rect: x=" + rect_x + " y=" + rect_y + " w=" + rect_w + " h=" + rect_h);
	logger.debug("attr_base_y=" + attr_base_y + " row_dist=" + attr_row_dist);

	// 1: rect inside screen
	Test.assert(rect_x >= 0);
	Test.assert(rect_y >= 0);
	Test.assert(rect_x + rect_w <= screen_w);
	Test.assert(rect_y + rect_h <= screen_h);

	// 2: rect starts right below title with gap = distance_lines (full font line)
	var title_y = common_base_y + 4 * distance_lines;
	var title_bottom = title_y + 20;
	logger.debug("title_y=" + title_y + " title_bottom=" + title_bottom + " rect_y=" + rect_y);
	Test.assert(rect_y >= title_bottom);

	// 3: Weight (last common attr) not overlapping rect badly
	var weight_y = common_base_y + 3 * distance_lines;
	var weight_overlap = (weight_y + 15) - rect_y;
	logger.debug("weight_y=" + weight_y + " weight_overlap=" + weight_overlap);
	Test.assert(weight_overlap <= 20);

	// 4: attribute rows inside rect vertically
	var row0_y = attr_base_y;
	var row3_y = attr_base_y + 3 * attr_row_dist;
	logger.debug("row0_y=" + row0_y + " row3_y=" + row3_y + " rect_bottom=" + (rect_y + rect_h));
	Test.assert(row0_y >= rect_y);
	Test.assert(row3_y <= rect_y + rect_h);

	// 5: columns inside rect horizontally
	Test.assert(attr_x_left >= rect_x);
	Test.assert(attr_x_right >= rect_x);

	logger.debug("=== Layout OK for " + screen_w + "x" + screen_h + " ===");
	return true;
}

function checkLckCentered(logger as Test.Logger, screen_w as Number, screen_h as Number) as Boolean {
	var view = new DCItemInfoValuesView(new Item());
	var layout = view.computeLayout(screen_w, screen_h);

	var rect_x = layout[:rect_x];
	var rect_w = layout[:rect_w];
	var attr_x_center = layout[:attr_x_center];

	var rect_center = rect_x + rect_w / 2;
	var lck_offset = attr_x_center - rect_center;

	logger.debug("Screen " + screen_w + "x" + screen_h + " LCK offset from rect center: " + lck_offset + "px");
	Test.assert(lck_offset >= -15);
	Test.assert(lck_offset <= 15);
	return true;
}

function checkRightColumnInsideRect(logger as Test.Logger, screen_w as Number, screen_h as Number) as Boolean {
	var view = new DCItemInfoValuesView(new Item());
	var layout = view.computeLayout(screen_w, screen_h);

	var rect_x = layout[:rect_x];
	var rect_w = layout[:rect_w];
	var attr_x_right = layout[:attr_x_right];
	var attr_x_value_offset = layout[:attr_x_value_offset];

	var right_value_x = attr_x_right + attr_x_value_offset + 30;
	var rect_right = rect_x + rect_w;

	logger.debug("Screen " + screen_w + "x" + screen_h + " right_value_x=" + right_value_x + " rect_right=" + rect_right);
	Test.assert(right_value_x <= rect_right + 15);
	return true;
}
