/*
    L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
    L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
    L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
    L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
    LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

extern double lot = 1;
extern int moving_average_calc = 21;

//////ADX variables
extern int timeFrame = 240;
extern int ADXma = 14;
extern double ADXbreak = 25;
extern double ADXbreakaddition = 0;
extern double ADXbreaksubtraction = 5;
extern bool is_trade_allowed = true;

//////Boll variables
extern double high_band_value = 1;
extern double low_band_value = .3;
extern double stop_loss = 50;
extern double take_profit = 250;
extern int long_chart = 240;
extern int mid_chart = 60;
extern int short_chart = 5;
extern int mini_chart = 1;
extern double limit_pips = 1;

//////RSI variables
extern double RSI_top = 70;
extern double RSI_middle = 50;
extern double RSI_bottom = 30;
extern int RSI_period = 21;
extern int RSI_price = 0; 

double pips;

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

void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double ADX1 = iADX(Symbol(),timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   double ADX2 = iADX(Symbol(),timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,2);
   double Boll_higher = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,1,1);
   double Boll_middle = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,0,1);
   double Boll_lower = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,2,1);
   double band1 = ((Boll_higher - Boll_lower)/Boll_middle)*100;
   
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_mini = iVolume(Symbol(),mini_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   double RSI0 = iRSI(Symbol(),60,RSI_period,RSI_price,0);
   double RSI1 = iRSI(Symbol(),60,RSI_period,RSI_price,1);
   double RSI2 = iRSI(Symbol(),60,RSI_period,RSI_price,2);
   double ima = iMA(Symbol(),0,moving_average_calc,0,MODE_SMA,PRICE_CLOSE,1);
   
   if(OrdersTotal() < 1)
      //Trend
      if(ADX1 > ADXbreak)
        {
         if(band1 > high_band_value)
            if(OrdersTotal() < 1 && band1 > high_band_value)
               if(iClose(Symbol(),0,1) > Boll_higher && (iClose(Symbol(),0,1) > iClose(Symbol(),0,2)))
                  if(vol_short0/3 > vol_short/5)
                     double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),Ask + (take_profit * pips),NULL,0100,0,clrNONE);
            if(OrdersTotal() < 1 && band1 > high_band_value)
               if(iClose(Symbol(),0,1) < Boll_lower  && (iClose(Symbol(),0,1) < iClose(Symbol(),0,2)))
                  if(vol_short0/3 > vol_short/5)
                     double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),Bid - (take_profit * pips),NULL,0100,0,clrNONE); 
        }
      //Range
      if(ADX1 < ADXbreak - ADXbreaksubtraction)  
         if(OrdersTotal() < 1 && iClose(Symbol(),0,1) < ima)
            if(RSI2 < RSI_bottom && RSI1 > RSI2)
              {
               double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0,NULL,0200,0,clrNONE);
              }
         if(OrdersTotal() < 1 && iClose(Symbol(),0,1) > ima)
            if(RSI2 > RSI_top && RSI1 > RSI2)
              {
               double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0,NULL,0200,0,clrNONE);
              }
  
     
        //Closing Orders
      for(int i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0100)
              {
               if((OrderType() == OP_BUY) && (iClose(Symbol(),0,1) < Boll_middle))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 } 
               if((OrderType() == OP_SELL) && (iClose(Symbol(),0,1) > Boll_middle))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }   
           }
        }
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0200)
              {
               if(OrderType() == OP_BUY && iClose(Symbol(),0,1) > ima)
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && iClose(Symbol(),0,1) < ima)
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
             
           }
        }
     
  }
  
//+------------------------------------------------------------------+
