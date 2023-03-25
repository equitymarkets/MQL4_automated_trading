//+------------------------------------------------------------------+
//|                                                            C.mq4 |
//|                                   Copyright 2022, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

input int input_var = 45;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   const unsigned int COUNT = 10;
   unsigned int i = 11;

   do 
     {
        Alert("[" + i + "] I love C++");
        ++i;
     } while (i < COUNT);
int Arr[] = {34,24,64,18,44}; 
int xeno = 156;


Alert(xeno);
int int_data = 56;




Alert(ArraySize(Arr));
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
