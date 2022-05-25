
TARFILE = ../vecpat-deposit-$(shell date +'%Y-%m-%d').tar.gz

# For building on my office desktop
# Rscript = ~/R/r-devel-vecpat/BUILD/bin/Rscript
# Rscript = ~/R/r-devel/BUILD/bin/Rscript
Rscript = ~/R/r-release/BUILD/bin/Rscript
# Rscript = Rscript

# For building in Docker container
# Rscript = /R/bin/Rscript

%.xml: %.cml %.bib
	# Protect HTML special chars in R code chunks
	$(Rscript) -e 't <- readLines("$*.cml"); writeLines(gsub("str>", "strong>", gsub("<rcode([^>]*)>", "<rcode\\1><![CDATA[", gsub("</rcode>", "]]></rcode>", t))), "$*-protected.xml")'
	$(Rscript) toc.R $*-protected.xml
	$(Rscript) bib.R $*-toc.xml
	$(Rscript) foot.R $*-bib.xml

%.Rhtml : %.xml
	# Transform to .Rhtml
	xsltproc knitr.xsl $*.xml > $*.Rhtml

%.html : %.Rhtml
	# Use knitr to produce HTML
	$(Rscript) knit.R $*.Rhtml

docker:
	sudo docker build -t pmur002/vecpat-report .
	sudo docker run -v $(shell pwd):/home/work/ -w /home/work --rm pmur002/vecpat-report make vecpat.html

web:
	make docker
	cp -r ../vecpat-report/* ~/Web/Reports/GraphicsEngine/vecpat/

zip:
	make docker
	tar zcvf $(TARFILE) ./*
