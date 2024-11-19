# Variables
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -g
TARGET = writer
SRC = writer.c
OBJ = $(SRC:.c=.o)

# Default target
.PHONY: all
all: $(TARGET)

# Build the application
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean target
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJ)
