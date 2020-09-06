CXX_SRC=sendserial.cpp debug.cpp
CXX_HEADERS=debug.h rs232wrapper.h binaryblob.h
BUILD_DIR=obj
CXX_OBJ=$(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CXX_SRC))
OBJ= $(CXX_OBJ)

CXX=g++

OUT=sendserial

all: $(BUILD_DIR) $(OUT)

clean:
	rm -rf $(BUILD_DIR) $(OUT)

$(OUT): $(OBJ)
	$(CXX) $(LDFLAGS) -o $@ $(OBJ)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
	
$(BUILD_DIR)/%.o: %.cpp
	$(CXX) $(CFLAGS) -c -o $@ $<

