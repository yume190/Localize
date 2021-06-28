
install: build
	cp .build/release/localize /usr/local/bin/localize

build:
	swift build -c release

gen:
	localize --it csv -i Tests/LocalizeTests/Resource/data.csv --ios --ios_code --android -o Temp
