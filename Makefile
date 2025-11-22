.PHONY: debug-build debug-run build test

BUILD :=	build
TARGET :=	# Apica destination target
EXT :=		# Apica file extension
ARGS :=		# Apica command-line arguments


debug-build:
	zig build -p $(BUILD)
	mv $(BUILD)/bin/* $(BUILD)
	rmdir $(BUILD)/bin

debug-run:
	cd $(BUILD) && ./Apica.exe $(ARGS)


build:
	zig build --release=fast -p $(BUILD) -Dtarget=$(TARGET)
	mv $(BUILD)/bin/* $(BUILD)
	mv $(BUILD)/Apica$(EXT) $(BUILD)/$(TARGET)-Apica$(EXT)
	rmdir $(BUILD)/bin
	rm -f $(BUILD)/*.pdb

test:
	$(foreach file,$(wildcard src/test_*.zig),zig test $(file);)