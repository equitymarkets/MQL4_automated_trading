//+------------------------------------------------------------------+
//|                                                        aLERT.mq4 |
//|                                   Copyright 2021, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   Alert(TimeCurrent() + MathRand());
   Sleep(5000);
   Alert(MarketInfo(Symbol(),MODE_TIME));
   Sleep(5000);
   
  }
//+------------------------------------------------------------------+
