#export CXX=clang++-8 # clang seems to perform better than g++-7
#export CXX=g++-8 # clang seems to perform better than g++-7
# use next for maximum optimization to local hardware
export CPPFLAGS+= -O3 -march=native -std=c++11
# USe next for compilation of static binary
# export CPPFLAGS+= -O3 -std=c++11

UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)
ifeq ($(OS),Windows_NT)
	export CPPFLAGS += -static -Wl,--no-as-needed
else
    #UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		  #export CPPFLAGS += -Wl,--no-as-needed
		  export INCLUDEFLAGS += -Wl,--no-as-needed
    endif
    ifeq ($(UNAME_S),Darwin)
        #export CPPFLAGS += -static -Wl,--no-as-needed
    endif
    #UNAME_P := $(shell uname -p)
    #ifeq ($(UNAME_P),x86_64)
    #    CCFLAGS += -D AMD64
    #endif
    #ifneq ($(filter %86,$(UNAME_P)),)
    #    CCFLAGS += -D IA32
    #endif
    #ifneq ($(filter arm%,$(UNAME_P)),)
    #    CCFLAGS += -D ARM
    #endif
endif

# NAME OF LIBRARY
MPSLIB = mpslib/mpslib.a

# LINK LIBRARIES
LDLIBS =  -lstdc++ -lpthread

all: mps_genesim mps_snesim_list mps_snesim_tree
	@echo $(OS)
	@echo $(UNAME_S)
	@echo $(UNAME_P)

.PHONY: mpslib
mpslib:
	make -C mpslib

mps_genesim: mpslib
	$(CXX) $(CPPFLAGS) $(INCLUDEFLAGS) mps_genesim.cpp ENESIM_GENERAL.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)

mps_snesim_tree: mpslib
	$(CXX) $(CPPFLAGS) $(INCLUDEFLAGS) mps_snesim_tree.cpp SNESIMTree.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)

mps_snesim_list: mpslib
	$(CXX) $(CPPFLAGS) $(INCLUDEFLAGS) mps_snesim_list.cpp SNESIMList.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)

.PHONY: clean
clean:
	rm -f *.o mps mpslib/*.o $(MPSLIB)

cleanexe:
	rm -f *.o mps *.exe mps_genesim mps_snesim_tree mps_snesim_list mpslib/*.o $(MPSLIB)

.PHONY: cleano
cleano:
	rm -f *.o mpslib/*.o $(MPSLIB)
