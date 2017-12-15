/**
 * In case of a bad boot, the component uses PersistentAddressC to set up the
 * address and then modifies the EUI64.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration BadSignatureHandlerC {
	provides interface Boot;
	uses interface Boot as BadBoot;
}
implementation {

	components BadSignatureHandlerP;
	Boot = BadSignatureHandlerP.Boot;

	components PersistentAddressC;
	PersistentAddressC.SysBoot = BadBoot;
	BadSignatureHandlerP.BadBoot -> PersistentAddressC.Boot;

	components UserSignatureAreaC;
	BadSignatureHandlerP.LocalIeeeEui64 -> UserSignatureAreaC;
	BadSignatureHandlerP.SetLocalIeeeEui64 -> UserSignatureAreaC;

}
