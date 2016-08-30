# Crate config
hosts = (ENV['CRATE_HOSTS'] || '127.0.0.1').split(',')

CRATE_OPTIONS = {
  hosts: hosts
}
