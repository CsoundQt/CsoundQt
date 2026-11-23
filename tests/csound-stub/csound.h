/*
 * Minimal Csound header for the standalone risset unit test.
 *
 * test_risset only needs the Opcode/Risset code, not the Csound API. types.h
 * includes <csound.h> for cs_float, so provide that single typedef without
 * requiring Csound development headers in the unit-test CI job.
 */
#ifndef CSOUND_STUB_H
#define CSOUND_STUB_H

#include <stdint.h>

typedef double cs_float;

// risset.cpp communicates this version to risset through LIBCSOUND_VERSION.
static inline int32_t csoundGetVersion(void) { return 7000; }

#endif
