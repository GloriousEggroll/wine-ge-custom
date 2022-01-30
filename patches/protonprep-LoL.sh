#!/bin/bash

    #WINE STAGING
    cd wine-staging
    git reset --hard HEAD
    git clean -xdf
    cd ..

    #WINE
    cd wine
    git reset --hard HEAD
    git clean -xdf

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W d3dx11_43-D3DX11CreateTextureFromMemory \
    -W oleaut32-OLEPictureImpl_SaveAsFile \
    -W dbghelp-Debug_Symbols \
    -W fltmgr.sys-FltBuildDefaultSecurityDescriptor \
    -W inseng-Implementation \
    -W msxml3-FreeThreadedXMLHTTP60 \
    -W ntdll-RtlQueryPackageIdentity \
    -W packager-DllMain \
    -W shell32-ACE_Viewer \
    -W wineboot-ProxySettings \
    -W winemenubuilder-Desktop_Icon_Path \
    -W xactengine-initial

    echo "clock monotonic"
    patch -Np1 < ../patches/proton/01-proton-use_clock_monotonic.patch

    echo "applying fsync patches"
    patch -Np1 < ../patches/proton/03-proton-fsync_staging.patch

    echo "proton futex waitv patches"
    patch -Np1 < ../patches/proton/57-fsync_futex_waitv.patch

    echo "LAA"
    patch -Np1 < ../patches/proton/04-proton-LAA_staging.patch

    echo "proton QPC performance patch"
    patch -Np1 < ../patches/proton/49-proton_QPC-update-replace.patch

    echo "proton LFH performance patch"
    patch -Np1 < ../patches/LoL/lfh-non-proton-pre-needed.patch
    patch -Np1 < ../patches/proton/50-proton_LFH.patch

    echo "LoL fixes"
    patch -Np1 < ../patches/LoL/LoL-6.17+-syscall-fix.patch
    patch -Np1 < ../patches/LoL/LoL-abi.vsyscall32-alternative_patch_by_using_a_fake_cs_segment.patch
    patch -Np1 < ../patches/LoL/LoL-broken-client-update-fix.patch
    patch -Np1 < ../patches/LoL/LoL-launcher-client-connectivity-fix-0001-ws2_32-Return-a-valid-value-for-WSAIoctl-SIO_IDEAL_S.patch
    patch -Np1 < ../patches/LoL/LoL-garena-childwindow.patch


    echo "cleanup .orig files"
    find ./ -name '*.orig' -delete


    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    ### END WINEPATCH SECTION ###

    #WINE CUSTOM PATCHES
    #add your own custom patch lines below

    #end
