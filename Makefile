.PHONY: build debug run clean

BUILD_DIR ?= build/
CXX ?= g++
CXXFLAGS := -Wall -Wextra -Wpedantic -Wold-style-cast -std=c++20

OBJDIR := temp
EXT ?= .exe

#################################################
# SDL CONFIG
#################################################

SDL_DIR ?= E:/SDL/SDL3

SDL_DEPS := sdl3 sdl3-image sdl3-mixer sdl3-ttf sdl3-shadercross

ifeq ($(SDL_DIR),)
    SDL_FLAGS := $(shell pkg-config --cflags $(SDL_DEPS) 2>/dev/null)
    SDL_LIBS := $(shell pkg-config --libs $(SDL_DEPS) 2>/dev/null)
else
    SDL_FLAGS := -I$(SDL_DIR)/include
    SDL_LIBS := -L$(SDL_DIR)/lib \
                -lSDL3 \
                -lSDL3_image \
                -lSDL3_mixer \
                -lSDL3_ttf \
                -lSDL3_shadercross
endif

UNAME_S := $(shell uname -s 2>/dev/null || echo "Windows")
ifeq ($(UNAME_S), Darwin)
    SDL_LIBS += -Wl,-rpath,@executable_path/../Frameworks
endif

#################################################
# PROJECT
#################################################

INCLUDES := -Iinc -Icommon/inc $(SDL_FLAGS)

SOURCES := \
	$(wildcard src/main.cpp) \
	$(wildcard src/nodes/*.cpp) \
	$(wildcard src/nodes/operations/*.cpp) \
	$(wildcard src/systems/*.cpp) \
	$(wildcard src/VM/*.cpp) \
	$(wildcard src/utils/*.cpp) \
	$(wildcard common/src/values/*.cpp) \
	$(wildcard common/src/*.cpp)

OBJECTS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SOURCES))

#################################################
# BUILD
#################################################

build: CXXFLAGS += -O2
build: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(INCLUDES) $(SDL_LIBS) -o $(BUILD_DIR)Apica$(EXT)

debug: CXXFLAGS += -g -D__APICA_DEBUG__
debug: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(INCLUDES) $(SDL_LIBS) -o $(BUILD_DIR)Apica$(EXT)

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

#################################################
# RUN / CLEAN
#################################################

run:
	cd $(BUILD_DIR) && ./Apica$(EXT)

clean:
	rm -rf $(OBJDIR) Apica$(EXT)