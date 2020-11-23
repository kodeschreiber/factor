PREFIX:=/usr/bin

install: ./git-factor
	/usr/bin/install -o 0 -g 0 -m 555 -t "$(PREFIX)" ./git-factor
	sed -i -e '/%doc%/{r README.md' -e 'd}' "$(PREFIX)/git-factor"