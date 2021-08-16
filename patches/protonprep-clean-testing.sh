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
    patch -Np1 < ../patches/wine-hotfixes/imm32-com-initialization_no_net_active_window.patch

    patch -Np1 < ../patches/proton/41-valve_proton_fullscreen_hack-staging-tkg.patch


    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    ### END WINEPATCH SECTION ###

    #WINE CUSTOM PATCHES
    #add your own custom patch lines below

    #end
