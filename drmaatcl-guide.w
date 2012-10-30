
%% drmaatcl-guide.w
%%	Introduction and User Guide.

%% Copyright (c) 2012 Fred Youhanaie
%%
%% This file is part of drmaatcl.
%%
%% drmaatcl is free software: you can redistribute it and/or modify it
%% under the terms of the GNU Lesser General Public License as published
%% by the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% drmaatcl is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
%% License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public
%% License along with drmaatcl. If not, see <http://www.gnu.org/licenses/>.

\def\tex{\TeX\ }

@*Introduction. This is the implementation of the Tcl language bindings
for the DRMAA specification.

There are two main reasons for providing this implementation, first,
to complement the existing scripting language bindings, such as Perl,
Python and Ruby, and second, to provide an intuitive facility for the
interactive user. The latter being one of the strengths of Tcl's command
based structure.

@ DRMAA\footnote{$^1$}{Pronounced drama} (Distributed Resource Management
Application API) is an API specification from the Open Grid Forum (OGF)
for the submission and control of jobs to one or more Distributed Resource
Management (DRM) systems. Details about DRMAA and OGF can be
found on their respective web sites, \url{http://drmaa.org} and
\url{http://ogf.org}.

The DRMAA specification is aimed at software vendors who need to create
applications that submit jobs to a DRM system, such as Grid Engine or
Condor, without the application requiring to include any DRM specific
code. This separates the application from the DRM specific interface
details, provided that the DRM supports DRMAA. In fact it alleviates the
need for the application to be rebuilt for each DRM.

The selection of the DRM is achieved at run time by leveraging the
dynamic library mechanism of the underlying operating system where it
is ensured that the DRMAA library for the specific DRM, normally called
\.{libdrmaa.so}, is found before any other library. One typically sets
the \.{LD\_LIBRARY\_PATH} environment variable appropriately.

The two main documents used for this implementation are {\tt DRMAA 1.0
Grid Recommendation (GFD.133)} and \.{DRMAA C Binding v1.0}. Both of
these can be downloaded from the DRMAA web site.

@ Tcl (Tool Command Language) is a scripting language that was created
in 1988 and has been in continuous development since its first
release. For a complete history of the language please see the web page
\url{http://tcl.tk/about/history.html}

Tcl is still going strong and currently there is a large number of Tcl
applications in existence. This library is being provided in the hope
that it may bring additional benefit to the existing, as well as future,
Tcl code base, especially those in grid/cluster computing environments.

Description and references relating to the Tcl language can be found on
the Tcl/Tk community web site, \url{http://tcl.tk}.

@ The programming language used in creating the library is \.{cweb},
which consists of standard C code together with the annotations describing
the code segments. This is known as Literate Programming. The web site
\url{http://literateprogramming.com} is a good starting point for those
not familiar with the concept.

Literate Programming allows one to produce from a single source file a
typeset documentation (this note) as well as a compilable C source code.

@ The current implementation provides a basic access to the C API
routines, but with a typical Tcl like interface. However, an object
oriented interface based on this library and written in pure Tcl will
be provided in due course.

The relationship between \.{drmaatcl} and other DRMAA components is
illustrated below:

\fig{Figures/overview-1}

Each DRM vendor that supports DRMAA will supply their own \.{libdrmaa.so}
library. The \.{drmaatcl} extension, once built and installed, will
have its own library, \.{libdrmaatcl.so}, which will access the vendor
supplied library. Tcl scripts will have access to the Tcl extensions
via \.{libdrmaatcl.so}, either via \.{drmaash}, or via other Tcl shells
such as \.{tclsh} or \.{wish} via the \.{package require drmaa} command.

@ This document provides guidance to those requiring access to DRMAA API
from Tcl scripts. This can be found in the early part of the document
following this introduction. It is assumed that the reader is already
familiar with the Tcl language.

For those who prefer to see how everything has been put together, the
source code can be found following the user guide. The source code will
also help those who are unsure of how a particular command is parsed
and executed. It is assumed that the reader is already familiar with
the Tcl C API.

@*1Implementation Notes. The implementation provides a Tcl extension
library using the DRMAA C bindings specification. However, the Tcl
commands made available to the user are closer to the definitions in
the API. The library has been hand crafted from ground up, rather than
using an automatic code generator such as SWIG.

@ {\bf Commands}. Each DRMAA call is defined as a Tcl command. The
commands are defined within the \.{drmaa::} namespace, e.g.
\.{drmaa::drmaa\_init}. A set of short commands can also be used with
the \.{namespace ensemble ...} feature of Tcl. Such an example is shown
in the examples section with author's own choice of shortcuts.

@ {\bf Error Handling}. All commands put success/error values in
\.{errorCode} and \.{errorInfo} as defined in \.{tclvars}. Applications
can use the Tcl \.{catch} command to handle exceptions. \.{errorCode}
will always have the fixed format \.{DRMAA {\sl errno errstr}}, where {\sl errno}
is the symbolic error name as defined by the API standard, but without
the \.{DRMAA\_ERRNO\_} prefix, and {\sl errstr} is the corresponding error
string as returned by \.{drmaa\_strerror()}.

For example, if a DRMAA library function returns
\.{DRMAA\_ERRNO\_INVALID\_ARGUMENT}, then \.{errorCode} will contain a
three element list such as the following example:
\smallskip
\noindent\.{DRMAA INVALID\_ARGUMENT \{The input value for an argument is invalid.\}}
\smallskip

\.{errorInfo} will contain the text string returned in the
\.{drmaa\_context\_error\_buf}, or \.{error\_diagnosis} parameter of
the C function. In fact \.{errorInfo} will contain a multi-line stack
trace, the top line of which will be the additional diagnosis string.

@ {\bf Multi-threading}. \.{libdrmaa} implementations are required to
support multi-threading. To this end the design of the Tcl extension has
been kept as simple as possible and with no internal state data.

All state information is either kept within the lower level DRMS and/or
DRMAA library, or the higher level user script.

In order to have multi-threaded Tcl scripts, the underlying Tcl Core
library needs to support it. The variable \.{\$tcl\_platform(threaded)}
can be used to confirm if the Tcl implementation supports multi-threading.

@ {\bf Command Outputs}. The \.{OUT} values specified in the API, if
any, are returned as the output of the command. These, depending on
the command, will be a list of zero or more strings. In case of error
return, the output of the command will be same as \.{errorCode}, see
Error Handling above.

Some of the API functions define \.{drmaa\_context\_error\_buf} as an
OUT value, however, since this is only used in the event of an error,
it will be assigned to the Tcl variable \.{errorInfo}. See the earlier
section on error handling.

@ {\bf Job Templates}. Newly allocated job templates will be identified
by symbolic handles generated from the opaque C structure pointer.

@ {\bf Job Attributes.} These are treated as character strings that
are passed to the underlying DRMS. No validation is performed by the
Tcl layer.

@ {\bf Interactive shell}. Also included in this implementation is the
\.{drmaash} interpreter, which is similar to \.{tclsh} and \.{wish}. This
shell interpreter can be used to interactively access the underlying
DRMAA based DRMS. It is implemented as a standard Tcl interpreter, it
will accept all the standard Tcl commands as well as commands related to
other packages that may be loaded at run time, such as \.{Tk}. \.{drmaash}
is described towards the end of this document.

On startup \.{drmaash} will evaluate the file \.{\~/.drmaashrc},
if present. Just like \.{tclsh} and \.{wish}, this file will not be
evaluated if a script file is present on the command line.

@ {\bf Testing}. drmaatcl has been tested using the \.{tcltest}
package. In future the test suite will be extended to include all of
(or as much of) the official DRMAA compliance test suite.

This will allow one to confirm that the Tcl library is compliant,
provided that the underlying DRMAA implementation is also compliant.

@* Installation notes. With the current (alpha) version, the build and
installation involves a number of manual steps that include the possible
editing of the supplied \.{Makefile}. These steps will be replaced with
autoconf scripts in the next release.

No binary files are being supplied, so you will need to build the
library from source.

The whole library is created from the five cweb files, {\tt
drmaatcl-main.w}, {\tt drmaatcl-guide.w}, {\tt drmaatcl-data.w}, {\tt
drmaatcl-code.w} and {\tt boilerplate.w}. In fact the latter four are
brought in (included with {\bf @@i}) via {\tt drmaatcl-main.w}.

From these files we generate a two C files, via {\tt ctangle}, and a
single \tex file, via {\tt cweave}. However, these two files have been
supplied, so you do not need to install {\tt cweb} on your system.

The C files, {\bf drmaash.c} and {\bf drmaatcl-main.c}, is then compiled
and linked with the Tcl library to give you the Tcl extension {\tt
libdrmaatcl.so}.

The \tex file is used to produce the current document, for example via
{\tt pdftex}.

@ {\bf Prerequisites}. The following packages are required:

{\tt cweb}, only if you need to regenerate the C and/or \tex files. You
may find this in one of the packages for your OS distribution, for example
for ubuntu cweb is included in {\tt texlive-extra-utils}.
Or, you may download, build and install it from
\url{http://literateprogramming.com}.

{\bf Tcl core library and header files}. Although the header files are
only needed for the compilation phase. The current version of {\tt
drmaatcl} was developed with Tcl 8.5.6.

{\bf C compiler and linker}. The library was developed and tested using
{\tt gcc 4.3.3}. Other ANSI C compilers should work too.

{\tt libdrmaa} implemetation files, {\tt libdrmaa.so} and {\tt drmaa.h}. The
latter is only required for the build phase.

@*1The Command Reference. The drmaatcl commands made available to users
are listed below in alphabetical order.

\medskip

\def\cmdref#1#2#3{
\filbreak
\smallskip{\noindent{\tt#1} {\sl#2}\par
{\leftskip=1in\noindent#3\par}}\smallskip}%%\hrule}

%%\hrule
\cmdref{drmaa::drmaa\_allocate\_job\_template}{}{A new job template is
created and the symbolic job template handle is returned.}

\cmdref{drmaa::drmaa\_control}{jobid action}{{\sl jobid} is as returned
by {\tt drmaa\_run\_job} or {\tt drmaa\_run\_bulk} commands.
{\sl action} is one of \.{SUSPEND}, \.{RESUME}, \.{HOLD}, \.{RELEASE}
or \.{TERMINATE}. Nothing is returned, unless error.}

\cmdref{drmaa::drmaa\_delete\_job\_template}{jt}{
{\sl jt} is the job template handle as returned by {\tt
drmaa\_allocate\_job\_template} Nothing is returned, unless error.}

\cmdref{drmaa::drmaa\_exit}{}{The DRMAA session is ended. Nothing is
returned, unless error.}

\cmdref{drmaa::drmaa\_get\_DRMAA\_implementation}{}{Returns the DRMAA
Implementation string.}

\cmdref{drmaa::drmaa\_get\_DRM\_system}{}{Returns the DRM system string.}

\cmdref{drmaa::drmaa\_get\_attribute}{jt attr}{Returns the current value
of attribute {\sl attr}, if set, within the job template {\sl jt}.}

\cmdref{drmaa::drmaa\_get\_attribute\_names}{}{Returns the list of
attribute names that are supported by the underlying DRMS.}

\cmdref{drmaa::drmaa\_get\_contact}{}{Returns the contact string.}

\cmdref{drmaa::drmaa\_get\_vector\_attribute}{jt attr}{Returns the
current list of values for vector attribute {\sl attr}, if set, within
job template {\sl jt}.}

\cmdref{drmaa::drmaa\_get\_vector\_attribute\_names}{}{Returns a list
of vector attribute names that are supported by the underlying DRMS.}

\cmdref{drmaa::drmaa\_init}{?contact?}{Initialises the DRMAA
session. {\sl contact} is optional and it will be set to the empty string,
if missing. Nothing is returned, unless error.}

\cmdref{drmaa::drmaa\_job\_ps}{jobid}{Returns the status of {\sl jobid},
the status will be one of {\tt UNDETERMINED}, {\tt QUEUED\_ACTIVE}, {\tt
SYSTEM\_ON\_HOLD}, {\tt USER\_SYSTEM\_ON\_HOLD}, {\tt RUNNING}, {\tt
SYSTEM\_SUSPENDED}, {\tt USER\_SUSPENDED}, {\tt DONE} or {\tt FAILED}.}

\cmdref{drmaa::drmaa\_run\_bulk\_jobs}{jt start end incr}{submits
the job specified by the job template {\sl jt} for the given range of
tasks. Returns a list of job IDs.}

\cmdref{drmaa::drmaa\_run\_job}{jt}{submits the job specified by the
job template {\sl jt}. Returns a job ID.}

\cmdref{drmaa::drmaa\_set\_attribute}{jt attr value}{set the value of
attribute {\sl attr} for job template {\sl jt}. Noting is returned,
unless error.}

\cmdref{drmaa::drmaa\_set\_vector\_attribute}{jt attr value
?value...?}{Sets the vector attribute {\sl attr} for job template {\sl
jt} to the given {\sl value}(s). Nothing is returned, unless error.}

\cmdref{drmaa::drmaa\_synchronize}{timeout dispose jobid
?jobid ...?}{Awaits for the completion of all the jobs listed as
arguments. {\sl timeout} is the maximum number of seconds to wait
if no jobs complete/terminate, if {\sl dispose} is 1, then the
status data for the completed job will be discarded. {\sl jobid}
should be a list of job IDs previously returned by \.{drmaa\_run\_job}
or \.{drmaa\_run\_bulk\_jobs}, alternatively, one can wait for all the
active jobs by using \.{DRMAA\_JOB\_IDS\_SESSION\_ALL} as the {\sl jobid}.
Nothing returned, unless error, note that timeout is returned as error
condition/exception.}

\cmdref{drmaa::drmaa\_version}{}{Returns the DRMAA API version as a list
of two numbers.}

\cmdref{drmaa::drmaa\_wait}{jobid timeout}{Awaits the completion of
any of the {\sl jobid}, which should be a jobID returned by one of
\.{drmaa\_run\_job} or \.{drmaa\_run\_bulk\_jobs}, alternatively, one
can wait for any of the submitted jobs by using
\.{DRMAA\_JOB\_IDS\_SESSION\_ANY} as the {\sl jobid}. Returns a
list made up of \.{jobid}, \.{stat} and a list of resource usage data, with each
element in the form of \.{name=value} pair.}

\cmdref{drmaa::drmaa\_wcoredump}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

\cmdref{drmaa::drmaa\_wexitstatus}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

\cmdref{drmaa::drmaa\_wifaborted}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

\cmdref{drmaa::drmaa\_wifexited}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

\cmdref{drmaa::drmaa\_wifsignaled}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

\cmdref{drmaa::drmaa\_wtermsig}{stat}{{\sl stat} should be from the
output of the \.{drmaa\_wait} command. Returns an integer.}

%%\hrule

@*1Examples. Here are some examples to help the reader started with
the library. All the examples shown here can be found in the \.{examples}
directory of the \.{drmaatcl} distribution.

@ {\tt example00-drmaashrc.tcl}. If you have Tcl 8.5 or higher, then
a set of short commands can be defined as shown below. The best way to
define these commands is to put the whole segment in the \.{\~/.drmaashrc}
file. With this set up, one can use, for example, \.{drmaa ajt} in place
of \.{drmaa::drmaa\_allocate\_job\_template}. This should hopefully make
life easier for the interactive user.

\medskip
{\tt \vbox{\+\hskip1cm\cleartabs&\hskip1cm&\hskip1cm&\cr
\+namespace eval drmaa $\{$\cr
\+&namespace ensemble create -map $\{$\cr
\+&&init&drmaa\_init\cr
\+&&exit&drmaa\_exit\cr
\+\cr
\+&&ajt&drmaa\_allocate\_job\_template\cr
\+&&djt&drmaa\_delete\_job\_template\cr
\+&&ga&drmaa\_get\_attribute\cr
\+&&gan&drmaa\_get\_attribute\_names\cr
\+&&gva&drmaa\_get\_vector\_attribute\cr
\+&&gvan&drmaa\_get\_vector\_attribute\_names\cr
\+&&sa&drmaa\_set\_attribute\cr
\+&&sva&drmaa\_set\_vector\_attribute\cr
\+\cr
\+&&rj&drmaa\_run\_job\cr
\+&&rbj&drmaa\_run\_bulk\_jobs\cr
\+&&ps&drmaa\_job\_ps\cr
\+&&ctrl&drmaa\_control\cr
\+&&sync&drmaa\_synchronize\cr
\+&&wait&drmaa\_wait\cr
\+\cr
\+&&wcd&drmaa\_wcoredump\cr
\+&&wes&drmaa\_wexitstatus\cr
\+&&wia&drmaa\_wifaborted\cr
\+&&wie&drmaa\_wifexited\cr
\+&&wis&drmaa\_wifsignaled\cr
\+&&wts&drmaa\_wtermsig\cr
\+\cr
\+&&gc&drmaa\_get\_contact\cr
\+&&vers&drmaa\_version\cr
\+&&gdi&drmaa\_get\_DRMAA\_implementation\cr
\+&&gds&drmaa\_get\_DRM\_system\cr
\+&$\}$\cr
\+$\}$\cr
} %vbox
} %tt

@ {\tt example01-simple.tcl}. Once the above short commands are defined,
then one can use them as in the example below.
Note that \.{drmaash} will only source the \.{\~/.drmaashrc} file if the
shell is run interactively, otherwise the rc file will need to be sourced
manually, as we have done below.

\medskip

{\tt \vbox{\+\hskip1cm\cleartabs&\hskip1cm&\hskip1cm&\cr
\+&source \~\,/.drmaashrc\cr
\+&\cr
\+&drmaa init\cr
\+&set jt [drmaa ajt]\cr
\+&drmaa sa \$jt drmaa\_remote\_command /bin/sleep\cr
\+&drmaa sva \$jt drmaa\_v\_argv 10\cr
\+&set jid [drmaa rj \$jt]\cr
\+&puts "Job ID is \$jid"\cr
\+&set wout [drmaa wait \$jid \$drmaa::DRMAA\_TIMEOUT\_WAIT\_FOREVER]\cr
\+&puts \$wout\cr
\+&drmaa exit\cr
}}

@ {\tt example02-proc.tcl}. This is an example of a simple user defined
procedure for submitting jobs. This script can be run via {\tt tclsh},
hence the need for the presence of the {\tt package} command.

\medskip

{\tt \vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&package require drmaa\cr
\+&\cr
\+&proc submit $\{$cmd args$\}$ $\{$\cr
\+&&set jt [drmaa::drmaa\_allocate\_job\_template]\cr
\+&&drmaa::drmaa\_set\_attribute \$jt drmaa\_remote\_command \$cmd\cr
\+&&drmaa::drmaa\_set\_vector\_attribute \$jt drmaa\_v\_argv \$args\cr
\+&&set jid [drmaa::drmaa\_run\_job \$jt]\cr
\+&&drmaa::drmaa\_delete\_job\_template \$jt\cr
\+&&return \$jid\cr
\+&$\}$\cr
\+&\cr
\+&drmaa::drmaa\_init\cr
\+&set jid [submit /bin/sleep 10]\cr
\+&set wout [drmaa::drmaa\_wait \$jid \$drmaa::DRMAA\_TIMEOUT\_WAIT\_FOREVER]\cr
\+&puts \$wout\cr
\+&drmaa::drmaa\_exit\cr
}
}

@ Here we parse the output of the \.{drmaa::drmaa\_wait} command. The
{\tt \$wout} variable from the simple example above would have contained
a list similar to the one shown below. Here, the first element is the
job ID, the second is job return status, and the rest are the resource
usage key/value pairs.

\medskip
{\tt \vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&10 1 io=0.0000 iow=0.0000 mem=0.0000 cpu=0.0040 vmem=0.0000\cr
\+&maxvmem=9519104.0000 submission\_time=1257296814.0000 priority=0.0000\cr
\+&exit\_status=0.0000 signal=0.0000 start\_time=1257296817.0000\cr
\+&end\_time=1257296822.0000 ru\_wallclock=5.0000 ru\_utime=0.0040\cr
\+&ru\_stime=0.0000 ru\_maxrss=0.0000 ru\_ixrss=0.0000 ru\_ismrss=0.0000\cr
\+&ru\_idrss=0.0000 ru\_isrss=0.0000 ru\_minflt=478.0000 ru\_majflt=0.0000\cr
\+&ru\_nswap=0.0000 ru\_inblock=0.0000 ru\_oublock=8.0000 ru\_msgsnd=0.0000\cr
\+&ru\_msgrcv=0.0000 ru\_nsignals=0.0000 ru\_nvcsw=2.0000 ru\_nivcsw=1.0000\cr
\+&acct\_cpu=0.0040 acct\_mem=0.0000 acct\_io=0.0000 acct\_iow=0.0000\cr
\+&acct\_maxvmem=9519104.0000\cr
}
}
\medskip

The command Tcl {\tt lindex \$wout 0} will return the job id,
while the command {\tt lindex \$wout 1} will return the job status.
The latter can be used as input to the set of commands that interpret
the return status, for example

\medskip
{\tt \vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&set stat [lindex \$wout 1]\cr
\+&drmaa::drmaa\_wexitstatus \$stat\cr
}
}
\medskip

As for the resource usage list, if present, they can be parsed into a
Tcl array. Below is one such example. Here, reading from right to left,
we first skip over the first two elements of the list, 0 and 1, then we
convert the {\tt =} characters to blanks, so that we have a flat list
of alternating key/value elements, this list is then assigned to the
array named {\tt rus}, from which various elements are extracted.

\medskip
{\tt \vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&array set rus [string map $\{$= " "$\}$ [lrange \$wout 2 end]]\cr
\+&puts "Wall clock is \$rus(ru\_wallclock)"\cr
\+&puts "cpu used is \$rus(cpu)"\cr
}
}

@ {\tt ex-c-example.tcl}. Here is the Tcl version of the C program
example in the DRMAA C API, translated to Tcl almost verbatim. The code
is shown in multiple paragraphs, however, the real script is just the
concatenation of the code segments described below.

\medskip

To make life easier for us, a simple procedure is employed for reporting
errors.

{\tt \vbox{ \+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&proc error\_report $\{$result errinfo$\}\;\{$\cr
\+&&puts stderr \$result\cr
\+&&puts stderr "=== Error Trace ==="\cr
\+&&puts stderr \$errinfo.\cr
\+&$\}$\cr
}
}

\medskip

The first segment is the definition of the \.{create\_job\_template}
procedure. A single \.{catch} command is used to catch the sequence of
{\tt drmaa} commands for creating job template.

{\tt\vbox{
\+\hskip\parskip\cleartabs\hskip.5cm&\hskip.5cm&\hskip.5cm&\hskip.5cm&\hskip.5cm&\hskip.5cm&\cr
\+&proc create\_job\_template $\{$job\_path seconds as\_bulk\_job$\}\;\{$\cr
\+&&if $\{$[catch $\{$\cr
\+&&&&&set jt [drmaa::drmaa\_allocate\_job\_template]\cr
\+&&&&&drmaa::drmaa\_set\_attribute \$jt drmaa\_wd \$drmaa::DRMAA\_PLACEHOLDER\_HD\cr
\+\cr
\+&&&&&drmaa::drmaa\_set\_attribute \$jt drmaa\_remote\_command \$job\_path\cr
\+&&&&&drmaa::drmaa\_set\_vector\_attribute \$jt drmaa\_v\_argv \$seconds\cr
\+&&&&&drmaa::drmaa\_set\_attribute \$jt drmaa\_join\_files y\cr
\+\cr
\+&&&&&set outpath ":\$drmaa::DRMAA\_PLACEHOLDER\_HD/DRMAA\_JOB"\cr
\+&&&&&if $\{$\$as\_bulk\_job$\}$ $\{$\cr
\+&&&&&&set outpath "\$outpath.\$drmaa::DRMAA\_PLACEHOLDER\_INCR"\cr
\+&&&&&$\}$\cr
\+&&&&&drmaa::drmaa\_set\_attribute \$jt drmaa\_output\_path \$outpath\cr
\+&&&&&$\}$ result]$\}$ then $\{$\cr
\+&&&error\_report "\$result" "\$::errorInfo"\cr
\+&&&return -code error\cr
\+&&$\}$ else $\{$\cr
\+&&&return \$jt\cr
\+&&$\}$\cr
\+&$\}$\cr
}
}

\medskip

The program initialisation is fairly straight forward.

{\tt \vbox{ \+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\cr
\+&if $\{$\$argc != 1$\}\;\{$\cr
\+&&puts stderr "Usage: [info script] <path-to-job>"\cr
\+&&return 1;\cr
\+&$\}$\cr
\+&set job\_path [lindex \$argv 0]\cr
\+&\cr
\+&set NBULKS 3\cr
\+&set JOB\_CHUNK 8\cr
\+&\cr
\+&list all\_jobids $\{\}$\cr
\+&\cr
\+&if $\{$[catch $\{$drmaa::drmaa\_init $\{\}\}$ result]$\}\;\{$\cr
\+&&error\_report "\$result" "\$::errorInfo"\cr
\+&&exit 1\cr
\+&$\}$\cr
}
}

\medskip

To submit the bulk jobs, we first create the template, then call {\tt
drmaa\_run\_bulk\_jobs} for the number of bulk jobs required. The job
ids are appended to the {\tt all\_jobids} list.

{\tt\vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\hskip1cm&\cr
\+&if $\{$[catch $\{$create\_job\_template \$job\_path 5 1$\}$ result]$\}\;\{$\cr
\+&&puts stderr "create\_job\_template failed"\cr
\+&&exit 1\cr
\+&$\}$ else $\{$\cr
\+&&set jt \$result\cr
\+&$\}$\cr
\+\cr
\+&for $\{$set i 0$\}\;\{$\$i $<$ \$NBULKS$\}\;\{$incr i$\}\;\{$\cr
\+&&if $\{$[catch $\{$drmaa::drmaa\_run\_bulk\_jobs \$jt 1 \$JOB\_CHUNK 1$\}$ result]$\}\;\{$\cr
\+&&&error\_report "\$result" "\$::errorInfo"\cr
\+&&&drmaa::drmaa\_exit\cr
\+&&&exit 1\cr
\+&&$\}$ else $\{$\cr
\+&&&set jobids \$result\cr
\+&&$\}$\cr
\+\cr
\+&&puts "submitted bulk job with jobids:"\cr
\+&&foreach jid \$jobids $\{$\cr
\+&&&puts "$\backslash$t $\backslash$"\$jid$\backslash$""\cr
\+&&&lappend all\_jobids \$jid\cr
\+&&$\}$\cr
\+&$\}$\cr
\+&drmaa::drmaa\_delete\_job\_template \$jt\cr
}
}

\medskip
Next, we submit some sequential jobs in a manner similar to the bulk
job submission above.

{\tt\vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\hskip1cm&\cr
\+&if $\{$[catch $\{$create\_job\_template \$job\_path 5 0$\}$ result]$\}\;\{$\cr
\+&&puts stderr "create\_job\_template failed "\cr
\+&&exit 1\cr
\+&$\}$ else $\{$\cr
\+&&set jt \$result\cr
\+&$\}$\cr
\+&puts "submitted single jobs with jobids:"\cr
\+&for $\{$set i 0$\}\;\{$\$i $<$ \$JOB\_CHUNK$\}\;\{$incr i$\}\;\{$\cr
\+&&set jobid [drmaa::drmaa\_run\_job \$jt]\cr
\+&&puts "$\backslash$t $\backslash$"\$jobid$\backslash$""\cr
\+&&lappend all\_jobids \$jobid\cr
\+&$\}$\cr
\+&drmaa::drmaa\_delete\_job\_template \$jt\cr
}
}

\medskip

Now that the jobs have been submitted, we wait for all of them to
complete.

{\tt\vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\hskip1cm&\cr
\+&set synclist \$all\_jobids\cr
\+&if $\{$[catch $\{$drmaa::drmaa\_synchronize\cr
\+&&\$drmaa::DRMAA\_TIMEOUT\_WAIT\_FOREVER 0 \$synclist$\}$ result]$\}\;\{$\cr
\+&&error\_report "\$result" "\$::errorInfo"\cr
\+&&drmaa::drmaa\_exit\cr
\+&&exit 1\cr
\+&$\}$\cr
\+&puts stderr "synchronized with all jobs"\cr
}
}

\medskip

Once the jobs have completed/terminated, we can start reaping the results
with {\tt drmaa\_wait} and finish off.

{\tt\vbox{\+\hskip\parskip\cleartabs\hskip1cm&\hskip1cm&\hskip1cm&\cr
\+&foreach jid \$all\_jobids $\{$\cr
\+&&if $\{$[catch $\{$drmaa::drmaa\_wait \$jid
	\$drmaa::DRMAA\_TIMEOUT\_WAIT\_FOREVER$\}$ result]$\}\;\{$\cr
\+&&&puts stderr "drmaa\_wait(\$jid) failed:"\cr
\+&&&error\_report "\$result" "\$::errorInfo"\cr
\+&&&continue\cr
\+&&$\}$ else $\{$\cr
\+&&&set job\_out \$result\cr
\+&&$\}$\cr
\+&&set stat [lindex \$job\_out 1]\cr
\+&&set rusage [lrange \$job\_out 2 end]\cr
\+\cr
\+&&if [drmaa::drmaa\_wifaborted \$stat] $\{$\cr
\+&&&puts stderr "job $\backslash$"\$jid$\backslash$" never ran"\cr
\+&&&continue\cr
\+&&$\}$\cr
\+&&if [drmaa::drmaa\_wifexited \$stat] $\{$\cr
\+&&&set exit\_status [drmaa::drmaa\_wexitstatus \$stat]\cr
\+&&&puts stderr "job $\backslash$"\$jid$\backslash$"
	finished regularly with exit status \$exit\_status"\cr
\+&&&continue\cr
\+&&$\}$\cr
\+&&if [drmaa::drmaa\_wifsignaled \$stat] $\{$\cr
\+&&&set termsig [drmaa::drmaa\_wtermsig \$stat]\cr
\+&&&puts stderr "job $\backslash$"\$jid$\backslash$" finished due to signal \$termsig"\cr
\+&&&continue\cr
\+&&$\}$\cr
\+&&puts stderr "job $\backslash$"\$jid$\backslash$" finished with unclear conditions"\cr
\+&$\}$\cr
\+\cr
\+&drmaa::drmaa\_exit\cr
}
}

