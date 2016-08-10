UserSignatureArea
=================

The UserSignatureArea is a component for retrieving EUI-64 address and board
information from atmega 65/128/256 user signature area. The stored data is
covered by a CRC and uses the entire 768 byte signature area, though most of
the version 1.0.0 signature is empty - filled with FF.

Integration
-----------
The module should be inserted into a boot chain. A successful read of the
signature will signal a Boot event. If the signature is empty or fails the CRC
check, then a BadBoot is signalled. Empty signatures will set the EUI-64 to
FFFFFFFFFFFFFFFF and a failed CRC check will set it to 0000000000000000.

Test application
----------------
There is a test application in [test/usersig](test/usersig). It should work with
the murp and denodeb platforms.

Generating and programming signatures
-------------------------------------
Signatures can be generated with the [signature generator](https://github.com/thinnect/euisiggen).

Programming the RFR2 user signature can only be done with Atmel AVR JTAG
programmers(JTAGICE, Atmel-ICE) and Atmel Studio 7 or atprogram.
Avrdude does not currently support writing signatures, see the
http://savannah.nongnu.org/bugs/?44644 issue for more information.

Known issues
------------
Occasionally the MCU fails to read out the data in the signature area - the area
appears empty. It has happend rarely enough that the cause is currently unknown.
Reading on the next boot seems to be successful, it is not known if a second
read attempt without a reboot would succeed.
