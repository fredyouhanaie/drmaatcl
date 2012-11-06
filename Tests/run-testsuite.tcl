
# test-1.tcl
#	complete test suite for drmaatcl
#	run via drmaash
#

package require tcltest
tcltest::configure -verbose bpstel

source drmaa-testsuite.tcl

tcltest::test ST_MULT_INIT {Multiple drmaa_init} {
	-body {ST_MULT_INIT}
	-returnCodes ok
}

tcltest::test ST_MULT_EXIT {Multiple drmaa_exit} {
	-body {ST_MULT_EXIT}
	-returnCodes ok
}

tcltest::test ST_SUPPORTED_ATTR {Supported attributes} {
	-body {ST_SUPPORTED_ATTR}
	-returnCodes ok
}

tcltest::test ST_SUPPORTED_VATTR {Supported vector attributes} {
	-body {ST_SUPPORTED_VATTR}
	-returnCodes ok
}

tcltest::test ST_VERSION {DRMAA version} {
	-body {ST_VERSION}
	-returnCodes ok
}

tcltest::test ST_DRM_SYSTEM {DRM system} {
	-body {ST_DRM_SYSTEM}
	-returnCodes ok
}

tcltest::test ST_DRMAA_IMPL {DRMAA implementation} {
	-body {ST_DRMAA_IMPL}
	-returnCodes ok
}

tcltest::test ST_CONTACT {Contact string} {
	-body {ST_CONTACT}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_WAIT {Wait for empty session} {
	-body {ST_EMPTY_SESSION_WAIT}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE {synchronize with empty session (dispose)} {
	-body {ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE {synchronize with empty session (nodispose)} {
	-body {ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_CONTROL {Control empty session} {
	-body {foreach action HOLD RELEASE RESUME SUSPEND TERMINATE {ST_EMPTY_SESSION_CONTROL $action}}
	-returnCodes ok
}

tcltest::test ST_BULK_SUBMIT_WAIT {Submit bulk jobs and wait for completion (single-thread)} {
	-body {ST_BULK_SUBMIT_WAIT}
	-returnCodes ok
}

tcltest::test ST_SUBMIT_WAIT {Submit jobs and wait for completion (single-thread)} {
	-body {ST_SUBMIT_WAIT}
	-returnCodes ok
}

tcltest::test  ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL {Submit bulk/single jobs, wait individually (single-thread)} {
	-body {ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE {Submit bulk/single jobs, sync all, dispose (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE {Submit bulk/single jobs, sync all, wait individually (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE}
	-returnCodes ok
}

