
# drmaatcl test suit.
# based on DRMAA_TEST_SUITE_VERSION "1.7.2"

#
# error report for investigation by user
# TODO maybe we should ask for catch/options instead of errorinfo!
proc error_report {result errinfo} {
	puts stderr $result
	puts stderr "=== Error Trace ==="
	puts stderr $errinfo.
}

set JOB_CHUNK	2
set NTHREADS	3
set NBULKS	3

set sleeper_job "/bin/sleep"	;# should really come from command line

# DRMAA_TIMEOUT_WAIT_FOREVER is anyway useless in a test suite
# we assume some local setting, fast enough for the single job runs
set max_wait_timeout 3600

proc ST_MULT_INIT {} {}
##	ST_MULT_INIT,
##	- drmaa_init() is called multiple times
##	- first time it must succeed - second time it must fail
##	- then drmaa_exit() is called

proc ST_MULT_EXIT {} {}
##	ST_MULT_EXIT,
##	- drmaa_init() is called
##	- then drmaa_exit() is called multiple times
##	- first time it must succeed - second time it must fail

proc ST_SUPPORTED_ATTR {} {}
##	ST_SUPPORTED_ATTR,
##	- drmaa_init() is called
##	- drmaa_get_attribute_names() is called
##	- the names of all supported non vector attributes are printed
##	- then drmaa_exit() is called

proc ST_SUPPORTED_VATTR {} {}
##	ST_SUPPORTED_VATTR,
##	- drmaa_init() is called
##	- drmaa_get_vector_attribute_names() is called
##	- the names of all supported vector attributes are printed
##	- then drmaa_exit() is called

proc ST_VERSION {} {}
##	ST_VERSION,
##	- drmaa_version() is called
##	- version information is printed

proc ST_DRM_SYSTEM {} {}
##	ST_DRM_SYSTEM,
##	- drmaa_get_DRM_system() is called
##	- the contact string is printed
##	- drmaa_init() is called
##	- drmaa_get_DRM_system() is called
##	- the DRM system name is printed
##	- then drmaa_exit() is called

proc ST_DRMAA_IMPL {} {}
##	ST_DRMAA_IMPL,
##	- drmaa_get_DRM_system() is called
##	- the contact string is printed
##	- drmaa_init() is called
##	- drmaa_get_DRMAA_implementation() is called
##	- the DRMAA implemention name is printed
##	- then drmaa_exit() is called

proc ST_CONTACT {} {}
##	ST_CONTACT,
##	- drmaa_get_contact() is called
##	- the contact string is printed
##	- drmaa_init() is called
##	- drmaa_get_contact() is called
##	- the contact string is printed
##	- then drmaa_exit() is called

proc ST_EMPTY_SESSION_WAIT {} {}
##	ST_EMPTY_SESSION_WAIT,
##	- drmaa_init() is called
##	- drmaa_wait() must return DRMAA_ERRNO_INVALID_JOB
##	- then drmaa_exit() is called

proc ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE {} {}
##	ST_EMPTY_SESSION_SYNCHRONIZE_DISPOSE,
##	- drmaa_init() is called
##	- drmaa_synchronize(DRMAA_JOB_IDS_SESSION_ALL, dispose=true) must return DRMAA_ERRNO_SUCCESS
##	- then drmaa_exit() is called

proc ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE {} {}
##	ST_EMPTY_SESSION_SYNCHRONIZE_NODISPOSE,
##	- drmaa_init() is called
##	- drmaa_synchronize(DRMAA_JOB_IDS_SESSION_ALL, dispose=false) must return DRMAA_ERRNO_SUCCESS
##	- then drmaa_exit() is called

proc ST_EMPTY_SESSION_CONTROL {x} {}
##	ST_EMPTY_SESSION_CONTROL,
##	- drmaa_init() is called
##	- drmaa_control(DRMAA_JOB_IDS_SESSION_ALL, <passed control operation>) must return DRMAA_ERRNO_SUCCESS
##	- then drmaa_exit() is called

proc ST_SUBMIT_WAIT {x} {}
##	ST_SUBMIT_WAIT,
##	- one thread
##	- submit jobs
##	- wait for jobend

proc ST_BULK_SUBMIT_WAIT {x} {}
##	ST_BULK_SUBMIT_WAIT,
##	- drmaa_init() is called
##	- a bulk job is submitted and waited
##	- then drmaa_exit() is called

proc ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL {x} {}
##	ST_BULK_SINGLESUBMIT_WAIT_INDIVIDUAL,
##	- drmaa_init() is called
##	- bulk and sequential jobs are submitted
##	- all jobs are waited individually
##	- then drmaa_exit() is called

proc ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE {x} {}
##	ST_SUBMITMIXTURE_SYNC_ALL_DISPOSE,
##	- drmaa_init() is called
##	- submit a mixture of single and bulk jobs
##	- do drmaa_synchronize(DRMAA_JOB_IDS_SESSION_ALL, dispose)
##	to wait for all jobs to finish
##	- then drmaa_exit() is called

