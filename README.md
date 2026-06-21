(UNIX SUPPORT (MAC/LINUX) IS LIMITED SINCE WE DON'T KNOW HOW THE GAME RUNS OVER THERE)

# ok so basically
now that ivy's added official modding support for evil egg loading the mod is much much easier now
this program runs using the (now deprecated but still functional) discord-rpc API

you will need to download it yourself; it can be found here:
- discordRPC: https://github.com/pfirsich/lua-discordRPC/tree/master

# how to install discordRPC
on windows, the discordRPC folder that you must've gotten from the repo linked above contains a bunch of folders with "-dynamic" or "-static" at the end of their names. you want the "-dynamic" versions. open the folder pertaining to your system architecture (find it by typing "echo %PROCESSOR_ARCHITECTURE%" in command prompt; if it says x86, open the win32 folder; otherwise open win64)   
open the "bin" folder inside and steal the .dll file you find inside.  
  
then you must put that .dll next to the game's .exe file. on steam you can right-click Evil Egg and select "Browse local files..." and it will open the folder with the .exe in it. put the .dll file in there so that the mod doesn't crash.

# how to run ominous presence
find the folder in the evil egg save called "mods" and put the folder OMP in there and your good.  
Oh right you might wanna download OMP... uhhhhh you can find it in the "Releases" tab to your right d: (o_o

# how to find evil egg save
you'll find it in C:/Users/yourusername/AppData/Roaming/EVIL EGG. (it is a hidden file, so it would be much easier to just follow the instruction below first)  
  
otherwise if you don't know how to enable hidden files in file explorer, hit Windows+R keys and input "appdata" and it'll take you straight to the AppData part. refer to the path above to locate the evil egg save from there.

# right now i plan:
- spectate players using both discord buttons or in-game menu (but that's a massive stretch so it'll be its own mod)
- switch apis to the not deprecated discord social sdk (but i don't know c or c++ so don't expect that)
