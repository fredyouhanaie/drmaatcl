#
# TransFig makefile
#

all: overview-1.pdf 

# translation into pdf

overview-1.pdf: overview-1.fig Makefile
	fig2dev -L pdf overview-1.fig overview-1.pdf
clean::
	rm -f overview-1.pdf

