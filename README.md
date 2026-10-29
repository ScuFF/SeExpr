===================================================================

  For info on using new v3 features and porting your code, see:

  http://wdas.github.io/SeExpr/doxygen/html/SeExpr_FAQ.html
  
===================================================================


# SeExpr - An embeddable expression evaluation engine


## Super impatient CMake building and installing guide

Requires CMake 3.16 or later. Python discovery uses CMake's `FindPython`;
existing `PYTHON_EXECUTABLE`, `PYTHON_INCLUDE_DIR`, `PYTHON_LIBRARY`, and
`PYTHON_DEBUG_LIBRARY` overrides are forwarded for compatibility.
For regression tests, install GoogleTest's CMake package and make it discoverable
through `CMAKE_PREFIX_PATH` or `GTest_DIR`. Tests link `GTest::gtest`, preserving
Debug/Release library selection; the current test target uses C++17.

Build all targets before running CTest. The core Python binding is staged as
an importable `SeExprPy` package inside the build tree (including `.pyd` on
Windows), so `basicPython` does not require installation. Missing imports
fail the test. `BlockTests` always checks interpreter results and compares
LLVM results only when that backend was compiled. The legacy image comparison
report is explicitly skipped when its separate comparison installations are
unavailable. CTest dashboard configuration is generated via `include(CTest)`.

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

## CMake engine linkage and runtime output

The existing `SeExpr2` library target retains its platform-specific linkage:
static on Windows, shared on other platforms. The alternative library is
`SeExpr2Shared` on Windows and `SeExpr2Static` elsewhere. Installed CMake targets
use the `seexpr2::` namespace. `SeExpr2Editor` continues to use the existing
`SeExpr2` engine; the alternative editor is `SeExpr2EditorShared` on Windows
and `SeExpr2EditorStatic` elsewhere. The editor library's own type is separate
from the engine linkage its name selects.

`SEEXPR_DEFAULT_LINKAGE=STATIC|SHARED` selects the engine used by bundled
applications and the Qt Python module. Its default is STATIC on Windows and
SHARED elsewhere. `SEEXPR_LINKAGE_<target>=DEFAULT|STATIC|SHARED` overrides one
application or module; DEFAULT follows the global selection. Editor consumers
select a matching editor library to avoid loading both engines into one process.

`SEEXPR_RUNTIME_OUTPUT_DIRECTORY` optionally places native applications, the
shared engine/editor, and the Qt Python module in a common build-tree directory.
It is empty by default, leaving normal CMake output-directory behavior intact,
including standard `CMAKE_RUNTIME_OUTPUT_DIRECTORY` and
`CMAKE_LIBRARY_OUTPUT_DIRECTORY` settings. On Windows a common directory can
simplify DLL discovery for shared applications. With default directories, arrange
DLL discovery separately when running shared applications. Multi-configuration
generators retain CMake's configuration subdirectories unless explicitly overridden.
The AST Python package retains its separate Python-package staging directory.

These are standalone SeExpr options: callers provide their own dependencies and
installation prefix. They do not download SDKs or require a parent project.

## Installed LLVM-enabled CMake package

An LLVM-enabled installation exposes LLVM headers through its public expression
headers. Its CMake package discovers LLVM with `find_dependency(LLVM CONFIG)` and
provides those include directories to both engine targets. Set `LLVM_DIR` or
`CMAKE_PREFIX_PATH` to a compatible LLVM SDK when configuring a consumer. Static
consumers also use the imported LLVM component libraries; shared consumers use
the shared SeExpr engine. No dependency download or workspace path is selected
by SeExpr. Interpreter-only packages do not require LLVM.

## Engine and editor CMake package components

The installed package separates engine and editor exports. Use
`find_package(seexpr2 CONFIG REQUIRED COMPONENTS Engine)` to consume engines
without probing for Qt, or `COMPONENTS Editor` to require the installed editor
capability and discover its Qt dependencies. With no components, editors are
exposed when their Qt dependencies are available; engine-only use remains
available otherwise. Unknown required components fail package discovery.

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
