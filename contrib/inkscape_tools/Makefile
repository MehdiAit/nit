all:
	mkdir -p bin
	../../bin/nitc --dir bin src/svg_to_png_and_nit.nit src/svg_to_icons.nit

check: test-tinks test-app

test-app: bin/svg_to_png_and_nit
	make -C tests/app

test-tinks: bin/svg_to_png_and_nit
	mkdir -p tests/tinks/images
	bin/svg_to_png_and_nit --assets tests/tinks/ --src tests/tinks/ ../tinks/art/drawing.svg

.PHONY: bin/svg_to_png_and_nit
