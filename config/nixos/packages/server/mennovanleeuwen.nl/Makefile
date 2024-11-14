build:
	cd ../; docker compose down;

	rm -rf dist/
	mkdir dist

	pandoc index.md --template=template.html --metadata title="Resume - Menno Cornelis van Leeuwen" -o dist/index.html 
	pandoc index.md -o dist/index.pdf

	mkdir dist/css/
	cp css/stylesheet.css dist/css/stylesheet.css
	cd ../; docker compose up -d;