//+------------------------------------------------------------------+
//|                                                       Layers.mq4 |
//|                                  Copyright 2020, laserdesign.io. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, laserdesign.io"
#property description "Let's experiment with a 3 dimensional (3 layer) trading system."
#property link      "https://www.laserdesign.io"




input int long_chart = 240;
input int mid_chart = 60;
input int short_chart = 5;
input int MA_fast = 13;
input int MA_slow = 34;
input double lots = .5;

input int MagicNumber = 4321;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
   Comment("Layers EA initialized.");
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {

   
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   
   double close_price_long = iClose(Symbol(),long_chart,1);
   double close_price_mid = iClose(Symbol(),mid_chart,1);
   double close_price_short0 = iClose(Symbol(),short_chart,0);
   double close_price_short1 = iClose(Symbol(),short_chart,1);
   
   double ima_slow0 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_slow1 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_slow2 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,2);
   double ima_fast0 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_fast1 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_fast2 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,2);
  
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   //Opening Orders    
      if(OrdersTotal()<1)
        {
         if((close_price_mid > close_price_long) && (ima_fast1 > ima_slow1) && (ima_slow1 > ima_slow2) && (vol_short/5 > vol_mid/60) && (vol_mid/60 > vol_long/240) && (vol_short0 > vol_short) && (ima_fast0 > ima_slow1))
           {
            if(close_price_short0 > close_price_short1)
              {
               double buy_order = OrderSend(Symbol(),OP_BUY,lots,Ask,0,0,0,NULL,MagicNumber,0,clrNONE);
              }
           } 
        } 
      if(OrdersTotal()<1)
        {
         if((close_price_mid < close_price_long) && (ima_fast1 < ima_slow1) && (ima_slow1 < ima_slow2) && (vol_short/5 > vol_mid/60) && (vol_mid/60 > vol_long/240) && (vol_short0 > vol_short) && (ima_fast0 < ima_slow1))
           {
            if(close_price_short0 < close_price_short1)
              {
               double sell_order = OrderSend(Symbol(),OP_SELL,lots,Bid,0,0,0,NULL,MagicNumber,0,clrNONE);
             
              }
           } 
        }    
   //Closing Orders
      for(int i; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if((OrderType() == OP_BUY) && (ima_fast0 < ima_slow1))
              {
               double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
              }
           }
        }
      for(int i; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if((OrderType() == OP_SELL) && (ima_fast0 > ima_slow1))
              {
               double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
              }
           }
        }
   }
//+------------------------------------------------------------------+
