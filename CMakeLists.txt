
# Copyright (c) 2012 Fred Youhanaie

cmake_minimum_required (VERSION 2.8)

project (drmaatcl C)

# These can be overridden on command line, or via edit_cache target
set (DRMAA_INC_DIR "/usr/local/include"
	CACHE PATH
	"drmaa.h include directory."
)
set (DRMAA_LIB_DIR "/usr/local/lib"
	CACHE PATH
	"libdrmaa.so lib directory."
)

find_package (TclStub REQUIRED)

# TCL_INCLUDE_PATH is supplied by TclStub package
include_directories (${TCL_INCLUDE_PATH} ${DRMAA_INC_DIR})
link_directories (${DRMAA_LIB_DIR})

# The everything is generated from the cweb sources
set (CWEB_MAIN
	${CMAKE_SOURCE_DIR}/drmaatcl-main.w
)
set (CWEB_SRCS
	${CWEB_MAIN}
	${CMAKE_SOURCE_DIR}/boilerplate.w
	${CMAKE_SOURCE_DIR}/drmaatcl-code.w
	${CMAKE_SOURCE_DIR}/drmaatcl-data.w
	${CMAKE_SOURCE_DIR}/drmaatcl-guide.w
)

# library source, generated from *.w files
set (DRMAATCL_SRC ${CMAKE_BINARY_DIR}/drmaatcl-main.c)
set_source_files_properties (${DRMAATCL_SRC} PROPERTIES GENERATED TRUE)

# interactive shell source, generated from *.w files
set (DRMAASH_SRC ${CMAKE_BINARY_DIR}/drmaash.c)
set_source_files_properties (${DRMAASH_SRC} PROPERTIES GENERATED TRUE)

# Tcl package index,
# so that "package require drmaa" can find the extension
set (PKG_INDEX_SRC "${CMAKE_SOURCE_DIR}/pkgIndex.tcl.in")
set (PKG_INDEX "${CMAKE_BINARY_DIR}/pkgIndex.tcl")
set_source_files_properties (${PKG_INDEX} PROPERTIES GENERATED TRUE)

# documentation source, generated from *.w
set (TEXFILE ${CMAKE_BINARY_DIR}/drmaatcl-main.tex)
set_source_files_properties (${TEXFILE} PROPERTIES GENERATED TRUE)

# deliverable documentation
set (PDFFILE ${CMAKE_BINARY_DIR}/drmaatcl-main.pdf)

# cmake needs to know about cweb/TeX intermediate files, for clean up
set (files_to_clean drmaatcl-main.idx drmaatcl-main.toc drmaatcl-main.scn drmaatcl-main.log)
set_directory_properties (PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${files_to_clean}")

#
# our primary build targets are the library and the shell
#
set (CMAKE_SKIP_RPATH TRUE) # No RPATH please!
add_definitions (-DUSE_TCL_STUBS)
add_library (drmaatcl SHARED ${DRMAATCL_SRC})
target_link_libraries (drmaatcl ${TCL_STUB_LIBRARY} drmaa)

add_executable (drmaash ${DRMAASH_SRC})
target_link_libraries (drmaash drmaatcl ${TCL_LIBRARY})

add_custom_command (
	OUTPUT		${DRMAATCL_SRC} ${DRMAASH_SRC}
	COMMAND		env CWEBINPUTS=${CMAKE_SOURCE_DIR} ctangle ${CWEB_MAIN}
	DEPENDS		${CWEB_SRCS}
)

#
# the pdf documentation involves a couple of explicit steps
#
add_custom_target (doc SOURCES ${PDFFILE})
#
# we need the additional env to accomodate out-of-source builds
# Note, the trailing ':' is important
add_custom_command (
	OUTPUT		${PDFFILE}
	MAIN_DEPENDENCY	${TEXFILE}
	COMMAND		env TEXINPUTS=${CMAKE_SOURCE_DIR}: pdftex
	ARGS		${TEXFILE}
)
#
# we need the additional env to accomodate out-of-source builds
add_custom_command (
	OUTPUT		${TEXFILE}
	DEPENDS		${CWEB_SRCS}
	COMMAND		env CWEBINPUTS=${CMAKE_SOURCE_DIR} cweave
	ARGS		${CWEB_MAIN}
)

#
# and finally to install ...
install (
	TARGETS			drmaash drmaatcl
	RUNTIME	DESTINATION	bin
	LIBRARY	DESTINATION	lib
)

# pkgIndex.tcl - so that "package require drmaa" works
install (
	FILES			${PKG_INDEX}
	DESTINATION		${CMAKE_INSTALL_PREFIX}/lib/tcltk/drmaa
)
configure_file (${PKG_INDEX_SRC} ${PKG_INDEX} @ONLY)
