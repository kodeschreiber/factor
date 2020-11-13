PREFIX:=/usr/bin

subtree-fix:
	chmod +x /usr/share/doc/git/contrib/subtree/git-subtree.sh
	ln -s /usr/share/doc/git/contrib/subtree/git-subtree.sh /usr/lib/git-core/git-subtree

install: ./factor
	/usr/bin/install -o 0 -g 0 -m 555 -t $PREFIX $<
	
