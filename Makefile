#--- Default player will be huge tracker HUGETRACKER/GBT_PLAYER
ifeq ($(DEFAULT_SPRITES_SIZE), )
	DEFAULT_SPRITES_SIZE = SPRITES_8x16
endif

ifeq ($(MUSIC_PLAYER), )
	MUSIC_PLAYER = HUGETRACKER
endif

BUILDDIR = build
OBJDIR = $(BUILDDIR)
OBJDIR_RES = $(BUILDDIR)/res
OBJDIR_ZGB = $(BUILDDIR)/zgb
BINDIR = bin

SDCC = sdcc
SDASGB = sdasgb
SDLDGB = sdldgb
MAKEBIN = makebin
IHXCHECK = ihxcheck
PNG2ASSET = png2asset
BANKPACK = bankpack

GBR2C = gbr2c
GBR2PNG = gbr2png
GBM2C = gbm2c
MOD2GBT = mod2gbt
UGE2SOURCE = uge2source

CFLAGS += -Wa-n -mgbz80 --no-std-crt0 --fsigned-char --use-stdout -Dnonbanked= -I$(GBDK_PATH)/include -D__PORT_gbz80 -D__TARGET_gb -I$(GBDK_PATH)/include/asm $(BUILD_DEFS) -I./include -I$(ZGB_PATH)/include
CFLAGS += -DFILE_NAME=$(basename $(<F)) -MMD

#since I am placing my OAM mirror at the end of the ram (0xDF00-0xDFFF) I need to move the stack to 0xDEFF
LNAMES=-g _shadow_OAM=0xC000 -g .STACK=0xDEFF -g .refresh_OAM=0xFF80 -b _DATA=0xc0a0 -b _CODE=0x0200
LFLAGS=-n -m -j -w -i -k $(GBDK_PATH)/lib/small/asxxxx/gbz80/ -l gbz80.lib -k $(GBDK_PATH)/lib/small/asxxxx/gb/ -l gb.lib -k $(OBJDIR_ZGB)/ -l zgb.lib $(LNAMES)

ifneq ($(strip $(N_BANKS)),)
	BINFLAGS += -yt 1 -yo $(N_BANKS)
endif

# DMG/Color flags
EXTENSION = gb
ifneq (,$(findstring color,$(MAKECMDGOALS)))
	BINFLAGS += -yc
	CFLAGS += -DCGB
	EXTENSION = gbc
endif

# SGB flags
ifneq ($(wildcard ./res/borders), )
	BINFLAGS +=-ys
endif

# gbt-player/Hugetracker flags
ifeq ($(MUSIC_PLAYER), HUGETRACKER)
	CFLAGS += -DMUSIC_DRIVER_HUGE
else
	CFLAGS += -DMUSIC_DRIVER_GBT
endif

ifeq ($(DEFAULT_SPRITES_SIZE), SPRITES_8x16)
	CFLAGS += -DLCDCF_OBJDEFAULT=LCDCF_OBJ16
	CFLAGSPNG2ASSET += -spr8x16
else
	CFLAGS += -DLCDCF_OBJDEFAULT=LCDCF_OBJ8
	CFLAGSPNG2ASSET += -spr8x8
endif

