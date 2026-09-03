/*
 * Minimal <strings.h> shim for MSVC.
 *
 * The Gumbo parser bundled with litehtml includes the POSIX header
 * <strings.h> and uses strcasecmp()/strncasecmp(). MSVC has no such header
 * and names those functions _stricmp()/_strnicmp() instead.
 *
 * This directory is only added to the include path when building with MSVC
 * (see litehtml.pri); on other platforms the system <strings.h> is used.
 */
#if defined(_MSC_VER)

#ifndef CSOUNDQT_COMPAT_STRINGS_H
#define CSOUNDQT_COMPAT_STRINGS_H

#include <string.h>

#ifndef strcasecmp
#define strcasecmp _stricmp
#endif

#ifndef strncasecmp
#define strncasecmp _strnicmp
#endif

#endif /* CSOUNDQT_COMPAT_STRINGS_H */

#endif /* _MSC_VER */
