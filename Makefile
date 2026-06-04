MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

SDKPATH ?= ./iPhoneOS.sdk

TARGET      = sockH3lix_exec
APP_BUNDLE  = sockH3lix.app
IPA_NAME    = sockH3lix.ipa

CC      = clang
CXX     = clang++
LD      = ld64
LDID   ?= true

TARGET_TRIPLE = arm64-apple-ios10.0

CFLAGS_COMMON = -isysroot $(SDKPATH) -O2 -DIMG4TOOL_NOMAIN -F. -fexceptions \
                -IsockH3lix -Iliboffsetfinder32 -Iliboffsetfinder64 -Iimg4tool \
				-Iplist -I. -IIOKit.framework/Headers -Wno-\#warnings

CFLAGS = -target $(TARGET_TRIPLE) $(CFLAGS_COMMON)

CXX_HEADERS = -nostdinc++ -isystem $(SDKPATH)/usr/include/c++/v1
CXXFLAGS = $(CFLAGS) -std=gnu++14 -stdlib=libc++ $(CXX_HEADERS)

LDFLAGS = -target $(TARGET_TRIPLE) -isysroot $(SDKPATH) -F. -LsockH3lix/libs \
          -fuse-ld=$(LD) \
          -framework Foundation -framework UIKit -framework IOKit \
          -lplist -lplist++ -limg4tool

C_SRCS = \
    liboffsetfinder32/patchfinder32.c \
    sockH3lix/exploit_utilities.c \
    sockH3lix/iosurface.c \
    sockH3lix/sock_port_exploit.c \
    sockH3lix/kernel_memory.c

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

OBJS = $(C_SRCS:.c=.c.o) \
       $(OBJC_SRCS:.m=.m.o) \
       $(OBJCXX_SRCS:.mm=.mm.o) \
       $(CXX_SRCS:.cpp=.cpp.o)

.PHONY: all bundle ipa clean

all: ipa

%.c.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@printf "	CC	$<\n"

%.m.o: %.m
	@$(CC) $(CFLAGS) -c $< -o $@
	@printf "	OBJCC	$<\n"

%.mm.o: %.mm
	@$(CXX) $(CXXFLAGS) -c $< -o $@
	@printf "	OBJCXX	$<\n"

%.cpp.o: %.cpp
	@$(CXX) $(CXXFLAGS) -c $< -o $@
	@printf "	CXX	$<\n"

$(TARGET): $(OBJS)
	@$(CXX) $(LDFLAGS) -o $@ $^
	@printf "	LD	$(TARGET)\n"

bundle: $(TARGET)
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)
	@printf "	COPY	$(TARGET)\n"
	@cp $(TARGET) $(APP_BUNDLE)/sockH3lix
	@printf "	COPY	sockH3lix/Info.plist\n"
	@cp sockH3lix/Info.plist $(APP_BUNDLE)/
	@printf "	COPY	icon.png\n"
	@cp icon.png $(APP_BUNDLE)
	@printf "	COPY	README.md\n"
	@cp README.md $(APP_BUNDLE)
	@printf "	COPY	sockH3lix/jbresources/Cydia-10.tar\n"
	@cp sockH3lix/jbresources/Cydia-10.tar $(APP_BUNDLE)
	@printf "	COPY	sockH3lix/jbresources/launchctl\n"
	@cp sockH3lix/jbresources/launchctl $(APP_BUNDLE)
	@printf "	COPY	sockH3lix/jbresources/tar\n"
	@cp sockH3lix/jbresources/tar $(APP_BUNDLE)
	@printf "	COPY	graphics/Default*.png\n"
	@cp graphics/Default*.png $(APP_BUNDLE)
	@printf "	COPY	AppIcons\n"
	@cp sockH3lix/Assets.xcassets/AppIcon.appiconset/*.png $(APP_BUNDLE)/ 2>/dev/null || true
	@printf "	COPY	sockH3lix/ui resources\n"
	@cp -R "sockH3lix/ui resources" $(APP_BUNDLE)/
	@printf "	LDID	$(APP_BUNDLE)/sockH3lix\n"
	@$(LDID) -S $(APP_BUNDLE)/sockH3lix

ipa: bundle
	@printf "	IPA	$(IPA_NAME)\n"
	@rm -rf Payload $(IPA_NAME)
	@mkdir -p Payload
	@cp -R $(APP_BUNDLE) Payload/
	@zip -q -r $(IPA_NAME) Payload
	@rm -rf Payload

clean:
	@printf "	CLEAN\n"
	@rm -f $(OBJS)
	@rm -f $(TARGET)
	@rm -rf $(APP_BUNDLE) Payload $(IPA_NAME)
