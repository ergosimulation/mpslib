INCLUDES = -I.
SRC_DIR = .

SRCS = $(wildcard $(SRC_DIR)/*.cpp)

%.o : $(SRC_DIR)/%.cpp
	$(CXX) -o $@ $(INCLUDES) $(CPPFLAGS) -static -c $^

all : mpslib.a

mpslib.a : $(SRCS:.cpp=.o) 
	$(AR) rsv $@ $^

clean:
	rm -f *.o *.a

