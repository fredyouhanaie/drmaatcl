
# test-2.tcl
#	temp test scripts
#

package require tcltest
tcltest::configure -verbose p

tcltest::test setvecattr {set vector attribute} {
	-setup {
		drmaa_init
		drmaa_allocate_job_template
		drmaa_set_vector_attribute jt0 drmaa_v_argv a bb ccc
	}
	-body {drmaa_get_vector_attribute jt0 drmaa_v_argv}
	-returnCodes ok
	-result {a bb ccc}
	-cleanup {drmaa_exit}
}

