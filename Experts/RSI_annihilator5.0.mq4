//+------------------------------------------------------------------+
//|                                              RSI_annihilator.mq4 |
//|                                   Copyright 2020 laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020 laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

extern double lot = 1;
extern double stop_loss = 25;
extern double take_profit = 100;
extern double RSI_top = 70;
extern double RSI_middle = 50;
extern double RSI_bottom = 30;
extern int long_chart = 60;
extern int mid_chart = 5;
extern int short_chart = 1;
extern int vol_divisor = 5;
extern int moving_average_short = 8;
extern int moving_average_long = 13;

extern int RSI_period = 14;
extern int RSI_price = 0;               //0=PRICE_CLOSE, 1=PRICE_OPEN ETC.

double pips;
int i;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
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
   double close_price_1 = iClose(Symbol(),0,1);
   double close_price_2 = iClose(Symbol(),0,2);
   double RSI0 = iRSI(Symbol(),60,RSI_period,RSI_price,0);
   double RSI1 = iRSI(Symbol(),60,RSI_period,RSI_price,1);
   double RSI2 = iRSI(Symbol(),60,RSI_period,RSI_price,2);
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid2 = iVolume(Symbol(),0,2);
   long vol_mid1 = iVolume(Symbol(),mid_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   double ima_short = iMA(Symbol(),0,moving_average_short,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_long = iMA(Symbol(),0,moving_average_long,0,MODE_SMA,PRICE_CLOSE,1);
   
   static bool trend = false;
   
   
   
   if(OrdersTotal() < 1)
      if(RSI1 < RSI_bottom && RSI1 < RSI2)
         //if(RSI0 > RSI_bottom)
            //if(close_price_1 >= close_price_2)
            //if(vol_short < vol_mid1/vol_divisor)
               //if(vol_short0 > vol_short)
                  if(ima_short > ima_long)
                     //if(vol_short < vol_mid1/vol_divisor)
                     if(iOpen(Symbol(),15,1) > iOpen(Symbol(),15,2))
                 {
                  double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0,NULL,0200,0,clrNONE);
                 }
   if(OrdersTotal() < 1)
      if(RSI2 > RSI_top && RSI1 > RSI2)
         //if(RSI0 < RSI_top)
            //if(close_price_1 < close_price_2)
            //if(vol_short < vol_mid1/vol_divisor)
               //if(vol_short0 > vol_short)
                  if(ima_short < ima_long)
                  if(iOpen(Symbol(),15,1) < iOpen(Symbol(),15,2))
                    {
                     double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0,NULL,0201,0,clrNONE);
                    }
    for(i = 0; i < OrdersTotal(); i++) 
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber() == 0200)
           {
            if((OrderType() == OP_BUY) && (RSI1 > RSI_middle - 5))
              {
               double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
              }
            }
         if(OrderMagicNumber() == 0201)
           { 
            if((OrderType() == OP_SELL) && (RSI1 < RSI_middle + 5))
              {
               double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
              }
            
           }   
        }
     }
  }
//+------------------------------------------------------------------+