ASMS_ZGB    = $(foreach dir,$(ZGB_PATH)/src,$(notdir $(wildcard $(dir)/*.s)))
CLASSES_ZGB = $(foreach dir,$(ZGB_PATH)/src,$(notdir $(wildcard $(dir)/*.c)))
ASMS        = $(foreach dir,./src,$(notdir $(wildcard $(dir)/*.s))) 
CLASSES     = $(foreach dir,./src,$(notdir $(wildcard $(dir)/*.c))) 
GBRS        = $(foreach dir,./res,$(notdir $(wildcard $(dir)/*.gbr)))
GBMS        = $(foreach dir,./res,$(notdir $(wildcard $(dir)/*.gbm)))
PNGS        = $(foreach dir,./res,$(notdir $(wildcard $(dir)/*.png)))
SPRITES     = $(foreach dir,./res/sprites,$(notdir $(wildcard $(dir)/*.gbr)))
SPRITES_PNG = $(foreach dir,./res/sprites,$(notdir $(wildcard $(dir)/*.png)))
SGB_BORDERS = $(foreach dir,./res/borders,$(notdir $(wildcard $(dir)/*.png)))
ifeq ($(MUSIC_PLAYER), GBT_PLAYER)
	MUSICS_MOD = $(foreach dir,./res/music,$(notdir $(wildcard $(dir)/*.mod)))
else
	MUSICS_UGE = $(foreach dir,./res/music,$(notdir $(wildcard $(dir)/*.uge)))
endif
OBJS = $(GBMS:%.gbm=$(OBJDIR_RES)/%.gbm.o) $(GBRS:%.gbr=$(OBJDIR_RES)/%.gbr.o) $(SPRITES:%.gbr=$(OBJDIR_RES)/sprites/%.gbr.o) $(SPRITES_PNG:%.png=$(OBJDIR_RES)/sprites/%.png.o) $(SGB_BORDERS:%.png=$(OBJDIR_RES)/borders/%.png.o) $(PNGS:%.png=$(OBJDIR_RES)/%.png.o) $(MUSICS_MOD:%.mod=$(OBJDIR_RES)/%.mod.o) $(MUSICS_UGE:%.uge=$(OBJDIR_RES)/%.uge.o) $(ASMS:%.s=$(OBJDIR)/%.o) $(CLASSES:%.c=$(OBJDIR)/%.o)
OBJS_ZGB = $(ASMS_ZGB:%.s=$(OBJDIR_ZGB)/%.o) $(CLASSES_ZGB:%.c=$(OBJDIR_ZGB)/%.o) $(OBJ_DIR_ZGB)
OBJS_ZGB_LIB = $(subst $(subst ,, ),\n,$(ASMS_ZGB:%.s=%.o) $(CLASSES_ZGB:%.c=%.o))

RELS = $(OBJS:%.o=%.rel)

#prevent gbr2c and gbm2c intermediate files from being deleted
.SECONDARY: $(GBMS:%.gbm=$(OBJDIR_RES)/%.gbm.c) $(GBRS:%.gbr=$(OBJDIR_RES)/%.gbr.c) $(SPRITES:%.gbr=$(OBJDIR_RES)/sprites/%.gbr.c) $(SPRITES_PNG:%.png=$(OBJDIR_RES)/sprites/%.png.c) $(SGB_BORDERS:%.png=$(OBJDIR_RES)/borders/%.png.c) $(PNGS:%.png=$(OBJDIR_RES)/%.png.c) $(MUSICS_MOD:%.mod=$(OBJDIR_RES)/%.mod.c) $(MUSICS_UGE:%.uge=$(OBJDIR_RES)/%.uge.c)

#dependencies -------------------------------------------------------------------------------------------
# option -MMD will generate .d files that can be included here for dependency checking (we can skip this on clean)
ifneq ($(MAKECMDGOALS),clean)
-include $(CLASSES:%.c=$(OBJDIR)/%.d) 
-include $(CLASSES_ZGB:%.c=$(OBJDIR_ZGB)/%.d)
endif
#---------------------------------------------------------------------------------------------------------

#folders---------------------------------------------
$(BINDIR):
	@echo Creating folder $(BINDIR)
	@mkdir $(BINDIR)
	
$(OBJDIR):
	@echo Creating folder $(OBJDIR)
	@mkdir $(OBJDIR)

$(OBJDIR_RES):
	@echo Creating folder $(OBJDIR_RES)
	@mkdir $(OBJDIR_RES)

$(OBJDIR_RES)/sprites:
	@echo Creating folder $(OBJDIR_RES)/sprites
	@mkdir $(OBJDIR_RES)/sprites

$(OBJDIR_RES)/borders:
	@echo Creating folder $(OBJDIR_RES)/borders
	@mkdir $(OBJDIR_RES)/borders

#resources---------------------------------------------
#a few notes of this rule (for future me)
#- SECONDEXPANSION is required to create an optional prerrequisite (meta doesn't exist the first time the sprite is created)
#- I have grouped GBR2PNG and PNG2MTSR in the same rule because the others rule had preference otherwise
#- $(@D) is the directory part of the target (http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables)
#- $(<F) is the filename without dir of the first prerrequisite
.SECONDEXPANSION:
$(OBJDIR_RES)/sprites/%.gbr.c: ./res/sprites/%.gbr $$(wildcard ./res/sprites/%.gbr.meta)
	@$(GBR2PNG) $< $(OBJDIR_RES)/sprites
	@$(PNG2ASSET) $(@D)/$(<F).png $(CFLAGSPNG2ASSET) `cat <$(@D)/$(<F).png.meta` -keep_palette_order -use_structs -c $@

.SECONDEXPANSION:
$(OBJDIR_RES)/sprites/%.png.c: ./res/sprites/%.png $$(wildcard ./res/sprites/%.png.meta)
	@$(PNG2ASSET) $< $(CFLAGSPNG2ASSET) `cat <$<.meta` -b 255 -use_structs -c $@

$(OBJDIR_RES)/%.gbm.c: ./res/%.gbm
	@$(GBM2C) $< $(OBJDIR_RES)

$(OBJDIR_RES)/%.gbr.c: ./res/%.gbr
	@$(GBR2C) $< $(OBJDIR_RES)

$(OBJDIR_RES)/borders/%.png.c: ./res/borders/%.png $(OBJDIR_RES)/borders
	@$(PNG2ASSET) $< -b 255 -map -bpp 4 -max_palettes 4 -use_map_attributes -use_structs -pack_mode sgb -c $@

$(OBJDIR_RES)/%.png.c: ./res/%.png $$(wildcard ./res/%.png.meta)
	@$(PNG2ASSET) $< -b 255 -map -noflip -use_structs $(if $(wildcard $<.meta),`cat <$<.meta`) -c $@

$(OBJDIR_RES)/%.mod.c: ./res/music/%.mod
	@$(MOD2GBT) $< $(basename $(basename $(notdir $<)))_mod 255 > /dev/null
	@mv output.c $@

$(OBJDIR_RES)/%.uge.c: ./res/music/%.uge
	@$(UGE2SOURCE) $< -b 255 $(basename $(basename $(notdir $<)))_uge $@

$(OBJDIR_RES)/%.o: $(OBJDIR_RES)/%.c
	@echo compiling resource $<
	@$(SDCC) $(CFLAGS) -c -o $@ $<
	
#ZGB---------------------------------------------	
$(OBJDIR_ZGB):
	@echo Creating folder $(OBJDIR_ZGB)
	@mkdir $(OBJDIR_ZGB)

$(OBJDIR)/zgb/%.o: $(ZGB_PATH)/src/%.s
	@echo compiling $<
	@$(SDASGB) -plosgffn -I"libc" -I$(GBDK_PATH)/lib/small/asxxxx/gb -c -o $@ $<

$(OBJDIR)/zgb/%.o: $(ZGB_PATH)/src/%.c
	@echo compiling $<
	@$(SDCC) $(CFLAGS) -c -o $@ $<

$(OBJDIR_ZGB)/zgb.lib: $(OBJDIR_ZGB) $(OBJS_ZGB) 
	@echo creating zgb.lib
	@rm -f $(OBJDIR_ZGB)/zgb.lib
	@echo "$(OBJS_ZGB_LIB)" >> $(OBJDIR_ZGB)/zgb.lib
	@sed -i -e 's/ /\n/g' $(OBJDIR_ZGB)/zgb.lib

#Project files------------------------------------
$(OBJDIR)/%.o: %.s
	@echo compiling $<
	@$(SDASGB) -plosgffn -I"libc" -c -o $@ $<

$(OBJDIR)/%.o: src/%.c
	@echo compiling $<
	@$(SDCC) $(CFLAGS) -c -o $@ $<	

$(BINDIR)/$(PROJECT_NAME).$(EXTENSION): $(OBJDIR) $(OBJDIR_ZGB)/zgb.lib $(OBJDIR_RES) $(OBJDIR_RES)/sprites $(BINDIR) $(OBJS)
	@echo Linking
	@$(BANKPACK) -ext=.rel -min=1 -yt1 $(OBJS) $(OBJS_ZGB)
	@$(SDLDGB) $(LFLAGS) $(OBJDIR)/rom.ihx $(GBDK_PATH)/lib/small/asxxxx/gb/crt0.o $(RELS) $(ZGB_PATH)/lib/hUGEDriver.obj.o
	@$(IHXCHECK) $(OBJDIR)/rom.ihx -e
	@$(MAKEBIN) -Z $(BINFLAGS) $(OBJDIR)/rom.ihx $(OBJDIR)/rom.$(EXTENSION)
	@cp $(OBJDIR)/rom.$(EXTENSION) $(BINDIR)/$(PROJECT_NAME).$(EXTENSION)
	@rm -f *.adb

.PHONY: clean release debug color

clean:
	@echo Cleaning $(PROJECT_NAME)
	@rm -rf $(BINDIR)
	@rm  -f $(OBJDIR)/*.*
	@rm -rf .map
	@rm -rf .lst
	@rm -rf $(OBJDIR_ZGB)
	@rm -rf $(OBJDIR_RES)

release: CFLAGS += -DNDEBUG
release: $(BINDIR)/$(PROJECT_NAME).$(EXTENSION)

debug: CFLAGS += --debug
debug: LFLAGS += -y
debug: PROJECT_NAME := $(PROJECT_NAME)-debug
debug: $(BINDIR)/$(PROJECT_NAME).$(EXTENSION)

all: release
