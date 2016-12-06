/**
 * RFR2 user signature area component for loading EUI64 and board info.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include <avr/boot.h>
#include <crc.h>
#include "SemanticVersion.h"
#include "UserSignatureArea.h"
module UserSignatureAreaC {
	provides {
		interface Boot;
		interface Boot as BadBoot;
		interface LocalIeeeEui64;
		interface SetStruct<ieee_eui64_t> as SetLocalIeeeEui64;
		interface Get<semantic_version_t> as PCBVersion;
		interface Get<semantic_version_t> as SignatureVersion;
		interface GetString as BoardName;
	}
	uses {
		interface Boot as SubBoot;
	}
}
implementation {

	#define __MODUUL__ "usig"
	#define __LOG_LEVEL__ ( LOG_LEVEL_UserSignatureAreaC & BASE_LOG_LEVEL )
	#include "log.h"

	ieee_eui64_t m_eui64;

	uint8_t read_signature_byte(uint16_t addr)
	{
		uint8_t value;
		atomic
		{
			value = boot_signature_byte_get(USERSIG_ADDR + addr);
		}
		return value;
	}

	uint16_t read_signature_bytes(uint16_t addr, uint8_t buf[], uint16_t length)
	{
		uint16_t i;
		if(addr + length > USERSIG_SIZE)
		{
			length = USERSIG_SIZE - (uint16_t)addr;
		}
		for(i=0;i<length;i++)
		{
			buf[i] = read_signature_byte(addr + i);
		}
		return i;
	}

	enum UserSigCheckResults {
		USERSIG_ERROR = 0,
		USERSIG_OK = 1,
		USERSIG_UNINITIALIZED = 0xFF
	};

	uint8_t sig_check()
	{
		bool uninitialized = TRUE;
		uint16_t crc = 0;
		uint16_t scrc;
		uint16_t i;

		for(i=0;i<USERSIG_SIZE-sizeof(uint16_t);i++)
		{
			uint8_t sigbyte = read_signature_byte(i);
			if(sigbyte != 0xFF)
			{
				uninitialized = FALSE;
			}
			crc = crcByte(crc, sigbyte);
		}

		scrc = ((uint16_t)read_signature_byte(i) << 8) + read_signature_byte(i + 1);

		if(uninitialized)
		{
			if(scrc == 0xFFFF)
			{
				return USERSIG_UNINITIALIZED;
			}
		}

		if(crc != scrc)
		{
			err1("crc=%04X scrc=%04X", crc, scrc);
			return USERSIG_ERROR;
		}

		return USERSIG_OK;
	}

	task void printsig()
	{
		#if __LOG_LEVEL__ & LOG_DEBUG1
			uint8_t sig[USERSIG_SIZE];
			uint8_t i;
			uint16_t read = read_signature_bytes(0, sig, sizeof(sig));
			debug1("sizeof(nx_usersig_t)=%u read=%u", sizeof(nx_usersig_t), read);
			for(i=0;i<sizeof(sig)/32;i++)
			{
				debugb1("%02u:", sig+32*i, 32, i);
			}
		#endif // __LOG_LEVEL__
	}

	void printsiginfo(semantic_version_t* sigversion)
	{
		#if __LOG_LEVEL__ & LOG_INFO1
			semantic_version_t b = call PCBVersion.get();
			char bn[USERSIG_BOARDNAME_MAX_STRLEN+1];

			call BoardName.get(bn, sizeof(bn));
			info1("sig(%u.%u.%u) ok", sigversion->major, sigversion->minor, sigversion->patch);
			infob1("%s %u.%u.%u EUI-64", m_eui64.data, sizeof(m_eui64.data), bn, b.major, b.minor, b.patch);
		#endif // __LOG_LEVEL__
	}

	task void booted()
	{
		uint8_t result = sig_check();

		post printsig();

		if(result == USERSIG_OK)
		{
			semantic_version_t v = call SignatureVersion.get();
			if((v.major == USERSIG_VERSION_MAJOR) && (v.minor >= USERSIG_VERSION_MINOR))
			{
				read_signature_bytes(offsetof(nx_usersig_t, header.eui64), m_eui64.data, sizeof(m_eui64.data));

				printsiginfo(&v);

				signal Boot.booted();
				return;
			}
			else err1("sig %u.%u.%u !~ %u.%u.x", v.major, v.minor, v.patch, USERSIG_VERSION_MAJOR, USERSIG_VERSION_MINOR);
		}
		else if(result == USERSIG_UNINITIALIZED)
		{
			memset(m_eui64.data, 0xFF, sizeof(m_eui64.data));
			warn1("sig empty");
			signal BadBoot.booted();
			return;
		}

		memset(m_eui64.data, 0x00, sizeof(m_eui64.data));
		err1("sig BAD");
		signal BadBoot.booted();
	}

	event void SubBoot.booted()
	{
		post booted();
	}

	command ieee_eui64_t LocalIeeeEui64.getId()
	{
		return m_eui64;
	}

	/**
	 * Command for changing the eui at runtime. Intended for debugging and error recovery.
	 */
	command error_t SetLocalIeeeEui64.set(ieee_eui64_t* eui)
	{
		m_eui64 = *eui;
		return SUCCESS;
	}

	command semantic_version_t SignatureVersion.get()
	{
		semantic_version_t v;
		v.major = read_signature_byte(offsetof(nx_usersig_t, header.version_major));
		v.minor = read_signature_byte(offsetof(nx_usersig_t, header.version_minor));
		v.patch = read_signature_byte(offsetof(nx_usersig_t, header.version_patch));
		return v;
	}

	command semantic_version_t PCBVersion.get()
	{
		semantic_version_t v;
		v.major = read_signature_byte(offsetof(nx_usersig_t, header.pcb_version_major));
		v.minor = read_signature_byte(offsetof(nx_usersig_t, header.pcb_version_minor));
		v.patch = read_signature_byte(offsetof(nx_usersig_t, header.pcb_version_assembly));
		return v;
	}

	command uint16_t BoardName.get(char buf[], uint16_t length)
	{
		if(length > 1)
		{
			uint16_t l = USERSIG_BOARDNAME_MAX_STRLEN;
			if(length < l)
			{
				l = length - 1;
			}
			buf[l] = 0;
			return read_signature_bytes(offsetof(nx_usersig_t, header.boardname), (uint8_t*)buf, l);
		}
		return 0;
	}

	default event void Boot.booted() { }
	default event void BadBoot.booted() { }

}
