import Toybox.Lang;

module StringUtil {

	function split(str as String, delimiter as Char) as Array<String> {
        var result = [] as Array<String>;
        var strArray = str.toCharArray();
        var current = "";
        for (var i = 0; i < strArray.size(); i++) {
            var c = strArray[i];
            if (c == delimiter) {
                result.add(current);
                current = "";
            } else {
                current = current + c;
            }
        }
        if (current != "") {
            result.add(current);
        }
        return result;
    }

}