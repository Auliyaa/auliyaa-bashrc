function prntsc()
{
  url='https://prnt.sc/'
  url="${url}$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -c 2 | tr '[:upper:]' '[:lower:]')" # add 2 random letters
  url="${url}$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))" # add for random digits
  xdg-open "${url}"
}
