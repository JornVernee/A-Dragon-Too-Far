KERNEL ?= ADTF_Kernel_C_Windows.s
MAIN = ADTF_Revive.s
TEST_MAIN = ADTF_test.s
SOURCES = ADTF_Util.s $(KERNEL)
OBJECTS = $(SOURCES:.s=.o)
ASSEMBLER = i686-w64-mingw32-gcc
FLAGS = -m32
DEBUG_FLAGS = -Wa,--defsym,DEBUG=1
OUTPUT_FILE = adtf_R
TEST_OUT = test
DEPS = clean

SCRIPTER = python
DEBUGSCRIPT = gen_debug.py

all: debug
	
debug: FLAGS += $(DEBUG_FLAGS)
debug: gen_debug release	

release: $(DEPS) $(OBJECTS) 
	$(ASSEMBLER) $(FLAGS) -o $(OUTPUT_FILE) $(MAIN) $(OBJECTS)
	
.s.o:
	$(ASSEMBLER) $(FLAGS) -c $< -o $@

gen_debug:	
	$(SCRIPTER) $(DEBUGSCRIPT)
	
test: $(DEPS) $(OBJECTS)
	$(ASSEMBLER) $(FLAGS) -o $(TEST_OUT) $(TEST_MAIN) $(OBJECTS)
	
clean:
	rm -f *.o $(OUTPUT_FILE) $(TEST_OUT)