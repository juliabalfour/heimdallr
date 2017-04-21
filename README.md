# Heimdallr

> One of the things Ford Prefect had always found hardest to understand about humans was their habit of continually stating and repeating the very very obvious.
>
> -- <cite>Douglas Adams, The Hitchhiker's Guide to the Galaxy</cite>

## Installation

Heimdallr is cryptographically signed. To be sure the gem you install has not been tampered with:

Add the Julia Balfour public key (if you have not already) as a trusted certificate

```shell
gem cert --add <(curl -Ls https://raw.github.com/juliabalfour/heimdallr/master/certs/juliabalfour.pem)
```

```shell
gem install heimdallr -P MediumSecurity
```

The MediumSecurity trust profile will verify signed gems, but allow the installation of unsigned dependencies. This is necessary because not all of project dependencies are signed, so we cannot use HighSecurity.
