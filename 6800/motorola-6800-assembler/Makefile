
APP        = as

CC         = gcc
LINKER     = gcc -o
RM         = rm -f
MKDIR      = mkdir -p
RMDIR      = rmdir

SRCDIR     = src
OBJDIR     = obj
BINDIR     = bin
TESTDIR    = test

CFLAGS    :=
LFLAGS    :=
DEPS      := $(SRCDIR)/as.h $(SRCDIR)/do.h $(SRCDIR)/eval.h $(SRCDIR)/globals.h
DEPS      += $(SRCDIR)/pseudo.h $(SRCDIR)/table.h $(SRCDIR)/ffwd.h
DEPS      += $(SRCDIR)/output.h $(SRCDIR)/symtab.h $(SRCDIR)/util.h
OBJ_as0   := $(OBJDIR)/do0.o $(OBJDIR)/table0.o
OBJ_as1   := $(OBJDIR)/do1.o $(OBJDIR)/table1.o
OBJ_as4   := $(OBJDIR)/do4.o $(OBJDIR)/table4.o
OBJ_as5   := $(OBJDIR)/do5.o $(OBJDIR)/table5.o
OBJ_as9   := $(OBJDIR)/do9.o $(OBJDIR)/table9.o
OBJ_as11  := $(OBJDIR)/do11.o $(OBJDIR)/table11.o
OBJ       := $(OBJDIR)/as.o $(OBJDIR)/eval.o $(OBJDIR)/symtab.o
OBJ       += $(OBJDIR)/util.o $(OBJDIR)/ffwd.o $(OBJDIR)/output.o $(OBJDIR)/pseudo.o
OBJ       += $(OBJDIR)/globals.o
DIRS      := $(OBJDIR) $(BINDIR)

.PHONEY: all
all: directories as0 as1 as4 as5 as9 as11

as0: directories $(BINDIR)/$(APP)0

as1: directories $(BINDIR)/$(APP)1

as4: directories $(BINDIR)/$(APP)4

as5: directories $(BINDIR)/$(APP)5

as9: directories $(BINDIR)/$(APP)9

as11: directories $(BINDIR)/$(APP)11

.PHONEY: directories
directories: $(DIRS)

$(OBJDIR):
	@$(MKDIR) $(OBJDIR)

$(BINDIR):
	@$(MKDIR) $(BINDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)
	@echo "Compiled "$@" successfully!"

$(BINDIR)/$(APP)0: $(OBJ) $(OBJ_as0)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

$(BINDIR)/$(APP)1: $(OBJ) $(OBJ_as1)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

$(BINDIR)/$(APP)4: $(OBJ) $(OBJ_as4)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

$(BINDIR)/$(APP)5: $(OBJ) $(OBJ_as5)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

$(BINDIR)/$(APP)9: $(OBJ) $(OBJ_as9)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

$(BINDIR)/$(APP)11: $(OBJ) $(OBJ_as11)
	$(LINKER) $@ $^ $(CFLAGS)
	@echo "Linking "$@" complete!"

.PHONEY: clean
clean:
	$(RM) $(OBJDIR)/*.o
	@echo "Derived objects removed!"

.PHONEY: realclean
realclean: clean
	@$(RM) $(BINDIR)/* $(TESTDIR)/*.s19
	@$(RMDIR) $(OBJDIR)
	@$(RMDIR) $(BINDIR)
	@echo "Binaries removed!"

