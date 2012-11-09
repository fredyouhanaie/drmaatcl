
%% drmaatcl-code.w
%%	The drmaatcl code. This file includes all the functions that
%%	implement the drmaatcl extension.

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

@*Library Source - Function Definitions.

The command procedures are grouped in the same way as the DRMAA API.  For
each \.{drmaa\_*} command of \.{drmaatcl}, we provide the corresponding
\.{Drmaa\_*} function. All the \.{Drmaa\_*} calls have the same call
signature, which is the \.{Tcl\_ObjCmdProc} typedef described in the
man page for \.{Tcl\_CreateObjCommand}.

Internally each \.{Drmaa\_*} function has three parts, the preparation
before the drmaa call, where the input arguments are parsed and checked,
the actual drmaa call, and a post call where the return results are
collected and passed back to the interpreter.

@c
@<Error Return@>;
@<Session Management Commands@>;
@<Job Template Commands@>;
@<Job Submission Commands@>;
@<Job Control Commands@>;
@<Auxiliary Comands@>;
@<AppInit@>;

@ \.{Drmaa\_AppInit} is the main package initialisation routine.
It follows the application packaging conventions recommended in the
Tcl/Tk book. The Tcl commands that the library accepts are defined
in the |DrmaaCommand| array.

@<AppInit@>=
int Drmaatcl_Init(Tcl_Interp *ti) {
	DrmaaCommand_t *dc = DrmaaCommand;

	if (Tcl_InitStubs(ti, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}

	while (dc->name != NULL) {
		Tcl_CreateObjCommand(ti, dc->name, dc->proc, NULL, NULL);
		dc++;
	}

	DrmaaVarS_t *dvs = DrmaaVarS;
	while (dvs->name != NULL) {
		if (Tcl_SetVar(ti, dvs->name, dvs->value, TCL_LEAVE_ERR_MSG) == NULL) {
			return TCL_ERROR;
		}
		dvs++;
	}

	DrmaaVarI_t *dvi = DrmaaVarI;
	char dvstr[10];
	while (dvi->name != NULL) {
		sprintf(dvstr, "%d", dvi->value);
		if (Tcl_SetVar(ti, dvi->name, dvstr, TCL_LEAVE_ERR_MSG) == NULL) {
			return TCL_ERROR;
		}
		dvi++;
	}

	Tcl_PkgProvide(ti, "drmaa", "0.1");
	return TCL_OK;
}

@ The |Drmaa_ErrorReturn| function is used for setting up the
\.{errorCode} and \.{errorInfo} variables in a standard format.  This is
called whenever any of the DRMAA API calls return a non success code,
i.e. anything other than \.{DRMAA\_ERRNO\_SUCCESS}.

\.{errorCode} will be set to a 3 element list, consisting of the fixed
element \.{DRMAA} to indicate that it is a DRMAA error, the symbolic
name of the error code without the \.{DRMAA\_ERRNO\_} prefix and the text
string corresponding to the error code, e.g. \.{DRMAA NO\_ACTIVE\_SESSION
\{No active session\}}

\.{errorInfo} will contain the additional diagnostic message that the
API may have provided, such as

{\tt job template must have "drmaa\_remote\_command" attribute set}.

@<Error Return@>=
void Drmaa_ErrorReturn(Tcl_Interp *ti, int errcode, char *errdiag) {
	Tcl_SetErrorCode(ti, "DRMAA", DrmaaErrorCode[errcode],
				drmaa_strerror(errcode), NULL);
	Tcl_AddErrorInfo(ti, errdiag);
	Tcl_AppendResult(ti, "DRMAA ", DrmaaErrorCode[errcode], " ",
				drmaa_strerror(errcode), NULL);
}

@ The following code segment is used by various functions that expect
a valid job template handle. It expects the character string |jthandle|
to contain the job template handle. The converted pointer will be stored
in |jt|.

@<Check and convert Job Template Handle@>=
drmaa_job_template_t *jt;
int jtparse;
jtparse = sscanf(jthandle, "jt%p", &jt);
if (jtparse != 1) {
	Tcl_AppendResult(ti, "No such template ", "\"", jthandle, "\"", (char *)NULL);
	return TCL_ERROR;
}

@*1Session Management Commands.

@ Call \.{drmaa\_init}. Initialize a new DRMAA session.
The {\sl contact} parameter is
optional. If missing we supply an empty string.

@<Session Management Commands@>=
int Drmaa_init(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];
	char *contact = NULL;

	if (objc == 2) {
		contact = Tcl_GetString(objv[1]);
	}
	else if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, "?contact?");
		return TCL_ERROR;
	}
