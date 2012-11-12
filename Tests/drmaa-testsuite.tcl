
package require drmaa

set myname [info script]

# drmaatcl test suit.
# based on DRMAA_TEST_SUITE_VERSION "1.7.2"

set JOB_CHUNK	2
set NTHREADS	3
set NBULKS	3

# TODO: should really come from command line
set sleeper_job	"/bin/sleep"
set exit_job	"/usr/local/bin/test_exit_helper"
set kill_job	"/usr/local/bin/test_kill_helper"

# DRMAA_TIMEOUT_WAIT_FOREVER is anyway useless in a test suite
# we assume some local setting, fast enough for the single job runs
set max_wait 3600

# shorter names to help the reader
set ANY_JOB	$drmaa::DRMAA_JOB_IDS_SESSION_ANY
set ALL_JOBS	$drmaa::DRMAA_JOB_IDS_SESSION_ALL
set NO_WAIT	$drmaa::DRMAA_TIMEOUT_NO_WAIT
set JS_HOLD	$drmaa::DRMAA_SUBMISSION_STATE_HOLD
set JS_ACTIVE	$drmaa::DRMAA_SUBMISSION_STATE_ACTIVE

# File paths
set SECURE_FILE "/tmp/drmaa_inaccessible_file"
set SLEEPER_LOG	"drmaa_sleeper_job.log"

# Tcl does not have a common garden (POSIX) sleep command
proc sleep {seconds} {
	after [expr 1000*$seconds]
}

# error report for investigation by user
# args are as generated by catch
proc error_report {result options} {
	puts stderr "=== result ========"
	puts stderr $result
	puts stderr "=== Error Trace ==="
	puts stderr $options
	puts stderr "==================="
}

proc create_sleeper_job_template {seconds in_hold} {
	# catch the errors, and pass them to the caller
	if [catch {	set jt [drmaa::drmaa_allocate_job_template]
			#drmaa::drmaa_set_attribute $jt drmaa_wd $drmaa::DRMAA_PLACEHOLDER_HD
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":$::SLEEPER_LOG"
			drmaa::drmaa_set_attribute $jt drmaa_join_files "y"
			drmaa::drmaa_set_attribute $jt drmaa_remote_command $::sleeper_job
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $seconds
			if $in_hold {
				drmaa::drmaa_set_attribute $jt drmaa_js_state $::JS_HOLD
			} } result] {
		return -code error $result
	}
	return $jt
}

proc create_exit_job_template {} {
	# catch the errors, and pass them to the caller
	if [catch {	set jt [drmaa::drmaa_allocate_job_template]
			drmaa::drmaa_set_attribute $jt drmaa_wd $drmaa::DRMAA_PLACEHOLDER_HD
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":/dev/null"
			drmaa::drmaa_set_attribute $jt drmaa_join_files "y"
			drmaa::drmaa_set_attribute $jt drmaa_remote_command $::exit_job
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv 0
			} result] {
		return -code error $result
	}
	return $jt
}

proc wait_n_jobs {njobs} {
	set some_error 0
	for {set i 0} {$i<$njobs} {incr i} {
		while [catch {set wout [drmaa::drmaa_wait $::ANY_JOB $::max_wait]} result] {
			if {[lindex $result 1]=="TRY_LATER"} {
				puts "\tretry ..."
				sleep 1
				continue
			} else {
				return -code error $result
			}
		}
		set jobid [lindex $wout 0]
		puts "\twaiting for any job resulted in finished job $jobid"
		#break;
	}
	puts "\tWaited for $njobs jobs"
	return
}

# wait for all ST jobs
proc wait_all_st_jobs {njobs} {
	puts "\twaiting for $njobs jobs"
	while {$njobs>0} {
		if [catch {set wout [drmaa::drmaa_wait $::ANY_JOB $::max_wait]} result] {
			if {[lindex $result 1] != "INVALID_JOB"} {
				return -code error $result
			}
			break
		}
		set jobid [lindex $wout 0]
		puts "\twaited job >$jobid<"
		incr njobs -1
	}
	puts "\twaited for the last job"
	return
}

# wait for all MT jobs
proc wait_all_mt_jobs {} {
	puts "\twaiting for all multithreaded jobs"
	while 1 {
		if [catch {set wout [drmaa::drmaa_wait $::ANY_JOB $::max_wait]} result] {
			if {[lindex $result 1] != "INVALID_JOB"} {
				return -code error $result
			}
			break
		}
		set jobid [lindex $wout 0]
		puts "\twaited job >$jobid<"
	}
	puts "\twaited for the last job"
	return
}

# submit nbulks of jchunk jobs
proc submit_bulk_sleeper_jobs {seconds in_hold nbulk jchunk} {
	set all_jobids {}
	if [catch {	set jt [create_sleeper_job_template $seconds $in_hold]
			for {set i 0} {$i<$nbulk} {incr i} {
				set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $jchunk 1]
				set all_jobids [concat $all_jobids " " $jobids]
				puts "\tSubmitted $jchunk bulk jobs with job ids: $jobids"
			}
			drmaa::drmaa_delete_job_template $jt} result] {
		return -code error $result
	}
	return $all_jobids
}

