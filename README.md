
drmaatcl
========

This is the Tcl extension for the DRMAA C API (v1). It also incorporates
an interactive shell, drmaash.

The extension is written in cweb, a literate programming tool for
producing C programs. see <http://literateprogramming.com/>.

You will need the cweb package to generate the C source files, which is
available via the above web site. cweb is also included in the texlive
packages, which you would need for creating the pdf document.

You will also need cmake to generate the makefiles, see
<http://cmake.org>. This should be available with most/all Linux
distributions.

Installation
============

You will need to tell cmake the paths to the drmaa.h and libdrmaa.so
files.  These are defined in DRMAA_INC_DIR and DRMAA_LIB_DIR variables,
the default paths are /usr/local/include and /usr/local/lib respectively.

To build the extension, once you have cloned or unpacked the sources,
change to the top directory, then

	mkdir build # out-of-source build is much tidier
	cd build
	cmake -DDRMAA_INC_DIR=<incdir> -DDRMAA_LIB_DIR=<libdir> ..
	make
	make doc

Note:
* The ".." on the cmake line is important
* You can also run "cmake ..", then modify the paths with "make edit_cache"

