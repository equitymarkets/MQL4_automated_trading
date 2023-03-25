//To-Do; fix volume custom and alert test,
/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2020, laserdesign.io"                                             //0
#property link      "https://www.laserdesign.io"                                                 //0
#property version   "1.00"
#property strict

extern double lot = 1;
extern int moving_average_calc = 21;


extern double ADXbreaksubtraction = 5;
//MA
extern int MA_timeframe = 60;
extern int moving_average_low = 13;
extern int moving_average_mid = 55;
//extern int moving_average_high = 13;
//extern int moving_average_upper = 21;
//Volume


double pips;
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
int OnInit()                                                                                     //0 
  {                                                                                              //0
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {   
      pips = tick * 10;
     }
   else pips = tick;
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
 
   //Layer_2: MA Crossover
   double moving_average_low_calc = iMA(Symbol(),MA_timeframe,moving_average_low,0,MODE_SMA,PRICE_CLOSE,0);
   double moving_average_mid_calc = iMA(Symbol(),MA_timeframe,moving_average_mid,0,MODE_SMA,PRICE_CLOSE,1);
   
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891   
   for(int i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0100)
              {
               if((OrderType() == OP_BUY) && iClose(Symbol(),0,0) < moving_average_low_calc)
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 } 
               if((OrderType() == OP_SELL) && iClose(Symbol(),0,0) > moving_average_low_calc)
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }   
           }
        }
  }