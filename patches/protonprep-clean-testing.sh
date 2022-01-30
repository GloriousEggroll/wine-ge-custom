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
    -W winex11-_NET_ACTIVE_WINDOW \
    -W winex11-WM_WINDOWPOSCHANGING \
    -W dbghelp-Debug_Symbols \
    -W dwrite-FontFallback

    # apply any custom patches here for testing

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
