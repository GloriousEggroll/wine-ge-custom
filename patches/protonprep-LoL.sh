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
    ../wine-staging/staging/patchinstall.py DESTDIR="." --all

    echo "clock monotonic"
    patch -Np1 < ../patches/proton/01-proton-use_clock_monotonic.patch

    # Client won't launch with fsync patches
    # echo "applying fsync patches"
    # patch -Np1 < ../patches/proton/03-proton-fsync_staging.patch
    # echo "proton futex waitv patches"
    # patch -Np1 < ../patches/proton/57-fsync_futex_waitv.patch

    echo "LAA"
    patch -Np1 < ../patches/proton/04-proton-LAA_staging.patch

    echo "proton QPC performance patch"
    patch -Np1 < ../patches/proton/49-proton_QPC-update-replace.patch

    # Doesn't apply
    # echo "proton LFH performance patch"
    # patch -Np1 < ../patches/wine-hotfixes/LoL/lfh-non-proton-pre-needed.patch
    # patch -Np1 < ../patches/proton/50-proton_LFH.patch

    echo "LoL fixes"
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-broken-client-update-fix.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-client-slow-start-fix.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-ntdll-nopguard-call_vectored_handlers.patch
    # Doesn't seem to be needed
    # patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-ntdll-stub-NtSetInformationThread-ThreadPriority.patch

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
