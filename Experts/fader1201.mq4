//+------------------------------------------------------------------+
//|                                                           EA.mq4 |
//|                                  Copyright 2020, laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020 laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

extern double lot = 1;
extern double stop_loss = 20;
extern double take_profit = 100;
extern double CCI_break_top = 350;
extern double CCI_break_bottom = 20;
extern int moving_average_calc = 10;       
extern double limit_amt = 1;
extern int seconds_plus = 600;

double pips;

//+-------------------------------------_-----------------------------+
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
   double CCI1 = iCCI(Symbol(),0,21,PRICE_CLOSE,1);
   double CCI2 = iCCI(Symbol(),0,21,PRICE_CLOSE,2);
   
   Alert(CCI1);
   
   datetime time_exp = TimeCurrent() + seconds_plus;
   
   if(CCI1 > CCI_break_top && OrdersTotal() < 1)
      if(iClose(Symbol(),0,0) > iClose(Symbol(),0,1))
        {
         double sell = OrderSend(Symbol(),ORDER_TYPE_SELL_LIMIT,lot,Bid + (limit_amt * pips),0,0,0,NULL,0,time_exp,clrNONE);
        }
   if(CCI1 < -CCI_break_top && OrdersTotal() < 1)
      if(iClose(Symbol(),0,0) < iClose(Symbol(),0,1))
        {
         
         double buy = OrderSend(Symbol(),ORDER_TYPE_BUY_LIMIT,lot,Ask - (limit_amt * pips),0,0,0,NULL,0,time_exp,clrNONE);
        }
     
   for(int i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (CCI1 > -CCI_break_bottom))
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
               if(OrderType()==OP_SELL && (CCI1 < CCI_break_bottom))
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
