# ==========================================================================
# cmake macros
# ==========================================================================
function __cmake()
{
  local _bm=${1}
  shift
  /usr/bin/cmake \
   -DCMAKE_C_COMPILER=/usr/bin/clang\
   -DCMAKE_CXX_COMPILER=/usr/bin/clang++\
   -DCMAKE_BUILD_TYPE=${_bm}\
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON\
   $@
}

function cmake_debug()
{
  __cmake Debug $@
}

function cmake_release()
{
  __cmake Release $@
}

function make()
{
  echo /usr/bin/make -j$(($(nproc) -2)) $@
}

# ==========================================================================
# number of cpus
# ==========================================================================
export corecount=$(grep -c ^processor /proc/cpuinfo)

# ==========================================================================
# Make alias for auto -j
# ==========================================================================
function make()
{
  /usr/bin/make -j$((corecount*2/3)) "${@}"
}

# ==========================================================================
# use verbose output for ctest
# ==========================================================================
export CTEST_OUTPUT_ON_FAILURE=1
