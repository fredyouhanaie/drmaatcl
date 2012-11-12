
# run-testuite.tcl
#	complete test suite for drmaatcl
#	run this via drmaash
#

package require tcltest
tcltest::configure -verbose bpstel

source drmaa-testsuite.tcl

# wrapper for all tests
proc runtest {tname args} {
	if [llength $args] {
		set alist [join $args "_"]
		set test_name "${tname}_${alist}"
	} else {
		set test_name $tname
	}
	# now that we have a decent test name, run it
	tcltest::test "$test_name" "$tname ($args)" {
		-body {$tname {*}$args}
		-cleanup {catch drmaa::drmaa_exit}
		-returnCodes ok
	}
}

runtest ST_MULT_INIT
runtest ST_MULT_EXIT
runtest ST_SUPPORTED_ATTR
runtest ST_SUPPORTED_VATTR
runtest ST_VERSION
runtest ST_DRM_SYSTEM
runtest ST_DRMAA_IMPL
runtest ST_CONTACT

runtest ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE
runtest ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE

foreach ctrl_op {HOLD RELEASE SUSPEND RESUME TERMINATE} {
	runtest ST_EMPTY_SESSION_CONTROL $ctrl_op
}

runtest ST_BULK_SUBMIT_WAIT
runtest ST_SUBMIT_WAIT

runtest ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL

runtest ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE
runtest ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE
runtest ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE
runtest ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE

runtest ST_EXIT_STATUS
runtest ST_SUBMIT_KILL_SIG

runtest ST_INPUT_FILE_FAILURE
runtest ST_OUTPUT_FILE_FAILURE
runtest ST_ERROR_FILE_FAILURE

runtest ST_SUBMIT_IN_HOLD_RELEASE
runtest ST_SUBMIT_IN_HOLD_DELETE

runtest ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE
runtest ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE
runtest ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE
runtest ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE

runtest ST_SUBMIT_POLLING_WAIT_TIMEOUT
runtest ST_SUBMIT_POLLING_WAIT_ZEROTIMEOUT
runtest ST_SUBMIT_POLLING_SYNCHRONIZE_TIMEOUT
runtest ST_SUBMIT_POLLING_SYNCHRONIZE_ZEROTIMEOUT

runtest ST_ATTRIBUTE_CHANGE

runtest ST_SUBMIT_SUSPEND_RESUME_WAIT

runtest ST_USAGE_CHECK

runtest ST_UNSUPPORTED_ATTR
runtest ST_UNSUPPORTED_VATTR

runtest MT_SUBMIT_WAIT 
runtest MT_SUBMIT_BEFORE_INIT_WAIT 
runtest MT_EXIT_DURING_SUBMIT
runtest MT_SUBMIT_MT_WAIT
runtest MT_EXIT_DURING_SUBMIT_OR_WAIT

runtest ST_GET_NUM_JOBIDS

runtest ST_BULK_SUBMIT_INCRPH

puts "\n\n"
tcltest::cleanupTests
