# "darwin" for macOS, "linux" for Linux
LOCAL_OS := $(shell uname -s | tr A-Z a-z)


# INCLUDES
-include ./Makefile_tf.mk
