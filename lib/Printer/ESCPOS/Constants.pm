package  Printer::ESCPOS;

use constant {
    ESC => "\x1b",
    GS  => "\x1d",
    DLE => "\x10",
    FS  => "\x1c",
    # Level 2 Constants
    FF  => "\x0c",
    SP  => "\x20",
};

# Commands that take a variable parameter
use constant {
    # Text Format
    TXT_FORMAT           => ESC . '!', # Set text format
    SELECT_JUSTIFICATION => ESC . 'a', # Select justification
    RIGHT_CHAR_SPACING   => ESC . SP , # Select right side character spacing 
};

use constant {
    # Page mode commands
    PAGE_MODE          => ESC . FF,               # Print data in page mode
    CAN                => "\x18",                 # In page mode, deletes(Cancel) all the data in the current printable area 
    # Feed control sequences
    LF                 => "\x0a",                 # Print and line feed
    FF                 => "\x0c",                 # Form feed
    CR                 => "\x0d",                 # Carriage return
    HT                 => "\x09",                 # Horizontal tab
    SET_HT             => ESC . 'D',              # Set horizontal tab positions
    VT                 => ESC . 'd' . "\x04",     # Vertical tab
    # Printer hardware
    HW_INIT            => ESC . '@',              # Clear data in buffer and reset modes
    HW_SELECT          => ESC . '=' . "\x01",     # Printer select
    HW_RESET           => ESC . '?' . "\x0a\x00", # Reset printer hardware
    # Cash Drawer
    CD_KICK_2          => ESC . 'p' . "\x00",     # Sends a pulse to pin 2 []
    CD_KICK_5          => ESC . 'p' . "\x01",     # Sends a pulse to pin 5 []
    # Paper
    PAPER_FULL_CUT     => GS . 'V' . "\x00",      # Full cut paper
    PAPER_PART_CUT     => GS . 'V' . "\x01",      # Partial cut paper
    # Text format
    TXT_NORMAL         => ESC . '!' . "\x00",     # Normal text
    TXT_2HEIGHT        => ESC . '!' . "\x10",     # Double height text
    TXT_2WIDTH         => ESC . '!' . "\x20",     # Double width text
    TXT_4SQUARE        => ESC . '!0',             # Quad area text
    TXT_UNDERL_OFF     => ESC . '-' . "\x00",     # Underline font OFF
    TXT_UNDERL_ON      => ESC . '-' . "\x01",     # Underline font 1-dot ON
    TXT_UNDERL2_ON     => ESC . '-' . "\x02",     # Underline font 2-dot ON
    TXT_BOLD_OFF       => ESC . 'E' . "\x00",     # Bold font OFF
    TXT_BOLD_ON        => ESC . 'E' . "\x01",     # Bold font ON
    TXT_FONT_A         => ESC . 'M' . "\x00",     # Font type A
    TXT_FONT_B         => ESC . 'M' . "\x01",     # Font type B
    TXT_ALIGN_LT       => ESC . 'a' . "\x00",     # Left justification
    TXT_ALIGN_CT       => ESC . 'a' . "\x01",     # Centering
    TXT_ALIGN_RT       => ESC . 'a' . "\x02",     # Right justification
    # Char code table
    CHARCODE_PC437     => ESC . 't' . "\x00",     # USA: Standard Europe
    CHARCODE_JIS       => ESC . 't' . "\x01",     # Japanese Katakana
    CHARCODE_PC850     => ESC . 't' . "\x02",     # Multilingual
    CHARCODE_PC860     => ESC . 't' . "\x03",     # Portuguese
    CHARCODE_PC863     => ESC . 't' . "\x04",     # Canadian-French
    CHARCODE_PC865     => ESC . 't' . "\x05",     # Nordic
    CHARCODE_WEU       => ESC . 't' . "\x06",     # Simplified Kanji, Hirakana
    CHARCODE_GREEK     => ESC . 't' . "\x07",     # Simplified Kanji
    CHARCODE_HEBREW    => ESC . 't' . "\x08",     # Simplified Kanji
    CHARCODE_PC1252    => ESC . 't' . "\x11",     # Western European Windows Code Set
    CHARCODE_PC866     => ESC . 't' . "\x12",     # Cyrillic                               # 2
    CHARCODE_PC852     => ESC . 't' . "\x13",     # Latin 2
    CHARCODE_PC858     => ESC . 't' . "\x14",     # Euro
    CHARCODE_THAI42    => ESC . 't' . "\x15",     # Thai character code 42
    CHARCODE_THAI11    => ESC . 't' . "\x16",     # Thai character code 11
    CHARCODE_THAI13    => ESC . 't' . "\x17",     # Thai character code 13
    CHARCODE_THAI14    => ESC . 't' . "\x18",     # Thai character code 14
    CHARCODE_THAI16    => ESC . 't' . "\x19",     # Thai character code 16
    CHARCODE_THAI17    => ESC . 't' . "\x1a",     # Thai character code 17
    CHARCODE_THAI18    => ESC . 't' . "\x1b",     # Thai character code 18
    # Barcode format
    BARCODE_TXT_OFF    => GS . 'H' . "\x00",      # HRI barcode chars OFF
    BARCODE_TXT_ABV    => GS . 'H' . "\x01",      # HRI barcode chars above
    BARCODE_TXT_BLW    => GS . 'H' . "\x02",      # HRI barcode chars below
    BARCODE_TXT_BTH    => GS . 'H' . "\x03",      # HRI barcode chars both above and below
    BARCODE_FONT_A     => GS . 'f' . "\x00",      # Font type A for HRI barcode chars
    BARCODE_FONT_B     => GS . 'f' . "\x01",      # Font type B for HRI barcode chars
    BARCODE_HEIGHT     => GS . 'hd'   ,           # Barcode Height [1-255]
    BARCODE_WIDTH      => GS . 'w' . "\x03",      # Barcode Width  [2-6]
    BARCODE_UPC_A      => GS . 'k' . "\x00",      # Barcode type UPC-A
    BARCODE_UPC_E      => GS . 'k' . "\x01",      # Barcode type UPC-E
    BARCODE_EAN13      => GS . 'k' . "\x02",      # Barcode type EAN13
    BARCODE_EAN8       => GS . 'k' . "\x03",      # Barcode type EAN8
    BARCODE_CODE39     => GS . 'k' . "\x04",      # Barcode type CODE39
    BARCODE_ITF        => GS . 'k' . "\x05",      # Barcode type ITF
    BARCODE_NW7        => GS . 'k' . "\x06",      # Barcode type NW7
    # Image format
    S_RASTER_N         => GS . 'v0' . "\x00",     # Set raster image normal size
    S_RASTER_2W        => GS . 'v0' . "\x01",     # Set raster image double width
    S_RASTER_2H        => GS . 'v0' . "\x02",     # Set raster image double height
    S_RASTER_Q         => GS . 'v0' . "\x03",     # Set raster image quadruple
    # Printing Density
    PD_N50             => GS . '|' . "\x00",      # Printing Density -50%
    PD_N37             => GS . '|' . "\x01",      # Printing Density -37.5%
    PD_N25             => GS . '|' . "\x02",      # Printing Density -25%
    PD_N12             => GS . '|' . "\x03",      # Printing Density -12.5%
    PD_0               => GS . '|' . "\x04",      # Printing Density  0%
    PD_P50             => GS . '|' . "\x08",      # Printing Density +50%
    PD_P37             => GS . '|' . "\x07",      # Printing Density +37.5%
    PD_P25             => GS . '|' . "\x06",      # Printing Density +25%
    PD_P12             => GS . '|' . "\x05",      # Printing Density +12.5%
};

1;
