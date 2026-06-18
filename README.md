# Homebrew Tap For Base

This repository is the Homebrew tap for
[Base](https://github.com/codeforester/base).

## Install

Install Base:

```bash
brew trust codeforester/base
brew install codeforester/base/base
basectl setup
basectl update-profile
exec "$SHELL" -l
```

The trust step is required on Homebrew versions that block formulae from
non-official taps until the tap is trusted. It is safe to run again on machines
that already trust `codeforester/base`.

Homebrew installs the Base files, but `basectl setup` still prepares the local
Base runtime under `~/.base.d/base/.venv`.

Install the standalone Bash libraries:

```bash
brew trust codeforester/base
brew install codeforester/base/base-bash-libs
source "$(brew --prefix codeforester/base/base-bash-libs)/libexec/lib/bash/std/lib_std.sh"
```

## Development

```bash
brew tap codeforester/base
brew trust codeforester/base
brew install codeforester/base/base
brew install codeforester/base/base-bash-libs
brew install --build-from-source Formula/base.rb
brew install --build-from-source Formula/base-bash-libs.rb
brew test codeforester/base/base
brew test codeforester/base/base-bash-libs
brew audit --new --formula Formula/base.rb
```

The stable formula installs Base from a versioned release archive. The formula's
`head` stanza remains available for local development against Base's `master`
branch.

## Build Bottles

Build Homebrew bottles from a tap release branch after `Formula/base.rb` points
at a published Base tag. The workflow builds bottle artifacts for Base and its
tap-owned `base-bash-libs` dependency, publishes the tarballs to a tap GitHub
Release named `base-vX.Y.Z`, merges the generated bottle stanzas into the
formula files, and pushes that change back to the same branch.

Use the GitHub Actions **Build Base Bottles** workflow on the tap release
branch, then review the branch diff before merging the tap PR.

After the tap PR is merged, verify the consumer bottle path:

```bash
brew update
brew trust codeforester/base
brew install --force-bottle codeforester/base/base
brew test codeforester/base/base
brew upgrade --no-ask codeforester/base/base
```

Use `brew reinstall --force-bottle codeforester/base/base` when Base is already
installed on the validation host.
