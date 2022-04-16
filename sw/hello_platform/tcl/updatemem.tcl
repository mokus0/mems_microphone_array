updatemem -force -meminfo \
    "main/_ide/bitstream/alchitry_platform.mmi" \
  -bit \
    "main/_ide/bitstream/alchitry_platform.bit" \
  -data \
    "main/Release/main.elf" \
  -proc alchitry_platform_i/microblaze_0 -out \
    "main.bit" 
