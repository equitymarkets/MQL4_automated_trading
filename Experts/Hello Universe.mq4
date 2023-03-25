//+------------------------------------------------------------------+
//|                                               Hello Universe.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

        
//double Hash() {
      
      
      //}
int OnInit() {
   
  
   
   Comment(" \nHello Universe!! This is the " + Period() + "\nM Chart and this is the " + Symbol() + " currency pair");
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
  // Alert(" Welcome! Libraries are set to " + IsLibrariesAllowed());
  }
//+------------------------------------------------------------------+
