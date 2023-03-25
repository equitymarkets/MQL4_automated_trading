//+------------------------------------------------------------------+
//|                                                         book.mq4 |
//|                                   Copyright 2021, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

double My_function(double alpha, double betta)
  {
   alpha = alpha * alpha + betta * betta;
   alpha = MathSqrt(alpha);
   return(alpha);
  }
  
datetime time_check()
  {
   return(iTime(Symbol(),0,3)); 
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
   Alert(time_check()); 
   
   Sleep(1000000000);
  }
//+------------------------------------------------------------------+
