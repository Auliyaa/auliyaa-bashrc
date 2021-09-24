function qtc_config()
{
  # generate config entries for Qt5
  echo '#define QT_CORE_LIB'
  echo '#define QT_GUI_LIB'
  echo '#define QT_WIDGETS_LIB'
  echo '#define GTEST_LINKED_AS_SHARED_LIBRARY 1'
}

function qtc_includes()
{
  # local prohect headers (estimation)
  find . -iname '*.h' -type f | xargs dirname | sort | uniq
  # qt include files
  echo '/usr/include/qt'
  echo '/usr/include/qt/QtWidgets'
  echo '/usr/include/qt/QtGui'
  echo '/usr/include/qt/QtCore'
  # gnu includes
  echo '/usr/lib/qt/mkspecs/linux-g++'
}

function qtc_cflags()
{
  echo '-std=gnu17'
}

function qtc_cxxflags()
{
  echo '-std=gnu++17'
}

function qtc_setup()
{
  local matches=($(ls *.includes 2>/dev/null))
  local match="${matches[0]}"
  if [[ -f "${match[0]}" ]]; then
    qtc_includes > "${match[0]}"
  fi

  local matches=($(ls *.config 2>/dev/null))
  local match="${matches[0]}"
  if [[ -f "${match[0]}" ]]; then
    qtc_config > "${match[0]}"
  fi

  local matches=($(ls *.cflags 2>/dev/null))
  local match="${matches[0]}"
  if [[ -f "${match[0]}" ]]; then
    qtc_cflags > "${match[0]}"
  fi

  local matches=($(ls *.cxxflags 2>/dev/null))
  local match="${matches[0]}"
  if [[ -f "${match[0]}" ]]; then
    qtc_cxxflags > "${match[0]}"
  fi
}
