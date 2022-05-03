#
# Compiler flags
#
CC     = gcc
CPPC   = g++
ASMC 	= nasm
CFLAGS = -std=c99
CPPFLAGS = -std=c++11
CXXFLAGS = -MD
ASMFLAGS = -f elf64
CXXLIBS =

#
# Project files
#
SRCDIR = ./src
SRCSCPP = $(wildcard $(SRCDIR)/*.cpp)
SRCSC = $(wildcard $(SRCDIR)/*.c)
SRCSASM = $(wildcard $(SRCDIR)/*.asm)
OBJS = $(patsubst %.cpp,%.o,$(SRCSCPP)) $(patsubst %.c,%.o,$(SRCSC)) $(patsubst %.asm,%.o,$(SRCSASM))
EXE  = main

#
# Debug build settings
#
DBGDIR = ./bin/debug
DBGEXE = $(DBGDIR)/$(EXE)
DBGOBJS = $(addprefix $(DBGDIR)/, $(OBJS))
DBGCXXFLAGS = -g -O0

#
# Release build settings
#
RELDIR = ./bin/release
RELEXE = $(RELDIR)/$(EXE)
RELOBJS = $(addprefix $(RELDIR)/, $(OBJS))
RELCXXFLAGS = -O3

.PHONY: all clean debug prep release remake

# Default build
all: prep debug

#
# Debug rules
#
debug: $(DBGEXE)

$(DBGEXE): $(DBGOBJS)
	$(CPPC) $(CXXFLAGS) $(DBGCXXFLAGS) -o $(DBGEXE) $^ $(CXXLIBS)

$(DBGDIR)/%.o: %.cpp
	$(CPPC) -c $(CPPFLAGS) $(CXXFLAGS) $(DBGCXXFLAGS) -o $@ $*.cpp
$(DBGDIR)/%.o: %.c
	$(CC) -c $(CFLAGS) $(CXXFLAGS) $(DBGCXXFLAGS) -o $@ $*.c
$(DBGDIR)/%.o: %.asm
	$(ASMC) $(ASMFLAGS) $*.asm -o $@

#
# Release rules
#
release: $(RELEXE)

$(RELEXE): $(RELOBJS)
	$(CPPC) $(CXXFLAGS) $(RELCXXFLAGS) -o $(RELEXE) $^ $(CXXLIBS)

$(RELDIR)/%.o: %.cpp
	$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $(RELCXXFLAGS) -o $@ $*.cpp
$(RELDIR)/%.o: %.c
	$(CC) -c $(CFLAGS) $(CXXFLAGS) $(RELCXXFLAGS) -o $@ $*.c
$(RELDIR)/%.o: %.asm
	$(ASMC) $(ASMFLAGS) $*.asm -o $@ 

#
# Other rules
#
prepwin:
	mkdir $(DBGDIR)\src $(RELDIR)\src
	xcopy src $(DBGDIR)\src /t /e
	xcopy src $(RELDIR)\src /t /e
	
prep:
	@mkdir -p $(DBGDIR)/src $(RELDIR)/src
	@cd src && find . -type d -exec mkdir -p -- ../$(DBGDIR)/src/{} ../$(RELDIR)/src/{} \;

remake: clean all

clean:
	rm -f $(RELEXE) $(RELOBJS) $(DBGEXE) $(DBGOBJS) $(patsubst %.o,%.d,$(DBGOBJS)) $(patsubst %.o,%.d,$(RELOBJS))

hardclean:
	rm -r ./bin

-include $(DBGOBJS:.o=.d)
-include $(RELOBJS:.o=.d)