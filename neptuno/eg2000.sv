//-------------------------------------------------------------------------------------------------
// EACA EG2000 Colour Genie implementation for SiDi by Kyp
// https://github.com/Kyp069/eg2000
//-------------------------------------------------------------------------------------------------
// Z80 chip module implementation by Sorgelig
// https://github.com/sorgelig/ZX_Spectrum-128K_MIST
//-------------------------------------------------------------------------------------------------
// UM6845R chip module implementation by Sorgelig
// https://github.com/sorgelig/Amstrad_MiST
//-------------------------------------------------------------------------------------------------
// AY chip module implementation by Jotego
// https://github.com/jotego/jt49
//-------------------------------------------------------------------------------------------------
module eg2000
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire       led,

	output wire[ 1:0] sync,
	output wire[17:0] rgb,

	input  wire       ear,
	output wire[ 1:0] audio,

	output wire       ramCk,
	output wire       ramCe,
	output wire       ramCs,
	output wire       ramWe,
	output wire       ramRas,
	output wire       ramCas,
	output wire[ 1:0] ramDqm,
	inout  wire[15:0] ramDQ,
	output wire[ 1:0] ramBA,
	output wire[12:0] ramA,

	input  wire[ 1:0] ps2,

	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	
	output        MCLK,
	output        SCLK,
	output        LRCLK,
	output        SDIN,
	output        STM_RST = 1'b0	
);
//-------------------------------------------------------------------------------------------------
wire locked;

clock Clock
(
	.inclk0 (clock50),
	.c0     (clock  ), // 35.468 MHz
	.locked (locked)
);

//-------------------------------------------------------------------------------------------------

reg[7:0] rs;
wire power = rs[7];// & ~status[0];
always @(posedge clock) if(!power) rs <= rs+1'd1;

//-------------------------------------------------------------------------------------------------

wire tape = ~ear;
wire[15:0] audio_dac;
wire[3:0] color;

glue Glue
(
	.clock  (clock  ),
	.power  (power  ),
	.hsync  (hsync  ),
	.vsync  (vsync  ),
	.ce_pix (ce_pix ),
	.pixel  (pixel  ),
	.color  (color  ),
	.tape   (tape   ),
	.audio_l(audio_dac),//.sound  (sound  ),
	.ps2    (ps2    ),
	.ramCk  (ramCk  ),
	.ramCe  (ramCe  ),
	.ramCs  (ramCs  ),
	.ramWe  (ramWe  ),
	.ramRas (ramRas ),
	.ramCas (ramCas ),
	.ramDqm (ramDqm ),
	.ramDQ  (ramDQ  ),
	.ramBA  (ramBA  ),
	.ramA   (ramA   )
);

//-------------------------------------------------------------------------------------------------

reg[17:0] palette[15:0];
initial begin
	palette[15] = 18'b111000_111000_111000; // FF FF FF // 16 // white
	palette[14] = 18'b100000_001000_111000; // 98 20 FF //  8 // magenta
	palette[13] = 18'b001000_110000_100000; // 1F C4 8C // 14 // turquise
	palette[12] = 18'b100000_100000_100000; // 8C 8C 8C // 13 // grey
	palette[11] = 18'b100000_011000_111000; // 8A 67 FF // 12 // violet
	palette[10] = 18'b110000_010000_111000; // C7 4E FF // 15 // pink
	palette[ 9] = 18'b101000_110000_111000; // BC DF FF //  9 // light blue
	palette[ 8] = 18'b001000_010000_111000; // 2F 53 FF //  8 // blue
	palette[ 7] = 18'b110000_111000_001000; // EA FF 27 // 11 // yellow/green
	palette[ 6] = 18'b111000_011000_001000; // EB 6F 2B //  5 // orange
	palette[ 5] = 18'b101000_111000_010000; // AB FF 4A //  2 // green
	palette[ 4] = 18'b111000_111000_001000; // FF F2 3D //  4 // yellow
	palette[ 3] = 18'b111000_111000_111000; // EA EA EA //  1 // light grey
	palette[ 2] = 18'b110000_001000_010000; // CB 26 5E //  3 // red
	palette[ 1] = 18'b011000_111000_111000; // 7C FF EA //  7 // cyan
	palette[ 0] = 18'b010000_010000_010000; // 5E 5E 5E // 10 // dark grey
end

wire[17:0] rgbQ = pixel ? palette[color] : 1'd0;

