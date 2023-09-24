# wine-ge-custom

This is my build of WINE based on/forked from the most recent bleeding-edge proton experimental wine repo. This is meant to be used with non-steam games outside of Steam.

For Steam games, I provide Proton-GE for usage with Lutris, found here:

https://github.com/gloriouseggroll/proton-ge-custom

## Occasionally, I also release League of Legends builds -- These builds will specifically have 'lol' or 'LoL' in the name. Please note these 'LoL' builds are for specific use with League of Legends, and NO other games.

## If you have an issue that happens with my Wine-GE or Wine-LoL-GE builds, provided FROM this repository, please contact me on Discord about the issue:

https://discord.gg/6y3BdzC

## Table of contents

- [Overview](#overview)
	- [Media Foundation Fixes (fully working or playable)](#media-foundation-fixes-fully-working-or-playable)
	- [Notes](#notes)
- [Installation](#installation)
	- [Manual](#manual)
- [Building](#building)
- [Modification](#modification)
- [Credits](#credits)
	- [TKG (Etienne Juvigny)](#tkg-etienne-juvigny)
	- [Guy1524 (Derek Lesho)](#guy1524-derek-lesho)
	- [Joshie (Joshua Ashton)](#joshie-joshua-ashton)
	- [doitsujin/ドイツ人 (Philip Rebohle)](#doitsujinドイツ人-philip-rebohle)
	- [HansKristian/themaister (Hans-Kristian Arntzen)](#hanskristianthemaister-hans-kristian-arntzen)
	- [flibitijibibo (Ethan Lee)](#flibitijibibo-ethan-lee)
	- [simmons-public (Chris Simmons)](#simmons-public-chris-simmons)
	- [Sporif (Amine Hassane)](#sporif-amine-hassane)
	- [wine-staging maintainers](#wine-staging-maintainers)
	- [Reporters](#reporters)
	- [Patrons](#patrons)
- [Donations](#donations)
## Overview

Things it contains that Valve's proton does not:

- Additional media foundation patches for better video playback support
- AMD FSR patches added directly to fullscreen hack that can be toggled with WINE_FULLSCREEN_FSR=1
- FSR Fake resolution patch (details here: https://github.com/GloriousEggroll/proton-ge-custom/pull/52)
- Nvidia CUDA support for phsyx and nvapi
- Raw input mouse support
- fix for Mech Warrior Online
- fix for Asseto Corsa HUD
- fix for MK11 crash in single player
- fix for Killer Instinct Vulkan related crash
- fix for Cities XXL patches
- various upstream WINE patches backported
- various wine-staging patches applied as they become needed

## Media Foundation fixes (Fully working or playable)

- Spyro Reignited Trilogy
- Mortal Kombat 11
- Injustice 2
- Power Rangers: Battle for the Grid
- Borderlands 3
- Resident Evil 0
- Resident Evil
- Resident Evil 2 Remastered
- Resident Evil 3 Remastered
- Resident Evil 5
- Resident Evil 6
- Resident Evil 7
- Resident Evil 8
- Resident Evil Revalations
- Resident Evil Revalations 2
- Persona 4 Golden
- PC Building Simulator
- Dangonronpa V3
- Super Lucky's Tale
- Remnant: From the Ashes
- BlazBlue Centralfiction
- Bloodstained: Ritual of the Night
- Crazy Machines 3
- Devil May Cry 5
- Wasteland 3
- Mutant Year Zero
- Ultimate Marvel Vs. Capcom 3
- Industry of Titan
- Call of Duty Black Ops III
- Tokyo Xanadu eX+
- Haven
- Nier Replicant
- Scrap Mechanic
- Aven Colony
- American Fugitive
- Asrtonner
- Soul Caliber VI
- Monster Hunter Rise
- Seven: Days Gone

## Notes

- Warframe is problematic with VSync. Turn it off or on in game, do not set to `Auto`
- Warframe needs a set a frame limit in game. Unlimited framerate can cause slowdowns
- Warframe on Nvidia: you may need to disable GPU Particles in game otherwise the game can freeze randomly. On AMD they work fine

## Installation

PLEASE NOTE: There are prerequisites for using this version of wine:

1. You must have wine installed on your system
2. You must have winetricks installed on your system
3. You must have wine dependencies installed on your system. See https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/
4. You must have vulkan gpu drivers/packages installed properly on your system. See https://github.com/lutris/docs/blob/master/InstallingDrivers.md

### Manual

This section is for manual installation of wine-ge for usage with Lutris.

1. Extract `wine-name-branch-x86_64.tar.gz` to `/home/USERNAME/.local/share/lutris/runners/wine/`
2. Restart lutris. You can now choose `wine-name-branch-x86_64` from the runners list in configuration options for any game.


## Building

Install docker/podman:  

    On Ubuntu: sudo apt install podman
    On Arch:   sudo pacman -S podman
    On Fedora: sudo dnf install podman

Build wine:

    usage:             ./makebuild.sh name winerepo branch
    example:           ./makebuild.sh lutris-GE https://github.com/GloriousEggroll/proton-wine Proton8-15
    build name output: builds/runners/wine/wine-lutris-GE-Proton8-15-x86_64.tar.xz

Additional tips:

  To access the container:

    docker start buildbot
    docker exec -it buildbot bash

  To exit the container:

    exit
    docker stop buildbot

  To delete the container and view containers list:

    docker container rm buildbot
    docker container list -a

  To delete the container image and view images list:

    docker rmi docker.io/gloriouseggroll/lutris_buildbot
    docker images

* IMPORTANT NOTES: 
- wine, wine-staging and patches repos/folders are here for my personal use. The build bot does -NOT- pull from any of these folders directly.__
- GloriousEggroll/proton-wine Proton* branches are PRE-PATCHED, meaning it is ready to compile, no patching needed.

If you need to make changes to the wine build it is recommended to:

  1. Fork the ValveSoftware/wine repository
  2. Clone your fork of the ValveSoftware/wine repository
  3. Add official ValveSoftware/wine repository as a remote branch in your clone/fork
  4. Checkout the latest experimental-wine-bleeding-edge tree and make a new branch from it.
  5. then run `./patches/protonprep.sh` to apply my changes to your own wine repository
  6. then commit + push those changes to your new branch on your -own- repository.
  7. THEN follow the makebuild.sh instructions from above, using your own repository URL and branch.


## Modification

Environment variable options:

| Compat config string  | Environment Variable           | Description  |
| :-------------------- | :----------------------------- | :----------- |
|                       | <tt>WINE_FULLSCREEN_FSR</tt>   | Enable AMD FidelityFX Super Resolution (FSR), use in conjunction with `WINE_FULLSCREEN_FSR_STRENGTH` Only works in vulkan games (dxvk and vkd3d-proton included).|
|                       | <tt>WINE_FULLSCREEN_FSR_STRENGTH</tt> | AMD FidelityFX Super Resolution (FSR), the default sharpening of 5 is enough without needing modification, but can be changed with 0-5 if wanted. 0 is the maximum sharpness, higher values mean less sharpening. 2 is the AMD recommended default and is set by proton-ge |

## Credits

As many of you may or may not already know, there is a Credits section in the README for this Git repository. My proton-ge project contains some of my personal tweaks to Proton, but a large amount of the patches, rebases and fixes come from numerous people's projects. While I tend to get credited for my builds, a lot of the work that goes into it are from other people as well. I'd like to take some time to point a few of these people out of recognition. In future builds, I plan to make clearer and more informative Git commits, as well as attempt to give these people further crediting, as my README may not be sufficient in doing so.

### TKG (Etienne Juvigny)

- https://www.patreon.com/tkglitch
- https://github.com/Frogging-Family/wine-tkg-git

I and many others owe TKG. In regards to both WINE and Proton. He has dedicated a lot of time (2+ years at least) to rebasing WINE and Proton patches, as well as making his own contributions. Before he came along, I did some rebasing work, and mainly only released things for Arch. These days he almost always beats me to rebasing, and it saves myself and others a **lot** of work.

### Guy1524 (Derek Lesho)

- https://github.com/Guy1524

Derek was responsible for the original rawinput patches, as well as several various game fixes in the past, just to name a few: MK11, FFXV, MHW, Steep, AC Odyssey FS fix. He has also done a massive amount of work on media foundation/mfplat, which should be hopefully working very soon.

### Joshie (Joshua Ashton)

- https://github.com/Joshua-Ashton/d9vk

Joshua is the creator of D9VK and also a huge contributor of DXVK. He is also known for his recent DOOM Eternal WINE fixes and also many of the Vulkan tweaks and fixes used, such as FS hack interger scaling.

### doitsujin/ドイツ人 (Philip Rebohle)

- https://github.com/doitsujin/dxvk

Philip is the creator of DXVK and a heavy contributor of VKD3D. He also put up a lot of my bug reporting for Warframe years ago, when DXVK started.

### HansKristian/themaister (Hans-Kristian Arntzen)

- https://github.com/HansKristian-Work

Hans-Kristian is a heavy contributor of VKD3D and he also created a lot of WINE patches that allowed WoW to work.

### flibitijibibo (Ethan Lee)

- https://github.com/sponsors/flibitijibibo
- https://fna-xna.github.io/

Ethan is the creator of FAudio, and he also listened to my Warframe bug reports years ago.

### simmons-public (Chris Simmons)

- https://github.com/simons-public

Chris is the creator of the original Protonfixes project. The portions of Protonfixes I've imported are what allow customizations to be made to prefixes for various Proton games. without Proton fixes many games would still be broken and/or require manual prefix modification. Huge thanks to Chris.

### Sporif (Amine Hassane)

- https://github.com/Sporif

Amine is the current maintainer of dxvk-async. This is a feature that was originally removed from dxvk as it happened around the same time a few overwatch bans happened. It was thought, but never confirmed whether or not this feature caused the bans, so the feature was removed as a safety precaution. It is still safe to use in many single player games, and games that do not have competitive anti-cheats. It has also been confirmed to work safely in Warframe and Path of Exile.

### wine-staging maintainers

I also of course need to thank my fellow wine-staging maintainers: Alistair Leslie-Hughes, Zebediah Figura and Paul Gofman

They have contributed MANY patches to staging, far beyond what I have done, as well as kept up with regular rebasing. A lot of times when bug reports come to me, if it has to do with staging I end up testing and relaying information to these guys in order to get issues resolved.

### Reporters

Additionally, a thank you is owed to Andrew Aeikum (aeikum), and kisak (kisak-valve) for regularly keeping me in the loop with Proton and fsync patches, as well as accepting PRs I've made to fix Proton build system issues, or listening to bug reports on early Proton patches before they reach Proton release.

### Patrons

And finally - To all of my patrons that have supported me, thank you so much. It's because of you that I've been able to keep this project going, getting bug fixes reported, getting Proton/WINE issues fixed, getting various hardware and/or game fixes handled, and so on. Thanks to you, I have been able to use the spare budget in order to both help support the other people that make my project possible, as well as get things necessary for testing such as new game releases or specific hardware that hits odd issues. It's had a huge effect not just for this project, but a large trickle down effect.

My wine-staging co-maintainers are often able to ask me for testing games, or testing on different hardware if they don't have access to it. This also trickles into both Proton bug reporting AND Lutris bug reporting, as I'm able to provide bug testing and feedback and custom builds and upgrades to them as well. I'm also able to test driver related issues for things such as mesa and getting things reported + patched. This in turn leads to early patches for Mesa, the kernel, VKD3D, and other packages on my copr repos as well. The trickle down effect is just one gigantic awesome rabbit hole for getting things fixed. Thank you once again.

## Donations

For anyone else interested, my Patreon can be found here:

https://www.patreon.com/gloriouseggroll
