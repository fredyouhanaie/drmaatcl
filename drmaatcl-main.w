
%% drmaatcl-main.w
%%	Main module of the drmaatcl cweb files.

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

\datethis

%%\pagewidth=5.5in
%%\pageheight=8.7in
%%\fullpageheight=9in
%%\setpage

%%\parindent=0pt
%%\parskip=1pt

\def\title{Tcl Language Bindings for DRMAA}
\def\author{Fred Youhanaie}
\def\version{(Version 0.1)}

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
\def\url#1{
	\ifx\pdfoutput\undefined
		\.{#1}
	\else
		\pdfURL{\.{#1}}{#1}
	\fi
}


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

@*Licensing.

\.{drmaatcl} is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

\medskip

\.{drmaatcl} is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
License for more details.

\medskip

You should have received a copy of the GNU Lesser General Public License
along with \.{drmaatcl}. If not, see \url{http://www.gnu.org/licenses/}.

@*Index.
