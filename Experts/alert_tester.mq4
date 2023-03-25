//+------------------------------------------------------------------+
//|                                                 alert_tester.mq4 |
//|                                    Copyright 2020 laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020 laserdesign.io"
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
   Alert(iCustom(Symbol(),0,"William Vix-Fix.ex4",0,0));
  }
//+------------------------------------------------------------------+
