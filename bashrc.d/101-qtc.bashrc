function qtc_config()
{
  # generate config entries for Qt5
  echo '#define Q_GADGET'
  echo '#define Q_OBJECT'
  echo '#define Q_WIDGETS_EXPORT'
  echo '#define Q_SLOTS'
  echo '#define Q_SIGNALS public'
  echo '#define QDOC_PROPERTY(...)'
  echo '#define Q_INVOKABLE'
  echo '#define QT_END_NAMESPACE'
  echo '#define Q_PRIVATE_SLOT(...)'
  echo '#define Q_ENUM(...)'
}
