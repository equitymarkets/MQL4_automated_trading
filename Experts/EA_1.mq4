/*

 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
 
*/

#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double pips;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
     {
      double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(tick == .00001 || tick == .001)
        {
         pips = tick * 10;
        }
      else pips = tick;   
     }
//---
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
//---
   
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
