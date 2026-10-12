/*
	Copyright (C) 2026 CsoundQt contributors

	This file is part of CsoundQt.

	CsoundQt is free software; you can redistribute it
	and/or modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	CsoundQt is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with Csound; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
	02111-1307 USA
*/

#ifndef VALUEMAPPING_H
#define VALUEMAPPING_H

#include <algorithm>
#include <cmath>

// Maps a normalized GUI position in [0, 1] to a real value in [minimum, maximum]
// using an exponent ("skew") curve, and provides the inverse mapping:
//
//   value    = minimum + position^exponent * (maximum - minimum)
//   position = ((value - minimum) / (maximum - minimum)) ^ (1 / exponent)
//
// An exponent of 1 is the identity (linear) mapping. An exponent > 1 gives finer
// resolution near the minimum, an exponent < 1 finer resolution near the maximum.
//
// The forward and inverse mappings are kept together so callers (the knob widget
// and, later, other controllers) cannot let them drift apart.
struct ValueMapping {
	double minimum = 0.0;
	double maximum = 1.0;
	double exponent = 1.0;

	// The exponent must be strictly positive; clamp rather than divide by zero.
	static double validExponent(double e)
	{
		return e < 0.001 ? 0.001 : e;
	}

	// GUI position in [0, 1] -> real value in [minimum, maximum].
	double toValue(double position) const
	{
		position = std::clamp(position, 0.0, 1.0);
		const double e = validExponent(exponent);
		if (e == 1.0) {
			return minimum + position * (maximum - minimum);
		}
		return minimum + std::pow(position, e) * (maximum - minimum);
	}

	// Real value -> GUI position in [0, 1].
	double toPosition(double value) const
	{
		const double span = maximum - minimum;
		if (span == 0.0) {
			return 0.0;
		}
		const double ratio = std::clamp((value - minimum) / span, 0.0, 1.0);
		const double e = validExponent(exponent);
		if (e == 1.0) {
			return ratio;
		}
		return std::pow(ratio, 1.0 / e);
	}
};

#endif // VALUEMAPPING_H
