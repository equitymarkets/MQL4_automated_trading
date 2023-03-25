//+------------------------------------------------------------------+
//|                                                         mOmO.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Entropy"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int TimeFrame = 60;
extern int MAchoice = 34;
extern int ModeMa = 1;
extern double volume = .1;

//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double minute_close1 = iClose(NULL,1,1);
   double minute_close2 = iClose(NULL,1,2);
   double fifteenminute_open = iOpen(NULL,15,1);
   double fifteenminute_close1 = iClose(Symbol(),PERIOD_M15,0);
   double fifteenminute_close2 = iClose(Symbol(),PERIOD_M15,2);
   //double thirtyminute_open = iOpen(NULL,30,1);
   double thirtyminute_close1 = iClose(NULL,30,1);
   double thirtyminute_close2 = iClose(NULL,30,2);
   //double hourly_open = iOpen(NULL,60,1);
   double hourly_close1 = iClose(NULL,60,1);
   double hourly_close2 = iClose(NULL,60,2);
   
   double fourhour1 = iClose(NULL,15,1);
   double fourhour2 = iClose(NULL,15,2);
   
   double MAClose1 = iMA(NULL,TimeFrame,MAchoice,1,ModeMa,PRICE_CLOSE,0);
   double MAClose2 = iMA(NULL,TimeFrame,MAchoice,2,ModeMa,PRICE_CLOSE,0);
   if(OrdersTotal() < 1 && iMA(Symbol(),15,34,0,MODE_SMA,PRICE_CLOSE,1) > iMA(Symbol(),15,34,0,MODE_SMA,PRICE_CLOSE,2))
      if(fifteenminute_close1 > fifteenminute_open)
         //if(fifteenminute_close1 > fifteenminute_close2)
            //if(minute_close1 > minute_close2)   
               OrderSend(Symbol(),OP_BUY,volume,Ask,0,0,0,NULL,0,0);
   
   
  }
//+------------------------------------------------------------------+



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