//assign rgb = rgbQ;
//assign sync = {vsync,hsync};
//-------------------------------------------------------------------------------------------------

//assign audio = {2{sound}};

//-------------------------------------------------------------------------------------------------

assign led = tape;

//-------------------------------------------------------------------------------------------------

wire       scandoubler_disable=host_scandoubler;


localparam CONF_STR = {
        "EG2000;;",
        "T0,Reset;",
        "O23,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
        "V,v1.1"
};

wire[31:0] status;

`ifndef CYCLONE
wire[ 1:0] ps2;

mist_io #(.STRLEN(($size(CONF_STR)>>3)), .PS2DIV(2500)) mist_io
(  
    .ioctl_ce    (1),
    .conf_str    (CONF_STR),
    .clk_sys     (clock   ),
    .SPI_SCK     (spiCk   ),
    .CONF_DATA0  (cfgD0   ),
    .SPI_SS2     (spiS2   ),
    .SPI_DO      (spiDo   ),
    .SPI_DI      (spiDi   ),
    .status      (status  ),
    .scandoubler_disable(scandoubler_disable),
    .ypbpr       (ypbpr   ),
	 .ps2_kbd_clk (ps2[0]  ),
	 .ps2_kbd_data(ps2[1]  ),

    // unused
  	 .ps2_key       (),
    .ps2_mouse_clk (),
    .ps2_mouse_data(),
    .joystick_analog_0(),
    .joystick_analog_1()
);
`else
wire [7:0]R_OSD,G_OSD,B_OSD;
wire [7:0]R_IN={rgbQ[17:12],2'b00};
wire [7:0]G_IN={rgbQ[11: 6],2'b00};
wire [7:0]B_IN={rgbQ[ 5: 0],2'b00};
wire host_scandoubler;

data_io data_io
(
	.clk(clock),
	.CLOCK_50(clock50), //Para modulos de I2s y Joystick
	
	.debug(),
	
	.reset_n(locked),

	.vga_hsync(hsync),
	.vga_vsync(vsync),
	
	.red_i(R_IN),
	.green_i(G_IN),
	.blue_i(B_IN),
	.red_o(R_OSD),
	.green_o(G_OSD),
	.blue_o(B_OSD),
	
	.ps2k_clk_in(ps2[0]),
	.ps2k_dat_in(ps2[1]),
	.ps2_key(),
	.host_scandoubler_disable(host_scandoubler),
	
`ifndef JOYDC
	.JOY_CLK(),
	.JOY_LOAD(),
	.JOY_DATA(),
	.JOY_SELECT(),
	.joy1(),
	.joy2(),
`endif
	.dac_MCLK(MCLK),
	.dac_LRCK(LRCLK),
	.dac_SCLK(SCLK),
	.dac_SDIN(SDIN),
	.sigma_L(audio[0]),
	.sigma_R(audio[1]),
	.L_data(audio_dac),
	.R_data(audio_dac),
	
	.spi_miso(SD_MISO),
	.spi_mosi(SD_MOSI),
	.spi_clk(SD_SCK),
	.spi_cs(SD_CS),

	.img_mounted(img_mounted),
	.img_size(img_size),

	.status(status),
	
	.ioctl_ce(1'b1),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_file_ext()
);
`endif

wire [1:0] scale = status[3:2];

video_mixer video_mixer
(
    .*,
    .ce_pix(ce_pix),
    .ce_pix_actual(ce_pix),
    .hq2x(scale == 1),
    .scanlines(scandoubler_disable ? 2'b00 : {scale==3, scale==2}),
    .clk_sys   ( clock     ),
    .SPI_SCK   (      ),
    .SPI_DI    (      ),
    .SPI_SS3   (      ),
	 .mono      (0),
    .ypbpr     (ypbpr      ),
    .line_start(0),
    .ypbpr_full(0),
    .HSync     (hsync),
    .VSync     (vsync),
`ifndef CYCLONE
    .R         (rgbQ[17:12]),
    .G         (rgbQ[11: 6]),
    .B         (rgbQ[ 5: 0]),
`else
	 .R         (R_OSD[7:2]),
	 .G         (G_OSD[7:2]),
	 .B         (B_OSD[7:2]),
`endif	 
    .VGA_R     (rgb[17:12] ),
    .VGA_G     (rgb[11: 6] ),
    .VGA_B     (rgb[ 5: 0] ),
    .VGA_VS    (sync[1]    ),
    .VGA_HS    (sync[0]    )
);


//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
