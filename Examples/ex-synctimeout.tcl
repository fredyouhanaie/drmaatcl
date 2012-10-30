
drmaa::drmaa_init
set jt [drmaa::drmaa_allocate_job_template]
drmaa::drmaa_set_attribute $jt drmaa_remote_command /bin/sleep
drmaa::drmaa_set_vector_attribute $jt drmaa_v_argv 100
set jobid [drmaa::drmaa_run_job $jt]
puts "job id is $jobid"
catch {drmaa::drmaa_synchronize 3 1 DRMAA_JOB_IDS_SESSION_ALL} sout
drmaa::drmaa_exit
puts "===$sout==="
