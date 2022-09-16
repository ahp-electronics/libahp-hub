/**
* \license
*    MIT License
*
*    libahp_hub library to drive the AHP XC HUB control port
*    Copyright (C) 2021  Ilia Platone
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
*/

#ifndef _AHP_HUB_H
#define _AHP_HUB_H

#ifdef  __cplusplus
extern "C" {
#endif
#ifdef _WIN32
#include <windows.h>
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT extern
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>

/**
* \mainpage AHP® HUB Controllers driver library API Documentation
* \section Introduction
*
* The AHP HUB is a special device used for smart communication with the XC cross-correlators<br>
* <br>
* This software is meant to work with the HUB series motor controllers
* visit https://www.iliaplatone.com/xc-hub for more informations and purchase options.
*
* \author Ilia Platone
* \version @AHPHUB_VERSION@
* \date 2017-2021
* \copyright MIT License.
*/

/**
 * \defgroup HUB_API AHP® HUB Controllers API
 *
 * This library contains functions for direct low-level usage of the AHP motor controllers.<br>
 *
 * This documentation describes utility, applicative and hardware control functions included into the library.<br>
 * Each section and component is documented for general usage.
*
* \{
* \defgroup Defs Types
* \{*/

/**\}
 * \defgroup Defines Defines
 *\{*/
///AHP_HUB_VERSION This library version
#define AHP_HUB_VERSION @AHP_HUB_VERSION@

/**\}
 * \defgroup Conn Connection
 * \{*/

 /**
 * \brief Obtain the current libahp-hub version
 * \return The current API version
 */
 DLL_EXPORT inline unsigned int ahp_hub_get_version(void) { return AHP_HUB_VERSION; }

/**
* \brief Connect to the HUB controller
* \param port The serial port filename
* \return non-zero on failure
*/
DLL_EXPORT int ahp_hub_connect(const char* port);

/**
* \brief Connect to the HUB controller using an existing file descriptor
* \param fd The serial stream file descriptor
* \return non-zero on failure
*/
DLL_EXPORT int ahp_hub_connect_fd(int fd);

/**
* \brief Return the file descriptor of the port connected to the HUB controllers
* \param fd The serial stream file descriptor
* \return The serial stream file descriptor
*/
DLL_EXPORT int ahp_hub_get_fd();

/**
* \brief Disconnect from the HUB controller
*/
DLL_EXPORT void ahp_hub_disconnect();

/**
* \brief Get the file descriptor that links to the controller
* \return The file descriptor
* \sa ahp_hub_connect
*/
DLL_EXPORT int ahp_hub_get_fd();

/**
* \brief Report connection status
* \return non-zero if already connected
* \sa ahp_hub_connect
* \sa ahp_hub_connect_fd
* \sa ahp_hub_disconnect
*/
DLL_EXPORT unsigned int ahp_hub_is_connected();

/**
* \brief Download an svf firmware file to the device
* \param svf_file The path of the firmware file
* \param bsdl_path The path of the BSDL boundary scan description file
* \return non-zero if any error occured
*/
DLL_EXPORT int ahp_hub_flash_svf(const char *svf_file, const char *bsdl_path);

/**
* \brief Download a dfu firmware file to the device
* \param dfu_file The path of the firmware file
* \param progress The progress in percent of this operation passed by reference
* \param finished When complete thi variable is set to 1 by reference
* \return non-zero if any error occured
*/
DLL_EXPORT int ahp_hub_flash_dfu(const char *dfu_file, int *progress, int *finished);

/**\}
 * \defgroup SG Communication
 * \{*/

 /**
 * \brief Send a command to the control port
 * \param buf the command string or buffer
 * \param len the length of the command in bytes
 * \sa ahp_hub_connect
 * \sa ahp_hub_connect_fd
 * \sa ahp_hub_disconnect
 */
 DLL_EXPORT void ahp_hub_send_command(unsigned char* buf, size_t len);

#ifdef __cplusplus
} // extern "C"
#endif

/**\}
 * \}*/
#endif //_AHP_HUB_H