proc ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE {x} {}
##	ST_SUBMITMIXTURE_SYNC_ALL_NODISPOSE,
##	- drmaa_init() is called
##	- submit a mixture of single and bulk jobs
##	- do drmaa_synchronize(DRMAA_JOB_IDS_SESSION_ALL, no-dispose)
##	to wait for all jobs to finish
##	- do drmaa_wait(DRMAA_JOB_IDS_SESSION_ANY) until
##	DRMAA_ERRNO_INVALID_JOB to reap all jobs
##	- then drmaa_exit() is called

proc ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE {x} {}
##	ST_SUBMITMIXTURE_SYNC_ALLIDS_DISPOSE,
##	- drmaa_init() is called
##	- submit a mixture of single and bulk jobs
##	- do drmaa_synchronize(all_jobids, dispose)
##	to wait for all jobs to finish
##	- then drmaa_exit() is called

proc ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE {x} {}
##	ST_SUBMITMIXTURE_SYNC_ALLIDS_NODISPOSE,
##	- drmaa_init() is called
##	- submit a mixture of single and bulk jobs
##	- do drmaa_synchronize(all_jobids, no-dispose)
##	to wait for all jobs to finish
##	- do drmaa_wait(DRMAA_JOB_IDS_SESSION_ANY) until
##	DRMAA_ERRNO_INVALID_JOB to reap all jobs
##	- then drmaa_exit() is called

proc ST_EXIT_STATUS {x} {}
##	ST_EXIT_STATUS,
##	- drmaa_init() is called
##	- 255 job are submitted
##	- job i returns i as exit status (8 bit)
##	- drmaa_wait() verifies each job returned the
##	correct exit status
##	- then drmaa_exit() is called

proc ST_SUBMIT_KILL_SIG {x} {}
##	ST_SUBMIT_KILL_SIG,
##	- drmaa_init() is called
##	- one job is submitted
##	- job is killed via SIGKILL and SIGINT
##	- drmaa_wtermsig() is used to validate if the correct termination signals where reported
##	- drmaa_exit_is_called

proc ST_INPUT_FILE_FAILURE {x} {}
##	ST_INPUT_FILE_FAILURE,
##	- drmaa_init() is called
##	- a job is submitted with input/output/error path specification
##	that must cause the job to fail
##	- use drmaa_synchronize() to ensure job was started
##	- drmaa_job_ps() must return DRMAA_PS_FAILED
##	- drmaa_wait() must report drmaa_wifaborted() -> true
##	- then drmaa_exit() is called

proc ST_OUTPUT_FILE_FAILURE {x} {}
##	ST_OUTPUT_FILE_FAILURE,
##	- drmaa_init() is called
##	- a job is submitted with input/output/error path specification
##	that must cause the job to fail
##	- use drmaa_synchronize() to ensure job was started
##	- drmaa_job_ps() must return DRMAA_PS_FAILED
##	- drmaa_wait() must report drmaa_wifaborted() -> true
##	- then drmaa_exit() is called

proc ST_ERROR_FILE_FAILURE {x} {}
##	ST_ERROR_FILE_FAILURE,
##	- drmaa_init() is called
##	- a job is submitted with input/output/error path specification
##	that must cause the job to fail
##	- use drmaa_synchronize() to ensure job was started
##	- drmaa_job_ps() must return DRMAA_PS_FAILED
##	- drmaa_wait() must report drmaa_wifaborted() -> true
##	- then drmaa_exit() is called

proc ST_SUBMIT_IN_HOLD_RELEASE {x} {}
##	ST_SUBMIT_IN_HOLD_RELEASE,
##	- drmaa_init() is called
##	- a job is submitted with a user hold
##	- use drmaa_job_ps() to verify user hold state
##	- hold state is released using drmaa_control()
##	- the job is waited
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_SUBMIT_IN_HOLD_DELETE {x} {}
##	ST_SUBMIT_IN_HOLD_DELETE,
##	- drmaa_init() is called
##	- a job is submitted with a user hold
##	- use drmaa_job_ps() to verify user hold state
##	- job is terminated using drmaa_control()
##	- the job is waited and it is checked if wifaborted is true
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE {x} {}
##	ST_BULK_SUBMIT_IN_HOLD_SESSION_RELEASE,
##	- drmaa_init() is called
##	- a bulk job is submitted with a user hold
##	- hold state is released for the session using drmaa_control()
##	- the job ids are waited
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE {x} {}
##	ST_BULK_SUBMIT_IN_HOLD_SINGLE_RELEASE,
##	- drmaa_init() is called
##	- a bulk job is submitted with a user hold
##	- hold state is released separately for each task using drmaa_control()
##	- the job ids are waited
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE {x} {}
##	ST_BULK_SUBMIT_IN_HOLD_SESSION_DELETE,
##	- drmaa_init() is called
##	- a bulk job is submitted with a user hold
##	- use drmaa_job_ps() to verify user hold state
##	- all session jobs are terminated using drmaa_control()
##	- the job ids are waited
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE {x} {}
##	ST_BULK_SUBMIT_IN_HOLD_SINGLE_DELETE,
##	- drmaa_init() is called
##	- a bulk job is submitted with a user hold
##	- use drmaa_job_ps() to verify user hold state
##	- all session jobs are terminated using drmaa_control()
##	- the job ids are waited
##	- then drmaa_exit() is called
##	(still requires manual testing)
##

