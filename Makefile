NAME = Crypt2
BUILD_DIR = build
BUILD_TYPE = Release
SETUP_OPTIONS = -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCRYPT_COPY_PLUGIN_AFTER_BUILD=OFF
BUILD_OPTIONS = --config ${BUILD_TYPE} ${TARGET}
BUILDROOT = BUILDROOT

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

install: build
	@echo "Installing ${NAME} to ${BUILDROOT}"
	rm -rf ${BUILDROOT}
	mkdir -p ${BUILDROOT}
	cmake --install ${BUILD_DIR} --prefix ${BUILDROOT}
.PHONY: install
