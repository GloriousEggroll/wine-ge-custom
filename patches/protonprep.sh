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

    # protonify syscall emulation
    patch -Np1 < ../patches/wine-hotfixes/staging/protonify_stg_syscall_emu.patch
    cd ..

### END PREP SECTION ###

### (2) WINE PATCHING ###

    cd wine
    git reset --hard HEAD
    git clean -xdf

### (2-1) PROBLEMATIC COMMIT REVERT SECTION ###

    # this breaks controllers in some unity games
    # https://bugs.winehq.org/show_bug.cgi?id=51277
    git revert --no-commit 97afac469fbe012e22acc1f1045c88b1004a241f

    # https://bugs.winehq.org/show_bug.cgi?id=49990
    echo "revert bd27af974a21085cd0dc78b37b715bbcc3cfab69 which breaks some game launchers and 3D Mark"
    git revert --no-commit bd27af974a21085cd0dc78b37b715bbcc3cfab69

    echo "temporary pulseaudio reverts"
    git revert --no-commit 2e64d91428757eaa88475b49bf50922cda603b59
    git revert --no-commit f77af3dd6324fadaf153062d77b51f755f71faea
    git revert --no-commit ce151dd681fe5ee80daba96dce12e37d6846e152
    git revert --no-commit 77813eb7586779df0fb3b700000a17e339fd5ce3
    git revert --no-commit d8e9621cfad50596378283704dfb1e6926d77ed8
    git revert --no-commit a4149d53f734bf898087e22170eab5bed9a423d1
    git revert --no-commit b4c7823bbb6a792098131f5572506784c8ed0f35
    git revert --no-commit 70f59eb179d6a1c1b4dbc9e0a45b5731cd260793
    git revert --no-commit e19d97ff4e2f5a7800d6df77b8acce95130b84c3
    git revert --no-commit 4432b66e372caf0096df56f45502d7dea1f1800c
    git revert --no-commit 6a6296562f536ed10d221f0df43ef30bbd674cb2
    git revert --no-commit aba40bd50a065b3ac913dbc1263c38535fb5d9e7
    git revert --no-commit bf74f36350c92daae84623dc0bd0530c212bb908
    git revert --no-commit 1518e73b23211af738ae448a80466c0199f24419
    git revert --no-commit 44e4132489c28b429737be022f6d4044c5beab3e
    git revert --no-commit a6131544e87c554f70c21a04fb4697d8e1f508d5
    git revert --no-commit 80b996c53c767fef4614f097f14c310285d9c081
    git revert --no-commit 459e911b653c7519a335661a6c0b0894e86d2f1a
    git revert --no-commit 42d826bc8c1d625ed2985ff06c2cd047209a1916
    git revert --no-commit 30c17619e5401618122ca330cf0909f49b170a59
    git revert --no-commit af84907ccad3e28f364ecfaa75ccb5fedf7f5a42
    git revert --no-commit a5997bece730beb8ab72d66b824ed2a1cb92c254
    git revert --no-commit 24a7c33fc1ad6dbab489284cfb6dba4130297ddb
    git revert --no-commit 8cb88173d87efedce8c345beea05641f5617d857
    git revert --no-commit 505d4b8b14913f3abd362bf27272e6b239cb6ce4
    git revert --no-commit 638455136b4d30b853b02b77a2f33dc61c60b267
    git revert --no-commit 13cac6287c454146eff73aabc4b92b5c8f76d4df
    git revert --no-commit d7b957654d4739b8dd07c91f051b7940f416ef42
    git revert --no-commit 8ea23d0d44ced0ce7dadc9b2546cbc56f6bce364
    git revert --no-commit 0b0ae164f4ccebf4b5bc1bb1529a90786d2d5941
    git revert --no-commit 131b7fd5e16a3da17aed28e86933074c5d663d9f
    git revert --no-commit 8060e56b26add8eafffb211119798569ea3188ff
    git revert --no-commit bca0706f3a93fa0a57f4dbdc6ae541e8f25afb34
    git revert --no-commit b1ddfca16e4696a52adf2bdd8333eeffb3c6170c
    git revert --no-commit a5d4079c8285c10ab2019c9fd9d19a6b22babb76
    git revert --no-commit ebd344f2922f4044117904e024a0a87576a3eff1
    git revert --no-commit 0eeefec6c56084a0677403aee46493e2c03a1dca
    git revert --no-commit 5477f2b0156d16952a286dd0df148c2f60b71fe6
    git revert --no-commit fa097243e06b3855a240c866a028add722025ead
    git revert --no-commit 8df72bade54d1ef7a6d9e79f20ee0a2697019c13
    git revert --no-commit e264ec9c718eb66038221f8b533fc099927ed966
    git revert --no-commit d3673fcb034348b708a5d8b8c65a746faaeec19d


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
    -W bcrypt-ECDHSecretAgreement \
    -W ntdll-NtAlertThreadByThreadId

    # apply this manually since imm32-com-initialization is disabled in staging.
    patch -Np1 < ../patches/wine-hotfixes/staging/imm32-com-initialization_no_net_active_window.patch

### END WINE STAGING APPLY SECTION ###

### (2-3) GAME PATCH SECTION ###

    echo "mech warrior online"
    patch -Np1 < ../patches/game-patches/mwo.patch

    echo "assetto corsa"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    # TODO: Add game-specific check
    echo "mk11 patch"
    patch -Np1 < ../patches/game-patches/mk11.patch

#    BLOPS2 uses CEG which does not work in proton. Disabled for now
#    echo "blackops 2 fix"
#    patch -Np1 < ../patches/game-patches/blackops_2_fix.patch

    echo "killer instinct vulkan fix"
    patch -Np1 < ../patches/game-patches/killer-instinct-winevulkan_fix.patch

### END GAME PATCH SECTION ###
    
### (2-4) PROTON PATCH SECTION ###

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

#    disabled for now, needs rebase. only used for vr anyway
#    echo "proton openxr patches"
#    patch -Np1 < ../patches/proton/37-proton-OpenXR-patches.patch

### END PROTON PATCH SECTION ###

### (2-5) WINE HOTFIX SECTION ###

    echo "mfplat additions"
    patch -Np1 < ../patches/wine-hotfixes/mfplat/mfplat-godfall-hotfix.patch

    # fixes witcher 3, borderlands 3, rockstar social club, and a few others
    echo "heap allocation hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-remi_heap_alloc.patch

    echo "uplay broken rendering hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-uplay_render_fix.patch

    echo "msfs2020 hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-msfs2020.patch

    echo "star citizen hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-starcitizen-StorageDeviceSeekPenaltyProperty.patch

#    disabled, still horribly broken
#    patch -Np1 < ../patches/wine-hotfixes/testing/wine_wayland_driver.patch

### END WINE HOTFIX SECTION ###

### (2-6) WINE PENDING UPSTREAM SECTION ###
    
    echo "BF4 ping fix"
    patch -Np1 < ../patches/wine-hotfixes/pending/hotfix-bf4_ping.patch

    echo "remi HID pending"
    patch -Np1 < ../patches/wine-hotfixes/pending/remi-HID-pending.patch
### END WINE PENDING UPSTREAM SECTION ###


### (2-7) WINE CUSTOM PATCHES ###

     echo "remi's HID joystick testing patches (automatically enabled)"
     patch -Np1 < ../patches/wine-hotfixes/testing/remi-joystick_HID.patch

### END WINE CUSTOM PATCHES ###
### END WINE PATCHING ###

    # need to run these after applying patches
    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f
