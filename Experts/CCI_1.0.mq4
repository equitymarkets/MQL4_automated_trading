//+------------------------------------------------------------------+
//|                                                           EA.mq4 |
//|                        Copyright 2020 . |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double lot = 1;
extern double stop_loss = 50;
extern double take_profit = 100;
extern double CCI_break_top = 100;
extern double CCI_break_bottom = 90;
extern int moving_average_calc = 55;       
extern double limit_amt = 1;
extern int seconds_plus = 600;

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
   double ma1 = iMA(Symbol(),0,moving_average_calc,0,MODE_SMA,PRICE_CLOSE,1);
   double price_time_1 = iClose(Symbol(),0,1); 
   double price_time_2 = iClose(Symbol(),0,2);
   double CCI1 = iCCI(Symbol(),0,moving_average_calc,PRICE_CLOSE,1);
   double CCI2 = iCCI(Symbol(),0,moving_average_calc,PRICE_CLOSE,2);
   double CCI3 = iCCI(Symbol(),0,moving_average_calc,PRICE_CLOSE,3);
   
   if(OrdersTotal() < 1)
      if(CCI1 > CCI_break_top)
         if((CCI1-CCI2)>(CCI2-CCI3))
           {
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0,0,clrNONE);
           }
   if(OrdersTotal() < 1)
      if(CCI1 < -CCI_break_top)
         if((CCI1-CCI2)<(CCI2-CCI3))
      
           {
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0,0,clrNONE);
           }
           
   for(int i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (CCI1 < CCI_break_bottom))
               {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1)
                     Alert("Trade Executed");
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_SELL && (CCI1 > -CCI_break_bottom))
               {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1)
                    
                     Alert("Trade Executed");
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
           }
  }
//+------------------------------------------------------------------+