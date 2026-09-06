# Distribution Package Installation

## Homebrew (macOS / Linuxbrew)

```bash
# Add tap (once Afiq adds the tap)
brew tap afiqandico13/pilgrims https://github.com/afiqandico13/homebrew-pilgrims

# Install
brew install pilgrims

# Verify
pilgrims --help
```

For local testing without a tap:
```bash
brew install --build-from-source packaging/pilgrims.rb
```

## Scoop (Windows)

```bash
# Add bucket (once bucket exists)
scoop bucket add pilgrims https://github.com/afiqandico13/scoop-pilgrims

# Install
scoop install pilgrims

# Verify
pilgrims --help
```

For local testing:
```bash
scoop install packaging/pilgrims.json
```

## AUR (Arch / Manjaro)

```bash
# Using yay
yay -S pilgrims-v17

# Or manual
git clone https://aur.archlinux.org/pilgrims-v17.git
cd pilgrims-v17
makepkg -si
```

## Docker (any platform)

```bash
docker pull ghcr.io/afiqandico13/pilgrims-v17:latest
docker run --rm ghcr.io/afiqandico13/pilgrims-v17:latest --help
```

## From source (universal)

```bash
git clone https://github.com/afiqandico13/pilgrims-v17.git
cd pilgrims-v17
chmod +x pilgrims.sh
./pilgrims.sh --help
```