@#
	errcode = drmaa_init(contact, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}

@ \.{drmaa\_exit}

Ends the DRMAA session.

@<Session Management Commands@>=
int Drmaa_exit(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	errcode = drmaa_exit(errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}

@*1Job Template Commands.

The job template commands create and use job template (jt) handles, which
are strings representing the job template pointer supplied by the underlying
libdrmaa implementation.

Routines that require a {\sl jt} handle as a parameter only check the string
for valid syntax, for example we do not check if {\sl jt} has been
allocated before, or if it has already been deleted. Although this may
change in future versions, where we might use a table to keep track
of the allocated/deleted {\sl jt} handles. The implementation of such
a table should be protected against multi-threaded access.

Of course, since we expect a higher level Tcl library to handle the
nicer user interface, then the {\sl jt} handles can be tracked at the Tcl level.

@ \.{drmaa\_allocate\_job\_template}

Creates a job template.

The command returns a job template handle in the form of {\bf jt0xP},
where \.{P} is the stringified C pointer to the opaque data structure
returned by the underlying \.{libdrmaa} call.

@<Job Template Commands@>=

int Drmaa_allocate_job_template(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	drmaa_job_template_t *jt;
	errcode = drmaa_allocate_job_template(&jt, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char jthandle[50];
	sprintf(jthandle, "jt%p", jt);
	Tcl_SetResult(ti, jthandle, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_delete\_job\_template} {\sl ?jt?}

{\sl jt} is only syntax checked.

@<Job Template Commands@>=
int Drmaa_delete_job_template(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	errcode = drmaa_delete_job_template(jt, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}


@ \.{drmaa\_set\_attribute} {\sl jt name value}

Add the ({\sl name}, {\sl value}) attribute pair to job template. The
check for the validity of {\sl jt} is minimal.

The validation of the attribute name is left to the \.{libdrmaa}
implementation.

@<Job Template Commands@>=
int Drmaa_set_attribute(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 4) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt name value");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	errcode = drmaa_set_attribute(jt, Tcl_GetString(objv[2]), Tcl_GetString(objv[3]),
			errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}

@ \.{drmaa\_get\_attribute} {\sl jt name}

Return value of attribute for job template {\sl jt}. {\sl jt} handle is
only syntax checked. The validation of {\sl name} is expected to be
checked by the underlying \.{libdrmaa} implementation.

@<Job Template Commands@>=
int Drmaa_get_attribute(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 3) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt name");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	char value[DRMAA_VALUE_BUFFER];
	errcode = drmaa_get_attribute(jt, Tcl_GetString(objv[2]), value, sizeof(value)-1,
			errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, value, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_get\_attribute\_names}

Return a list of the supported attribute names.

@<Job Template Commands@>=
int Drmaa_get_attribute_names(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	drmaa_attr_names_t *attr_names;
	errcode = drmaa_get_attribute_names(&attr_names, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char attr[DRMAA_ATTR_BUFFER];
	while (drmaa_get_next_attr_name(attr_names, attr, sizeof(attr)-1) == DRMAA_ERRNO_SUCCESS)
		Tcl_AppendElement(ti, attr);
	drmaa_release_attr_names(attr_names);
@#
	return TCL_OK;
@#
}

@ \.{drmaa\_get\_vector\_attribute} {\sl jt name}

Return the values of the vector attribute {\sl name} for {\sl jt} as a
list. {\sl jt} is only syntax checked, {\sl name} is expected to be
validated by the underlying \.{libdrmaa} implementation.

@<Job Template Commands@>=
int Drmaa_get_vector_attribute(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 3) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt name");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	drmaa_attr_values_t *attr_values;
	errcode = drmaa_get_vector_attribute(jt, Tcl_GetString(objv[2]), &attr_values,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char value[DRMAA_VALUE_BUFFER];
	while (drmaa_get_next_attr_value(attr_values, value, sizeof(value)-1) == DRMAA_ERRNO_SUCCESS)
		Tcl_AppendElement(ti, value) ;
	drmaa_release_attr_values(attr_values);
@#
	return TCL_OK;
}

@ \.{drmaa\_get\_vector\_attribute\_names}

Return a list of the supported attribute names.

@<Job Template Commands@>=
int Drmaa_get_vector_attribute_names(ClientData cd, Tcl_Interp *ti,
		int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	drmaa_attr_names_t *attr_names;
	errcode = drmaa_get_vector_attribute_names(&attr_names,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char attr[DRMAA_ATTR_BUFFER];
	while (drmaa_get_next_attr_name(attr_names, attr, sizeof(attr)-1) == DRMAA_ERRNO_SUCCESS)
		Tcl_AppendElement(ti, attr);
	drmaa_release_attr_names(attr_names);
@#
	return TCL_OK;
}

@ \.{drmaa\_set\_vector\_attribute} {\sl jt name value ?value...?}

Set the vector attribute {\sl name} for {\sl jt} to a given list of
{\sl values}.

@<Job Template Commands@>=
int Drmaa_set_vector_attribute(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc < 4) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt name values ...");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	const char **values;
	values = (const char **)Tcl_AttemptAlloc((objc-3+1)*sizeof(char **));
	if (values == NULL) {
		errcode = DRMAA_ERRNO_NO_MEMORY;
		strncpy(errdiag, "Too many vector attribute values", sizeof(errdiag)-1);
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
	int i;
	for (i=0 ; i<(objc-3) ; i++) {
		values[i] = Tcl_GetString(objv[i+3]);
	}
	values[objc-3] = NULL;

	errcode = drmaa_set_vector_attribute(jt, Tcl_GetString(objv[2]), values,
			errdiag, sizeof(errdiag)-1);
	Tcl_Free((char *)values);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}


@*1Job Submission Commands.

@ \.{drmaa\_run\_bulk\_jobs} {\sl jt start end incr}

submit a bulk job and return the list of job names.

@<Job Submission Commands@>=
int Drmaa_run_bulk_jobs(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 5) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt start end incr");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	int start, end, incr;
	if (Tcl_GetIntFromObj(ti, objv[2], &start) != TCL_OK) {
		Tcl_SetResult(ti, "start is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(ti, objv[3], &end) != TCL_OK) {
		Tcl_SetResult(ti, "end is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(ti, objv[4], &incr) != TCL_OK) {
		Tcl_SetResult(ti, "incr is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	drmaa_job_ids_t *job_ids;
	errcode = drmaa_run_bulk_jobs(&job_ids, jt, start, end, incr,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char jobid[DRMAA_JOBNAME_BUFFER];
	while (drmaa_get_next_job_id(job_ids, jobid, sizeof(jobid)-1) == DRMAA_ERRNO_SUCCESS)
		Tcl_AppendElement(ti, jobid);
@#
	return TCL_OK;
}

@ \.{drmaa\_run\_job} {\sl jt}

submit a single job and return job id.

@<Job Submission Commands@>=
int Drmaa_run_job(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "jt");
		return TCL_ERROR;
	}
@#
	char *jthandle = Tcl_GetString(objv[1]);
	@<Check and convert Job Template Handle@>@/
@#
	char jobid[DRMAA_JOBNAME_BUFFER];
	errcode = drmaa_run_job(jobid, sizeof(jobid)-1, jt,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, jobid, TCL_VOLATILE);
	return TCL_OK;
@#
}

@*1Job Control Commands.

@ \.{drmaa\_control} {\sl jobid action}

Perform action on the jobs specified by jobid.

@<Job Control Commands@>=
int Drmaa_control(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 3) {
		Tcl_WrongNumArgs(ti, 1, objv, "jobid action");
		return TCL_ERROR;
	}
	int action;
	if (Tcl_GetIndexFromObjStruct(ti, objv[2], DrmaaControl, sizeof(DrmaaControl_t),
			"action", TCL_EXACT, &action) != TCL_OK) {
		return TCL_ERROR;
	}
@#
	errcode = drmaa_control(Tcl_GetString(objv[1]), DrmaaControl[action].value,
			errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	return TCL_OK;
@#
}

@ \.{drmaa\_job\_ps} {\sl jobid}

Return status of job.

@<Job Control Commands@>=
int Drmaa_job_ps(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "jobid");
		return TCL_ERROR;
	}
@#
	int remote_ps;
	errcode = drmaa_job_ps(Tcl_GetString(objv[1]), &remote_ps,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	DrmaaJobPS_t *ps = DrmaaJobPS;
	while (ps != NULL && ps->ps != remote_ps) {
		ps++;
	}
	if (ps != NULL) {
		Tcl_SetResult(ti, ps->name, TCL_VOLATILE);
	}@+ else {
		char rempsstr[10];
		sprintf(rempsstr, "0x%x", remote_ps);
		Tcl_SetResult(ti, rempsstr, TCL_VOLATILE);
	}
	return TCL_OK;
@#
}

@ \.{drmaa\_synchronize} {\sl timeout dispose jobid ?jobid ...?}

Wait for the completeion of jobs.

@<Job Control Commands@>=
int Drmaa_synchronize(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc < 4) {
		Tcl_WrongNumArgs(ti, 1, objv, "timeout dispose jobid ?jobid ...?");
		return TCL_ERROR;
	}

	long timeout;
	if (Tcl_GetLongFromObj(ti, objv[1], &timeout) != TCL_OK) {
		Tcl_SetResult(ti, "timeout is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}

	int dispose;
	if (Tcl_GetIntFromObj(ti, objv[2], &dispose) != TCL_OK) {
		Tcl_SetResult(ti, "dispose is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	char **jobids;
	jobids = (char **)Tcl_AttemptAlloc((objc-3+1)*sizeof(char **));
	if (jobids == NULL) {
		errcode = DRMAA_ERRNO_NO_MEMORY;
		strncpy(errdiag, "Too many jobids", sizeof(errdiag)-1);
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
	int i;
	for (i=0 ; i<(objc-3) ; i++) {
		jobids[i] = Tcl_GetString(objv[i+3]);
	}
	jobids[objc-3] = NULL;
@#
	errcode = drmaa_synchronize((const char **)jobids, timeout, dispose, errdiag, sizeof(errdiag)-1);
	Tcl_Free((char *)jobids);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Tcl_ResetResult(ti);
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}

	Tcl_ResetResult(ti);
	return TCL_OK;
}

@ \.{drmaa\_wait} {\sl jobid timeout}

Wait for specific or any job. Returns \.{jobid} of waited job, \.{stat}
indicating job status and \.{rusage} as a list of \.{name=value} elements.

Note that if |drmaa_wait| returns \.{DRMAA\_ERRNO\_NO\_RUSAGE}, then
we treat that as not an error, and return a two element result, \.{jobid}
and \.{stat}.

@<Job Control Commands@>=
int Drmaa_wait(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 3) {
		Tcl_WrongNumArgs(ti, 1, objv, "jobid timeout");
		return TCL_ERROR;
	}
	int timeout;
	if (Tcl_GetIntFromObj(ti, objv[2], &timeout) != TCL_OK) {
		Tcl_SetResult(ti, "timeout is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	char jobid[DRMAA_JOBNAME_BUFFER];
	int stat;
	drmaa_attr_values_t *rusage;
	errcode = drmaa_wait(Tcl_GetString(objv[1]), jobid, sizeof(jobid)-1,
		&stat, (signed long)timeout, &rusage,
		errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS && errcode != DRMAA_ERRNO_NO_RUSAGE) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_AppendElement(ti, jobid);
	char statstr[20];
	sprintf(statstr, "%d", stat);
	Tcl_AppendElement(ti, statstr);
@#
	if (errcode != DRMAA_ERRNO_NO_RUSAGE) {
		char ru[DRMAA_VALUE_BUFFER];
		while (drmaa_get_next_attr_value(rusage, ru, sizeof(ru)-1) == DRMAA_ERRNO_SUCCESS)
			Tcl_AppendElement(ti, ru);
		drmaa_release_attr_values(rusage);
	}

	return TCL_OK;
@#
}

@ \.{drmaa\_wcoredump} {\sl stat}

Return true if job terminated with core dump. {\sl stat} should come
from a successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wcoredump(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	int stat;
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	int core_dump;
	errcode = drmaa_wcoredump(&core_dump, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char corestr[10];
	sprintf(corestr, "%d", core_dump);
	Tcl_SetResult(ti, corestr, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_wexitstatus} {\sl stat}

Return the exit status of waited job as specifed in \.{stat}. {\sl stat}
should come from a successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wexitstatus(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	int stat;
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	int exit_status;
	errcode = drmaa_wexitstatus(&exit_status, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char exitstr[10];
	sprintf(exitstr, "%d", exit_status);
	Tcl_SetResult(ti, exitstr, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_wifaborted} {\sl stat}

Return true if job exit status specified in \.{stat} was aborted. {\sl
stat} should come from a successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wifaborted(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];
	int	stat;
	int	aborted;
	char	abortstr[10];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	errcode = drmaa_wifaborted(&aborted, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	sprintf(abortstr, "%d", aborted);
	Tcl_SetResult(ti, abortstr, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_wifexited} {\sl stat}

Return true if job exited normally. {\sl stat} should come from a
successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wifexited(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];
	int	stat;
	int	exited;
	char	exitstr[10];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	errcode = drmaa_wifexited(&exited, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	sprintf(exitstr, "%d", exited);
	Tcl_SetResult(ti, exitstr, TCL_VOLATILE);
	return TCL_OK;
}

@ \.{drmaa\_wifsignaled} {\sl stat}

Return true if job was terminated due to signal. {\sl stat} should come
from a successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wifsignaled(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];
	int stat;
	int signaled;
	char signalstr[10];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}

	errcode = drmaa_wifsignaled(&signaled, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}

	sprintf(signalstr, "%d", signaled);
	Tcl_SetResult(ti, signalstr, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_wtermsig} {\sl stat}

Return the signal name, if job was temrinated by signal. {\sl stat}
should come from a successful \.{drmaa\_wait} call.

@<Job Control Commands@>=
int Drmaa_wtermsig(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 2) {
		Tcl_WrongNumArgs(ti, 1, objv, "stat");
		return TCL_ERROR;
	}
	int stat;
	if (Tcl_GetIntFromObj(ti, objv[1], &stat) != TCL_OK) {
		Tcl_SetResult(ti, "stat is not an integer", TCL_STATIC);
		return TCL_ERROR;
	}
@#
	char signal[DRMAA_SIGNAL_BUFFER];
	errcode = drmaa_wtermsig(signal, sizeof(signal)-1, stat, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, signal, TCL_VOLATILE);
	return TCL_OK;
@#
}


@*1Auxiliary Commands.

@ \.{drmaa\_get\_DRMAA\_implementation}
- get DRMAA implementation name
@<Auxiliary Comands@>=
int Drmaa_get_DRMAA_implementation(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	@<non-standard constant workaround@>;
	char impl[DRMAA_DRMAA_IMPL_BUFFER];
	errcode = drmaa_get_DRMAA_implementation(impl, sizeof(impl)-1,
			errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, impl, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ We need this extra bit since the constant for the buffer size is not
standardised across implementations. If neither name is defined, then
we let the compiler complain. Of course we could have just rolled our
own locally!

@<non-standard constant workaround@>=
#ifndef DRMAA_DRMAA_IMPL_BUFFER
#  ifdef DRMAA_DRMAA_IMPLEMENTATION_BUFFER
#    define DRMAA_DRMAA_IMPL_BUFFER DRMAA_DRMAA_IMPLEMENTATION_BUFFER
#  endif    
#endif    

@ \.{drmaa\_get\_DRM\_system}
- get DRMS identifier(s)
@<Auxiliary Comands@>=
int Drmaa_get_DRM_system(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	char drms[DRMAA_DRM_SYSTEM_BUFFER];
	errcode = drmaa_get_DRM_system(drms, sizeof(drms)-1,
				errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, drms, TCL_VOLATILE);
	return TCL_OK;
@#
}

@ \.{drmaa\_get\_contact}
- get contact info for DRMS
@<Auxiliary Comands@>=
int Drmaa_get_contact(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	char contact[DRMAA_CONTACT_BUFFER];
	errcode = drmaa_get_contact(contact, sizeof(contact)-1,
			errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	Tcl_SetResult(ti, contact, TCL_VOLATILE);
	return TCL_OK;
@#
}


@ \.{drmaa\_version}
- return the major and minor version of underlying DRMS
@<Auxiliary Comands@>=
int Drmaa_version(ClientData cd, Tcl_Interp *ti, int objc, Tcl_Obj *CONST objv[])
{
	int	errcode;
	char	errdiag[DRMAA_ERROR_STRING_BUFFER];

	if (objc != 1) {
		Tcl_WrongNumArgs(ti, 1, objv, NULL);
		return TCL_ERROR;
	}
@#
	int major, minor;
	errcode = drmaa_version(&major, &minor, errdiag, sizeof(errdiag)-1);
	if (errcode != DRMAA_ERRNO_SUCCESS) {
		Drmaa_ErrorReturn(ti, errcode, errdiag);
		return TCL_ERROR;
	}
@#
	char version[20];
	sprintf(version, "%d %d", major, minor);
	Tcl_SetResult(ti, version, TCL_VOLATILE);
	return TCL_OK;
@#
}

@*1\.{drmaash}. \.{drmaash} is an interactive shell similar to \.{tclsh}
and \.{wish}. When run, it will automatically load the \.{drmaatcl}
library, and run the \.{\~/.drmaashrc} script, if present.

After initialization, \.{drmaash} will print the prompt \.{drmaash\%~}
and await user commands.

@ The program code is minimal, we include the standard header file,

@(drmaash.c@>=
#include <tcl.h>

@ Create our custom initialisation function, \.{AppInit}:

@(drmaash.c@>=

int AppInit(Tcl_Interp *interp) {
	if(Tcl_Init(interp) == TCL_ERROR)@/
		return TCL_ERROR;
	if (Drmaatcl_Init(interp) == TCL_ERROR)@/
		return TCL_ERROR;
	Tcl_SetVar(interp, "tcl_rcFileName", "~/.drmaashrc", TCL_GLOBAL_ONLY);
	Tcl_SetVar(interp, "tcl_prompt1", "puts -nonewline {drmaash% }", TCL_GLOBAL_ONLY);
	return TCL_OK;
}

@ And call \.{Tcl\_Main} from our \.{main} function, which in turn calls
our initialization script, \.{AppInit}:

@(drmaash.c@>=

int main(int argc, char *argv[]) {
	Tcl_Main(argc, argv, AppInit);
	return 0;
}

