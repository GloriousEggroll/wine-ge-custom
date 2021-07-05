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

    # needed for wayland
    #git revert --no-commit d171d1116764260f4ae272c69b54e5dfd13c6835

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W winex11-_NET_ACTIVE_WINDOW \
    -W winex11-WM_WINDOWPOSCHANGING \
    -W imm32-com-initialization \
    -W ntdll-NtAlertThreadByThreadId

    # apply this manually since imm32-com-initialization is disabled in staging.
    patch -Np1 < ../patches/wine-hotfixes/imm32-com-initialization_no_net_active_window.patch

patch -Np1 < ../patches/proton/38-proton-mouse-focus-fixes.patch
#patch -Np1 < ../patches/proton/41-valve_proton_fullscreen_hack-staging-tkg.patch
#    patch -Np1 < ../patches/wine-hotfixes/scratch.diff

    # this is needed for battle.net
    patch -RNp1 < ../patches/wine-hotfixes/revert-ws2_32-Reimplement-select-on-top-of-IOCTL_AFD_POL.patch

#    patch -Np1 < ../patches/wine-hotfixes/wine_wayland_driver.patch

    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    ### END WINEPATCH SECTION ###

    #WINE CUSTOM PATCHES
    #add your own custom patch lines below

    #end
