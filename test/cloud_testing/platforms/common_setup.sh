#!/bin/bash

portable_dirname() {
  if [ "x$(uname -s)" = "xDarwin" ]; then
    echo $(dirname $(/usr/local/bin/greadlink --canonicalize $1))
  else
    echo $(dirname $(readlink --canonicalize $1))
  fi
}

script_location=$(portable_dirname $0)
. ${script_location}/common.sh

#
# Common functionality for cloud platform test execution engine (test setup)
# After sourcing this file the following variables are set:
#
#  SERVER_PACKAGE        location of the CernVM-FS server package to install
#  CLIENT_PACKAGE        location of the CernVM-FS client package to install
#  FUSE3_PACKAGE         location of the libcvmfs_fuse3 package
#  DEVEL_PACKAGE         location of the CernVM-FS devel package to install
#  CONFIG_PACKAGES       location of the CernVM-FS config packages
#  SOURCE_DIRECTORY      location of the CernVM-FS sources forming above packages
#  UNITTEST_PACKAGE      location of the CernVM-FS unit test package
#  SHRINKWRAP_PACKAGE    location of the CernVM-FS shrinkwrap package
#  LOG_DIRECTORY         location of the test log files to be created
#  GATEWAY_BUILD_URL     location of the repository gateway build to install
#  NOTIFY_SRV_BUILD_URL  location of the notification server build to install
#

SERVER_PACKAGE=""
CLIENT_PACKAGE=""
FUSE3_PACKAGE=""
DEVEL_PACKAGE=""
UNITTEST_PACKAGE=""
SHRINKWRAP_PACKAGE=""
CONFIG_PACKAGES=""
SOURCE_DIRECTORY=""
LOG_DIRECTORY=""
GATEWAY_BUILD_URL=""
NOTIFY_SRV_BUILD_URL=""

# parse script parameters (same for all platforms)
while getopts "s:c:d:k:t:g:l:w:n:p:f:" option; do
  case $option in
    s)
      SERVER_PACKAGE=$OPTARG
      ;;
    c)
      CLIENT_PACKAGE=$OPTARG
      ;;
    f)
      FUSE3_PACKAGE=$OPTARG
      ;;
    d)
      DEVEL_PACKAGE=$OPTARG
      ;;
    k)
      CONFIG_PACKAGES="$OPTARG"
      ;;
    t)
      SOURCE_DIRECTORY=$OPTARG
      ;;
    g)
      UNITTEST_PACKAGE=$OPTARG
      ;;
    p)
      SHRINKWRAP_PACKAGE=$OPTARG
      ;;
    l)
      LOG_DIRECTORY=$OPTARG
      ;;
    w)
      GATEWAY_BUILD_URL=$OPTARG
      ;;
    n)
      NOTIFY_SRV_BUILD_URL=$OPTARG
      ;;
    ?)
      shift $(($OPTIND-2))
      usage "Unrecognized option: $1"
      ;;
  esac
done

# check that all mandatory parameters are set
if [ "x$SOURCE_DIRECTORY"      = "x" ] ||
   [ "x$LOG_DIRECTORY"         = "x" ] ||
   [ "x$CLIENT_PACKAGE"        = "x" ]; then
  echo "missing parameter(s), cannot run platform dependent test script"
  exit 100
fi
if [ "x$(uname -s)" != "xDarwin" ]; then
    if [ "x$SERVER_PACKAGE"        = "x" ] ||
       [ "x$CONFIG_PACKAGES"       = "x" ] ||
       [ "x$UNITTEST_PACKAGE"      = "x" ] ||
       [ "x$SHRINKWRAP_PACKAGE"    = "x" ] ||
       [ "x$GATEWAY_BUILD_URL"     = "x" ] ||
       [ "x$NOTIFY_SRV_BUILD_URL"  = "x" ] ||
       [ "x$DEVEL_PACKAGE"         = "x" ]; then
      echo "missing parameter(s), cannot run platform dependent test script"
      exit 200
    fi
fi

# check that the script is running under the correct user account
if [ $(id -u -n) != "sftnight" ]; then
  echo "test cases need to run under user 'sftnight'... aborting"
  exit 3
fi

echo "Hostname is $(hostname)"
