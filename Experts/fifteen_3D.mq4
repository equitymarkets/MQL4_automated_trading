//+------------------------------------------------------------------+
//|                                                   fifteen_3D.mq4 |
//|                        Copyright 202o, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

input int period = 21;
input double deviation = 2;
input double boll_high_bound = 1;
input double lot = 1;
input int stop = 10;

input int long_chart = 60;
input int mid_chart = 15;
input int short_chart = 5;

input double vol_multiplier = 1.5;

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
   Comment("fifteen_3D_tester");
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
  
   double boll_high = iBands(Symbol(),0,period,deviation,0,PRICE_CLOSE,1,1);
   double boll_middle = iBands(Symbol(),0,period,deviation,0,PRICE_CLOSE,0,1);
   double boll_low = iBands(Symbol(),0,period,deviation,0,PRICE_CLOSE,2,1);
   
   double band1 = ((boll_high - boll_low)/boll_middle)*100;
   
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_short2 = iVolume(Symbol(),short_chart,2);
   long vol_short1 = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   Alert(iCCI(Symbol(),0,21,PRICE_CLOSE,1));
   
   if(OrdersTotal() < 1 && (iClose(Symbol(),0,1) > iClose(Symbol(),0,2) && band1 > boll_high_bound))
      if(iClose(Symbol(),0,1) > boll_high && iClose(Symbol(),0,0) > iClose(Symbol(),0,1))
         if(vol_short0 > (vol_short1*vol_multiplier))
           {
            double buy_order = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0201,0,clrNONE);   
           }
   if(OrdersTotal() < 1 && (iClose(Symbol(),0,1) < iClose(Symbol(),0,2) && band1 > boll_high_bound))
      if(iClose(Symbol(),0,1) < boll_low  && iClose(Symbol(),0,0) < iClose(Symbol(),0,1))
         if(vol_short0 > (vol_short1*vol_multiplier))
           {
            double sell_order = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0201,0,clrNONE);   
           }
   for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0201)
              {
               if((OrderType() == OP_BUY) && (iClose(Symbol(),0,1) < boll_middle))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 } 
               if((OrderType() == OP_SELL) && (iClose(Symbol(),0,1) > boll_middle))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }
               
           }
        }
  }
//+------------------------------------------------------------------+