proc ST_SUBMIT_POLLING_WAIT_TIMEOUT {x} {}
##	ST_SUBMIT_POLLING_WAIT_TIMEOUT,
##	- drmaa_init() is called
##	- a single job is submitted
##	- repeatedly drmaa_wait() with a timeout is used until job is finished
##	- then drmaa_exit() is called

proc ST_SUBMIT_POLLING_WAIT_ZEROTIMEOUT {x} {}
##	ST_SUBMIT_POLLING_WAIT_ZEROTIMEOUT,
##	- drmaa_init() is called
##	- a single job is submitted
##	- repeatedly do drmaa_wait(DRMAA_TIMEOUT_NO_WAIT) + sleep() until job is finished
##	- then drmaa_exit() is called

proc ST_SUBMIT_POLLING_SYNCHRONIZE_TIMEOUT {x} {}
##	ST_SUBMIT_POLLING_SYNCHRONIZE_TIMEOUT,
##	- drmaa_init() is called
##	- a single job is submitted
##	- repeatedly drmaa_synchronize() with a timeout is used until job is finished
##	- then drmaa_exit() is called

proc ST_SUBMIT_POLLING_SYNCHRONIZE_ZEROTIMEOUT {x} {}
##	ST_SUBMIT_POLLING_SYNCHRONIZE_ZEROTIMEOUT,
##	- drmaa_init() is called
##	- a single job is submitted
##	- repeatedly do drmaa_synchronize(DRMAA_TIMEOUT_NO_WAIT) + sleep() until job is finished
##	- then drmaa_exit() is called

proc ST_ATTRIBUTE_CHANGE {} {}
##	ST_ATTRIBUTE_CHANGE,
##	- all attributes a written with different values for two times
##	- check if the JT is correct afterwards

proc ST_SUBMIT_SUSPEND_RESUME_WAIT {x} {}
##	ST_SUBMIT_SUSPEND_RESUME_WAIT,
##	- drmaa_init() is called
##	- a single job is submitted
##	- drmaa_job_ps() is used to actively wait until job is running
##	- drmaa_control() is used to suspend the job
##	- drmaa_job_ps() is used to verify job was suspended
##	- drmaa_control() is used to resume the job
##	- drmaa_job_ps() is used to verify job was resumed
##	- drmaa_wait() is used to wait for the jobs regular end
##	- then drmaa_exit() is called

proc ST_USAGE_CHECK {x} {}
##	ST_USAGE_CHECK,
##	- one thread
##	- submit jobs
##	- wait for jobend
##	- print job usage

proc ST_UNSUPPORTED_ATTR {} {}
##	// ST_UNSUPPORTED_ATTR,
##	- drmaa_init() is called
##	- drmaa_set_attribute() is called for an invalid attribute
##	- then drmaa_exit() is called

proc ST_UNSUPPORTED_VATTR {} {}
##	// ST_UNSUPPORTED_VATTR,
##	- drmaa_init() is called
##	- drmaa_set_vector_attribute() is called for an invalid attribute
##	- then drmaa_exit() is called

proc MT_SUBMIT_WAIT {x} {}
##	MT_SUBMIT_WAIT,
##	- multiple submission threads
##	- wait is done by main thread

proc MT_SUBMIT_BEFORE_INIT_WAIT {x} {}
##	MT_SUBMIT_BEFORE_INIT_WAIT,
##	- no drmaa_init() was called
##	- multiple threads try to submit but fail
##	- when drmaa_init() is called by main thread
##	submission proceed
##	- wait is done by main thread

proc MT_EXIT_DURING_SUBMIT {x} {}
##	MT_EXIT_DURING_SUBMIT,
##	- drmaa_init() is called
##	- multiple submission threads submitting (delayed) a series
##	of jobs
##	- during submission main thread does drmaa_exit()

proc MT_SUBMIT_MT_WAIT {x} {}
##	MT_SUBMIT_MT_WAIT,
##	- drmaa_init() is called
##	- multiple submission threads submit jobs and wait these jobs
##	- when all threads are finished main thread calls drmaa_exit()

proc MT_EXIT_DURING_SUBMIT_OR_WAIT {x} {}
##	MT_EXIT_DURING_SUBMIT_OR_WAIT,
##	- drmaa_init() is called
##	- multiple submission threads submit jobs and wait these jobs
##	- while submission threads are waiting their jobs the main
##	thread calls drmaa_exit()

proc ST_GET_NUM_JOBIDS {x} {}
##	ST_GET_NUM_JOBIDS,
##	- drmaa_init() ist called
##	- bulk job is submitted
##	- functionality of drmaa_get_num_jobids is tested
##	- drmaa_exit is called

proc ST_BULK_SUBMIT_INCRPH {x} {}
##	ST_BULK_SUBMIT_INCRPH
##	- drmaa_init() ist called
##	- bulk job is submitted
##	- drmaa_wd_ph and drmaa_incr_ph placeholders are used in output file name
##	- existence of files is checked
##	- drmaa_exit is called

