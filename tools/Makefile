CC = gcc
INCLUDES =
CFLAGS = -Wall -Wextra -Wshadow -Wpedantic -O2 $(INCLUDES)
LDFLAGS = 
OBJS =  compressor.o

TARGET = compressor

all: $(TARGET)

$(TARGET) : $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)
	
clean:
	rm -f $(TARGET) $(OBJS) $(ASM_FILES) *~