.PHONY: all build release dev install uninstall clean test

all: build

install:
	@printf "\033[1;34m==>\033[0m Installing...\n"
	@merodi build --release
	@rsync -av src/static/ /srv/www/git.pi66.xyz/public/static/

build:
	@printf "\033[1;34m==>\033[0m Building...\n"
	@merodi build

release:
	@printf "\033[1;34m==>\033[0m Building release...\n"
	@merodi build --release

dev:
	@printf "\033[1;34m==>\033[0m Starting development server...\n"
	@cp -r src/static draft/
	@merodi watch & live-server draft --host=0.0.0.0 --port=3000 --verbose

clean:
	@printf "\033[1;34m==>\033[0m Cleaning...\n"
	@merodi clean
