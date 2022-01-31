#!/bin/bash

trap TrapClean ERR INT

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${root_dir}

lib_path="../../lib/"
runtime_path=$(readlink -f "../../runtime/extra/")
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

buildbot32host="buildbot32"
buildbot64host="buildbot64"
runner_name=$(get_runner)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="5.0"
configure_opts="--disable-tests --with-x --with-gstreamer"

params=$(getopt -n $0 -o a:b:w:v:p:snd6kfcmt --long as:,branch:,with:,version:,patch:,staging,noupload,dependencies,64bit,keep,keep-upload-file,useccache,usemingw,nostrip -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -a|--as) build_name=$2; shift 2 ;;
        -b|--branch) branch_name=$2; shift 2 ;;
        -w|--with) repo_url=$2; shift 2 ;;
        -v|--version) version=$2; shift 2 ;;
        -p|--patch) patch=$2; shift 2 ;;
        -s|--staging) STAGING=1; shift ;;
        -n|--noupload) NOUPLOAD=1; shift ;;
        -d|--dependencies) INSTALL_DEPS=1; shift ;;
        -6|--64bit) WOW64=1; shift ;;
        -k|--keep) KEEP=1; shift ;;
        -f|--keep-upload-file) KEEP_UPLOAD_FILE=1; shift ;;
        -c|--useccache) CCACHE=1; shift ;;
        -m|--usemingw) MINGW=1; shift ;;
        -t|--nostrip) NOSTRIP=1; shift ;;
        *) shift; break ;;
    esac
done

if [ "$build_name" ]; then
    filename_opts="${build_name}-"
elif [ "$STAGING" ]; then
    filename_opts="staging-"
fi

if [ "$WOW64" ]; then
    # Change arch name, this is used in the final file name and we want the
    # x86_64 part even on the 32bit container for WOW64.
    arch="x86_64"
fi

bin_dir="${filename_opts}${version}-${arch}"
wine32_archive="${bin_dir}-32bit.tar.gz"
dest_file="${bin_dir}-build.tar.gz"
upload_file="wine-${filename_opts}${version}-${arch}.tar.xz"

BuildWine() {
    trap TrapClean ERR INT
    prefix=${root_dir}/${bin_dir}
    mkdir -p $build_dir
    cd $build_dir

    # Do not use $arch here since it migth have been changed for the WOW64
    # build on the 32bit container
    if [ "$(uname -m)" = "x86_64" ]; then
        configure_opts="$configure_opts --enable-win64 --libdir=$prefix/lib64"
    fi

    # Third step to stitch together Wine64 and Wine32 build for the WOW64 build
    if [ "$1" = "combo" ]; then
        configure_opts="$configure_opts --with-wine64=../wine64 --with-wine-tools=../wine32 --libdir=$prefix/lib"
    fi

    if [ "$(uname -m)" = "x86_64" ]; then
        export LD_LIBRARY_PATH=${runtime_path}/lib64
        custom_ld_flags="-L${runtime_path}/lib64 -Wl,-rpath-link,${runtime_path}/lib64"
    else
        export LD_LIBRARY_PATH=${runtime_path}/lib32
        custom_ld_flags="-L${runtime_path}/lib32 -Wl,-rpath-link,$runtime_path/lib32"
    fi

    if [ $CCACHE ]; then
        export CC="ccache gcc"
            if [ "$(uname -m)" = "x86_64" ]; then
                export CROSSCC="ccache x86_64-w64-mingw32-gcc"
            else
                export CROSSCC="ccache i686-w64-mingw32-gcc"
            fi
        else
        export CC="gcc"
            if [ "$(uname -m)" = "x86_64" ]; then
                export CROSSCC="x86_64-w64-mingw32-gcc"
            else
                export CROSSCC="i686-w64-mingw32-gcc"
            fi
    fi

    if [ $MINGW ]; then
        MINGW_STATE="--with-mingw"
        else
        MINGW_STATE="--without-mingw"
    fi

    LDFLAGS="$custom_ld_flags" $source_dir/configure ${configure_opts} --prefix=$prefix $MINGW_STATE
    make -j$(getconf _NPROCESSORS_ONLN)
    
}

BuildFinalWow64Build() {
    trap TrapClean ERR INT
    cd ${root_dir}
    # Extract the wine build received from the 32bit container
    tar xzf $wine32_archive
    cd $build_dir
    make install
}

