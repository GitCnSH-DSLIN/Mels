/**************************************************************************************************
 * ==> Main --------------------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : Main form for the scrollbox containing a MD2 model component demo.               *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#include <vcl.h>
#pragma hdrstop
#include "Main.h"

// std
#include <memory>

#pragma package(smart_init)
#pragma link "UTQRVCLModelComponentGL"
#pragma link "UTQRVCLMD2ModelComponentGL"
#pragma resource "*.dfm"

//--------------------------------------------------------------------------------------------------
TMainForm* MainForm;
//--------------------------------------------------------------------------------------------------
__fastcall TMainForm::TMainForm(TComponent* pOwner) :
    TForm(pOwner)
{}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::FormShow(TObject* pSender)
{
    if (m2Model->CanFocus())
        m2Model->SetFocus();

    UpdateRichEditHeight();
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::btSaveToFileClick(TObject* pSender)
{
    if (!sdSave->Execute())
        return;

    // create a bitmap to receive the model
    std::auto_ptr<TBitmap> pBitmap(new TBitmap());
    pBitmap->PixelFormat = pf32bit;
    pBitmap->AlphaFormat = afPremultiplied;
    pBitmap->SetSize(100, 100);

    // draw model into bitmap
    ::SendMessage(m2Model->Handle, WM_PRINTCLIENT, LPARAM(pBitmap->Canvas->Handle), 0);

    // save bitmap
    pBitmap->SaveToFile(sdSave->FileName);
}
//--------------------------------------------------------------------------------------------------
void TMainForm::UpdateRichEditHeight()
{
    HDC hDC = ::GetDC(reQuakeII->Handle);

    TTextMetric metrics;

    try
    {
        HFONT hSaveFont = (HFONT)::SelectObject(hDC, reQuakeII->Handle);
        ::GetTextMetrics(hDC, &metrics);
        ::SelectObject(hDC, hSaveFont);
    }
    __finally
    {
        ::ReleaseDC(reQuakeII->Handle, hDC);
    }

    int lineHeight = metrics.tmHeight;
    int increase   = reQuakeII->Height;
    int lc         = reQuakeII->Lines->Count;

    if (lc < 1)
        lc = 1;

    reQuakeII->Height         = (lc * lineHeight)         + 8;
    increase                  = reQuakeII->Height         - increase;
    reQuakeII->Parent->Height = reQuakeII->Parent->Height + increase;
}
//--------------------------------------------------------------------------------------------------