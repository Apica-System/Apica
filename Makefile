.PHONY: build debug run clean

CXX ?= g++
CXXFLAGS := -Wall -Wextra -Wpedantic -Wold-style-cast -std=c++20

OBJDIR := temp
EXT ?= .exe

#################################################
# SDL CONFIG
#################################################

SDL_DIR ?= E:/SDL/SDL3

# Noms des paquets pour pkg-config (CI)
SDL_DEPS := sdl3 sdl3-image sdl3-mixer sdl3-ttf

ifeq ($(SDL_DIR),)
    # =========================================================
    # CONFIGURATION CI (GitHub Actions) -> 100% STATIQUE
    # =========================================================
    SDL_FLAGS := $(shell pkg-config --cflags $(SDL_DEPS) 2>/dev/null)
    SDL_LIBS := $(shell pkg-config --static --libs $(SDL_DEPS) 2>/dev/null)
    
    # Force l'intégration de tout le monde en CI
    STATIC_LDFLAGS := -static -static-libgcc -static-libstdc++
else
    # =========================================================
    # CONFIGURATION LOCALE (Ton PC) -> DYNAMIQUE (Pas d'erreur)
    # =========================================================
    SDL_FLAGS := -I$(SDL_DIR)/include
    SDL_LIBS := -L$(SDL_DIR)/lib \
                -lSDL3 \
                -lSDL3_image \
                -lSDL3_mixer \
                -lSDL3_ttf
                
    # Pas de flags statiques en local pour éviter que 'ld' ne râle
    STATIC_LDFLAGS := 
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
	$(wildcard src/utils/*.cpp) \
	$(wildcard common/src/values/*.cpp) \
	$(wildcard common/src/*.cpp)

OBJECTS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SOURCES))

#################################################
# BUILD
#################################################

build: CXXFLAGS += -O2
build: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(INCLUDES) $(STATIC_LDFLAGS) $(SDL_LIBS) -o Apica$(EXT)

debug: CXXFLAGS += -g -D__APICA_DEBUG__
debug: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(INCLUDES) $(STATIC_LDFLAGS) $(SDL_LIBS) -o Apica$(EXT)

#################################################
# RULES
#################################################

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

#################################################
# RUN / CLEAN
#################################################

run:
	./Apica$(EXT)

clean:
	rm -rf $(OBJDIR) Apica$(EXT)