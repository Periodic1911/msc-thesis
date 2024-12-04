ENTRY(_dummy_start)
SECTIONS
{
  _dummy_start = 0;
  . = 0x0000;
  .text : { *(.text) }
}

