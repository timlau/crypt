NAME = crypt
BUILD_DIR = build
BUILD_TYPE = Release
SETUP_OPTIONS = -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
BUILD_OPTIONS = --config ${BUILD_TYPE} ${TARGET}


all: build

clean:
	@echo "Cleaning build directory : ${BUILD_DIR}"
	@rm -rf ${BUILD_DIR}
.PHONY: clean	

setup:
	cmake -B ${BUILD_DIR} ${SETUP_OPTIONS}
.PHONY: setup

build: setup
	cmake --build ${BUILD_DIR} ${BUILD_OPTIONS}
.PHONY: build

