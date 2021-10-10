#!/bin/bash

### (1) PREP SECTION ###

    #WINE STAGING
    cd wine-staging
    git reset --hard HEAD
    git clean -xdf

    # revert pending pulseaudio changes
    git revert --no-commit 183fd3e089b170d5b7405a80a23e81dc7c4dd682

    # reenable pulseaudio patches
    patch -Np1 < ../patches/wine-hotfixes/staging/staging-reenable-pulse.patch
    patch -RNp1 < ../patches/wine-hotfixes/staging/staging-pulseaudio-reverts.patch
    cd ..

### END PREP SECTION ###

### (2) WINE PATCHING ###

    cd wine
    git reset --hard HEAD
    git clean -xdf

### (2-1) PROBLEMATIC COMMIT REVERT SECTION ###

    # https://github.com/ValveSoftware/Proton/issues/1295#issuecomment-859185208
    echo "these break Tokyo Xanadu Xe+"
    git revert --no-commit 2ad44002da683634de768dbe49a0ba09c5f26f08
    git revert --no-commit dfa4c07941322dbcad54507cd0acf271a6c719ab

    echo "temporary bcrypt reverts for rdr2"
    git revert --no-commit dc3a240a2dc89e5280f37c3b50df86e09705dc70
    git revert --no-commit 696255907c53d52836d80c2360bf4c66ec327a3d
    git revert --no-commit 52ca433e7801cbc588763089bf6a8637f076bfe1
    git revert --no-commit e4f716bc26fc61e2734f6e8dec4473fc63b6b99f


    echo "pulseaudio fixup to re-enable staging patches"
    patch -Np1 < ../patches/wine-hotfixes/staging/wine-pulseaudio-fixup.patch


### END PROBLEMATIC COMMIT REVERT SECTION ###


### (2-2) WINE STAGING APPLY SECTION ###

    # these cause window freezes/hangs with origin
    # -W winex11-_NET_ACTIVE_WINDOW \
    # -W winex11-WM_WINDOWPOSCHANGING \

    # this needs to be disabled of disabling the winex11 patches above because staging has them set as a dependency.
    # -W imm32-com-initialization
    # instead, we apply it manually:
    # patch -Np1 < ../patches/wine-hotfixes/imm32-com-initialization_no_net_active_window.patch

    # This is currently disabled in favor of a rebased version of the patchset
    # which includes fixes for red dead redemption 2
    # -W bcrypt-ECDHSecretAgreement \

    # This was found to cause hangs in various games
    # Notably DOOM Eternal and Resident Evil Village
    # -W ntdll-NtAlertThreadByThreadId

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W winex11-_NET_ACTIVE_WINDOW \
    -W winex11-WM_WINDOWPOSCHANGING \
    -W imm32-com-initialization \
    -W ntdll-NtAlertThreadByThreadId

    # apply this manually since imm32-com-initialization is disabled in staging.
    patch -Np1 < ../patches/wine-hotfixes/staging/imm32-com-initialization_no_net_active_window.patch

    echo "applying staging Compiler_Warnings revert for steamclient compatibility"
    # revert this, it breaks lsteamclient compilation
    patch -RNp1 < ../wine-staging/patches/Compiler_Warnings/0031-include-Check-element-type-in-CONTAINING_RECORD-and-.patch

    # https://bugs.winehq.org/show_bug.cgi?id=49990
    echo "revert bd27af974a21085cd0dc78b37b715bbcc3cfab69 which breaks some game launchers and 3D Mark"
    patch -RNp1 < ../patches/wine-hotfixes/pending/hotfix-revert_bd27af974a21085cd0dc78b37b715bbcc3cfab69.patch

### END WINE STAGING APPLY SECTION ###

### (2-3) GAME PATCH SECTION ###

    echo "mech warrior online"
    patch -Np1 < ../patches/game-patches/mwo.patch

    echo "ffxiv launcher"
    patch -Np1 < ../patches/game-patches/ffxiv-launcher-workaround.patch

    echo "assetto corsa"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    echo "mk11 patch"
    patch -Np1 < ../patches/game-patches/mk11.patch

#    BLOPS2 uses CEG which does not work in proton. Disabled for now
#    echo "blackops 2 fix"
#    patch -Np1 < ../patches/game-patches/blackops_2_fix.patch

    echo "killer instinct vulkan fix"
    patch -Np1 < ../patches/game-patches/killer-instinct-winevulkan_fix.patch

### END GAME PATCH SECTION ###

