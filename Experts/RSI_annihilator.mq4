//+------------------------------------------------------------------+
//|                                              RSI_annihilator.mq4 |
//|                                   Copyright 2020 laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020 laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

input double lot = 1;
input double stop_loss = 50;
input double take_profit = 100;
input double RSI_top = 70;
input double RSI_middle = 50;
input double RSI_bottom = 30;

int RSI_period = 14;
int RSI_price = 0;               //0=PRICE_CLOSE, 1=PRICE_OPEN ETC.

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
   double RSI0 = iRSI(Symbol(),0,RSI_period,RSI_price,0);
   double RSI1 = iRSI(Symbol(),0,RSI_period,RSI_price,1);
   double RSI2 = iRSI(Symbol(),0,RSI_period,RSI_price,2);
   
   static bool trend = false;
   
   
   
   if(OrdersTotal() < 1)
      if(RSI1 < RSI_bottom && RSI1 < RSI2)
         if(RSI0 < RSI1)
        {
         double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0200,0,clrNONE);
        }
   if(OrdersTotal() < 1)
      if(RSI2 > RSI_top && RSI1 > RSI2)
         if(RSI0 > RSI1)
        {
         double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0201,0,clrNONE);
        }
    for(i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0200)
              {
               if((OrderType() == OP_BUY) && (RSI1 > RSI_middle))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               }
            if(OrderMagicNumber() == 0201)
              { 
               if((OrderType() == OP_SELL) && (RSI1 < RSI_middle))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }   
           }
        }
  }
//+------------------------------------------------------------------+
