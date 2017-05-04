# Heimdallr

> Exactly!" said Deep Thought. "So once you do know what the question actually is, you'll know what the answer means.
>
> ― <cite>Douglas Adams, The Hitchhiker's Guide to the Galaxy</cite>

## Installing / Getting Started

Heimdallr is cryptographically signed. To be sure the gem you install has not been tampered with, add the Heimdallr public key (if you have not already) as a trusted certificate:
```shell
gem cert --add <(curl -Ls https://raw.github.com/juliabalfour/heimdallr/master/certs/heimdallr.pem)
```

gem install heimdallr -P MediumSecurity

The MediumSecurity trust profile will verify signed gems, but allow the installation of unsigned dependencies.
This is necessary because not all of Heimdallr's dependencies are signed, so we cannot use HighSecurity.

## Testing

```shell
bin/rails db:create db:migrate RAILS_ENV=test
bundle exec rspec
```
