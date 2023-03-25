//+------------------------------------------------------------------+
//|                                                    functions.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define MAGICNUM 101320

input double lots = .1;
input int MA1 = 8;
input int MA2 = 13;
input int MA3 = 21;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("functions.mql4 Initialized");
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
   //Comment("Initialized");
   
  }
//+------------------------------------------------------------------+
