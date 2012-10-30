
% boilerplate.w
%	Title page and copyright notice, no C code here.

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

\def\topofcontents{
	\leftline{\sc\today\ at \hours}\bigskip\bigskip
	\centerline{\titlefont\title}
	\vskip 15pt \centerline{\author} \vfil
	\vskip 15pt \centerline{\version} \vfil
}

\font\ninett=cmtt9
\def\botofcontents{\vskip 0pt plus 1filll
\ninerm\baselineskip10pt
\noindent Copyright \copyright\ 2009-2012 \author
\bigskip\noindent
\ninerm
Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3 or
any later version published by the Free Software Foundation; with no
Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.

For the full license text see http://www.gnu.org/licenses/fdl-1.3.html.
}
