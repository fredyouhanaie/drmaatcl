
%% drmaatcl-main.w
%%	Main module of the drmaatcl cweb files.

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

\datethis

%%\pagewidth=6.5in % a4 width=8.5, less 2x1 in for margins
%%\pageheight=10in
%\fullpageheight=9in
%%\setpage

%%\parindent=0pt
%%\parskip=1pt

\def\title{Tcl Language Bindings for DRMAA}
\def\author{Fred Youhanaie}
\def\version{(Version 0.1)}

\ifx\pdfoutput\undefined\else
	\pdfinfo{
		/Title	(\title)
		/Author	(\author)
	}
\fi

@i boilerplate.w

%% \fig{file} will insert an eps/pdf picture file
\def\fig#1{
	\medskip
	\ifx\pdfoutput\undefined
		\input epsf.tex \epsfbox{#1.eps}
	\else
		\pdfximage {#1.pdf}\pdfrefximage\pdflastximage
	\fi
	\medskip
}

%% \url will create the proper links for the PDF files.
\def\url#1{\ifx\pdfoutput\undefined\.{#1}\else\pdfURL{\.{#1}}{#1}\fi}

%% \bul provide bullet points
\def\bul{\hfil\item{\romannumeral\count255} \advance\count255 by 1}
%% the following needs to be repeated for each set of new bullet points
\count255=1

%% To a C programmer NULL is more familiar than Lambda.
@s NULL normal

%% Treat the Tcl and DRMAA data types as reserved words during
%% typesetting.

@s ClientData int
@s Tcl_Obj int
@s Tcl_Interp int
@s Tcl_ObjCmdProc int
@s drmaa_attr_values_t int
@s drmaa_attr_names_t int
@s drmaa_job_ids_t int
@s drmaa_job_template_t int

@i drmaatcl-guide.w

@i drmaatcl-data.w

@i drmaatcl-code.w

@*Licensing of the software.

\.{drmaatcl} is free software, you can redistribute it and/or modify it
under the terms of the BSD License, see
\url{http://opensource.org/licenses/BSD-2-Clause}.

\medskip

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

\count255=1
\bul Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

\bul Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

\medskip

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS~IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

@*Index.
