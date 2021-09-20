# encrypt a string given as parameter
function encrypt()
{
  openssl aes-256-cbc -a -pbkdf2
}

# decrypt a string given as parameter
function decrypt()
{
  openssl aes-256-cbc -d -a -pbkdf2
}
