/***************************************************************************
 *   Copyright                                                             *
 *   (c) 2003 by John D. Ramsdell.                                         *
 *   (c) 2008 by Andres Cabrera                                            *
 *   mantaraya36@gmail.com                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              *
 ***************************************************************************/
#ifndef CURVE_H
#define CURVE_H

#include <QString>

enum Polarity {
  POLARITY_NOPOL,
  POLARITY_NEGPOL,
  POLARITY_POSPOL,
  POLARITY_BIPOL,
};

class Curve
{
  public:
    Curve(float *, size_t, const QString&, Polarity,
          float, float, float, float, bool);
    Curve(double *, size_t, const QString&, Polarity,
          double, double, double, double, bool);
    Curve(const Curve&);
    Curve &operator=(const Curve&);
    ~Curve();
    float *get_data() const;
    size_t get_size() const;      // number of points
    QString get_caption() const; // title of curve
    Polarity get_polarity() const; // polarity
    float get_max() const;        // curve max
    float get_min() const;        // curve min
    float get_absmax() const;     // abs max of above
    float get_y_scale() const;    // Y axis scaling factor
    bool is_divider_dotted() const; // Add dotted divider when true
    bool has_same_caption(Curve *) const;
  private:
    float *m_data;
    size_t m_size;
    QString m_caption;
    Polarity m_polarity;
    float m_max, m_min, m_absmax, m_y_scale;
    bool m_dotted_divider;
    static float *copy(size_t, float *);
    static float *copy(size_t, double *);
    void destroy();
};

#endif
