function __cmake()
{
  local _bm=${1}
  shift
  /usr/bin/cmake -DCMAKE_BUILD_TYPE=${_bm} $@
}

function cmake_debug()
{
  __cmake Debug $@
}

function cmake_release()
{
  __cmake Debug $@
}

function make()
{
  echo /usr/bin/make -j$(($(nproc) -2)) $@
}
