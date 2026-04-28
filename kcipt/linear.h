//
// MATLAB Compiler: 5.1 (R2014a)
// Date: Wed Jan 25 16:58:52 2017
// Arguments: "-B" "macro_default" "-W" "cpplib:linear" "-T" "link:lib"
// "linear_permutation.m" "-C" 
//

#ifndef __linear_h
#define __linear_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_linear
#define PUBLIC_linear_C_API __global
#else
#define PUBLIC_linear_C_API /* No import statement needed. */
#endif

#define LIB_linear_C_API PUBLIC_linear_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_linear
#define PUBLIC_linear_C_API __declspec(dllexport)
#else
#define PUBLIC_linear_C_API __declspec(dllimport)
#endif

#define LIB_linear_C_API PUBLIC_linear_C_API


#else

#define LIB_linear_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_linear_C_API 
#define LIB_linear_C_API /* No special import/export declaration */
#endif

extern LIB_linear_C_API 
bool MW_CALL_CONV linearInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_linear_C_API 
bool MW_CALL_CONV linearInitialize(void);

extern LIB_linear_C_API 
void MW_CALL_CONV linearTerminate(void);



extern LIB_linear_C_API 
void MW_CALL_CONV linearPrintStackTrace(void);

extern LIB_linear_C_API 
bool MW_CALL_CONV mlxLinear_permutation(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                        *prhs[]);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_linear
#define PUBLIC_linear_CPP_API __declspec(dllexport)
#else
#define PUBLIC_linear_CPP_API __declspec(dllimport)
#endif

#define LIB_linear_CPP_API PUBLIC_linear_CPP_API

#else

#if !defined(LIB_linear_CPP_API)
#if defined(LIB_linear_C_API)
#define LIB_linear_CPP_API LIB_linear_C_API
#else
#define LIB_linear_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_linear_CPP_API void MW_CALL_CONV linear_permutation(int nargout, mwArray& P, const mwArray& D);

#endif
#endif
