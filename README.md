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
