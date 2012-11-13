
# selective-test.tcl
# run tests selectively

package require tcltest
# full verbosity = {body start skip pass error line}
tcltest::configure -verbose {body start skip pass error line}

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

set All_tests {	ST_MULT_INIT
		MT_EXIT_DURING_SUBMIT
		MT_EXIT_DURING_SUBMIT_OR_WAIT
		MT_SUBMIT_BEFORE_INIT_WAIT 
		MT_SUBMIT_MT_WAIT
		MT_SUBMIT_WAIT 
		ST_ATTRIBUTE_CHANGE
		ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL
		ST_BULK_SUBMIT_INCRPH
		ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE
		ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE
		ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE
		ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE
		ST_BULK_SUBMIT_WAIT
		ST_CONTACT
		ST_DRMAA_IMPL
		ST_DRM_SYSTEM
		ST_EMPTY_SESSION_CONTROL
		ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE
		ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE
		ST_ERROR_FILE_FAILURE
		ST_EXIT_STATUS
		ST_GET_NUM_JOBIDS
		ST_INPUT_FILE_FAILURE
		ST_MULT_EXIT
		ST_OUTPUT_FILE_FAILURE
		ST_SUBMIT_IN_HOLD_DELETE
		ST_SUBMIT_IN_HOLD_RELEASE
		ST_SUBMIT_KILL_SIG
		ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE
		ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE
		ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE
		ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE
		ST_SUBMIT_POLLING_SYNCHRONIZE_TIMEOUT
		ST_SUBMIT_POLLING_SYNCHRONIZE_ZEROTIMEOUT
		ST_SUBMIT_POLLING_WAIT_TIMEOUT
		ST_SUBMIT_POLLING_WAIT_ZEROTIMEOUT
		ST_SUBMIT_SUSPEND_RESUME_WAIT
		ST_SUBMIT_WAIT
		ST_SUPPORTED_ATTR
		ST_SUPPORTED_VATTR
		ST_UNSUPPORTED_ATTR
		ST_UNSUPPORTED_VATTR
		ST_USAGE_CHECK
		ST_VERSION
}

foreach tname $argv {
	if {$tname in $All_tests} {
		if {$tname == "ST_EMPTY_SESSION_CONTROL"} {
			foreach ctrl_op {HOLD RELEASE SUSPEND RESUME TERMINATE} {
				runtest $tname $ctrl_op
			}
		} else {
			runtest $tname
		}
	} else {
		puts stderr "Unknown test name >$tname<"
	}
}

tcltest::cleanupTests
