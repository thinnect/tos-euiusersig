/**
 * Provide PCB version info from data in the user signature area of the MCU.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration PCBVersionInfoC {
	provides interface Get<semantic_version_t> as PCBVersion;
}
implementation {

	components UserSignatureAreaC;
	PCBVersion = UserSignatureAreaC.PCBVersion;

}
