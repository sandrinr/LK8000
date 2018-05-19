/*
 * LK8000 Tactical Flight Computer -  WWW.LK8000.IT
 * Released under GNU/GPL License v.2
 * See CREDITS.TXT file for authors and copyrights
 *
 * File:   IOIOUartPort.cpp
 * Author: Bruno de Lacheisserie
 */


#include "IOIOUartPort.h"
#include "Main.hpp"
#include "Android/IOIOHelper.hpp"

bool IOIOUartPort::CreateBridge() {

    bridge = ioio_helper->openUart(Java::GetEnv(), _ID, _baud);

    return (bridge);
}
