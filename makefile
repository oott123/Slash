all:
	npm install
	cd browser
	bower install
	cd ..
	gulp
watch:
	gulp watch
test:
	mocha --compilers coffee:coffee-script/register