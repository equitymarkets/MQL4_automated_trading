//+------------------------------------------------------------------+
//|                                                        noise.mq4 |
//|                                   Copyright 2022, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

/*double AdjustPrice(double const arg)
     {
      double v0, v1;
      if(m_Infos.TypeSymbol == OTHER)
         return arg;
      v0 = (m_Infos.TypeSymbol == WDO ? round(arg * 10.0) : round(arg));
      v1 = fmod(round(v0), 5.0);
      v0 = ((v1 != 0) || (v1 != 5) ? v1 : 0);
      return (m_Infos.TypeSymbol == WDO ? v0 / 10.0 : v0);
     }*/
/*int x = 6;
int a = (x == 5 ? 10 : 15);*/
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
   Alert(TerminalPath());   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
