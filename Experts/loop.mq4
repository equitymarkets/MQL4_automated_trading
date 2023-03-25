//+------------------------------------------------------------------+
//|                                                           EA.mq4 |
//|                                   Copyright 2020 laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

extern double lot = .1;
extern double stop_loss = 50;
extern double take_profit = 100;

//////ADX variables
extern int timeFrame = 0;
extern int ADXma = 14;
double pips;

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
   //iADX(NULL,0,14,PRICE_HIGH,MODE_PLUSDI,0)
   double ADX1 = iADX(Symbol(),timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   Alert(ADX1);
   if(OrdersTotal() < 1 &&  ADX1 > .3)
     {
      double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0,0,clrNONE);
     }
   if(OrdersTotal() < 1)
     {
      double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0,0,clrNONE);
     }
   for(int i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY)
               {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1)
                     Alert("Trade Executed");
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
            }
  }
//+------------------------------------------------------------------+
