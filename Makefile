.PHONY: pub-get analyze test

pub-get:
	cd driver && flutter pub get
	cd customer && flutter pub get
	cd admin && flutter pub get

analyze:
	cd driver && flutter analyze
	cd customer && flutter analyze
	cd admin && flutter analyze

test:
	cd driver && flutter test
	cd customer && flutter test
	cd admin && flutter test
