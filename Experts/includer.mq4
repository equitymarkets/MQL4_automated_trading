#include <includerheader.mqh>

extern int num1=10;
extern int num2=25;





void OnTick()
  {
//---
   //Comment("laserdesign.io");
   Comment("The number is " + numcalc(num1, num2));
  }
//+------------------------------------------------------------------+
