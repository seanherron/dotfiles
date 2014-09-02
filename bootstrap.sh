# git pull origin master;
echo "hello";

function zpreztoInit {
	cp .zprezto/runcoms/z* .
	for f in z*
	do
		mv $f .$f
	done
}

function doIt() {
	zpreztoInit;
	unset zpreztoInit;
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" -avh --no-perms . ~;
	zsh
	chsh -s /bin/zsh
}

read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
echo "";
if [[ $REPLY =~ ^[Yy]$ ]]; then
	doIt;
fi;

unset doIt;