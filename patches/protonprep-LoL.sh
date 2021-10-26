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
    -W imm32-com-initialization \
    -W ntdll-NtAlertThreadByThreadId

    # apply this manually since imm32-com-initialization is disabled in staging.
    patch -Np1 < ../patches/wine-hotfixes/staging/imm32-com-initialization_no_net_active_window.patch

    echo "clock monotonic"
    patch -Np1 < ../patches/proton/01-proton-use_clock_monotonic.patch

    echo "LAA"
    patch -Np1 < ../patches/proton/04-proton-LAA_staging.patch

    echo "applying fsync patches"
    patch -Np1 < ../patches/proton/03-proton-fsync_staging.patch

    echo "proton futex2 patches"
    patch -Np1 < ../patches/proton/40-proton-futex2.patch

    echo "proton QPC performance patch"
    patch -Np1 < ../patches/proton/49-proton_QPC.patch

    echo "proton LFH performance patch"
    patch -Np1 < ../patches/wine-hotfixes/LoL/lfh-non-proton-pre-needed.patch
    patch -Np1 < ../patches/proton/50-proton_LFH.patch

    echo "LoL fix"
    patch -Np1 < ../patches/wine-hotfixes/LoL/LoL-6.19-fix.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/alternative_patch_by_using_a_fake_cs_segment.patch
    patch -Np1 < ../patches/wine-hotfixes/LoL/lol-update-fix.patch

    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    ### END WINEPATCH SECTION ###

    #WINE CUSTOM PATCHES
    #add your own custom patch lines below

    #end
