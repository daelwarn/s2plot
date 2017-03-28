#!/bin/csh -f
## ccbuild.csh
 #
 # Copyright 2006-2012 David G. Barnes, Paul Bourke, Christopher Fluke
 #
 # This file is part of S2PLOT.
 #
 # S2PLOT is free software: you can redistribute it and/or modify it
 # under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # S2PLOT is distributed in the hope that it will be useful, but
 # WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 # General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with S2PLOT.  If not, see <http://www.gnu.org/licenses/>. 
 #
 # We would appreciate it if research outcomes using S2PLOT would
 # provide the following acknowledgement:
 #
 # "Three-dimensional visualisation was conducted with the S2PLOT
 # progamming library"
 #
 # and a reference to
 #
 # D.G.Barnes, C.J.Fluke, P.D.Bourke & O.T.Parry, 2006, Publications
 # of the Astronomical Society of Australia, 23(2), 82-93.
 #
 # $Id: ccbuild.csh 5815 2012-10-19 04:51:26Z dbarnes $
 #
 # usage: ccbuild.csh target
 # - compiles 'target.cc' and links to produce executable 'target'
 #

set objnames=

foreach arg( $* )

set objnames=($objnames $arg.o)

end
 
echo $objnames
 
if (!(${?S2PATH})) then
  echo "S2PATH environment variable MUST be set ... please fix and retry."
  exit(-1);
endif
if (! -d $S2PATH || ! -e ${S2PATH}/scripts/s2plot.csh) then
  echo "S2PATH is set but invalid: ${S2PATH} ... please fix and retry."
  exit(-1);
endif
source ${S2PATH}/scripts/s2plot.csh
if ($status) then
  exit(-1)
endif

set thisdir=`pwd`

if ($thisdir == $S2PATH) then
  echo "You must NOT be in directory ${S2PATH} to build your own programs."
  exit(-1);
endif

foreach arg( $* )

#set target=`echo $1 | sed -e 's/\.cc$//g'`
set target=`echo $arg | sed -e 's/\.cc$//g'`
set source=${target}.cc
set object=${target}.o
if (! -e ${source}) then
  echo "Cannot find source code: ${source}[.cc]"
  exit(-1);
endif 

echo "Checking ${target}.* date against $1.."
set newerfile=`find ${target}.* -newer $1`
#if ({ find ${target}.* -newer $1 }) then
if("$newerfile" == "") then
  # check if the output file exists first
  if(-e $object) then
    echo "Skipping file ${target}, it appears up-to-date"
    continue
  else
    echo "${target} is missing, building.."
  endif
else
  echo "Building ${target}"
endif

echo "Compiling source code file ${source} ..."
$S2CCMPILER ${S2EXTRAINC} -std=c++11 -I${S2PATH}/src $source

if($status != 0) then
  echo "Build failed on file ${source}, aborting!"
  exit(-1);
endif

echo "Status: ${status}"

end

set target=$1

#echo "Linking object file ${target}.o ..."
echo "Linking object files ${objnames} into executable ${target}..."
#$S2CCINKER -o $target ${object} -L${S2PATH}/${S2KERNEL} ${S2LINKS} ${MLLINKS} ${SWLINKS} ${GLLINKS} -L${S2X11PATH}/lib${S2LBITS} ${S2FORMSLINK} -lXpm -lX11 ${IMATH} -lm ${XLINKPATH} ${S2EXTRALIB}
$S2CCINKER -o $target ${objnames} -L${S2PATH}/${S2KERNEL} ${S2LINKS} ${MLLINKS} ${SWLINKS} ${GLLINKS} -L${S2X11PATH}/lib${S2LBITS} ${S2FORMSLINK} -lXpm -lX11 ${IMATH} -lm ${XLINKPATH} ${S2EXTRALIB}

if ((${?S2INSTALLPATH})) then
  if (! -d $S2INSTALLPATH) then
    echo "S2INSTALLPATH is set but invalid (i.e. doesn't exist) ... please fix and retry."
    exit(-1);
  else
    echo "Installing ${target} in ${S2INSTALLPATH} ..."
    cp -f $target $S2INSTALLPATH
    rm -f $target
  endif
endif

# Disabled cleanup for incremental builds
#echo "Cleaning up ..."
#rm -rf $object

echo "Done!"
