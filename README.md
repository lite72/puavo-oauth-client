puavo-oauth-client
==================

Example Puavo OAuth2 client. Please read first the puavo-users OAuth2 documentation:
https://github.com/opinsys/puavo-users/wiki/Puavo-OAuth2-authorization-service

Installation instructions
=========================

```sh
sudo apt-get install ruby1.8 rubygems # or newer, etc..
sudo gem install bundle
git clone https://github.com/lite72/puavo-oauth-client.git
cd puavo-oauth-client
bundle install # it's possible you need to install some libxxxxx-dev packages first
vim src/client.rb  # correct the credentials and uris
rackup
```
