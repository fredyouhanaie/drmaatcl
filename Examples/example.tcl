
proc create_job_template {job_path seconds as_bulk_job} {

	set jt [drmaa::drmaa_allocate_job_template]
	drmaa::drmaa_set_attribute $jt drmaa_wd $drmaa::DRMAA_PLACEHOLDER_HD

	drmaa::drmaa_set_attribute $jt drmaa_remote_command $job_path
	drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv $seconds
	drmaa::drmaa_set_attribute $jt drmaa_join_files y
	if {$as_bulk_job} {
		set outpath ":$drmaa::DRMAA_PLACEHOLDER_HD/DRMAA_JOB.$drmaa::DRMAA_PLACEHOLDER_INCR"
	} {
		set outpath ":$drmaa::DRMAA_PLACEHOLDER_HD/DRMAA_JOB"
	}
	drmaa::drmaa_set_attribute $jt drmaa_output_path $outpath
	return $jt
}

#
# MAIN PROGRAM STARTS HERE
#
if {$argc != 1} {
	##puts stderr "Usage: example <path-to-job>"
	puts stderr "Usage: [info script] <path-to-job>"
	return 1;
}
set job_path [lindex $argv 0]
puts "drmaa::DRMAA_PLACEHOLDER_HD=$drmaa::DRMAA_PLACEHOLDER_HD"

set NBULKS 3
set JOB_CHUNK 8

list all_jobids {}

drmaa::drmaa_init {}

#
# submit bulk jobs
#
set jt [create_job_template $job_path 5 1]

for {set i 0} {$i < $NBULKS} {incr i} {
	set jobids [drmaa::drmaa_run_bulk_jobs $jt 1 $JOB_CHUNK 1]

	puts "submitted bulk job with jobids:"
	foreach jid $jobids {
		puts "\t \"$jid\""
		lappend all_jobids $jid
	}
}
drmaa::drmaa_delete_job_template $jt

#
# submit some sequential jobs
#
set jt [create_job_template $job_path 5 0]
puts "submitted single jobs with jobids:"
for {set i 0} {$i < $JOB_CHUNK} {incr i} {
	set jobid [drmaa::drmaa_run_job $jt]
	puts "\t \"$jobid\""
	lappend all_jobids $jobid
}
drmaa::drmaa_delete_job_template $jt

#
# synchronize with all jobs
#
set syncjobids $all_jobids
set syncjobids $drmaa::DRMAA_JOB_IDS_SESSION_ALL
set jids    [drmaa::drmaa_synchronize $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER 0 $syncjobids]
puts stderr "synchronized with all jobs"

#
# wait all those jobs
#
foreach jid $all_jobids {
	set job_out [drmaa::drmaa_wait $jid $drmaa::DRMAA_TIMEOUT_WAIT_FOREVER]
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

	set signaled [drmaa::drmaa_wifsignaled $stat]
	if $signaled {
		set termsig [drmaa::drmaa_wtermsig $stat]
		puts stderr "job \"$jid\" finished due to signal $termsig"
		continue
	}

	puts stderr "job \"$jid\" finished with unclear conditions"
}

drmaa::drmaa_exit

