//+------------------------------------------------------------------+
//|                                                        timer.mq4 |
//|                                   Copyright 2021, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define timer 120921


input double lot = .1;


input int MA_1 = 21;
input int MA_2 = 55;

double pips;

bool CheckOpenOrders()
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         int check = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol() == Symbol()) 
               return(true);
        }
      return(false);
     }
     
bool CheckProfit()
     {
      for(int i = 0; i < OrdersTotal(); i++) 
        {
         int check = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
              {
               if(OrderProfit() > 0) return(true); 
              }
        }
            return(false);
     }  




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
   struct PriceVariable
     {
      double price;
      double price_1;
      double price_2;
     }pv;
     
   struct MovingAVG
     {
      double MA_low;
      double MA_high;
     }ma;  
      
   pv.price = iClose(Symbol(),0,0);
   pv.price_1 = iClose(Symbol(),0,1);
   pv.price_2 = iClose(Symbol(),0,2);
      
   ma.MA_low = iMA(Symbol(),0,MA_1,0,MODE_SMA,PRICE_CLOSE,1);
   ma.MA_high = iMA(Symbol(),0,MA_2,0,MODE_SMA,PRICE_CLOSE,1); 
   
   if(CheckOpenOrders() == false)
      if(pv.price_1 > pv.price_2)
         if(ma.MA_low > ma.MA_high)
           {
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",timer,0,clrNONE);
           }
   if(CheckOpenOrders() == false)
      if(pv.price_1 < pv.price_2)
         if(ma.MA_low < ma.MA_high)
           {
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",timer,0,clrNONE);
           }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
  for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == timer)
              {
               if(OrderType() == OP_BUY) 
                  if(OrderProfit() < 0)
                    { 
                     if((DayOfWeek() == 2 || DayOfWeek() == 3) && (iTime(Symbol(),0,1)-OrderOpenTime()> 345600))
                       {
                        double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE); 
                       }
                     if((DayOfWeek() == 4 || DayOfWeek() == 5 || DayOfWeek() == 6) && (iTime(Symbol(),0,1)-OrderOpenTime() > 172800))
                       {
                        double long_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                       }
                    }
                  if(pv.price_1 < pv.price_2)
                    {
                     double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                    }
               if(OrderType() == OP_SELL) 
                  if(OrderProfit() < 0)
                    { 
                     if((DayOfWeek() == 2 || DayOfWeek() == 3) && (iTime(Symbol(),0,1)-OrderOpenTime()> 345600))
                       {
                        double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                       }
                     if((DayOfWeek() == 4 || DayOfWeek() == 5 || DayOfWeek() == 6) && (iTime(Symbol(),0,1)-OrderOpenTime()> 172800))
                       {
                        double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                       }
                    }
                  if(pv.price_1 < pv.price_2)
                    {
                     double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                    }
              }
               
           }
        }
  }
//+------------------------------------------------------------------+
