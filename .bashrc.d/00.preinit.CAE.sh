[ -f /.bash_profile_global ] || return
[ -d /afs/engr.wisc.edu ] || return
# Run a reduced version of CAE's default .bash_profile

##
# CAE global .bash_profile file - Linux
# Rev 8/07
##

umask 026
ulimit -S -c 4096

# Setup the environment
if [ "$UID" -ne 0 ]; then
	PATH=/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/opt/bin:/afs/engr.wisc.edu/oss/bin:/afs/engr.wisc.edu/apps/bin:/afs/engr.wisc.edu/common/scripts:/opt/java/bin:/opt/jdk/bin:/afs/engr.wisc.edu/local/bin
	export PATH
fi

MANPATH=/usr/share/man:/usr/local/man:/usr/local/share/man:/afs/engr.wisc.edu/oss/man:/afs/engr.wisc.edu/apps/man:/afs/engr.wisc.edu/common/man:/opt/jdk/man:/afs/engr.wisc.edu/local/man:/afs/engr.wisc.edu/apps/condor/@sys/man
export MANPATH

export CLASSPATH=/afs/engr.wisc.edu/common/java/lib:.
export ORACLE_HOME="/opt/oracle"

export SYSTEM=$(/usr/bin/fs sysname | cut -d\' -f2)


# Set the default printer
if [ -f /usr/CAE/local/host_config ] ; then
	PRINTER=$(awk -F= '/^printer/ {print $2}' /usr/CAE/local/host_config)
	if [ -z ${PRINTER} ] ; then
		PRINTER=ps
	fi
else
	PRINTER=ps
fi

export PRINTER

# vim: set ft=sh noet : 
