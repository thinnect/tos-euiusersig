/**
 * Interface for getting a string from a component into a client buffer.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface GetString {

	/**
	 * @param buf Buffer to store the string in.
	 * @param length Length of buf.
	 * @return Actual strlen() of the string stored into buf.
	 */
	command uint16_t get(char buf[], uint16_t length);

}
