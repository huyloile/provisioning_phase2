#!/bin/sh
#
# Checks out and builds a combination of :
# - generic cellcube from a specified branch (1st parameter)
# - orangef stuff from HEAD

# Require CVSROOT to be set in environment
# (will be needed for subsequent use of CVS

if [ -z $CVSROOT ]; then
    echo "CVSROOT must be set in environment"
    exit 1
fi

# First parameter is name of branch for generic stuff

if [ "x"$1 = "xhelp" -o $# -ne 1 ]; then
    echo 1>&2 "Usage:   $0 <GENERIC BRANCH>"
    echo 1>&2 "Example: $0 release_cellcube_3_7_patches"
    exit 1
fi
branch=$1

# Function that modifies variables in a makefile

set_var()
{
    if grep -e "^$2=" $1; then
        sed -i "s,^$2=.*,$2=$3," $1
    else
	echo "Error: variable $2 not found in $1"
	exit 1
    fi
}

# Checkout and build

cvs checkout -r $branch cellicium
set_var cellicium/Makefile.defs TOPDIR $PWD/cellicium
set_var cellicium/Makefile.defs DO_CUSTOM 1
set_var cellicium/Makefile.defs CUSTOM orangef
cvs update -d -r $branch cellicium
make -C cellicium depend
cvs update -d -r $branch cellicium
for dir in pservices_orangef pdist_orangef pfront_orangef webmin_orangef webuser_orangef; do
    pushd cellicium/possum/lib/$dir
    cvs update -r HEAD
    cvs update -A
    popd
done
pushd cellicium/possum/releases/orangef
cvs update -r HEAD
cvs update -A
popd
make -C cellicium all
make -C cellicium/possum install-generic
