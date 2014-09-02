# git pull origin master;
echo "hello";

function zpreztoInit {
	cp .zprezto/runcoms/z* .
	for f in z*
	do
		mv $f .$f
	done
}

function zpreztoDestroy {
	rm -f .zlogin
	rm -f .zlogout
	rm -f .zpreztorc
	rm -f .zshenv
	rm -f .zshrc
	rm -f .zprofile
}

function doIt() {
	zpreztoInit;
	unset zpreztoInit;
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" -avh --no-perms . ~;
	chsh -s /bin/zsh
	zpreztoDestroy;
	unset zpreztoDestroy;
}

read "brave?This may overwrite existing files in your home directory. Are you sure? (y/n) "
echo "";
if [[ $brave =~ ^[Yy]$ ]]; then
	doIt;
fi;

unset doIt;