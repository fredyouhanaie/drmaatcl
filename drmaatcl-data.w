
%% drmaatcl-data.w
%%	drmaatcl data definitions. This file collects all the data
%%	structures and constants for the drmaatcl extension.

%% Copyright (c) 2009-2012, Fred Youhanaie
%% All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions
%% are met:
%%
%%	* Redistributions of source code must retain the above copyright
%%	  notice, this list of conditions and the following disclaimer.
%%
%%	* Redistributions in binary form must reproduce the above copyright
%%	  notice, this list of conditions and the following disclaimer
%%	  in the documentation and/or other materials provided with the
%%	  distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
%% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

@*Library Source - Data Definitions. From here on is the source code
of the library. Both the data definitions and the function definitions
will end up in a single C file, rather than there being the traditional
separate header file.

@ We use a minimal set of include files.

The constant |DRMAA_VALUE_BUFFER| defines the upper limit for attribute
and individual vector attribute values that we are prepared to accept from
|drmaa_get_attribute| and |drmaa_get_next_attr_value|. Of course one would
like to see the constant defined in the \.{drmaa.h} header file.

@c

#include <tcl.h>
#include <string.h>
#include <drmaa.h>
@#
#define DRMAA_VALUE_BUFFER 1024
@#
@<drmaa commands@>;
@<error codes@>;
@<drmaa constants@>;

@*1Command declarations. For the details of the \.{Tcl\_ObjCmdProc}
see the \.{Tcl\_CreateObjCommand} man page. We declare the prototypes
that will be stored in |DrmaaCommand| array.

@<drmaa commands@>=
Tcl_ObjCmdProc Drmaa_init, Drmaa_exit;
@#
Tcl_ObjCmdProc Drmaa_allocate_job_template, Drmaa_delete_job_template;
Tcl_ObjCmdProc Drmaa_set_attribute, Drmaa_get_attribute;
Tcl_ObjCmdProc Drmaa_set_vector_attribute, Drmaa_get_vector_attribute;
Tcl_ObjCmdProc Drmaa_get_attribute_names, Drmaa_get_vector_attribute_names;
@#
Tcl_ObjCmdProc Drmaa_run_job, Drmaa_run_bulk_jobs;
@#
Tcl_ObjCmdProc Drmaa_control, Drmaa_job_ps, Drmaa_synchronize, Drmaa_wait;
Tcl_ObjCmdProc Drmaa_wcoredump, Drmaa_wexitstatus, Drmaa_wifaborted;
Tcl_ObjCmdProc Drmaa_wifexited, Drmaa_wifsignaled, Drmaa_wtermsig;
@#
Tcl_ObjCmdProc Drmaa_get_DRMAA_implementation, Drmaa_get_DRM_system;
Tcl_ObjCmdProc Drmaa_get_contact, Drmaa_version;

@ The \.{DrmaaCommand\_t} structure is used for maintaining the Tcl
command to drmaa function mapping. The structure will only be used once
during the library initialization.

@<drmaa commands@>=
typedef struct DrmaaCommand_s {
	char		*name;
	Tcl_ObjCmdProc	*proc;
} DrmaaCommand_t;

@ The initial set of commands we are expected to recognize are defined
in the \.{DrmaaCommand[]} table. Each element of the array is a structure
that contains a pair of constants (in the form of a struct), the command
string and its corresponding procedure. The last element of the array
should be a struct with a pair of \.{NULL} elements.

The array is primarily used in the \.{Drmaa\_AppInit} routine for
the creating of commands.

