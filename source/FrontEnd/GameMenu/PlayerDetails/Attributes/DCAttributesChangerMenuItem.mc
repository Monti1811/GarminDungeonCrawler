import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! This is the custom item drawable.
//! It draws the label it is initialized with at the center of the region
class DCAttributesChangerMenuItem extends WatchUi.CustomMenuItem {


    private var _label as String;
	private var _sublabel as String;
    private var _id as Symbol;

    //! Constructor
    //! @param id The identifier for this item
    //! @param text Text to display
    public function initialize(text as String, subtext as String, id as Symbol) {
        CustomMenuItem.initialize(id, {});
        _label = text;
		_sublabel = subtext;
        _id = id;
	}

    //! Draw the item string at the center of the item.
    //! @param dc Device context
    public function draw(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 1 / 3, Graphics.FONT_MEDIUM, _label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 2 / 3, Graphics.FONT_SMALL, _sublabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.drawLine(0, 0, dc.getWidth(), 0);
        dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);

		dc.drawText(30, dc.getHeight() / 2, Graphics.FONT_MEDIUM, "-", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(330, dc.getHeight() / 2, Graphics.FONT_MEDIUM, "+", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! Get the item label
    //! @return The label
    public function getLabel() as String {
        return _label;
    }

    public function getID() as Symbol {
        return _id;
    }

	public function updateSubLabel(subtext as String) as Void {
		_sublabel = subtext;
		WatchUi.requestUpdate();
	}

}