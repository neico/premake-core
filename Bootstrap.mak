BUILD_DIR = build/bootstrap
LUA_DIR = contrib/lua/src

SRC		= src/host/*.c			\
		$(LUA_DIR)/lapi.c		\
		$(LUA_DIR)/lcode.c		\
		$(LUA_DIR)/ldebug.c		\
		$(LUA_DIR)/ldump.c		\
		$(LUA_DIR)/lgc.c		\
		$(LUA_DIR)/liolib.c		\
		$(LUA_DIR)/lmathlib.c	\
		$(LUA_DIR)/loadlib.c	\
		$(LUA_DIR)/lopcodes.c	\
		$(LUA_DIR)/lparser.c	\
		$(LUA_DIR)/lstring.c	\
		$(LUA_DIR)/ltable.c		\
		$(LUA_DIR)/ltm.c		\
		$(LUA_DIR)/lvm.c		\
		$(LUA_DIR)/lbaselib.c	\
		$(LUA_DIR)/ldblib.c		\
		$(LUA_DIR)/ldo.c		\
		$(LUA_DIR)/lfunc.c		\
		$(LUA_DIR)/linit.c		\
		$(LUA_DIR)/llex.c		\
		$(LUA_DIR)/lmem.c		\
		$(LUA_DIR)/lobject.c	\
		$(LUA_DIR)/loslib.c		\
		$(LUA_DIR)/lstate.c		\
		$(LUA_DIR)/lstrlib.c	\
		$(LUA_DIR)/ltablib.c	\
		$(LUA_DIR)/lundump.c	\
		$(LUA_DIR)/lzio.c

PLATFORM = none
default: $(PLATFORM)

none:
	@echo "Please do"
	@echo "   nmake -f Bootstrap.mak windows"
	@echo "or"
	@echo "   CC=mingw32-gcc mingw32-make -f Bootstrap.mak mingw"
	@echo "or"
	@echo "   make -f Bootstrap.mak HOST_PLATFORM"
	@echo "where HOST_PLATFORM is one of these:"
	@echo "   osx linux"

mingw: $(SRC)
	mkdir -p $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -I"$(LUA_DIR)" $? -lole32
	./$(BUILD_DIR)/premake_bootstrap embed
	./$(BUILD_DIR)/premake_bootstrap --os=windows --to=$(BUILD_DIR) gmake
	$(MAKE) -C $(BUILD_DIR)

osx: $(SRC)
	mkdir -p $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_MACOSX -I"$(LUA_DIR)" -framework CoreServices $?
	./$(BUILD_DIR)/premake_bootstrap embed
	./$(BUILD_DIR)/premake_bootstrap --to=$(BUILD_DIR) gmake
	$(MAKE) -C $(BUILD_DIR) -j`getconf _NPROCESSORS_ONLN`

linux: $(SRC)
	mkdir -p $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/premake_bootstrap -DPREMAKE_NO_BUILTIN_SCRIPTS -DLUA_USE_POSIX -DLUA_USE_DLOPEN -I"$(LUA_DIR)" $? -lm -ldl -lrt
	./$(BUILD_DIR)/premake_bootstrap embed
	./$(BUILD_DIR)/premake_bootstrap --to=$(BUILD_DIR) gmake
	$(MAKE) -C $(BUILD_DIR) -j`getconf _NPROCESSORS_ONLN`

windows: $(SRC)
	if not exist $(BUILD_DIR:/=\) (mkdir $(BUILD_DIR:/=\))
	$(CC) /Fo.\$(BUILD_DIR:/=\)\ /Fe.\$(BUILD_DIR:/=\)\premake_bootstrap /DPREMAKE_NO_BUILTIN_SCRIPTS /I"$(LUA_DIR)" user32.lib ole32.lib $?
	.\$(BUILD_DIR:/=\)\premake_bootstrap embed
!	ifdef VS140COMNTOOLS
		.\$(BUILD_DIR:/=\)\premake_bootstrap --to=$(BUILD_DIR) vs2015
!	elseifdef VS120COMNTOOLS
		.\$(BUILD_DIR:/=\)\premake_bootstrap --to=$(BUILD_DIR) vs2013
!	elseifdef VS110COMNTOOLS
		.\$(BUILD_DIR:/=\)\premake_bootstrap --to=$(BUILD_DIR) vs2012
!	elseifdef VS100COMNTOOLS
		.\$(BUILD_DIR:/=\)\premake_bootstrap --to=$(BUILD_DIR) vs2010
!	endif
	devenv .\$(BUILD_DIR:/=\)\Premake5.sln /Build Release
