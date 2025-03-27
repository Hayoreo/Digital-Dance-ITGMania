# Digital Dance v1.1.0

# ------------ Differences from 1.0.9.X ------------
- ITL 2025 support.
- NPS Sorting and Filters added.
- Ghost Judgment added.
- Practice mode now works for P2 and 2 player.
- QR Groovestats Login support for local and guest profiles.
- Added D-Mod speed type.
- Toggle to allow animated banners on gameplay.
- The life line on the Steps Statistics density graph will now respect "Hide Lifebar" setting.
- Added "Delayed Back" as an operator menu option in Advanced Settings.
- Added mid-session set summary! It can be accessed via the player menu.
- Changed Name Entry screen to allow keyboard input. Also changed character limit from 4 to 12.
- Fixed subtractive scoring for both normal and ex score.
- Held miss indicator graphics have been added! Can be accessed via the player menu.
- Player tags have been added.
- Player tag menu can be accessed via "ctrl + t" on screen select music.
- Player tags are seperated between single and double.
- Player tags can be applied to both songs and packs.
- Moved WRSounds to Player Profile.
- Guest profiles have DD-Stats support (resets between sessions).
- You can now click on the density graph to seek the preview music (the entire song will play from where you select).
- A progress bar has also been added to the density graph as well.
- Sound effects on ScreenTitleMenu have been fixed.
- Player EXScore/Points/ITL Rank added to the music wheel (for ITL songs).
- Added Step Statistics to double mode.
- New "Digital" judgment graphic has been added.
- Mouse Input is always enabled now.
- Fixed notefield UI in regards to NoteFieldX and NoteFieldY player mods.
- Changed subtractive score behavior for EXScore to stop constantly rounding.
- Fixed rounding issue in the Player Menu.
- Various bug fixes

## Practice Mode
Practice mode has been in DD for awhile now. However due to previous engine
limitations it was only ever accessible by P1 if they were the only player joined.
It is now possible to use Practice Mode with both P1 and P2 (or even on 2 player).
It is accessible in the Player Menu on the Select Music screen under the "System" tab.

## D-Mod
The D in D-Mod stands for Dynamic. It is a speed mod type similar to M-Mod, 
however if the chart is C-Mod legal (no stops, bpm changes, attacks, etc) it will use a C-Mod instead of an M-Mod.
This also means if a song has bpm changes, but no stops/etc and has a display bpm a C-Mod will be used.

## ITL 2025 support
Evaluation screen will show titles unlocked and quests completed/songs unlocked as well as properly download and extract songs that are unlocked (if the GS setting is enabled).
Select Music will also display your ExScore on the music wheel for ITL charts along with how many points you got and what song rank it is for you.
The D-Mod speed type is also supported for ITL charts and will switch between C and M depending on if the song is "No CMOD" or not (it will ignore the above settings to determine what to use).

## QR Groovestats Login
You can now log into Groovestats via QR Code after selecting your profile if you have it enabled in the Operator Menu under Groovestats Options.

The three possible options are:
Always - It will always prompt the user to scan regardless if their profile is set up with a GS api key or not.
Sometimes - It will only prompt the user if their profile is a Guest Profile or it does not have the GS api key set up.
Never - It will never prompt the player to login with QR (previous old behavior).

## Ghost Judgment
Ghost Judgment is similar to how FA+ works, however you can choose what value you want it to be (1-22ms for normal timing and 1-14ms for FA+).
Ghost Judgment has no effect on both normal score and ExScore and serves only as another aide for players.

## Player WR Sounds
This is set up similarly to how WRSounds were before. Now instead of using the Sounds folder in the theme you need to go to your profile folder (Save/Local Profiles/[Your Profile Folder Here]) and then add a folder called "WRSounds".
Within that folder you can then add any .mp3 or .ogg files you wish that will be randomly selected to play when you achieve a world record or a quad/quint. 
These sounds are seperated by player now so each player's sounds will only play if they get the record.

## ITGMANIA ONLY
- As noted in the "About" section this theme is intended for use with ITGMania only.
- If you are using ITGMania version 1.0.0 or older you will need to upgrade to 1.0.1 or newer.

# -- General things to note --
- This theme is intended for home use only.
- This theme is optimized for keyboard and mouse use.

# ------------ Future endeavors ------------
- Add keyboard support for number fields in the player menu.
- Add more detailed sorts/filters.
- Add tech parsing for double (it does not work at all right now).
- Add a way for a single player to switch sides without ending a session.
- Give all screens mouse functionality.