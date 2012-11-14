
# drmaatcl

This is the Tcl extension for the DRMAA C API (v1). It also incorporates
an interactive shell, `drmaash`. The interactive shell was the main
drive behind this project.

You will need `cmake`, <http://cmake.org/> to generate the makefiles.
This should be available as an installable package with most/all Linux
distributions.

The extension is written in `cweb`, a literate programming tool for
producing C programs. see <http://literateprogramming.com/>.

You will need the `cweb` package to generate the C source files, which is
available via the above web site. `cweb` is also included in the texlive
packages, which you would need if you wanted generate the pdf document.

## Installation

You will need to tell cmake the paths to the drmaa.h and libdrmaa.so
files. These are defined in `DRMAA_INC_DIR` and `DRMAA_LIB_DIR`
variables, the default paths are `/usr/local/include` and `/usr/local/lib`
respectively.

To build the extension, once you have cloned or unpacked the sources,
change to the top directory, then

	mkdir build # out-of-source build is much tidier
	cd build
	cmake -DDRMAA_INC_DIR=<incdir> -DDRMAA_LIB_DIR=<libdir> ..
	make
	make install
	make doc

### Notes:

* The ".." on the cmake line is important
* You can also run `cmake ..`, then modify the paths with `make edit_cache`
* The files are installed in `/usr/local/{bin,lib}` by default,
  change the path in `CMAKE_INSTALL_PREFIX`.

## Contributions

Contributions to the project are welcome, either via github fork, or
with patches.

Enjoy!
Fred Youhanaie

