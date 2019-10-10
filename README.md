# startLazarusPortable
## Description
 A launcher app that starts lazarus from a folder/USB Stick and keeps it all contained.
 It currently only supports windows, but it may support other operating systems in the future.

## How to use
 To set this up, you can either copy the files from a previously installed version or use the files from a fresh install.
 
 * Previous installation
  Fistly, create a folder to put the portable lazarus installation into. Copy the files from the lazarus installation directory(the directory containing the lazarus.exe) into that folder aswell as the **startLazarusPortable.exe**. Now, create a folder in the portable lazarus folder, called "LazarusConfig" and another one called "Temp". The you have to copy the Lazarus configuration files(Standard location is C:\Users\<User name>\AppData\Local\lazarus\) into the "LazarusConfig" folder.
 * New Installation
  Firstly, download the lauzarus installer and install it in any folder(if you already have lazarus installed, you can select secondary installation and select any folder to now overwrite you previous config). Then, create a folder to put the portable lazarus installation into. Copy the files from the folder you installed lazarus to into that folder aswell as the **startLazarusPortable.exe**. Now, create a folder in the portable lazarus folder, called "LazarusConfig" and another one called "Temp". The you have to copy the config from the fresh install(Standard location, or the folder you selected) into the "LazarusConfig" folder.
  
 Finally, execute the **startLazarusPortable.exe**. If everything worked, lazarus should start and not show any errors. Then, close Lazarus and you have finished installing Lazarus portable.
 
 If you now want to start Lazarus, execute **startLazarusPortable.exe**.
