#
# TransFig makefile
#

all: overview-1.pdf overview-1.eps

# translation into pdf/ps

overview-1.pdf: overview-1.fig Makefile
	fig2dev -L pdf overview-1.fig overview-1.pdf

overview-1.eps: overview-1.fig Makefile
	fig2dev -L eps overview-1.fig overview-1.eps

clean::
	rm -f overview-1.pdf overview-1.eps