# submit individual sleeper job(s)
proc submit_sleeper_jobs {seconds in_hold njobs} {
	set all_jobids {}
	if [catch {	set jt [create_sleeper_job_template $seconds $in_hold]
			for {set i 0} {$i<$njobs} {incr i} {
				set jobid [drmaa::drmaa_run_job $jt]
				lappend all_jobids $jobid
				puts "\tsubmitted job >$jobid<"
			}
			drmaa::drmaa_delete_job_template $jt} result] {
		return -code error $result
	}
	return $all_jobids
}

# submit individual submit sleeper jobs
# mt_exit=1 for MT_EXIT_DURING_SUBMIT_OR_WAIT and MT_EXIT_DURING_SUBMIT
proc submit_sleeper_thread {njobs mt_exit} {
	set all_jobids {}
	if [catch {	set jt [create_sleeper_job_template 10 0]
			for {set i 0} {$i<$njobs} {incr i} {
				while [catch {set jobid [drmaa::drmaa_run_job $jt]} result] {
					set errno [lindex $result 1]
					puts "\tfailed submitting job: $errno"
					if {$errno == "TRY_LATER"} {
						puts "retry ..."
						sleep 1
						continue
					} elseif {$errno == "NO_ACTIVE_SESSION"} {
						if $mt_exit {
							set jobid 0
							break
						} else {
							return -code error $result
						}
					} else {
						return -code error $result
					}
				}
				if {$jobid==0} {
					puts "\tunable to submit job"
				} else {
					lappend all_jobids $jobid
					puts "\tsubmitted job >$jobid<"
				}
			}
			drmaa::drmaa_delete_job_template $jt} result] {
		return -code error $result
	}
	return $all_jobids
}

proc submit_and_wait_thread {njobs} {
	if [catch {	submit_sleeper_thread $njobs 0 
			wait_all_st_jobs $njobs} result] {
		return -code error $result
	}
	return
}

# wait for individual jobs
proc wait_individual_jobs {all_jobids} {
	puts "\twaiting for $all_jobids"
	if [catch {	foreach jobid $all_jobids {
				while 1 {
					if [catch {set wout [drmaa::drmaa_wait $jobid $::max_wait]} result] {
						set err [lindex $result 1]
						if {$err =="DRM_COMMUNICATIONS_FAILURE"} {
							sleep 1
							continue
						} elseif {$err != "INVALID_JOB"} {
							return -code error $result
						}
						break
					}
					set real_job_id [lindex $wout 0]
					puts "\twaited job >$real_job_id<"
					break
				}
			}} result] {
		return -code error $result
	}
	puts "\twaited all jobs"
	return
}

proc check_term_details {stat exp_aborted exp_exited exp_signaled} {
	if [catch {	set aborted [drmaa::drmaa_wifaborted $stat]
			if {$exp_aborted && !$aborted} {
				return -code error "Expected wifaborted = $exp_aborted got $aborted"
			}
			set exited [drmaa::drmaa_wifexited $stat]
			if {$exp_exited && !$exited} {
				return -code error "Expected wifexited = $exp_exited, got $exited"
			}
			set signaled [drmaa::drmaa_wifsignaled $stat]
			if {$exp_signaled && !$signaled} {
				return -code error "Expected wifsignaled = $exp_signaled, got $signaled"
			} } result] {
		return -code error $result
	}
	return
}

proc check_job_state {jobid exp_jobstate} {
	set retry_count 3
	set retry_sleep 5
	while {$retry_count > 0} {
		set job_state [drmaa::drmaa_job_ps $jobid]
		if {$job_state == $exp_jobstate} {
			puts "\tjob state for $jobid is $exp_jobstate, as expected"
			return
		} else {
			puts "\tCurrent job state $jobid is $job_state, expected $exp_jobstate,"
			puts "\ttrying to get another answer ($retry_count attempts left)"
			incr retry_count -1
			sleep $retry_sleep
		}
	}
	return -code error "Too many drmaa_job_ps retries, while $exp_jobstate was expected."
}


# check single valued vector attribute value
proc check_vector_attr {jt attr exp_val} {
	set attr_vec [drmaa::drmaa_get_vector_attribute $jt $attr]
	set vec_len [llength $attr_vec]
	if {$vec_len != 1} {
		return -code error "$attr has wrong count $vec_len, expected 1"
	}
	if {$attr_vec != $exp_val} {
		return -code error "Incorrect value after change for $attr attribute"
	}
}

# check an attribute
proc check_attribute {jt attr exp_val} {
	set attr_val [drmaa::drmaa_get_attribute $jt $attr]
	if {$attr_val != $exp_val} {
		return -code error "Incorrect value after change for $attr attribute"
	}
}


