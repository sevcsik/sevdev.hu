cabalver=1.24.0.0
site=.stack-work/dist/x86_64-linux/Cabal-$(cabalver)/build/site/site 

all: _site/index.html

$(site):
	stack build

_site/index.html: $(site)
	$(site) build

clean:
	rm -rf _site
	rm -rf .stack-work
