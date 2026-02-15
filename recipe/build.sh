#!/bin/bash
set -ex

# ----- Jetson (pre-built binary) path -----
if [[ "${jetpack_version:-None}" != "None" ]]; then
    # Install the base arm64 package (binary + CPU runner libraries)
    # The official install extracts the entire archive, which includes
    # bin/ollama and lib/ollama/ with runner .so files
    mkdir -p "$PREFIX/bin" "$PREFIX/lib/ollama"
    cp ollama-bin/bin/ollama "$PREFIX/bin/ollama"
    chmod +x "$PREFIX/bin/ollama"
    if [ -d "ollama-bin/lib/ollama" ]; then
        cp -r ollama-bin/lib/ollama/* "$PREFIX/lib/ollama/"
    fi

    # Overlay JetPack CUDA runner libraries
    # Debug: show what the JetPack archive contains
    echo "=== JetPack archive contents ==="
    find ollama-jetpack-libs/ -type f -o -type l | head -50
    echo "=== end ==="

    # The JetPack archive overlays on top of the base install
    # Try lib/ollama/ first, fall back to searching for the cuda_jetpack directory
    if [ -d "ollama-jetpack-libs/lib/ollama" ]; then
        cp -r ollama-jetpack-libs/lib/ollama/* "$PREFIX/lib/ollama/"
    elif [ -d "ollama-jetpack-libs/ollama" ]; then
        cp -r ollama-jetpack-libs/ollama/* "$PREFIX/lib/ollama/"
    else
        # Last resort: find and copy any cuda_jetpack directory
        find ollama-jetpack-libs/ -type d -name "cuda_jetpack*" -exec cp -r {} "$PREFIX/lib/ollama/" \;
    fi

    # Install Jetson activation/deactivation scripts
    mkdir -p "$PREFIX/etc/conda/activate.d"
    cp "$RECIPE_DIR/activate-jetson.sh" "$PREFIX/etc/conda/activate.d/ollama-jetson.sh"

    mkdir -p "$PREFIX/etc/conda/deactivate.d"
    cp "$RECIPE_DIR/deactivate-jetson.sh" "$PREFIX/etc/conda/deactivate.d/ollama-jetson.sh"

    exit 0
fi

# ----- Standard build-from-source path -----
if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
  if [[ ${cuda_compiler_version} == 12.* ]]; then
    cmake ${CMAKE_ARGS} --preset 'CUDA 12' \
        && cmake --build --preset 'CUDA 12' \
        && cmake --install build --component CUDA --strip
  elif [[ ${cuda_compiler_version} == 13.* ]]; then
    cmake ${CMAKE_ARGS} --preset 'CUDA 13' \
        && cmake --build --preset 'CUDA 13' \
        && cmake --install build --component CUDA --strip
  else
    echo "unsupported cuda version"
    exit 1
  fi
else
    cmake ${CMAKE_ARGS} --preset 'CPU' \
        && cmake --build --preset 'CPU' \
        && cmake --install build --component CPU --strip
fi


go build -trimpath -buildmode=pie -ldflags="-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -o $PREFIX/bin/ollama .

go-licenses save . --save_path="$SRC_DIR/license-files/" 