proc wrong_job_finish {comment jobid stat} {
	if [drmaa::drmaa_wifaborted $stat] {
		return "$comment: job $jobid never ran"
	}
	if [drmaa::drmaa_wifexited $stat] {
		set exit_status [drmaa::drmaa_wexitstatus $stat]
		return "$comment: job $jobid finished regularly with exit status $exit_status"
	}
	if [drmaa::drmaa_wifsignaled $stat] {
		set termsig [drmaa::drmaa_wtermsig $stat]
		return "$comment: job $jobid finished due to signal $termsig"
	}
	return "$comment: job $jobid finished with unclear conditions"
}

proc ST_MULT_INIT {} {
	# init - should succeed
	if [catch {drmaa::drmaa_init} result] {
		return -code error $result
	}
	# init again should fail
	if {[catch {drmaa::drmaa_init} result]} {
		if {[lindex $result 1] != "ALREADY_ACTIVE_SESSION"} {
			return -code error $result
		}
	} else {
		return -code error "second drmaa_init succeeded!"
	}
	# exit
	if [catch {drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_MULT_EXIT {} {
	# init + exit
	if [catch {drmaa::drmaa_init; drmaa::drmaa_exit} result] {
		return -code error $result
	}
	# exit again
	if {[catch {drmaa::drmaa_exit} result] == 0} {
		return -code error "second drmaa_exit succeeded!"
	}
	if {[lindex $result 1] != "NO_ACTIVE_SESSION"} then {
		return -code error $result
	}
	return
}

proc ST_SUPPORTED_ATTR {} {
	if [catch {	drmaa::drmaa_init
			set attrlist [drmaa::drmaa_get_attribute_names]
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	foreach attr $attrlist { puts "\t$attr" }
	return
}

proc ST_SUPPORTED_VATTR {} {
	if [catch {	drmaa::drmaa_init
			set attrlist [drmaa::drmaa_get_vector_attribute_names]
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	foreach attr $attrlist { puts "\t$attr" }
	return
}

proc ST_VERSION {} {
	if [catch {set maj_min [drmaa::drmaa_version]} result] {
		return -code error $result
	}
	puts "\tversion [join $maj_min .]"
	return
}

proc ST_DRM_SYSTEM {} {
	if [catch {	set DRM_system [drmaa::drmaa_get_DRM_system]
			puts "\tdrmaa_get_DRM_system returned \"$DRM_system\" before init."
			drmaa::drmaa_init
			set DRM_system [drmaa::drmaa_get_DRM_system]
			puts "\tdrmaa_get_DRM_system returned \"$DRM_system\" after init."
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_DRMAA_IMPL {} {
	if [catch {	set DRMAA_impl [drmaa::drmaa_get_DRMAA_implementation]
			puts "\tdrmaa_get_DRMAA_implementation returned \"$DRMAA_impl\" before init."
			drmaa::drmaa_init
			set DRMAA_impl [drmaa::drmaa_get_DRMAA_implementation]
			puts "\tdrmaa_get_DRMAA_implementation returned \"$DRMAA_impl\" after init."
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_CONTACT {} {
	if [catch {	set contact [drmaa::drmaa_get_contact]
			puts "\tdrmaa_get_contact returned \"$contact\" before init."
			drmaa::drmaa_init
			set DRMAA_impl [drmaa::drmaa_get_DRMAA_implementation]
			puts "\tdrmaa_get_contact returned \"$contact\" after init."
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_EMPTY_SESSION_WAIT {} {
	if [catch {drmaa::drmaa_init} result] {
		return -code error $result
	}
	if [catch {drmaa::drmaa_wait $drmaa::DRMAA_JOB_IDS_SESSION_ANY $::max_wait
			} result] {
		if {[lindex $result 1] != "INVALID_JOB"} {
			return -code error $result
		}
	} else {
		return -code error "drmaa_wait returned success!"
	}
	if [catch {drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE {} {
	if [catch {	drmaa::drmaa_init
			drmaa::drmaa_synchronize $::max_wait 1 $drmaa::DRMAA_JOB_IDS_SESSION_ALL
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE {} {
	if [catch {	drmaa::drmaa_init
			drmaa::drmaa_synchronize $::max_wait 0 $drmaa::DRMAA_JOB_IDS_SESSION_ALL
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_EMPTY_SESSION_CONTROL {action} {
	if [catch {	drmaa::drmaa_init
			drmaa::drmaa_control $drmaa::DRMAA_JOB_IDS_SESSION_ALL $action
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_WAIT {} {
	if [catch {	drmaa::drmaa_init
			submit_sleeper_jobs 5 0 $::JOB_CHUNK
			wait_all_st_jobs $::JOB_CHUNK
			drmaa::drmaa_exit
			} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_WAIT {} {
	if [catch {	drmaa::drmaa_init
			submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK
			wait_all_st_jobs [expr $::NBULKS*$::JOB_CHUNK]
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL {} {
	set all_jobids {}
	if [catch {	drmaa::drmaa_init
			set all_jobids [concat $all_jobids [submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK]]
			set all_jobids [concat $all_jobids [submit_sleeper_jobs 5 0 $::JOB_CHUNK]]
			wait_individual_jobs $all_jobids
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return

}

proc ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE {} {
	if [catch {	drmaa::drmaa_init
			submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK
			submit_sleeper_jobs 5 0 $::JOB_CHUNK
			puts "\tsynchronizing with all jobs."
			drmaa::drmaa_synchronize $::max_wait 1 $::ALL_JOBS
			puts "\tsynchronized with all jobs."
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE {} {
	set all_jobids {}
	if [catch {	drmaa::drmaa_init
			set bjobs [submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK]
			set ijobs [submit_sleeper_jobs 5 0 $::JOB_CHUNK]
			set all_jobids [concat $bjobs " " $ijobs]
			puts "\tsynchronizing with all jobs."
			drmaa::drmaa_synchronize $::max_wait 1 $::ALL_JOBS
			puts "\tsynchronized with all jobs."
			wait_individual_jobs $all_jobids
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE {} {
	set all_jobids {}
	if [catch {	drmaa::drmaa_init
			set bjobs [submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK]
			set ijobs [submit_sleeper_jobs 5 0 $::JOB_CHUNK]
			set all_jobids [concat $bjobs " " $ijobs]
			puts "\tsynchronizing: $all_jobids"
			drmaa::drmaa_synchronize $::max_wait 1 {*}$all_jobids
			puts "\tsynchronized with all jobs."
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return

}

proc ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE {} {
	set all_jobids {}
	if [catch {	drmaa::drmaa_init
			set bjobs [submit_bulk_sleeper_jobs 5 0 $::NBULKS $::JOB_CHUNK]
			set ijobs [submit_sleeper_jobs 5 0 $::JOB_CHUNK]
			set all_jobids [concat $bjobs " " $ijobs]
			puts "\tsynchronizing: $all_jobids"
			drmaa::drmaa_synchronize $::max_wait 0 {*}$all_jobids
			puts "\tsynchronized with all jobs."
			wait_individual_jobs $all_jobids
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return


}

proc ST_EXIT_STATUS {} {
	set alljobs {}
	if [catch {	drmaa::drmaa_init
			set jt [create_exit_job_template]
			for {set i 0} {$i<126} {incr i} {
				drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $i
				set jobid [drmaa::drmaa_run_job $jt]
				lappend alljobs $jobid
				puts "\t$i\t$jobid"
			}
			drmaa::drmaa_delete_job_template $jt
			for {set i 0} {$i<126} {incr i} {
				set jobid [lindex $alljobs $i]
				while [catch {set wout [drmaa::drmaa_wait $jobid $::max_wait]} result] {
					if {[lindex $result 1] == "DRM_COMMUNICATIONS_FAILURE"} {
						sleep 1 
						continue
					} else {
						return -code error $result
					}
				}
				puts "\tjob $i with job id $jobid finished"
				set jobstat [lindex $wout 1]
				if {! [drmaa::drmaa_wifexited $jobstat]} {
					return -code error "Job $jobid did not exit cleanly"
				}
				set exit_status [drmaa::drmaa_wexitstatus $jobstat]
				if {$exit_status != $i} {
					return -code error "Job $jobid returned $exit_status instead of $i!"
				}
			}
			puts "\twaited all jobs"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_KILL_SIG {} {
	array set sigList {
		 1	SIGHUP
		 3	SIGQUIT
		 4	SIGILL
		 6	SIGABRT
		 8	SIGFPE
		 9	SIGKILL
		10	SIGUSR1
		11	SIGSEGV
		12	SIGUSR2
		14	SIGALRM
		15	SIGTERM
	}
	if [catch {	drmaa::drmaa_init
			set jt [drmaa::drmaa_allocate_job_template]
			drmaa::drmaa_set_attribute $jt drmaa_wd $drmaa::DRMAA_PLACEHOLDER_HD
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":/dev/null"
			drmaa::drmaa_set_attribute $jt drmaa_join_files "y"
			drmaa::drmaa_set_attribute $jt drmaa_remote_command $::kill_job
			foreach {sig exp_sigName} [array get sigList] {
				puts "\tTesting with $exp_sigName ($sig)"
				drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $sig
				set jobid [drmaa::drmaa_run_job $jt]
				puts "\tsubmitted job $jobid"
				set wout [drmaa::drmaa_wait $jobid $::max_wait]
				set jobstat [lindex $wout 1]
				check_term_details $jobstat 0 0 1
				set sigName [drmaa::drmaa_wtermsig $jobstat]
				if {$sigName == $exp_sigName} {
					puts -nonewline "\tjob $jobid was killed with $sigName, as expected"
					set was_dumped [drmaa::drmaa_wcoredump $jobstat]
					if $was_dumped {
						puts " (with core dump file)"
					} else {
						puts " (without core dump file)"
					}
				} else {
					return -code error "Reported signal is $sigName, expected $exp_sigName."
				}
			}
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_INPUT_FILE_FAILURE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			drmaa::drmaa_set_attribute $jt drmaa_input_path ":$::SECURE_FILE"
			set jobid [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $jobid"
			drmaa::drmaa_delete_job_template $jt
			puts "\tsynchronizing: $::ALL_JOBS"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			check_job_state $jobid FAILED
			drmaa::drmaa_wait $jobid $drmaa::DRMAA_TIMEOUT_NO_WAIT
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_OUTPUT_FILE_FAILURE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			drmaa::drmaa_set_attribute $jt drmaa_join_files "y"
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":$::SECURE_FILE"
			set jobid [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $jobid"
			drmaa::drmaa_delete_job_template $jt
			puts "\tsynchronizing: $::ALL_JOBS"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			check_job_state $jobid FAILED
			drmaa::drmaa_wait $jobid $drmaa::DRMAA_TIMEOUT_NO_WAIT
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_ERROR_FILE_FAILURE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			drmaa::drmaa_set_attribute $jt drmaa_join_files "n"
			drmaa::drmaa_set_attribute $jt drmaa_error_path ":$::SECURE_FILE"
			set jobid [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $jobid"
			drmaa::drmaa_delete_job_template $jt
			puts "\tsynchronizing: $::ALL_JOBS"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			check_job_state $jobid FAILED
			drmaa::drmaa_wait $jobid $drmaa::DRMAA_TIMEOUT_NO_WAIT
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_IN_HOLD_RELEASE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set job_id [drmaa::drmaa_run_job $jt]
			drmaa::drmaa_delete_job_template $jt
			puts "\tsubmitted job in hold state $job_id"
			if [catch {check_job_state $job_id USER_ON_HOLD}] {
				check_job_state $job_id SYSTEM_ON_HOLD
			}
			puts "\tverified user hold state for job $job_id"
			drmaa::drmaa_control $job_id RELEASE
			puts "\treleased user hold state for job $job_id"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			check_job_state $job_id DONE
			wait_n_jobs 1
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_IN_HOLD_DELETE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set job_id [drmaa::drmaa_run_job $jt]
			drmaa::drmaa_delete_job_template $jt
			puts "\tsubmitted job in hold state $job_id"
			if [catch {check_job_state $job_id USER_ON_HOLD}] {
				check_job_state $job_id SYSTEM_ON_HOLD
			}
			puts "\tverified user hold state for job $job_id"
			drmaa::drmaa_control $job_id TERMINATE
			puts "\treleased user hold state for job $job_id"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			check_job_state $job_id FAILED
			if [catch {set wout [drmaa::drmaa_wait $job_id $::max_wait]} result] {
				if {[lindex $result 1] != "NO_RUSAGE"} {
					return -code error $result
				}
			}
			check_term_details [lindex $wout 1] 1 0 0
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $::JOB_CHUNK 1]
			puts "\tsubmitted bulk job with jobids: $jobids"
			drmaa::drmaa_delete_job_template $jt
			foreach jid $jobids {
				if [catch {check_job_state $jid USER_ON_HOLD}] {
					check_job_state $jid USER_SYSTEM_ON_HOLD
				}
			}
			puts "\tverified user hold state for bulk job"
			drmaa::drmaa_control $::ALL_JOBS RELEASE
			puts "\treleased all jobs"
			#puts "\tterminated all jobs"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			foreach jid $jobids {
				check_job_state $jid DONE
			}
			wait_n_jobs $::JOB_CHUNK
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $::JOB_CHUNK 1]
			puts "\tsubmitted bulk job with jobids: $jobids"
			drmaa::drmaa_delete_job_template $jt
			foreach jid $jobids {
				if [catch {check_job_state $jid USER_ON_HOLD}] {
					check_job_state $jid USER_SYSTEM_ON_HOLD
				}
			}
			puts "\tverified user hold state for bulk job"
			foreach jid $jobids {
				drmaa::drmaa_control $jid RELEASE
			}
			puts "\treleased all jobs"
			drmaa::drmaa_synchronize $::max_wait 0 $::ALL_JOBS
			puts "\tsynchronized with job finish"
			foreach jid $jobids {
				check_job_state $jid DONE
			}
			wait_n_jobs $::JOB_CHUNK
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $::JOB_CHUNK 1]
			puts "\tsubmitted bulk job with jobids: $jobids"
			drmaa::drmaa_delete_job_template $jt
			foreach jid $jobids {
				if [catch {check_job_state $jid USER_ON_HOLD}] {
					check_job_state $jid USER_SYSTEM_ON_HOLD
				}
			}
			puts "\tverified user hold state for bulk job"
			drmaa::drmaa_control $::ALL_JOBS TERMINATE
			puts "\tterminated all jobs"
			foreach jid $jobids {
				check_job_state $jid FAILED
			}
			wait_n_jobs $::JOB_CHUNK
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 1]
			set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $::JOB_CHUNK 1]
			puts "\tsubmitted bulk job with jobids: $jobids"
			drmaa::drmaa_delete_job_template $jt
			foreach jid $jobids {
				if [catch {check_job_state $jid USER_ON_HOLD}] {
					check_job_state $jid USER_SYSTEM_ON_HOLD
				}
			}
			puts "\tverified user hold state for bulk job"
			foreach jid $jobids {
				drmaa::drmaa_control $jid TERMINATE
			}
			puts "\tterminated all jobs"
			foreach jid $jobids {
				check_job_state $jid FAILED
			}
			wait_n_jobs $::JOB_CHUNK
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_POLLING_WAIT_TIMEOUT {} {
	set timeout 5
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			set job_id [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $job_id"
			drmaa::drmaa_delete_job_template $jt
			while 1 {
				if [catch {drmaa::drmaa_wait $job_id $timeout} result] {
					if {[lindex $result 1] != "EXIT_TIMEOUT"} {
						return -code error $result
					}
					puts "\tstill waiting for job $job_id to finish"
				} else {
					break
				}
			}
			puts "\tjob $job_id finished"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_POLLING_WAIT_ZEROTIMEOUT {} {
	set timeout 5
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			set job_id [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $job_id"
			drmaa::drmaa_delete_job_template $jt
			while 1 {
				if [catch {drmaa::drmaa_wait $job_id $::NO_WAIT} result] {
					if {[lindex $result 1] != "EXIT_TIMEOUT"} {
						return -code error $result
					}
					puts "\tstill waiting for job $job_id to finish"
					sleep $timeout
					puts "\tslept $timeout seconds"
				} else {
					break
				}
			}
			puts "\tjob $job_id finished"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_POLLING_SYNCHRONIZE_TIMEOUT {} {
	set timeout 5
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			set job_id [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $job_id"
			drmaa::drmaa_delete_job_template $jt
			while 1 {
				if [catch {drmaa::drmaa_synchronize $timeout 1 $job_id} result] {
					if {[lindex $result 1] != "EXIT_TIMEOUT"} {
						return -code error $result
					}
					puts "\tstill trying to synchronize with job $job_id to finish"
				} else {
					break
				}
			}
			puts "\tjob $job_id finished"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_POLLING_SYNCHRONIZE_ZEROTIMEOUT {} {
	set timeout 5
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			set job_id [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $job_id"
			drmaa::drmaa_delete_job_template $jt
			while 1 {
				if [catch {drmaa::drmaa_synchronize $::NO_WAIT 1 $job_id} result] {
					if {[lindex $result 1] != "EXIT_TIMEOUT"} {
						return -code error $result
					}
					puts "\tstill trying to synchronize with job $job_id to finish"
					sleep $timeout
					puts "\tslept $timeout seconds"
				} else {
					break
				}
			}
			puts "\tjob $job_id finished"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_ATTRIBUTE_CHANGE {} {
	if [catch {	drmaa::drmaa_init
			puts "\tTesting change of job template attributes"
			puts "\tGetting job template"
			set jt [drmaa::drmaa_allocate_job_template]
			puts "\tFilling job template for the first time"
			set job_argv {argv1}
			set job_env {env1}
			set email_addr {email1}
			drmaa::drmaa_set_attribute $jt drmaa_remote_command "job1"
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $job_argv
			drmaa::drmaa_set_attribute $jt drmaa_js_state $::JS_HOLD
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_env $job_env
			drmaa::drmaa_set_attribute $jt drmaa_wd "/tmp1"
			drmaa::drmaa_set_attribute $jt drmaa_job_category "category1"
			drmaa::drmaa_set_attribute $jt drmaa_native_specification "native1"
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_email $email_addr
			drmaa::drmaa_set_attribute $jt drmaa_block_email "1"
			drmaa::drmaa_set_attribute $jt drmaa_start_time "11:11"
			drmaa::drmaa_set_attribute $jt drmaa_job_name "jobname1"
			drmaa::drmaa_set_attribute $jt drmaa_input_path ":/dev/null1"
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":/dev/null1"
			drmaa::drmaa_set_attribute $jt drmaa_error_path ":/dev/null1"
			drmaa::drmaa_set_attribute $jt drmaa_join_files "y"
			puts "\tFilling job template for the second time"
			set job_argv {2}
			set job_env {env2}
			set email_addr {email2}
			drmaa::drmaa_set_attribute $jt drmaa_remote_command "job2"
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $job_argv
			drmaa::drmaa_set_attribute $jt drmaa_js_state $::JS_ACTIVE
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_env $job_env
			drmaa::drmaa_set_attribute $jt drmaa_wd "/tmp2"
			drmaa::drmaa_set_attribute $jt drmaa_job_category "category2"
			drmaa::drmaa_set_attribute $jt drmaa_native_specification "native2"
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_email $email_addr
			drmaa::drmaa_set_attribute $jt drmaa_block_email "0"
			drmaa::drmaa_set_attribute $jt drmaa_start_time "11:22"
			drmaa::drmaa_set_attribute $jt drmaa_job_name "jobname2"
			drmaa::drmaa_set_attribute $jt drmaa_input_path ":/dev/null2"
			drmaa::drmaa_set_attribute $jt drmaa_output_path ":/dev/null2"
			drmaa::drmaa_set_attribute $jt drmaa_error_path ":/dev/null2"
			drmaa::drmaa_set_attribute $jt drmaa_join_files "n"
			puts "\tChecking current values of job template"
			check_vector_attr	$jt drmaa_v_argv		$job_argv
			check_vector_attr	$jt drmaa_v_env			$job_env
			check_vector_attr	$jt drmaa_v_email		$email_addr
			check_attribute		$jt drmaa_remote_command	"job2"
			check_attribute		$jt drmaa_js_state		$::JS_ACTIVE
			check_attribute		$jt drmaa_wd			"/tmp2"
			check_attribute		$jt drmaa_job_category		"category2"
			check_attribute		$jt drmaa_native_specification	"native2"
			check_attribute		$jt drmaa_block_email		"0"
			check_attribute		$jt drmaa_start_time		"11:22"
			check_attribute		$jt drmaa_job_name		"jobname2"
			check_attribute		$jt drmaa_input_path		":/dev/null2"
			check_attribute		$jt drmaa_output_path		":/dev/null2"
			check_attribute		$jt drmaa_error_path		":/dev/null2"
			check_attribute		$jt drmaa_join_files		"n"
			puts "\tAll attributes verified OK"
			drmaa::drmaa_delete_job_template $jt
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_SUBMIT_SUSPEND_RESUME_WAIT {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 30 0]
			set jobid [drmaa::drmaa_run_job $jt]
			puts "\tsubmitted job $jobid"
			drmaa::drmaa_delete_job_template $jt
			while 1 {
				set job_state [drmaa::drmaa_job_ps $jobid]
				if {$job_state == "RUNNING"} {
					break
				} else {
					puts "\tWaiting forever to get job state DRMAA_PS_RUNNING ..."
					sleep 5
				}
			}
			puts "\tjob $jobid is now running"
			drmaa::drmaa_control $jobid SUSPEND
			puts "\tsuspended job $jobid"
			check_job_state $jobid USER_SUSPENDED
			puts "\tverified suspend was done for job $jobid"
			drmaa::drmaa_control $jobid RESUME
			puts "\tresumed job $jobid"
			if [catch {check_job_state $jobid RUNNING}] {
				check_job_state $jobid FAILED
			}
			puts "\tverified resume was done for job $jobid"
			set wout [drmaa::drmaa_wait $jobid $::max_wait]
			set stat [lindex $wout 1]
			set exited [drmaa::drmaa_wifexited $stat]
			if $exited {set exit_status [drmaa::drmaa_wexitstatus $stat]}
			if {! $exited || $exit_status != 0} {
				return -code error [wrong_job_finish "expected regular job end" $jobid $stat]
			}
			puts "\tjob $jobid finished as expected"
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_USAGE_CHECK {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_exit_job_template]
			puts "\tRunning job"
			set jobid [drmaa::drmaa_run_job $jt]
			drmaa::drmaa_delete_job_template $jt
			puts "\tWaiting for job $jobid to complete"
			set wout [drmaa::drmaa_wait $jobid $::max_wait]
			puts "\tJob with job id $jobid finished"
			set rusage [lrange $wout 2 end]
			if {[llength $rusage] == 0} {
				return -code error "no rusage from drmaa_wait($jobid) and no DRMAA_ERRNO_NO_RUSAGE"
			}
			foreach ru $rusage {
				puts "\t$ru"
			}
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_UNSUPPORTED_ATTR {} {
	if [catch {	drmaa::drmaa_init
			set jt [drmaa::drmaa_allocate_job_template]
			if [catch {drmaa::drmaa_set_attribute $jt "blah" "blah1"} result] {
				if {[lindex $result 1] != "INVALID_ARGUMENT"} {
					return -code error $result
				}
			} else {
				return -code error  "drmaa_set_attribute allowed invalid attribute"
			}
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_UNSUPPORTED_VATTR {} {
	if [catch {	drmaa::drmaa_init
			set jt [drmaa::drmaa_allocate_job_template]
			if [catch {drmaa::drmaa_set_vector_attribute $jt "blah" "blah1" "blah2"} result] {
				if {[lindex $result 1] != "INVALID_ARGUMENT"} {
					return -code error $result
				}
			} else {
				return -code error  "drmaa_set_vector_attribute allowed invalid attribute"
			}
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc MT_SUBMIT_WAIT {} {
	package require Thread	;# only needed for the MT_* procs
	if [catch {	drmaa::drmaa_init
			set all_tids {}
			set thread_script "source $::myname; submit_sleeper_thread $::JOB_CHUNK 0"
			for {set i 0} {$i<$::NTHREADS} {incr i} {
				lappend all_tids [thread::create -joinable "$thread_script"]
			}
			puts "\twaiting for threads to complete"
			foreach tid $all_tids {thread::join $tid}
			wait_all_mt_jobs
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc MT_SUBMIT_BEFORE_INIT_WAIT {} {
	package require Thread	;# only needed for the MT_* procs
	if [catch {	#delayed#drmaa::drmaa_init
			set all_tids {}
			set thread_script "source $::myname; submit_sleeper_thread $::JOB_CHUNK 0"
			for {set i 0} {$i<$::NTHREADS} {incr i} {
				lappend all_tids [thread::create -joinable "$thread_script"]
			}
			sleep 5
			drmaa::drmaa_init
			foreach tid $all_tids {thread::join $tid}
			wait_all_mt_jobs
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc MT_EXIT_DURING_SUBMIT {} {
	package require Thread	;# only needed for the MT_* procs
	if [catch {	drmaa::drmaa_init
			set all_tids {}
			set thread_script "source $::myname; submit_sleeper_thread $::JOB_CHUNK 1"
			for {set i 0} {$i<$::NTHREADS} {incr i} {
				lappend all_tids [thread::create -joinable "$thread_script"]
			}
			sleep 1
			drmaa::drmaa_exit
			puts "\tdrmaa_exit() succeeded" } result] {
		return -code error $result
	}
	puts "\twaiting for threads to complete"
	catch {foreach tid $all_tids {thread::join $tid}}
	return
}

proc MT_SUBMIT_MT_WAIT {} {
	package require Thread	;# only needed for the MT_* procs
	if [catch {	drmaa::drmaa_init
			set all_tids {}
			set thread_script "source $::myname; submit_and_wait_thread $::JOB_CHUNK"
			for {set i 0} {$i<$::NTHREADS} {incr i} {
				lappend all_tids [thread::create -joinable "$thread_script"]
			}
			foreach tid $all_tids {thread::join $tid}
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc MT_EXIT_DURING_SUBMIT_OR_WAIT {} {
	package require Thread	;# only needed for the MT_* procs
	if [catch {	drmaa::drmaa_init
			set thread_script "source $::myname; catch {submit_and_wait_thread $::JOB_CHUNK}"
			for {set i 0} {$i<$::NTHREADS} {incr i} {
				lappend all_tids [thread::create -joinable "$thread_script"]
			}
			sleep 2
			puts "\tNow calling drmaa_exit, while submitter threads are waiting ..."
			drmaa::drmaa_exit
			puts "\tdrmaa_exit succeeded"
			puts "\twaiting for threads to complete"
			foreach tid $all_tids {thread::join $tid}} result] {
		return -code error $result
	}
	return
}

proc ST_GET_NUM_JOBIDS {} {
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			for {set i 0} {$i<$::NBULKS} {incr i} {
				set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $::JOB_CHUNK 1]
				puts "\tsubmitted $::JOB_CHUNK bulk job with jobids: $jobids"
				set njobs [llength $jobids]
				if {$njobs != $::JOB_CHUNK} {
					return -code error "run_bulk_jobs returned $njobs jobids, expected $::JOB_CHUNK"
				}
			}
			drmaa::drmaa_delete_job_template $jt
			wait_n_jobs [expr $::NBULKS * $::JOB_CHUNK]
			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}

proc ST_BULK_SUBMIT_INCRPH {} {
	set outfile {:$drmaa_hd_ph$/tmp_out$drmaa_incr_ph$}
	set homedir $::env(HOME)
	#set homedir "/home/fy"
	if [catch {	drmaa::drmaa_init
			set jt [create_sleeper_job_template 5 0]
			drmaa::drmaa_set_attribute $jt drmaa_output_path $outfile
			set jobids [drmaa::drmaa_run_bulk_jobs $jt 10 [expr $::JOB_CHUNK+10-1] 1]
			puts "\tsubmitted $::JOB_CHUNK bulk job with jobids: $jobids"
			drmaa::drmaa_delete_job_template $jt
			wait_n_jobs $::JOB_CHUNK
			for {set i 10} {$i<$::JOB_CHUNK+10} {incr i} {
				set fname "${homedir}/tmp_out${i}"
				if [file exists $fname] {
					puts "\tFound expected output file $fname"
					if [catch {file delete $fname} result] {
						puts "could not remove temp file $fname:\n\t$result"
					}
				} else {
					return -code error "could not find expected output file: $fname"
				}
			}

			drmaa::drmaa_exit} result] {
		return -code error $result
	}
	return
}


