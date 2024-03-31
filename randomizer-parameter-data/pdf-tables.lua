local pdf_tables = {}

local fnc = {}

fnc.inc = function(x) return x + 1 end
fnc.dec = function(x) return x - 1 end

pdf_tables.magazine_size = {
    sanitizer = fnc.inc,
    desanitizer = fnc.dec,
    range = "small",
    min = 1

}