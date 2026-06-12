# Homebrew Tap For Base

This repository is the Homebrew tap for
[Base](https://github.com/codeforester/base).

## Install

```bash
brew install codeforester/base/base
basectl setup
basectl update-profile
exec "$SHELL" -l
```

Homebrew installs the Base files, but `basectl setup` still prepares the local
Base runtime under `~/.base.d/base/.venv`.

## Development

```bash
brew tap codeforester/base
brew install --formula base
brew install --build-from-source Formula/base.rb
brew test codeforester/base
brew audit --new --formula Formula/base.rb
```

The stable formula installs Base from a versioned release archive. The formula's
`head` stanza remains available for local development against Base's `master`
branch.

## Build Bottles

Build Homebrew bottles from a tap release branch after `Formula/base.rb` points
at a published Base tag. The workflow publishes bottle tarballs to a tap GitHub
Release named `base-vX.Y.Z`, merges the generated bottle stanza into
`Formula/base.rb`, and pushes that change back to the same branch.

Use the GitHub Actions **Build Base Bottles** workflow on the tap release
branch, then review the branch diff before merging the tap PR.

After the tap PR is merged, verify the consumer bottle path:

```bash
brew update
brew install --force-bottle codeforester/base/base
brew test codeforester/base/base
```

Use `brew reinstall --force-bottle codeforester/base/base` when Base is already
installed on the validation host.
