luacam
======

INSTALLATION NOTES:

Requirements (tested on Debian 8.1):

```
Lua 5.1.x (included on Debian Stable)
IUP 3.10.1 (run ./install and ./config_lua_module)
```
[http://webserver2.tecgraf.puc-rio.br/iup/](http://webserver2.tecgraf.puc-rio.br/iup/)
LibCD 5.8(.2) ([http://webserver2.tecgraf.puc-rio.br/cd/](http://webserver2.tecgraf.puc-rio.br/cd/) same as above)
zlib1g-dev (apt-get install zlib1g-dev)
luarocks (apt-get install luarocks)
sqlite3 (apt-get install sqlite3)
sqlite3 headers (apt-get install libsqlite3-dev)
lsqlite3 (luarocks install lsqlite3)
```

Files for production:
```
lib.lua
iup.lua
/macros/
luacam.sh
```

RUN GUI:

```
chmod +x luacam.sh
./luacam.sh
```
or
```
lua iup.lua
```

RUN CLI:

```
lua clicam.lua
```

RUN text interface:
```
lua uicam.lua
```

Lua tools for macro generation of [CNC](http://en.wikipedia.org/wiki/Numerical_control) [G-code](http://en.wikipedia.org/wiki/G-code) programs.

Translation of psuedo-lua code with inline G-code into sequential ISO compatible G-code. This provides named variables, functions, looping and control structures for macro G-code programming, as well as access to mathematical libraries. All numerical values are automatically rounded to four decimal points, the standard for CNC controls operating in imperial (U.S. customary units).

Many CNC machines have basic macro capability built in, but they are incompatible and often limited and verbose. The most common Fanuc macro standard has variables of the form #1, #2 etc. and only GOTO statements for control structures. 

__luacam__ can also be used with inline macro codes, but these will necessarily be machine specific.

An example program `test.lua`:

```  
G95 G91

G00 X0 Y0 Z12

current_depth = 10
feed = 0.004

for i = current_depth, 8, -1 do
  clearance = i + 0.1
  G01 Z$i F$feed
  G01 X10
  G01 Z$clearance
  G00 X0
end

G00 X0 Y0 Z12
M99
```
Running `lua clicam.lua test.lua 1100.eia` produces the following output in file `1100.eia`:
```
G95 G91
G00 X0.0000 Y0.0000 Z12.0000
G01 Z10.0000 F0.0040
G01 X10.0000
G01 Z10.1000
G00 X0.0000
G01 Z9.0000 F0.0040
G01 X10.0000
G01 Z9.1000
G00 X0.0000
G01 Z8.0000 F0.0040
G01 X10.0000
G01 Z8.1000
G00 X0.0000
G00 X0.0000 Y0.0000 Z12.0000
M99
```

While these two examples are similar in length, note that changing the number of passes in `test.lua` requires changing only characters, for possible output of thousands of lines of G-code. A further advantage of the pseudo-lua code is that it is far more readable and expressive.

Using luacam
------------

In Windows, double clicking `g-code.bat` runs the GUI version.

`lua iup.lua` will run the gui version from a shell on any platform.

Select a macro on the left (located in `./macros`), and edit variables on the bottom left as necessary. These are not saved in the raw macro source (middle pane, read only), but are only used for this session. The right most pane displays the output (read only again).

`lua clicam.lua` at a shell prompt will show usage for the command line version.

Details
--------

```
--##
z_clearance = 4
feed = 0.02
z_zero = -1.675
depth = .4
dia = 15.6344
cutter_dia = 0
pitch = 0.1
safety = 0.03
--##
```

In macro files, variables may optionally be placed between matching --## marks (as above) and are pulled into the GUI version and can be re-assigned for g-code output without modifying the defaults in the macro. For example, if we wanted this macro with more Z axis clearance we could change z_clearance in the bottom left text box and this value will be used to generate the output, rather than the original file.

__luacam__ looks for macros in `./macros`.

The last saved macro is selected when __luacam__ is reopened, and the last saved program number is restored. These values reside in `./uicam.cfg` in human readable form.

License	
----------------------------

LuaCAM is copyright © 2013-2014 Jesse Meade-Clift.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
