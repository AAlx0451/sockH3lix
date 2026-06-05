MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

SDKPATH ?= ./iPhoneOS.sdk

OBJ_DIR     = obj
TARGET      = $(OBJ_DIR)/bin/sockH3lix
APP_BUNDLE  = sockH3lix.app
IPA_NAME    = sockH3lix.ipa

CC     ?= clang
CXX    ?= clang++
LD     ?= ld64
LIPO   ?= lipo
LDID   ?= true

TRIPLE_arm64 = arm64-apple-ios10.0
TRIPLE_armv7 = armv7-apple-ios10.0

CFLAGS_COMMON = -isysroot $(SDKPATH) -O2 -DIMG4TOOL_NOMAIN -F. -fexceptions \
                -IsockH3lix -Iliboffsetfinder32 -Iliboffsetfinder64 -Ivendor/include \
                -I. -IIOKit.framework/Headers -Wno-\#warnings \
                -MMD -MP

CXX_HEADERS = -nostdinc++ -isystem $(SDKPATH)/usr/include/c++/v1
CXXFLAGS_COMMON = $(CFLAGS_COMMON) -std=gnu++14 -stdlib=libc++ $(CXX_HEADERS)

LDFLAGS_COMMON = -isysroot $(SDKPATH) -F. \
                 -fuse-ld=$(LD) \
                 -framework Foundation -framework UIKit -framework IOKit \
                 -lcompression

C_SRCS = \
    liboffsetfinder32/patchfinder32.c \
    sockH3lix/exploit_utilities.c \
    sockH3lix/iosurface.c \
    sockH3lix/sock_port_exploit.c \
    sockH3lix/kernel_memory.c

VENDOR_SRCS = \
    vendor/src/base64.c \
    vendor/src/bplist.c \
    vendor/src/bytearray.c \
    vendor/src/hashtable.c \
    vendor/src/img4.c \
    vendor/src/img4tool.c \
    vendor/src/iterator.c \
    vendor/src/list.c \
    vendor/src/lzssdec.c \
    vendor/src/node.c \
    vendor/src/node_iterator.c \
    vendor/src/node_list.c \
    vendor/src/plist.c \
    vendor/src/ptrarray.c \
    vendor/src/time64.c \
    vendor/src/xplist.c

OBJC_SRCS = \
    sockH3lix/main.m \
    sockH3lix/AppDelegate.m \
    sockH3lix/ViewController.m \
    sockH3lix/offsets.m \
    sockH3lix/kutil.m

OBJCXX_SRCS = \
    sockH3lix/offsets.mm \
    sockH3lix/jailbreak.mm

CXX_SRCS = \
    liboffsetfinder64/liboffsetfinder64.cpp \
    liboffsetfinder64/insn.cpp \
    liboffsetfinder64/exception.cpp \
    liboffsetfinder64/patch.cpp \
    liboffsetfinder32/lzssdec.cpp \
    liboffsetfinder32/img3dec.cpp \
    liboffsetfinder32/offsetfinder32.cpp

SRCS_LIST = $(C_SRCS:.c=.c.o) \
            $(VENDOR_SRCS:.c=.c.o) \
            $(OBJC_SRCS:.m=.m.o) \
            $(OBJCXX_SRCS:.mm=.mm.o) \
            $(CXX_SRCS:.cpp=.cpp.o)

OBJS_arm64 = $(addprefix $(OBJ_DIR)/arm64/, $(SRCS_LIST))
OBJS_armv7 = $(addprefix $(OBJ_DIR)/armv7/, $(SRCS_LIST))

DEPS = $(OBJS_arm64:.o=.d) $(OBJS_armv7:.o=.d)

.PHONY: all bundle ipa clean

all: ipa

define ARCH_TEMPLATE
$$(OBJ_DIR)/$(1)/%.c.o: %.c
	@mkdir -p $$(dir $$@)
	@$$(CC) -target $$(TRIPLE_$(1)) $$(CFLAGS_COMMON) -c $$< -o $$@
	@printf "	%-8s [%-5s] %s\n" "CC" "$(1)" "$$<"

