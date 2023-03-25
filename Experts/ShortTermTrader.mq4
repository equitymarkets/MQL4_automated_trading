//limit orders with short expiration?
/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2021, laserdesign.io"                                             //0
#property link      "https://www.laserdesign.io"                                                 //0
#property version   "1.00"
#property strict

extern double lot = 1;

//Bollinger
extern int moving_average_calc = 21;

//ADX
extern int adx_timeFrame = 15;
extern int adx_bigTimeFrame = 240;
extern int adx_bigBreak = 25;
extern int ADXma = 14;
extern double ADX_break = 25;

//Volume
extern int vol_timeFrame = 15;
extern double vol_multiplier = 2;

double pips;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Bollinger
   double bollHigh_mid_1 = iBands(Symbol(),0,moving_average_calc,1.5,0,PRICE_CLOSE,1,1);
   double bollMid_mid_1 = iBands(Symbol(),0,moving_average_calc,1.5,0,PRICE_CLOSE,0,1);
   double bollLow_mid_1 = iBands(Symbol(),0,moving_average_calc,1.5,0,PRICE_CLOSE,2,1);
   
   //ADX
   double ADX1 = iADX(Symbol(),adx_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   double ADX2 = iADX(Symbol(),adx_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,2);
   double ADX3 = iADX(Symbol(),adx_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,3);
   double ADX_large = iADX(Symbol(),adx_bigTimeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   
   //Volume
   long vol_mid_0 = iVolume(Symbol(),vol_timeFrame,0);
   long vol_mid_1 = iVolume(Symbol(),vol_timeFrame,1);
   long vol_mid_2 = iVolume(Symbol(),vol_timeFrame,2);
   
   
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891   
   if(OrdersTotal() < 1 && adx_bigTimeFrame > adx_bigBreak)
      if(iClose(Symbol(),0,1) > bollHigh_mid_1 && iClose(Symbol(),0,1) > iClose(Symbol(),0,2))
         if((ADX1 > ADX_break) && (ADX1 > ADX2) && (ADX2 > ADX3))
            if((ADX1 - ADX2) > (ADX2 - ADX3))
               if(vol_mid_0 > (vol_mid_1 * vol_multiplier))  
                 {
                  double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0100,0,clrNONE);
                 }
   if(OrdersTotal() < 1 && adx_bigTimeFrame > adx_bigBreak)
      if(iClose(Symbol(),0,1) < bollLow_mid_1 && iClose(Symbol(),0,1) < iClose(Symbol(),0,2))
         if((ADX1 > ADX_break) && (ADX1 > ADX2) && (ADX2 > ADX3))
            if((ADX1 - ADX2) > (ADX2 - ADX3))
               if(vol_mid_0 > (vol_mid_1 * vol_multiplier))
                 {
                  double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0100,0,clrNONE);
                  
                 }
    for(int i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0100)
              {
               if((OrderType() == OP_BUY) && (iClose(Symbol(),0,1) < bollMid_mid_1))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  
                 } 
               if((OrderType() == OP_SELL) && (iClose(Symbol(),0,1) > bollMid_mid_1))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  
                 }
               
              }   
           }
        }
      
  }
//+------------------------------------------------------------------+
