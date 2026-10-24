===================================================================

  For info on using new v3 features and porting your code, see:

  http://wdas.github.io/SeExpr/doxygen/html/SeExpr_FAQ.html
  
===================================================================


# SeExpr - An embeddable expression evaluation engine


## Super impatient CMake building and installing guide

Requires CMake 3.16 or later. Python discovery uses CMake's `FindPython`;
existing `PYTHON_EXECUTABLE`, `PYTHON_INCLUDE_DIR`, `PYTHON_LIBRARY`, and
`PYTHON_DEBUG_LIBRARY` overrides are forwarded for compatibility.

```bash
$ git clone https://github.com/wdas/SeExpr
$ cd SeExpr
$ mkdir build
$ cd build
$ cmake ../
$ make doc      # optional make documentation
$ make install
```

You can try the test application asciiGraph which is a simple
function grapher... e.g.
```bash
./asciiGraph "x^3-8*x"
```

## Getting started

### Qt Python editor bindings

With `USE_PYTHON=ON` and Qt5 available, the `expreditor2` target uses SIP 6
and PyQt5 from the selected `PYTHON_EXECUTABLE` environment. Install their
build/runtime packages into that environment:

```bash
python -m pip install "sip>=6.8,<7" "PyQt5>=5.15.11,<5.16"
```

The binding generator requires Python 3.11 or later. It generates wrappers
inside the CMake build directory; CMake compiles and links them against the
native Qt5 SDK. The SDK must be compatible with the Qt version used by PyQt5.
Legacy SIP 4, `sipconfig`, PyQt4, and `distutils` are not used by this target.
The separate core Python module still requires Boost.Python.

```bash
cmake --build build --target expreditor2
ctest --test-dir build -R '^qtPythonBindings$' --output-on-failure
```

The smoke test is registered when `BUILD_TESTS=ON`; it creates widgets using
Qt's offscreen platform and checks expression text, Unicode conversion, and
signal connections. On Windows the module is built with the `.pyd` suffix.
For the normal PyQt5 wheels, use a Release native build: Debug configurations
require matching Qt/Python runtime and development libraries and have not
been validated. Linux builds of the modernized binding are also unverified.

Examining the demo applications in src/demo is a great way to see
some usage examples of the library. The basic strategy is to subclass
the Expression class and implement the methods that describe what
extra functions and variables your expression evaluation will need

Be sure to check out the doxygen pages for an API overview:
http://wdas.github.io/SeExpr/doxygen/
http://wdas.github.io/SeExpr/doxygen/v1 (for older documentation)

## Source code overview

```
src/
   SeExpr2/  Library code
   ui/       User Interface components for editing
   demos/    Demo Applications
   tests/    Regression Tests
   doc/      Doxygen generation
```

## SeExpr Developers

 * David Aguilar
 * Janet Berlin
 * Brent Burley
 * Lawrence Chai
 * Noah Kagan
 * Jared Reisweber
 * Andrew Selle
 * Dan Teece
 * Tom Thompson

Walt Disney Animation Studios
