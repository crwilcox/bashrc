# part of default .bashrc for users for computer sciences users

# only set /s/std/bin if it's not a root user

if [ $UID -ne 0 ]; then
  PATH=/s/std/bin:$PATH
fi

if [ -d "/s" ]; then
  # set linux paths
  PATH=$PATH:/usr/afsws/bin # AFS SOFTWARE
  PATH=$PATH:/opt/SUNWspro/bin # compilers (on Solaris)
  PATH=$PATH:/usr/ccs/bin # programming tools (on Solaris)
  PATH=$PATH:/usr/ucb # standard programs
  PATH=$PATH:/bin # standard programs
  PATH=$PATH:/usr/bin # standard programs
  PATH=$PATH:/usr/X11R6/bin # X software for linux
  PATH=$PATH:/s/handin/bin # handin software
  PATH=$PATH:/p/course/cs354-common/public/bin
else
  # set cygwin paths
  PATH=$PATH:/cygdrive/c/WINDOWS
  PATH=$PATH:/cygdrive/c/Progra~1/OpenAFS/Client/Program
fi

export PATH