$$(OBJ_DIR)/$(1)/%.m.o: %.m
	@mkdir -p $$(dir $$@)
	@$$(CC) -target $$(TRIPLE_$(1)) $$(CFLAGS_COMMON) -c $$< -o $$@
	@printf "	%-8s [%-5s] %s\n" "OBJCC" "$(1)" "$$<"

$$(OBJ_DIR)/$(1)/%.mm.o: %.mm
	@mkdir -p $$(dir $$@)
	@$$(CXX) -target $$(TRIPLE_$(1)) $$(CXXFLAGS_COMMON) -c $$< -o $$@
	@printf "	%-8s [%-5s] %s\n" "OBJCXX" "$(1)" "$$<"

$$(OBJ_DIR)/$(1)/%.cpp.o: %.cpp
	@mkdir -p $$(dir $$@)
	@$$(CXX) -target $$(TRIPLE_$(1)) $$(CXXFLAGS_COMMON) -c $$< -o $$@
	@printf "	%-8s [%-5s] %s\n" "CXX" "$(1)" "$$<"

$$(OBJ_DIR)/$(1)/bin/sockH3lix: $$(OBJS_$(1))
	@mkdir -p $$(dir $$@)
	@$$(CXX) -target $$(TRIPLE_$(1)) $$(LDFLAGS_COMMON) -o $$@ $$^
	@printf "	%-8s [%-5s] %s\n" "LD" "$(1)" "$$@"
endef

$(eval $(call ARCH_TEMPLATE,arm64))
$(eval $(call ARCH_TEMPLATE,armv7))

$(TARGET): $(OBJ_DIR)/arm64/bin/sockH3lix $(OBJ_DIR)/armv7/bin/sockH3lix
	@mkdir -p $(dir $@)
	@$(LIPO) -create -output $@ $^
	@printf "	%-17s %s\n" "LIPO" "$(TARGET)"

bundle: $(TARGET)
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "$(TARGET)"
	@cp $(TARGET) $(APP_BUNDLE)/sockH3lix
	@printf "	%-17s %s\n" "COPY" "sockH3lix/Info.plist"
	@cp sockH3lix/Info.plist $(APP_BUNDLE)/
	@printf "	%-17s %s\n" "COPY" "icon.png"
	@cp icon.png $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "README.md"
	@cp README.md $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "sockH3lix/jbresources/Cydia-10.tar"
	@cp sockH3lix/jbresources/Cydia-10.tar $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "sockH3lix/jbresources/launchctl"
	@cp sockH3lix/jbresources/launchctl $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "sockH3lix/jbresources/tar"
	@cp sockH3lix/jbresources/tar $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "graphics/Default*.png"
	@cp graphics/Default*.png $(APP_BUNDLE)
	@printf "	%-17s %s\n" "COPY" "AppIcons"
	@cp sockH3lix/Assets.xcassets/AppIcon.appiconset/*.png $(APP_BUNDLE)/ 2>/dev/null || true
	@printf "	%-17s %s\n" "COPY" "sockH3lix/ui resources"
	@cp -R "sockH3lix/ui resources" $(APP_BUNDLE)/
	@printf "	%-17s %s\n" "LDID" "$(APP_BUNDLE)/sockH3lix"
	@$(LDID) -S $(APP_BUNDLE)/sockH3lix

ipa: bundle
	@printf "	%-17s %s\n" "IPA" "$(IPA_NAME)"
	@rm -rf Payload $(IPA_NAME)
	@mkdir -p Payload
	@cp -R $(APP_BUNDLE) Payload/
	@zip -q -r $(IPA_NAME) Payload
	@rm -rf Payload

clean:
	@printf "	%-17s\n" "CLEAN"
	@rm -rf $(OBJ_DIR)
	@rm -rf $(APP_BUNDLE) Payload $(IPA_NAME)

-include $(DEPS)
