# Build and install a copy of the library into the standard location of
# the ASF tool tree.

# Where we stage the library so the main build system can nab it
ROOT_DIR := $(shell cd ../.. ; pwd)
LIB_DIR := $(ROOT_DIR)/lib
INCLUDE_DIR := $(ROOT_DIR)/include

# These variables specify the jpeg tarball and what it unpacks into.
UNPACK_DIR := jpeg-6b

# Use patched version to match binary version bundled
# with GTK and to provide reversible compression support for both
# Linux and Windows.  Patch is the lossless compression patch
# (checked in)
TARFILE := jpegsrc.v6b.patched.tar
ZIPFILE := $(TARFILE).gz

build: build_stamp

# Create the library & necessary components in the proper place for retrieval
build_stamp:
	mkdir -p $(LIB_DIR) $(INCLUDE_DIR)
	gunzip --to-stdout $(ZIPFILE) > $(TARFILE)
	tar xvf $(TARFILE)
	rm -f $(TARFILE)
	(   cd $(UNPACK_DIR) ; \
	    ./configure --prefix=$(ROOT_DIR) ; \
	    make ; \
	    make install-lib ; \
	)
	touch $@

clean:
	rm -rf $(UNPACK_DIR) build_stamp
