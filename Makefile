run:
	cd public/javascripts; coffee -b -c draw.coffee
	ruby gyaki.rb
push:
	git push git@github.com:masui/Gyaki.git
	git push pitecan.com:/home/masui/git/Gyaki.git