@<drmaa commands@>=
static DrmaaCommand_t DrmaaCommand[] = {@/
	{"drmaa::drmaa_allocate_job_template", Drmaa_allocate_job_template},@/
	{"drmaa::drmaa_control", Drmaa_control},@/
	{"drmaa::drmaa_delete_job_template", Drmaa_delete_job_template},@/
	{"drmaa::drmaa_exit", Drmaa_exit},@/
	{"drmaa::drmaa_get_DRMAA_implementation", Drmaa_get_DRMAA_implementation},@/
	{"drmaa::drmaa_get_DRM_system", Drmaa_get_DRM_system},@/
	{"drmaa::drmaa_get_attribute", Drmaa_get_attribute},@/
	{"drmaa::drmaa_get_attribute_names", Drmaa_get_attribute_names},@/
	{"drmaa::drmaa_get_contact", Drmaa_get_contact},@/
	{"drmaa::drmaa_get_vector_attribute", Drmaa_get_vector_attribute},@/
	{"drmaa::drmaa_get_vector_attribute_names", Drmaa_get_vector_attribute_names},@/
	{"drmaa::drmaa_init", Drmaa_init},@/
	{"drmaa::drmaa_job_ps", Drmaa_job_ps},@/
	{"drmaa::drmaa_run_bulk_jobs", Drmaa_run_bulk_jobs},@/
	{"drmaa::drmaa_run_job", Drmaa_run_job},@/
	{"drmaa::drmaa_set_attribute", Drmaa_set_attribute},@/
	{"drmaa::drmaa_set_vector_attribute", Drmaa_set_vector_attribute},@/
	{"drmaa::drmaa_synchronize", Drmaa_synchronize},@/
	{"drmaa::drmaa_version", Drmaa_version},@/
	{"drmaa::drmaa_wait", Drmaa_wait},@/
	{"drmaa::drmaa_wcoredump", Drmaa_wcoredump},@/
	{"drmaa::drmaa_wexitstatus", Drmaa_wexitstatus},@/
	{"drmaa::drmaa_wifaborted", Drmaa_wifaborted},@/
	{"drmaa::drmaa_wifexited", Drmaa_wifexited},@/
	{"drmaa::drmaa_wifsignaled", Drmaa_wifsignaled},@/
	{"drmaa::drmaa_wtermsig", Drmaa_wtermsig},@/
	{NULL, NULL}	/* marks the end of the list */@/
};

@*1DRMAA Constants. The \.{DrmaaVarS\_t} and \.{DrmaaVarI\_t} structures
are used to define the list of the C compile time symbols that are being
made available to the Tcl scripts. The two structures are used for string
and integer types.

@<drmaa constants@>=
typedef struct DrmaaVarS_s {
	char	*name;
	char	*value;
} DrmaaVarS_t;
@#
typedef struct DrmaaVarI_s {
	char	*name;
	int	value;
} DrmaaVarI_t;

@ The arrays \.{DrmaaVarS} and \.{DrmaaVarI} contain the set of DRMAA
constants required by various API calls. The arrays are read once during
the initialisation of the library, where the various Tcl variables
are initialised.

@<drmaa constants@>=
static DrmaaVarS_t DrmaaVarS[] = {@/
	{"drmaa::DRMAA_PLACEHOLDER_HD",		DRMAA_PLACEHOLDER_HD},@/
	{"drmaa::DRMAA_PLACEHOLDER_INCR",	DRMAA_PLACEHOLDER_INCR},@/
	{"drmaa::DRMAA_PLACEHOLDER_WD",		DRMAA_PLACEHOLDER_WD},@/
	{"drmaa::DRMAA_JOB_IDS_SESSION_ANY",	DRMAA_JOB_IDS_SESSION_ANY},@/
	{"drmaa::DRMAA_JOB_IDS_SESSION_ALL",	DRMAA_JOB_IDS_SESSION_ALL},@/
	{"drmaa::DRMAA_SUBMISSION_STATE_ACTIVE",DRMAA_SUBMISSION_STATE_ACTIVE},@/
	{"drmaa::DRMAA_SUBMISSION_STATE_HOLD",	DRMAA_SUBMISSION_STATE_HOLD},@/
	{NULL, NULL}@/
};
@#
static DrmaaVarI_t DrmaaVarI[] = {@/
	{"drmaa::DRMAA_TIMEOUT_WAIT_FOREVER",	DRMAA_TIMEOUT_WAIT_FOREVER},@/
	{"drmaa::DRMAA_TIMEOUT_NO_WAIT",	DRMAA_TIMEOUT_NO_WAIT},@/
	{"drmaa::DRMAA_PS_UNDETERMINED",	DRMAA_PS_UNDETERMINED},@/
	{"drmaa::DRMAA_PS_QUEUED_ACTIVE",	DRMAA_PS_QUEUED_ACTIVE},@/
	{"drmaa::DRMAA_PS_SYSTEM_ON_HOLD",	DRMAA_PS_SYSTEM_ON_HOLD},@/
	{"drmaa::DRMAA_PS_USER_SYSTEM_ON_HOLD",	DRMAA_PS_USER_SYSTEM_ON_HOLD},@/
	{"drmaa::DRMAA_PS_RUNNING",		DRMAA_PS_RUNNING},@/
	{"drmaa::DRMAA_PS_SYSTEM_SUSPENDED",	DRMAA_PS_SYSTEM_SUSPENDED},@/
	{"drmaa::DRMAA_PS_USER_SUSPENDED",	DRMAA_PS_USER_SUSPENDED},@/
	{"drmaa::DRMAA_PS_DONE",		DRMAA_PS_DONE},@/
	{"drmaa::DRMAA_PS_FAILED",		DRMAA_PS_FAILED},@/
	{"drmaa::DRMAA_CONTROL_SUSPEND",	DRMAA_CONTROL_SUSPEND},@/
	{"drmaa::DRMAA_CONTROL_RESUME",		DRMAA_CONTROL_RESUME},@/
	{"drmaa::DRMAA_CONTROL_HOLD",		DRMAA_CONTROL_HOLD},@/
	{"drmaa::DRMAA_CONTROL_RELEASE",	DRMAA_CONTROL_RELEASE},@/
	{"drmaa::DRMAA_CONTROL_TERMINATE",	DRMAA_CONTROL_TERMINATE},@/
	{NULL, 0}@/
};

