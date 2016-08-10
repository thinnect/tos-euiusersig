/**
 * In case of a bad boot, the component uses PersistentAddressC to set up the address and then
 * modifies the EUI64.
 *
 * @author Raido Pahtma
 * @license MIT
 */
module BadSignatureHandlerP {
	provides interface Boot;
	uses {
		interface Boot as BadBoot;
		interface LocalIeeeEui64;
		interface SetStruct<ieee_eui64_t> as SetLocalIeeeEui64;
	}
}
implementation {

	event void BadBoot.booted() {
		ieee_eui64_t eui = call LocalIeeeEui64.getId();
		eui.data[sizeof(eui.data) - 1] = (uint8_t)TOS_NODE_ID;
		eui.data[sizeof(eui.data) - 2] = (uint8_t)(TOS_NODE_ID >> 8);
		call SetLocalIeeeEui64.set(&eui);
		signal Boot.booted();
	}

}
