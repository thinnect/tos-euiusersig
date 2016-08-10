/**
 * Struct for semantic versioning.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef SEMANTICVERSION_H_
#define SEMANTICVERSION_H_

typedef struct semantic_version_t {
	uint8_t major;
	uint8_t minor;
	uint8_t patch;
} semantic_version_t;

#endif // SEMANTICVERSION_H_
