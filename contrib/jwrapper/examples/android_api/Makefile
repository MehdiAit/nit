ANDROID_JAR ?= ~/sdks/android-sdk/platforms/android-10/android.jar

all: android_api.nit

java_api.nit:
	mkdir -p tmp
	../../bin/jwrapper -vv -u comment -o java_api.nit -r "^(java|javax|junit|org)" $(ANDROID_JAR) -i ../../../../lib/java/collections.nit --save-model
	echo "+ Disabled functions: `grep '#\s*fun' $@ | wc -l` / `grep '^\s*fun' $@ | wc -l`"

android_api.nit: java_api.nit
	../../bin/jwrapper -vv -u comment -o android_api.nit -r "^(android|com.android)" -i java_api.nit $(ANDROID_JAR) -i ../../../../lib/java/collections.nit -m java_api.jwrapper.bin
	echo "+ Disabled functions: `grep '#\s*fun' $@ | wc -l` / `grep '^\s*fun' $@ | wc -l`"

	# Insert an import between the 2 modules
	sed -i -e "s/import java/import java\nimport java_api/" android_api.nit

# Base wrappers to implement the lib/android/load_image.nit module
bitmap.nit: ../../bin/jwrapper
	../../bin/jwrapper -vv -u comment -o $@ -r "^(android.graphics.Bitmap|java.nio.Buffer|java.nio.ByteBuffer).class$$" \
	-i ../../../../lib/android/assets_and_resources.nit $(ANDROID_JAR) -i ../../../../lib/java/collections.nit

check: android_api.nit
	../../../../bin/nitpick android_api.nit

.PHONY: android_api.nit java_api.nit
