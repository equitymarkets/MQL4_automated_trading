//+------------------------------------------------------------------+
//|                                                    regulator.mq4 |
//|                                   Copyright 2021, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define timecheck 0201

 bool TimeCheck()
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == timecheck)
             {
              datetime close = OrderCloseTime(), now = TimeCurrent();
              if((now - close) > 14400) return(true);
             }
        }
      return(false);
     }
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
//---
  
  }


//+------------------------------------------------------------------+
