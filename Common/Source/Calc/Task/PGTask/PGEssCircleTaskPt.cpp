/*
 * LK8000 Tactical Flight Computer -  WWW.LK8000.IT
 * Released under GNU/GPL License v.2
 * See CREDITS.TXT file for authors and copyrights
 *  
 * File:   PGEssCircle.cpp
 * Author: Bruno de Lacheisserie
 *
 * Author: bruno
 * 
 * Created on September 20, 2016, 11:47 PM
 */

#include "PGEssCircleTaskPt.h"

PGEssCicrcleTaskPt::PGEssCicrcleTaskPt() {
}

PGEssCicrcleTaskPt::~PGEssCicrcleTaskPt() {
}

void PGEssCicrcleTaskPt::Optimize(const ProjPt& prev, const ProjPt& next, double Alt) {
    PGCicrcleTaskPt::Optimize(prev, ProjPt::null, Alt);
}


