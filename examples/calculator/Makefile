NITC=../../bin/nitc
NITLS=../../bin/nitls

all: bin/calculator bin/test

bin/calculator: $(shell ${NITLS} -M src/calculator.nit linux) ${NITC}
	mkdir -p bin
	${NITC} -o $@ src/calculator.nit -m linux

# ---
# Android

android: bin/calculator.apk

bin/calculator.apk: $(shell ${NITLS} -M src/calculator.nit android) ${NITC} res/drawable-ldpi/icon.png
	mkdir -p bin
	${NITC} -o $@ src/calculator.nit -m ../../lib/android/ui/ -D debug

android-release: $(shell ${NITLS} -M src/calculator.nit android) ${NITC} res/drawable-ldpi/icon.png
	mkdir -p bin
	${NITC} -o bin/calculator.apk src/calculator.nit -m ../../lib/android/ui/ --release

res/drawable-ldpi/icon.png: art/icon.svg ../../contrib/inkscape_tools/bin/svg_to_icons
	mkdir -p res
	../../contrib/inkscape_tools/bin/svg_to_icons art/icon.svg --android --out res/

../../contrib/inkscape_tools/bin/svg_to_icons:
	make -C ../../contrib/inkscape_tools/

android-install: bin/calculator.apk
	adb install -r bin/calculator.apk

# ---
# iOS

bin/calculator.app: $(shell ${NITLS} -M src/calculator.nit ios) ${NITC}
	mkdir -p bin
	${NITC} -o $@ src/calculator.nit -m ios -D debug

# ---
# Tests

bin/test: $(shell ${NITLS} -M src/calculator_test.nit) ${NITC}
	mkdir -p bin
	${NITC} -o $@ src/calculator_test.nit

check: bin/test
	bin/test
