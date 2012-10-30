#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require drmaa

proc submit {cmd args} {
	set jt [drmaa::drmaa_allocate_job_template]
	drmaa::drmaa_set_attribute $jt drmaa_remote_command $cmd
	drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $args
	set jid [drmaa::drmaa_run_job $jt]
	drmaa::drmaa_delete_job_template $jt
	return $jid
}

drmaa::drmaa_init
set jid [submit /bin/sleep 10]
set wout [drmaa::drmaa_wait $jid $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER]
puts $wout
drmaa::drmaa_exit

