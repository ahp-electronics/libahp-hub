/**
*    MIT License
*
*    libahp_hub library to drive the AHP HUB controllers
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

#include "ahp_hub.h"
#include "rs232.c"
#include <pthread.h>
#include <urjtag.h>

static int mutexes_initialized = 0;
static pthread_mutexattr_t mutex_attr;
static pthread_mutex_t mutex;
static unsigned int ahp_hub_connected = 0;

static int program_jtag(const char *svf_file, const char *drivername, const char *bsdl_path, long frequency)
{
    int ret = 1;
    urj_chain_t *chain;
    const urj_cable_driver_t *driver;
    chain = urj_tap_chain_alloc ();
    if(bsdl_path != NULL)
        urj_bsdl_set_path (chain, bsdl_path);
    driver = urj_tap_cable_find (drivername);
    urj_cable_t *cable = urj_tap_cable_usb_connect (chain, driver, NULL);
    urj_tap_cable_set_frequency (cable, frequency);
    int ndevs = urj_tap_detect(chain, 32);
    if(ndevs == URJ_STATUS_OK) {
        FILE *svf = fopen(svf_file, "r");
        if(svf != NULL) {
            urj_svf_run (chain, svf, 0, 0);
            if(URJ_STATUS_OK)
                ret = 0;
            fclose (svf);
        }
    }
    urj_tap_chain_free(chain);
    return ret;
}
int ahp_hub_connect_fd(int fd)
{
    if(ahp_hub_is_connected())
        return 0;
    if(fd != -1) {
        ahp_serial_SetFD(fd, 9600);
        ahp_hub_connected = 1;
    }
    return 1;
}

int ahp_hub_get_fd()
{
    if(!ahp_hub_is_connected())
        return -1;
    return ahp_serial_GetFD();
}

int ahp_hub_connect(const char* port)
{
    if(ahp_hub_is_connected())
        return 0;
    if(!ahp_serial_OpenComport(port)) {
        if(!ahp_serial_SetupPort(9600, "8N1", 0)) {
            ahp_hub_connected = 1;
            return 0;
        }
        ahp_serial_CloseComport();
    }
    return 1;
}

void ahp_hub_disconnect()
{
    if(ahp_hub_is_connected()) {
        ahp_serial_CloseComport();
        if(mutexes_initialized) {
            pthread_mutex_unlock(&mutex);
            pthread_mutex_destroy(&mutex);
            pthread_mutexattr_destroy(&mutex_attr);
            mutexes_initialized = 0;
        }
        ahp_hub_connected = 0;
    }
}

int ahp_hub_load_firmware(const char *svf_file, const char *bsdl_path)
{
    return program_jtag(svf_file, "dirtyjtag", bsdl_path, 1000000);
}

unsigned int ahp_hub_is_connected()
{
    return ahp_hub_connected;
}

void ahp_hub_send_command(unsigned char* buf, size_t len)
{
    ahp_serial_SendBuf(buf, len);
}
