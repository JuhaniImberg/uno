###
Copyright (c) 2013 Juhani Imberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

colorize = () ->
	o = {}
	o.escapeStart = "\u001b["
	o.escapeEnd = "m"
	o.reset = o.escapeStart+0+o.escapeEnd

	o.clear = 0
	o.bold = 1
	o.underline = 4
	o.negative = 7
	o.black = 30
	o.red = 31
	o.green = 32
	o.yellow = 33
	o.blue = 34
	o.magenta = 35
	o.cyan = 36
	o.white = 37

	o.escape = (what, wut) ->
		if typeof wut == "number"
			return this.escapeStart+wut+this.escapeEnd+what+o.reset
		if typeof this[wut] == undefined
			return "you bastard"
		return this.escapeStart+this[wut]+this.escapeEnd+what+o.reset

	return o

exports.colorize = new colorize