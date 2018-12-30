UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    export CPPFLAGS += -O3 -std=c++11
else
	export CPPFLAGS += -static -O3 -std=c++11 -Wl,--no-as-needed
endif

# NAME OF LIBRARY
MPSLIB = mpslib/mpslib.a

# LINK LIBRARIES
LDLIBS =  -lstdc++ -lpthread

all: mps_genesim mps_snesim_list mps_snesim_tree

.PHONY: mpslib
mpslib:
	make -C mpslib

mps_genesim: mpslib
	$(CC) $(CPPFLAGS) mps_genesim.cpp ENESIM_GENERAL.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)

mps_snesim_tree: mpslib
	$(CC) $(CPPFLAGS) mps_snesim_tree.cpp SNESIMTree.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)

mps_snesim_list: mpslib
	$(CC) $(CPPFLAGS) mps_snesim_list.cpp SNESIMList.cpp $(MPSLIB) -o $@ -I mpslib/ $(LDLIBS)


.PHONY: clean
clean:
	rm -f *.o mps mpslib/*.o $(MPSLIB)

cleanexe:
	rm -f *.o mps *.exe mps_genesim mps_snesim_tree mps_snesim_list mpslib/*.o $(MPSLIB)

.PHONY: cleano
cleano:
	rm -f *.o mpslib/*.o $(MPSLIB)
