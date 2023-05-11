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
    
    git revert --no-commit e62dd2a5b62a6a75d9bcaec29e80b31eb257c41d
    git revert --no-commit b6ad9e57a90a189f2806273feb8fffac6c9c8264

    echo "applying staging patches"
    ../wine-staging/staging/patchinstall.py DESTDIR="." --all

    echo "applying fsync patches"
    patch -Np1 < ../patches/proton/03-proton-fsync_staging.patch
    echo "proton futex waitv patches"
    patch -Np1 < ../patches/proton/57-fsync_futex_waitv.patch

    echo "LoL fixes"
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-broken-client-update-fix.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-client-slow-start-fix.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-ntdll-nopguard-call_vectored_handlers.patch

    echo "Custom"
    patch -Np1 < ../patches/custom/hide_prefix_update_window.patch

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
