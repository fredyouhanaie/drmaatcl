
# test-1.tcl
#	complete test suite for drmaatcl (via drmaash)
#

package require tcltest
tcltest::configure -verbose p

#
#	Session Management Routines
#
tcltest::test init-1.0 {drmaa::drmaa_init no contact} {
	-body {drmaa::drmaa_init}
	-returnCodes ok
	-cleanup {drmaa::drmaa_exit}
}

tcltest::test init-1.1 {drmaa::drmaa_init null contact} {
	-body {drmaa::drmaa_init {}}
	-returnCodes ok
	-cleanup {drmaa::drmaa_exit}
}

tcltest::test init-1.2 {drmaa::drmaa_init invalid contact} {
	-body {drmaa::drmaa_init hello}
	-returnCodes error
	-match glob
	-result {DRMAA INVALID_ARGUMENT *}
}

tcltest::test init-1.3 {drmaa::drmaa_init called twice} {
	-body {drmaa::drmaa_init {}; drmaa::drmaa_init {}}
	-returnCodes error
	-match glob
	-result {DRMAA ALREADY_ACTIVE_SESSION *}
	-cleanup {drmaa::drmaa_exit}
}

tcltest::test exit-1.0 {drmaa::drmaa_exit wrong args} {
	-body {drmaa::drmaa_exit xxx}
	-returnCodes error
	-result {wrong # args: should be "drmaa::drmaa_exit"}
}

tcltest::test exit-1.1 {drmaa::drmaa_exit following drmaa::drmaa_init} {
	-setup {drmaa::drmaa_init {}}
	-body {drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test exit-1.2 {drmaa::drmaa_exit called twice} {
	-body {drmaa::drmaa_init {}; drmaa::drmaa_exit; drmaa::drmaa_exit}
	-returnCodes error
	-match glob
	-result {DRMAA NO_ACTIVE_SESSION *}
}
#
#	Auxiliary Routines
#
tcltest::test contact-1.1 {drmaa::drmaa_version before drmaa::drmaa_init} {
	-body {drmaa::drmaa_version}
	-returnCodes ok
	-match regexp
	-result {\d+ \d+}
}

tcltest::test version-1.0 {drmaa::drmaa_version wrong args} {
	-body {drmaa::drmaa_version xxx}
	-returnCodes error
	-result {wrong # args: should be "drmaa::drmaa_version"}
}

tcltest::test version-1.1 {drmaa::drmaa_version before drmaa::drmaa_init} {
	-body {drmaa::drmaa_version}
	-returnCodes ok
	-match regexp
	-result {\d+ \d+}
}

tcltest::test version-1.2 {drmaa::drmaa_version after drmaa::drmaa_init} {
	-setup {drmaa::drmaa_init {}}
	-body {drmaa::drmaa_version}
	-cleanup {drmaa::drmaa_exit}
	-returnCodes ok
	-match regexp
	-result {\d+ \d+}
}

tcltest::test newjt-1.0 {drmaa::drmaa_allocate_job_template wrong args} {
	-setup {drmaa::drmaa_init}
	-body {drmaa::drmaa_allocate_job_template xxx}
	-cleanup {drmaa::drmaa_exit}
	-returnCodes error
	-result {wrong # args: should be "drmaa::drmaa_allocate_job_template"}
}

tcltest::test newjt-1.1 {drmaa::drmaa_allocate_job_template normal call} {
	-setup {drmaa::drmaa_init}
	-body {drmaa::drmaa_allocate_job_template}
	-cleanup {drmaa::drmaa_exit}
	-match regexp
	-result {jt0x[0-9a-f]+}
	-returnCodes ok
}

tcltest::test deljt-1.0 {drmaa::drmaa_delete_job_template wrong args} {
	-setup {drmaa::drmaa_init}
	-body {drmaa::drmaa_delete_job_template}
	-cleanup {drmaa::drmaa_exit}
	-returnCodes error
	-result {wrong # args: should be "drmaa::drmaa_delete_job_template jt"}
}

tcltest::test deljt-1.1 {drmaa::drmaa_delete_job_template normal call} {
	-setup {drmaa::drmaa_init; set jt [drmaa::drmaa_allocate_job_template]}
	-body {drmaa::drmaa_delete_job_template $jt}
	-cleanup {drmaa::drmaa_exit}
	-returnCodes ok
}

