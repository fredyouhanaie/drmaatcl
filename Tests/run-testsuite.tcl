
# test-1.tcl
#	complete test suite for drmaatcl
#	run via drmaash
#

package require tcltest
tcltest::configure -verbose bpstel

source drmaa-testsuite.tcl

tcltest::test ST_MULT_INIT {Multiple drmaa_init} {
	-body {ST_MULT_INIT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_MULT_EXIT {Multiple drmaa_exit} {
	-body {ST_MULT_EXIT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_SUPPORTED_ATTR {Supported attributes} {
	-body {ST_SUPPORTED_ATTR}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_SUPPORTED_VATTR {Supported vector attributes} {
	-body {ST_SUPPORTED_VATTR}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_VERSION {DRMAA version} {
	-body {ST_VERSION}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_DRM_SYSTEM {DRM system} {
	-body {ST_DRM_SYSTEM}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_DRMAA_IMPL {DRMAA implementation} {
	-body {ST_DRMAA_IMPL}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_CONTACT {Contact string} {
	-body {ST_CONTACT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_WAIT {Wait for empty session} {
	-body {ST_EMPTY_SESSION_WAIT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE {synchronize with empty session (dispose)} {
	-body {ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE {synchronize with empty session (nodispose)} {
	-body {ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_EMPTY_SESSION_CONTROL {Control empty session} {
	-body {foreach action HOLD RELEASE RESUME SUSPEND TERMINATE {ST_EMPTY_SESSION_CONTROL $action}}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_BULK_SUBMIT_WAIT {Submit bulk jobs and wait for completion (single-thread)} {
	-body {ST_BULK_SUBMIT_WAIT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test ST_SUBMIT_WAIT {Submit jobs and wait for completion (single-thread)} {
	-body {ST_SUBMIT_WAIT}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL {Submit bulk/single jobs, wait individually (single-thread)} {
	-body {ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE {Submit bulk/single jobs, sync all, dispose (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE {Submit bulk/single jobs, sync all, wait individually (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE {Submit bulk/single jobs, sync all ids, dispose (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE {Submit bulk/single jobs, sync all ids, wait individually (single-thread)} {
	-body {ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_EXIT_STATUS {Submit single jobs, check exit status} {
	-body {ST_EXIT_STATUS}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMIT_KILL_SIG {Submit single jobs, kill, check termination} {
	-body {ST_SUBMIT_KILL_SIG}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_INPUT_FILE_FAILURE {Submit single job with invalid input path} {
	-body {ST_INPUT_FILE_FAILURE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_OUTPUT_FILE_FAILURE {Submit single job with invalid output path} {
	-body {ST_OUTPUT_FILE_FAILURE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_ERROR_FILE_FAILURE {Submit single job with invalid error path} {
	-body {ST_ERROR_FILE_FAILURE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMIT_IN_HOLD_RELEASE {Submit job in hold, then release and check} {
	-body {ST_SUBMIT_IN_HOLD_RELEASE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_SUBMIT_IN_HOLD_DELETE {Submit job in hold, then terminate and check} {
	-body {ST_SUBMIT_IN_HOLD_DELETE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE {Submit bulk job in hold, then release and check} {
	-body {ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE {Submit bulk job in hold, then terminate and check} {
	-body {ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE {Submit bulk job in hold, then release and check} {
	-body {ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

tcltest::test  ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE {Submit bulk job in hold, then terminate and check} {
	-body {ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE}
	-cleanup {catch drmaa::drmaa_exit}
	-returnCodes ok
}

puts "\n\n"
tcltest::cleanupTests
