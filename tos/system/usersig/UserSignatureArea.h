/**
 * UserSignatureArea header.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef USERSIGNATUREAREA_H_
#define USERSIGNATUREAREA_H_

	enum UserSignatureAreaEnum {
		USERSIG_VERSION_MAJOR = 1,
		USERSIG_VERSION_MINOR = 0,
		USERSIG_SIZE = 768,
		USERSIG_ADDR = 0x100,
		USERSIG_BOARDNAME_MAX_STRLEN = 16,
	};

	typedef nx_struct nx_usersig_header_t {
		nx_uint8_t version_major;
		nx_uint8_t version_minor;
		nx_uint8_t version_patch;

		nx_uint64_t eui64;

		nx_uint16_t year;
		nx_uint8_t month;
		nx_uint8_t day;
		nx_uint8_t hours;
		nx_uint8_t minutes;
		nx_uint8_t seconds;

		nx_int64_t unix_time; // Same moment in time

		nx_uint8_t boardname[USERSIG_BOARDNAME_MAX_STRLEN]; // up to 16 chars or 0 terminated

		nx_uint8_t pcb_version_major;
		nx_uint8_t pcb_version_minor;
		nx_uint8_t pcb_version_assembly;
	} nx_usersig_header_t;

	typedef nx_struct nx_usersig_t {
		nx_usersig_header_t header;
		nx_uint8_t padding[USERSIG_SIZE - sizeof(nx_usersig_header_t) - sizeof(nx_uint16_t)];
		nx_uint16_t crc;
	} nx_usersig_t;

#endif // USERSIGNATUREAREA_H_
