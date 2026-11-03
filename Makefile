CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Iinclude $(shell pkg-config --cflags json-c)
LDLIBS = $(shell pkg-config --libs json-c)
SRC = main.cpp $(wildcard src/*.cpp)

all: dbms

dbms: $(SRC) $(wildcard include/*.h)
	$(CXX) $(CXXFLAGS) $(SRC) -o dbms $(LDLIBS)

clean:
	rm -f dbms dbms.exe

.PHONY: all clean
