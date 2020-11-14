PREFIX:=/usr/bin

install: ./git-factor ./isolate
	/usr/bin/install -o 0 -g 0 -m 555 -t "$(PREFIX)" ./git-factor
	/usr/bin/install -o 0 -g 0 -m 555 -t "$(PREFIX)" ./isolate
