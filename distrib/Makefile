ROOT = ~/lib/matlab/rvctools

release:  build doco 

build: 
	# clean up
	-\rm -rf rvctools tmpdoc vision.zip vision.tgz

	# make a temp directory to hold the files
	mkdir -p rvctools/vision rvctools/simulink rvctools/common

	# create the Manifest
	buildcontent -r `cat ../RELEASE` --mvtb $<

	# copy all m-files and classes listed in the Manifest
	mancp Manifest .. rvctools/vision
	mancp Manifest $(ROOT)/common rvctools/common

	# copy simulink models
	cp -r ../simulink/*.mdl rvctools/simulink
	cp -r ../examples rvctools/vision
	cp -r ../mex rvctools/vision
	cp -r ../private rvctools/vision
	#cp -r ../images rvctools/vision
	mkdir rvctools/vision/images

	# copy misc documentation files
	cp ../README rvctools/vision
	-cp ../CHANGES rvctools/vision
	cp ../RELEASE rvctools/vision
	cp ../CITATION rvctools/vision
	cp ../LGPL-LICENCE.txt rvctools/vision
	cp ../startup_mvtb.m rvctools/vision

	cp $(ROOT)/common/*.m rvctools/common
	cp $(ROOT)/startup_rvc.m rvctools


	# remove all SVN files
	find rvctools -name .svn -exec rm {} \;

doco:
	-\rm -rf tmpdoc
	-mkdir tmpdoc
	-mkdir -p rvctools/vision/info/html
	-cp -r rvctools/vision/* tmpdoc
	-cp rvctools/common/* tmpdoc
	-rm tmpdoc/HiddenFigure.m

	# build the PDF manual
	(cd tmpdoc; help3.py -l --include @* *.m; mv all.tex ../../doc)
	(cd ../doc; make)
	mv ../doc/vision.pdf rvctools/vision

	# build the XML/info stuff for matlab help browser system
	-mkdir -p rvctools/vision/info/html
	cp -r ../info/vision_product_page.html rvctools/vision/info
	(cd tmpdoc; help3.py --mvtb -m @* *.m; mv *.html ../rvctools/vision/info/html)
	cp contents.html rvctools/vision/info
	cp contents_alpha.html rvctools/vision/info
	cp contents_toc.html rvctools/vision/info

	cp ../info.xml rvctools/vision
	cp ../info/helptoc.xml rvctools/vision/info
	cp ../info/*.html rvctools/vision/info
	cp -r ../info/icons rvctools/vision/info
	cp -r ../doc/mvtb-montage-notext.png rvctools/vision/info

	# copy over the autogen files
	cp helpfuncbycat.xml rvctools/vision/info
	cp contents_toc.html rvctools/vision/info

	# build the web/HTML doco
	-mkdir html
	(cd tmpdoc; help3.py --mvtb -w @* *.m; mv *.html ../html)
	cp index.html html
	cp index_alpha.html html

	# classical matlab toolbox index
	cp Contents.m rvctools/vision


zipit:
	# build the distrib archives
	zip -rq vision-`cat ../RELEASE`.zip ./rvctools
	#tar zcf vision.tgz ./rvctools

dropbox:
	cp -r ./{vision,simulink,common} $(HOME)/Dropbox

install: zipit
	scp -C vision-*.zip geek:www/MVTB
	scp -Cr html geek:www/MVTB
	scp -C rvctools/vision/vision.pdf geek:www/MVTB
	ssh geek chmod -R a+rX www/MVTB

clean:
	@-\rm -rf vision.zip vision.tgz
	@-\rm -rf simulink common tmpdoc vision vision.zip vision.tgz
	@-\rm -rf info tmpdoc html
	@-\rm *.m *.xml *.html *.png Manifest
	-\rm -rf rvctools tmpdoc vision.zip vision.tgz
