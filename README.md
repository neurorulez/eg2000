EACA EG2000 Colour Genie FPGA implementation for ZX-Uno board (http://zxuno.speccy.org/)

Implements a EACA EG2000 Colour Genie with 32K or RAM

F12 - EG2000 reset

# eg2000.MiSTer
# EACA EG2000 Colour Genie FPGA implementation for MiSTer board

This core is a RW-FPGA dev team project implemented by Ricardo Martinez (KYP) initially in ZXUno.
A port to Altera has been made, covering the boards, MiST, MiSTica, SiDi and MiSTer by KYP and rampa069.
This core has been designed from scratch.

## Background

The Colour Genie was released in 1982.  It was an attractive machine, with a solid 
full-stroke keyboard and 16K BASIC in ROM. 
As well as the 63-key typewriter keyboard and powerful BASIC, it featured the 
trusty Z-80, running at 2.2 MHz, 16k-32k of RAM, 3 channels of sound, 8 colours 
(4 for text), 40 columns x 24 rows for text (initially) and 160 x 102 pixels 
for graphics.Ports which included RS-232, Joysticks (2), light pen, RGB and audio.  

## Specifications:

Z80 running at 2.2 MHz

Video Hardware

    Motorola 6845 CRTC
    40×24 text (original ROMs) or 40×25 text (upgraded ROMs), 16 colours, 
    128 user defined characters
    
    160×96 graphics (original ROMs) or 160×102 graphics (upgraded ROMs), 
    4 colours x up to 4 pages

Sound Hardware

    General Instruments AY-3-8910
    3 sound channels, ADSR programmable
    1 noise channel

## Coverage

The core works in RGB and VGA. 
Both Basic and Machine Code programs are loaded through the audio input ( CLOAD or SYSTEM ) TRS-80 style.


