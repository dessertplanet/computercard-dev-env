# Sample upload

This example demonstrates a simple way for users to choose and upload custom audio samples to a Computer card. It uses the built-in RP2040 USB bootloader to upload samples to a Computer card, exploiting the fact that a suitably designed UF2 file containing audio samples can be uploaded 'on top of' the UF2 file containing the RP2040 firmware executable, without overwriting this executable. 

Here, a standalone HTML/JavaScript page provides the interface for the user to select WAV files and convert these into UF2 file that can be uploaded to a Computer card.


## Usage
1. Compile this example and upload the resulting `sample_upload.uf2` to the Computer
2. Open `generate_sample_uf2.html` in a browser and use the interface to select some (16-bit mono) WAV file samples to upload. Use this page to generate a UF2 file containing the samples, and upload this to the Computer.

Once uploaded,
* Samples are played through both audio outputs
* Knob Y + CV input 2 control the playback speed
* if the switch is up, the samples are played in sequence
* if the switch is in the middle position, the main knob + CV input 1 select which sample to play
* if the switch is held down for two seconds, the Computer reboots into UF2 upload mode (no need to remove the Main Knob!)


## Shortcomings
Only 16-bit mono PCM WAV files are supported. More fundamentally, the approach use here of leveraging the built-in RP2040 bootloader for sample upload means that it not possible to use this interface to query what samples are already uploaded, or what the size of the memory card is. A more flexible approach (requiring somewhat more programming effort) would be to build into the RP2040 firmware a custom interface for uploading samples over USB and saving them to the flash memory.

