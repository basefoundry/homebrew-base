# Homebrew Tap For Base

This repository is the Homebrew tap for
[Base](https://github.com/codeforester/base).

## Install

```bash
brew install codeforester/base/basectl
basectl setup
basectl update-profile
exec "$SHELL" -l
```

Homebrew installs the Base files, but `basectl setup` still prepares the local
Base runtime under `~/.base.d/base/.venv`.

## Development

```bash
brew tap codeforester/base
brew install --build-from-source Formula/basectl.rb
brew test basectl
brew audit --new --formula Formula/basectl.rb
```

This tap currently follows Base's `master` branch. After Base starts publishing
release tarballs, the formula should switch to a versioned URL plus SHA256.