Send64BitBuildAndBuild32bit() {
    trap TrapClean ERR INT
    # Build the 64bit version of wine, send it to the 32bit container then exit
    cd ${root_dir}

    # Package the 64bit build (in a wine64 folder)
    echo "Sending the 64bit build to the 32bit container"
    mv wine wine64
    tar czf ${dest_file} wine64
    scp ${dest_file} ${buildbot32host}:${root_dir}
    mv wine64 wine
    rm ${dest_file}

    echo "Building 32bit wine"
    opts=""
    if [ $STAGING ]; then
        opts="--staging"
    fi
    if [ $KEEP ]; then
        opts="${opts} --keep"
    fi
    if [ $KEEP_UPLOAD_FILE ]; then
        opts="${opts} --keep-upload-file"
    fi
    if [ $NOUPLOAD ]; then
        opts="${opts} --noupload"
    fi
    if [ $INSTALL_DEPS ]; then
        opts="${opts} --dependencies"
    fi
    if [ $patch ]; then
        opts="${opts} --patch $patch"
    fi
    if [ $build_name ]; then
        opts="${opts} --as $build_name"
    fi
    if [ $repo_url ]; then
        opts="${opts} --with $repo_url"
    fi
    if [ "$branch_name" ]; then
        opts="${opts} --branch $branch_name"
    fi
    if [ "$CCACHE" ]; then
        opts="${opts} --useccache"
    fi
    if [ "$MINGW" ]; then
        opts="${opts} --usemingw"
    fi
    if [ "$NOSTRIP" ]; then
        opts="${opts} --nostrip"
    fi

    echo "Building 32bit wine on 32bit container"
    ssh -t ${buildbot32host} "${root_dir}/build.sh -v ${version} ${opts} --64bit"
    echo "Relaunch local build after the 32bit build finished"
    ./build.sh -v ${version} ${opts}
    echo "Build relaunched"
}

Combine64and32bitBuilds() {
    trap TrapClean ERR INT
    cd ${root_dir}
    # Extract the 64bit build of Wine received from the buildbot64 container
    wine64build_archive="${filename_opts}${version}-x86_64-build.tar.gz"
    if [ ! -f $wine64build_archive ]; then
        echo "Missing wine64 build file $wine64build_archive"
        exit 2
    fi
    tar xzf "$wine64build_archive"

    # Rename the 32bit build of wine
    mv wine wine32

    # Build the combined Wine32 + Wine64
    BuildWine combo
    make install

    cd ${root_dir}
    # Package and send the build to the 64bit container
    tar czf ${wine32_archive} ${bin_dir}
    scp ${wine32_archive} ${buildbot64host}:${root_dir}
    if [ ! $KEEP ]; then
        rm -rf ${build_dir} ${wine32_archive} ${wine64build_archive} wine32 wine64 ${bin_dir}
    fi
}

Build() {
    trap TrapClean ERR INT
    if [ -f ${wine32_archive} ]; then
        # The 64bit container has received the 32bit build
        BuildFinalWow64Build
    else
    
        BuildWine

        if [ "$(uname -m)" = "x86_64" ]; then
            # Send the build to the 32bit container
            Send64BitBuildAndBuild32bit
            exit
        fi

        if [ "$WOW64" ]; then
            # On a 32bit container, build wine then send it back to the 64bit
            # container
            Combine64and32bitBuilds
            exit
        fi

        echo "Running make install"
        make install
    fi
}

Package() {
    trap TrapClean ERR INT
    cd ${root_dir}

    # Clean up wine build
    if [ ! $NOSTRIP ]; then
        find ${bin_dir}/bin -type f -exec strip {} \;
        for _f in "$bin_dir"/{bin,lib,lib64}/{wine/*,*}; do
            if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
                strip --strip-unneeded "$_f" || true
            fi
        done
        for _f in "$bin_dir"/{bin,lib,lib64}/{wine/{x86_64-unix,x86_64-windows,i386-unix,i386-windows}/*,*}; do
            if [[ "$_f" = *.so ]] || [[ "$_f" = *.dll ]]; then
                strip --strip-unneeded "$_f" || true
            fi
        done
    fi

    #copy sdl2, faudio, vkd3d, and ffmpeg libraries
    cp -R $runtime_path/lib32/* ${bin_dir}/lib/

    if [ "$(uname -m)" = "x86_64" ]; then
        mkdir -p ${bin_dir}/lib64/
        cp -R $runtime_path/lib64/* ${bin_dir}/lib64/
    fi

    rm -rf ${bin_dir}/include

    if [ -f ${root_dir}/${upload_file} ]; then
        rm ${root_dir}/${upload_file}
    fi
    tar cJf ${upload_file} ${bin_dir}
}


TrapClean() {
    if [ ! $KEEP ]; then
        cd ${root_dir}
        rm -rf ${build_dir} ${bin_dir} ${wine32_archive} ${dest_file} ${upload_file}
    fi
    printf "Build failed, cleaned up.\n"
    exit
}

if [ $1 ]; then
    $1
else
    Build
    Package
fi