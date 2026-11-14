/*
 * Minimal Csound header for the standalone risset unit test.
 *
 * test_risset only needs the Opcode/Risset code, not the Csound API. types.h
 * includes <csound.h> for cs_float, so provide that single typedef without
 * requiring Csound development headers in the unit-test CI job.
 */
#ifndef CSOUND_STUB_H
#define CSOUND_STUB_H

typedef double cs_float;

#endif
