
# Copyright (c) 2012 Fred Youhanaie

cmake_minimum_required (VERSION 2.8)

project (drmaatcl C)

##set (LIBHDR drmaa.h)
##include_directories (${CMAKE_SOURCE_DIR})

set (WEBFILE ${CMAKE_SOURCE_DIR}/drmaatcl-main.w)

##set (LIBSRC ${CMAKE_BINARY_DIR}/drmaatcl-main.c)
##set_source_files_properties (${LIBSRC} PROPERTIES GENERATED TRUE)

set (TEXFILE ${CMAKE_BINARY_DIR}/drmaatcl-main.tex)
set_source_files_properties (${TEXFILE} PROPERTIES GENERATED TRUE)

set (PDFFILE ${CMAKE_BINARY_DIR}/drmaatcl-main.pdf)

set_directory_properties(PROPERTIES
	ADDITIONAL_MAKE_CLEAN_FILES "drmaatcl-main.idx;drmaatcl-main.toc;drmaatcl-main.scn;drmaatcl-main.log"
)

#
# our primary build target is the library
#
##add_library (drmaa SHARED ${LIBSRC} ${LIBHDR})
#
##add_custom_command (
	##OUTPUT		${LIBSRC}
	##COMMAND		ctangle ${WEBFILE}
	##DEPENDS		${WEBFILE}
##)

#
# the pdf documentation involves a couple of explicit steps
#
add_custom_target (doc SOURCES ${PDFFILE})
#
add_custom_command (
	OUTPUT		${PDFFILE}
	MAIN_DEPENDENCY	${TEXFILE}
	COMMAND		pdftex
	ARGS		${TEXFILE}
)
#
add_custom_command (
	OUTPUT		${TEXFILE}
	MAIN_DEPENDENCY	${WEBFILE}
	COMMAND		cweave
	ARGS		${WEBFILE}
)

