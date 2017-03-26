ROOT = ~/code/rvc
BUILD = tmp
MANUAL = $(BUILD)/manual/vision.pdf
SRC = $(ROOT)/vision
ROBOT = rvctools/robot
VISION = rvctools/vision
COMMON = rvctools/common
CONTRIB = rvctools/contrib
LIB = ~/lib/matlab

release:  build doco zipit

release-ipt: build-ipt doco zipit

doco:	pdf markup

build:  tmp allfuncs.txt

build-ipt: build ipt

tmp:
	# make a temp directory to hold the files
	mkdir tmp

	# recurse
	$(MAKE) -C tmp -f ../Makefile $(MFLAGS) _build

_build: 
	# runs in tmp
	mkdir -p rvctools/vision rvctools/robot rvctools/simulink rvctools/common rvctools/vision/images rvctools/contrib

	# create the Manifest
	buildcontent -r `cat ../../RELEASE` --mvtb ../allfuncs.txt

	# copy all m-files and classes listed in the Manifest
	mancp --verbose Manifest $(SRC) $(VISION)
	mancp --verbose Manifest $(ROOT)/robot $(ROBOT)
	mancp --verbose Manifest $(ROOT)/common $(COMMON)

	# copy any contrib files that will be included
	cp -r $(ROOT)/contrib/vgg $(CONTRIB)
	cp -r $(ROOT)/contrib/vlfeat-0.9.20 $(CONTRIB)

	cp -r $(ROOT)/contrib/graphseg $(CONTRIB)
	cp -r $(ROOT)/contrib/OpenSURF $(CONTRIB)

	cp $(LIB)/deg2utm.m $(CONTRIB)
	cp $(LIB)/arrow3.m $(CONTRIB)
	mv rvctools/vision/colorspace.m $(CONTRIB)
	cp $(ROOT)/common/count_unique.m $(CONTRIB)

	# install images for MOOC
	# -mkdir rvctools/vision/images
	cp $(ROOT)/images1/*.png rvctools/vision/images
	cp $(ROOT)/images1/*.jpg rvctools/vision/images
	cp $(ROOT)/images1/*.mpg rvctools/vision/images

	# copy other bits and bobs
	cp -r $(SRC)/simulink/*.slx rvctools/simulink
	cp -r $(SRC)/examples rvctools/vision
	cp -r $(SRC)/mex rvctools/vision
	cp -r $(SRC)/private rvctools/vision
	cp -r $(SRC)/IPT rvctools/vision
	#cp -r ../images rvctools/vision
	-mkdir rvctools/vision/images
	
	# copy misc documentation files
	cp $(SRC)/README rvctools/vision
	-cp $(SRC)/CHANGES rvctools/vision
	cp $(SRC)/RELEASE rvctools/vision
	cp $(SRC)/CITATION rvctools/vision
	cp $(SRC)/LGPL-LICENCE.txt rvctools/vision
	cp $(SRC)/startup_mvtb.m rvctools/vision

	cp $(ROOT)/startup_rvc.m rvctools

	# remove all SVN files
	find rvctools -name .svn -type d | xargs rm -rf

CMD = '/INSERT_HERE/ {\
r helpfuncbycat.xml\
d\
}'

pdf:	tmp $(MANUAL)

$(MANUAL):
	# recurse
	$(MAKE) -C tmp -f ../Makefile $(MFLAGS) _pdf

_pdf:
	-echo "---------build the manual"
	-\rm -rf tmpdoc
	-mkdir tmpdoc 
	-cp -r rvctools/vision/* tmpdoc
	-cp rvctools/common/* tmpdoc

	# copy over the manual skeleton, we will work here
	cp -r $(ROOT)/vision/doc/manual .
	
	# generate LaTeX code for all functions in there
	(cd tmpdoc; help3.py -v -l --include @* *.m; mv all.tex ../manual)

	# copy over the index generator support
	-mv funcidx* manual

	# build the PDF manual
	(cd manual; make)

	cp manual/vision.pdf rvctools/vision

	# and let's take a look
	open manual/vision.pdf 


CMD = '/INSERT_HERE/ {\
r helpfuncbycat.xml\
d\
}'

markup: $(MANUAL)
	# rely on pdf code to build all the temp files
	# recurse
	$(MAKE) -C tmp -f ../Makefile $(MFLAGS) _markup

_markup:
	# build the XML/info stuff for matlab help browser system
	# build it in info, info/html
	-mkdir -p info/html
	cp -r $(SRC)/doc/info/vision_product_page.html info
	(cd tmpdoc; help3.py --mvtb -m @* *.m; mv *.html ../info/html)

	# copy over the autogen files
	cp contents.html info
	cp contents_alpha.html info
	cp contents_toc.html info

	# create the helptoc.xml file
	cp $(SRC)/doc/info/helptoc.xml info
	#sed '/<!--INSERT_HERE-->/r helpfuncbycat.xml' < $(SRC)/info/helptoc.xml > info/helptoc.xml

	# copy invariant files from the distro
	cp $(SRC)/doc/info/*.html info
	cp $(SRC)/doc/info/*.css info
	#cp -r $(SRC)/info/icons info
	#cp manual/figs/rtb-montage.png info

	
	# build the web/HTML doco
	-mkdir html
	(cd tmpdoc; help3.py --mvtb -w @* *.m; mv *.html ../html)
	cp index.html html
	cp index_alpha.html html

	# classical matlab toolbox index
	cp Contents.m rvctools/vision

	# install it all
	cp -r info rvctools
	cp $(SRC)/doc/info.xml rvctools


zipit:
	# build the distrib archives
	(cd tmp; zip -rq ../vision-`cat ../../RELEASE`.zip ./rvctools)
	#tar zcf vision.tgz ./rvctools

ipt:
	mv tmp/rvctools/vision/IPT/* tmp/rvctools/vision
	rm -rf tmp/rvctools/vision/mex

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
	@-\rm -rf tmp
