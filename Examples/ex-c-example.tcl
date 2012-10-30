
proc error_report {result errinfo} {
	puts stderr $result
	puts stderr "=== Error Trace ==="
	puts stderr $errinfo.
}

proc create_job_template {job_path seconds as_bulk_job} {
	if {[catch {	set jt [drmaa::drmaa_allocate_job_template]
			drmaa::drmaa_set_attribute $jt drmaa_wd $drmaa::DRMAA_PLACEHOLDER_HD

			drmaa::drmaa_set_attribute $jt drmaa_remote_command $job_path
			drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $seconds
			drmaa::drmaa_set_attribute $jt drmaa_join_files y

			set outpath ":$drmaa::DRMAA_PLACEHOLDER_HD/DRMAA_JOB"
			if {$as_bulk_job} {
				set outpath "$outpath.$drmaa::DRMAA_PLACEHOLDER_INCR"
			}
			drmaa::drmaa_set_attribute $jt drmaa_output_path $outpath
			} result]} then {
		error_report "$result" "$::errorInfo"
		return -code error
	} else {
		return $jt
	}

}

#	MAIN PROGRAM STARTS HERE
#
if {$argc != 1} {
	puts stderr "Usage: [info script] <path-to-job>"
	return 1;
}
set job_path [lindex $argv 0]

set NBULKS 3
set JOB_CHUNK 8

list all_jobids {}

if {[catch {drmaa::drmaa_init {}} result]} {
	error_report "$result" "$::errorInfo"
	exit 1
}

#	submit bulk jobs
#
if {[catch {create_job_template $job_path 5 1} result]} {
	puts stderr "create_job_template failed "
	exit 1
} else {
	set jt $result
}

for {set i 0} {$i < $NBULKS} {incr i} {
	if {[catch {drmaa::drmaa_run_bulk_jobs $jt 1 $JOB_CHUNK 1} result]} {
		error_report "$result" "$::errorInfo"
		drmaa::drmaa_exit
		exit 1
	} else {
		set jobids $result
	}

	puts "submitted bulk job with jobids:"
	foreach jid $jobids {
		puts "\t \"$jid\""
		lappend all_jobids $jid
	}
}
drmaa::drmaa_delete_job_template $jt

#	submit some sequential jobs
#
if {[catch {create_job_template $job_path 5 0} result]} {
	puts stderr "create_job_template failed "
	exit 1
} else {
	set jt $result
}
puts "submitted single jobs with jobids:"
for {set i 0} {$i < $JOB_CHUNK} {incr i} {
	set jobid [drmaa::drmaa_run_job $jt]
	puts "\t \"$jobid\""
	lappend all_jobids $jobid
}
drmaa::drmaa_delete_job_template $jt

#	synchronize with all jobs
#
set synclist $all_jobids
if {[catch {drmaa::drmaa_synchronize $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER 0 $synclist} result]} {
	error_report "$result" "$::errorInfo"
	drmaa::drmaa_exit
	exit 1
}
puts stderr "synchronized with all jobs"

#	wait all those jobs
#
foreach jid $all_jobids {

	if {[catch {drmaa::drmaa_wait $jid $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER} result]} {
		puts stderr "drmaa_wait($jid) failed:"
		error_report "$result" "$::errorInfo"
		continue
	} else {
		set job_out $result
	}
	set stat [lindex $job_out 1]
	set rusage [lrange $job_out 2 end]

	if [drmaa::drmaa_wifaborted $stat] {
		puts stderr "job \"$jid\" never ran"
		continue
	}
	if [drmaa::drmaa_wifexited $stat] {
		set exit_status [drmaa::drmaa_wexitstatus $stat]
		puts stderr "job \"$jid\" finished regularly with exit status $exit_status"
		continue
	}
	if [drmaa::drmaa_wifsignaled $stat] {
		set termsig [drmaa::drmaa_wtermsig $stat]
		puts stderr "job \"$jid\" finished due to signal $termsig"
		continue
	}
	puts stderr "job \"$jid\" finished with unclear conditions"
}

drmaa::drmaa_exit

