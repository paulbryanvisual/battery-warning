APP_NAME = ADHBattery
BUNDLE_ID = com.bryanpaul.adhbattery
SRC_DIR = ADHBattery/Sources
SOURCES = $(wildcard $(SRC_DIR)/*.swift)
APP_BUNDLE = $(APP_NAME).app
APP_CONTENTS = $(APP_BUNDLE)/Contents
APP_MACOS = $(APP_CONTENTS)/MacOS
APP_RESOURCES = $(APP_CONTENTS)/Resources

SWIFTC = swiftc
SWIFT_FLAGS = -O -parse-as-library -target x86_64-apple-macosx12.0 -target arm64-apple-macosx12.0

all: $(APP_BUNDLE)

$(APP_BUNDLE): $(SOURCES) ADHBattery/Info.plist
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(APP_MACOS)
	@mkdir -p $(APP_RESOURCES)
	$(SWIFTC) $(SWIFT_FLAGS) $(SOURCES) -o $(APP_MACOS)/$(APP_NAME)
	@cp ADHBattery/Info.plist $(APP_CONTENTS)/Info.plist
	@codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "Build complete."

run: $(APP_BUNDLE)
	@open $(APP_BUNDLE)

clean:
	rm -rf $(APP_BUNDLE)
