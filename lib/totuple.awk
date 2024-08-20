################################
#
# Parse out a two dimensional tuple from string value
#
# If Inner tuple has two values (key/value), the use
# of the Python dict class can be used to convert tuple
# into a dictionary
#
# Usage:
#
#     Set optional variable "is2d" via the CLI to parse two-dimentional tuples
#
#     Example:
#
#          # Will parse 2-dimentional tuple
#          awk -v is2d=1 -f totuple.awk <<< "INPUT STRING"
#
#          # Will parse 1-dimentional tuple
#          awk -f totuple.awk <<< "INPUT STRING"
#
# 1-Dimensional Example:
#
#     Input:    Chicago|Cincinnati|St. Louis|Washington, DC
#
#     Output:   ("Chicago","Cincinnati","St. Louis","Washington, DC")
#
# 2-Dimensional Example (unencoded comma's not allowed in keys/values):
#
#     Input:    name,Bob|age,38|town,Chicago
#
#     Output:   (("name","Bob"),("age","38"),("town","Chicago"))
#
#     Output of dict:  { "name":"Bob", "age":"38", "town":"Chicago" }
#
################################

BEGIN {
	RS="|";
	TEXT = "(";
}
{
	if (length($0) > 1) {
		element = gensub(/"|\n/,"","g",$0);
		if (typeof(is2d) == "untyped") {
			TEXT = TEXT sprintf("\"%s\",",element);
		}
		else {
			TEXT = TEXT "(";
			c = split(element,a,",");
			for (i = 1; i <= c; i++) {
				TEXT = TEXT sprintf("\"%s\",",a[i]);
			}
			sub(/,$/,"",TEXT);
			TEXT = TEXT sprintf("),",element);
		}
	}
}
END {
	sub(/,$/,"",TEXT);
	TEXT = TEXT sprintf(")");
	print TEXT;
}