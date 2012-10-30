
namespace eval drmaa {
	namespace ensemble create -map {
		init	drmaa_init
		exit	drmaa_exit

		ajt	drmaa_allocate_job_template
		djt	drmaa_delete_job_template
		ga	drmaa_get_attribute
		gan	drmaa_get_attribute_names
		gva	drmaa_get_vector_attribute
		gvan	drmaa_get_vector_attribute_names
		sa	drmaa_set_attribute
		sva	drmaa_set_vector_attribute

		rj	drmaa_run_job
		rbj	drmaa_run_bulk_jobs
		ps	drmaa_job_ps
		ctrl	drmaa_control
		sync	drmaa_synchronize
		wait	drmaa_wait

		wcd	drmaa_wcoredump
		wes	drmaa_wexitstatus
		wia	drmaa_wifaborted
		wie	drmaa_wifexited
		wis	drmaa_wifsignaled
		wts	drmaa_wtermsig

		gc	drmaa_get_contact
		vers	drmaa_version
		gdi	drmaa_get_DRMAA_implementation
		gds	drmaa_get_DRM_system
	}
}
