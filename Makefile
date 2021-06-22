
install: build
	cp .build/release/localize /usr/local/bin/localize

build:
	swift build -c release