# Copyright (C) 1995-2009, by Peter I. Corke
#
# This file is part of The Machine Vision Toolbox for Matlab (MVTB).
# 
# MVTB is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# MVTB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Leser General Public License
# along with MVTB.  If not, see <http://www.gnu.org/licenses/>.

#DEBUG = -g

mex:
	mex $(DEBUG) closest.c
	mex $(DEBUG) fhist.c
	mex $(DEBUG) hist2d.c
	mex $(DEBUG) ilabel.c
	mex $(DEBUG) imatch.c
	mex $(DEBUG) imorph.c
	mex $(DEBUG) irank.c
	mex $(DEBUG) ivar.c
	mex $(DEBUG) iwindow.c
	mex $(DEBUG) stereo_match.c

	
UNAME = $(shell uname)
MATLAB = $(subst /bin/matlab,,$(shell which matlab))

framegrabber:
ifeq ($(UNAME), Darwin)
    # for MacOS we use QTKit to access the camera, the code is written in ObjC++
    # need to modify mexopts.sh to include the frameworks since they cannot be passed as
    # options.  You need to add:
    # -framework QTKit -framework Foundation -framework QTKit -framework CoreVideo 
    # -framework Cocoa

	g++ -I ${MATLAB}/extern/include -c $(DEBUG) framegrabber_qtkit.mm
	mex $(DEBUG) -output framegrabber -cxx framegrabber_qtkit.o 
endif
ifeq ($(UNAME), Linux)
	mex -output framegrabber framegrabber_firewire.c -ldc1394_control -lraw1394
endif

clean:
	-\rm *.mex*