### (2-4) PROTON PATCH SECTION ###

    echo "applying proton-specific syscall emulation patch"
    patch -Np1 < ../patches/proton/53-protonif_stg_syscall_emu.patch

    echo "clock monotonic"
    patch -Np1 < ../patches/proton/01-proton-use_clock_monotonic.patch

    #WINE FSYNC
    echo "applying fsync patches"
    patch -Np1 < ../patches/proton/03-proton-fsync_staging.patch

    echo "LAA"
    patch -Np1 < ../patches/proton/04-proton-LAA_staging.patch

    echo "protonify"
    patch -Np1 < ../patches/proton/10-proton-protonify_staging.patch

    echo "protonify-audio"
    patch -Np1 < ../patches/proton/11-proton-pa-staging.patch

    echo "amd ags"
    patch -Np1 < ../patches/proton/18-proton-amd_ags.patch

    echo "valve rdr2 fixes"
    patch -Np1 < ../patches/proton/25-proton-rdr2-fixes.patch

    echo "valve rdr2 bcrypt fixes"
    patch -Np1 < ../patches/proton/55-proton-bcrypt_rdr2_fixes.patch

    echo "apply staging bcrypt patches on top of rdr2 fixes"
    patch -Np1 < ../patches/wine-hotfixes/staging/0001-bcrypt-Allow-multiple-backends-to-coexist.patch
    patch -Np1 < ../patches/wine-hotfixes/staging/0002-bcrypt-Implement-BCryptSecretAgreement-with-libgcryp.patch

    echo "set prefix win10"
    patch -Np1 < ../patches/proton/28-proton-win10_default.patch

    echo "proton-specific mfplat video conversion patches"
    patch -Np1 < ../patches/proton/34-proton-winegstreamer_updates.patch

    echo "mouse focus fixes"
    patch -Np1 < ../patches/proton/38-proton-mouse-focus-fixes.patch

    echo "CPU topology overrides"
    patch -Np1 < ../patches/proton/39-proton-cpu-topology-overrides.patch

    echo "proton futex2 patches"
    patch -Np1 < ../patches/proton/40-proton-futex2.patch

    echo "fullscreen hack"
    patch -Np1 < ../patches/proton/41-valve_proton_fullscreen_hack-staging-tkg.patch

    echo "fullscreen hack fsr patch"
    patch -Np1 < ../patches/proton/48-proton-fshack_amd_fsr.patch

    echo "proton QPC performance patch"
    patch -Np1 < ../patches/proton/49-proton_QPC.patch

    echo "proton LFH performance patch"
    patch -Np1 < ../patches/proton/50-proton_LFH.patch

    echo "proton quake champions patches"
    patch -Np1 < ../patches/proton/52-proton_quake_champions_syscall.patch

    echo "create Lutris custom registry overrides sections"
    patch -Np1 < ../patches/lutris/LutrisClient-registry-overrides-section.patch

    echo "msvcrt overrides"
    patch -Np1 < ../patches/lutris/19-lutris-msvcrt_nativebuiltin.patch

    echo "atiadlxx needed for cod games"
    patch -Np1 < ../patches/lutris/20-lutris-atiadlxx.patch

    echo "lutris registry entries"
    patch -Np1 < ../patches/lutris/21-lutris-01_wolfenstein2_registry.patch
    patch -Np1 < ../patches/lutris/22-lutris-02_rdr2_registry.patch
    patch -Np1 < ../patches/lutris/23-lutris-03_nier_sekiro_ds3_registry.patch
    patch -Np1 < ../patches/lutris/24-lutris-04_cod_registry.patch
    patch -Np1 < ../patches/lutris/32-lutris-05_spellforce_registry.patch
    patch -Np1 < ../patches/lutris/33-lutris-06_shadow_of_war_registry.patch
    patch -Np1 < ../patches/lutris/41-lutris-07_nfs_registry.patch
    patch -Np1 < ../patches/lutris/45-lutris-08_FH4_registry.patch
    patch -Np1 < ../patches/lutris/47-lutris-10-Civ6Launcher_Workaround.patch
    patch -Np1 < ../patches/lutris/48-lutris-11-Dirt_5.patch
    patch -Np1 < ../patches/lutris/54-lutris-12_death_loop_registry.patch

### END PROTON PATCH SECTION ###

### (2-5) WINE HOTFIX SECTION ###

    echo "mfplat additions"
    patch -Np1 < ../patches/wine-hotfixes/mfplat/mfplat-godfall-hotfix.patch

    # fixes witcher 3, borderlands 3, rockstar social club, and a few others
    echo "heap allocation hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-remi_heap_alloc.patch

    echo "star citizen hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-starcitizen-StorageDeviceSeekPenaltyProperty.patch

#    disabled, still horribly broken
#    patch -Np1 < ../patches/wine-hotfixes/testing/wine_wayland_driver.patch


### END WINE HOTFIX SECTION ###

### (2-6) WINE PENDING UPSTREAM SECTION ###

    # https://bugs.winehq.org/show_bug.cgi?id=49887
    echo "EA Desktop fix (for new EA beta client)"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-EA_desktop_fix.patch


### END WINE PENDING UPSTREAM SECTION ###


### (2-7) WINE CUSTOM PATCHES ###

### END WINE CUSTOM PATCHES ###
### END WINE PATCHING ###

    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f
