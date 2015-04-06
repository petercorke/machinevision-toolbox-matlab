ROOT = ~/rvc

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
	cp -r ../IPT rvctools/vision
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
	find rvctools -name .svn -type d | xargs rm -rf

CMD = '/INSERT_HERE/ {\
r helpfuncbycat.xml\
d\
}'

doco:
	-\rm -rf tmpdoc
	-mkdir tmpdoc
	-mkdir -p rvctools/vision/info/html
	-cp -r rvctools/vision/* tmpdoc
	-cp rvctools/common/* tmpdoc
	-rm tmpdoc/HiddenFigure.m

	# build the PDF manual
	(cd tmpdoc; help3.py -l --include @* *.m; mv all.tex ../../doc/manual)
	-cp funcidx* ../doc/manual
	(cd ../doc/manual; make)
	mv ../doc/manual/vision.pdf rvctools/vision

	# build the XML/info stuff for matlab help browser system
	-mkdir -p rvctools/vision/info/html
	cp -r ../info/vision_product_page.html rvctools/vision/info
	(cd tmpdoc; help3.py --mvtb -m @* *.m; mv *.html ../rvctools/vision/info/html)
	cp contents.html rvctools/vision/info
	cp contents_alpha.html rvctools/vision/info
	cp contents_toc.html rvctools/vision/info

	# create the helptoc.xml file
	cp ../info.xml rvctools/vision
	sed '/<!--INSERT_HERE-->/r helpfuncbycat.xml' < ../info/helptoc.xml > rvctools/vision/info/helptoc.xml 
	cp ../info/*.html rvctools/vision/info
	cp -r ../info/icons rvctools/vision/info
	cp -r ../doc/mvtb-montage-notext.png rvctools/vision/info

	# copy over the autogen files
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

toolbox:
	# build the .mltbx file
	mkdir flat
	cp -r rvctools/vision/* flat
	cp rvctools/common/* flat
	cp ~/rvc/vision/images/*.png flat/images
	cp ~/rvc/vision/images/*.jpg flat/images
	cp ~/rvc/vision/images/*.mpg flat/images
	rm flat/vision/startup_mvtb.m

dropbox:
	cp -r ./{vision,simulink,common} $(HOME)/Dropbox

install: zipit
	scp -C vision-`cat ../RELEASE`.zip geek:www/MVTB/r3
	#scp -Cr html geek:www/MVTB
	rsync -az html geek:www/MVTB/r3
	scp -C rvctools/vision/vision.pdf geek:www/MVTB/r3
	ssh geek chmod -R a+rX www/MVTB/r3

stage:
	ssh geek mv www/MVTB/vision-*.zip www/MVTB/r3

clean:
	@-\rm -rf vision.zip vision.tgz
	@-\rm -rf simulink common tmpdoc vision vision.zip vision.tgz
	@-\rm -rf info tmpdoc html
	@-\rm *.m *.xml *.html *.png Manifest funcid*
	-\rm -rf rvctools tmpdoc vision.zip vision.tgz