@ |DrmaaControl| is the lookup table for \.{DRMAA\_CONTROL\_*} constants,
it is used in the \.{Drmaa\_control} routine. The array should terminate
with a \.{NULL} {\sl name}.

@<drmaa constants@>=

typedef struct DrmaaControl_s {
	char	*name;
	int	value;
} DrmaaControl_t;
@#
DrmaaControl_t DrmaaControl[] = {@/
	{"SUSPEND",	DRMAA_CONTROL_SUSPEND},@/
	{"RESUME",	DRMAA_CONTROL_RESUME},@/
	{"HOLD",	DRMAA_CONTROL_HOLD},@/
	{"RELEASE",	DRMAA_CONTROL_RELEASE},@/
	{"TERMINATE",	DRMAA_CONTROL_TERMINATE},@/
	{NULL,		0}@/
};

@ |DrmaaJobPS| is the lookup table for \.{DRMAA\_PS\_*} constants. It is
used in the \.{Drmaa\_job\_ps} routine to return symbolic results. The array
should terminate with a \.{NULL} entry pair.

@<drmaa constants@>=

typedef struct DrmaaJobPS_s {
	char	*name;
	int	ps;
} DrmaaJobPS_t;
@#
DrmaaJobPS_t DrmaaJobPS[] = {@/
	{"UNDETERMINED",	DRMAA_PS_UNDETERMINED},@/
	{"QUEUED_ACTIVE",	DRMAA_PS_QUEUED_ACTIVE},@/
	{"SYSTEM_ON_HOLD",	DRMAA_PS_SYSTEM_ON_HOLD},@/
	{"USER_SYSTEM_ON_HOLD",	DRMAA_PS_USER_SYSTEM_ON_HOLD},@/
	{"RUNNING",		DRMAA_PS_RUNNING},@/
	{"SYSTEM_SUSPENDED",	DRMAA_PS_SYSTEM_SUSPENDED},@/
	{"USER_SUSPENDED",	DRMAA_PS_USER_SUSPENDED},@/
	{"DONE",		DRMAA_PS_DONE},@/
	{"FAILED",		DRMAA_PS_FAILED}@/
};


@*1The Error Codes. The |DrmaaErrorCode| array defines the symbolic
error codes corresinding to the numeric error codes.  These are the codes
that will be returned to the application via the |errorCode| variable,
in case of an error (see \.{tclvars} man page.)

The order of the error codes below is important, they are in the same
order as the \.{DRMAA\_ERRNO\_*} error codes.

@<error codes@>=
static char* DrmaaErrorCode[] = {@/
	"SUCCESS",@/
	"INTERNAL_ERROR",@/
	"DRM_COMMUNICATION_FAILURE",@/
	"AUTH_FAILURE",@/
	"INVALID_ARGUMENT",@/
	"NO_ACTIVE_SESSION",@/
	"NO_MEMORY",@/
	"INVALID_CONTACT_STRING",@/
	"DEFAULT_CONTACT_STRING_ERROR",@/
	"NO_DEFAULT_CONTACT_STRING_SELECTED",@/
	"DRMS_INIT_FAILED",@/
	"ALREADY_ACTIVE_SESSION",@/
	"DRMS_EXIT_ERROR",@/
	"INVALID_ATTRIBUTE_FORMAT",@/
	"INVALID_ATTRIBUTE_VALUE",@/
	"CONFLICTING_ATTRIBUTE_VALUES",@/
	"TRY_LATER",@/
	"DENIED_BY_DRM",@/
	"INVALID_JOB",@/
	"RESUME_INCONSISTENT_STATE",@/
	"SUSPEND_INCONSISTENT_STATE",@/
	"HOLD_INCONSISTENT_STATE",@/
	"RELEASE_INCONSISTENT_STATE",@/
	"EXIT_TIMEOUT",@/
	"NO_RUSAGE",@/
	"NO_MORE_ELEMENTS",@/
	"NO_ERRNO"@/
};

@ The above constants have been provided as a minimum set for the Tcl
programmer, since they require access at C level. Although one can think
of other symbolic constants worthy of inclusion here, these can easily
be added later in a pure Tcl library script.

