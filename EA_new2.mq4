//+------------------------------------------------------------------+
//|                                                      EA_new2.mq4 |
//|                                                   laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "laserdesign.io"
#property link      "https://www.laserdesign.io"
#property strict

enum chartTimeframe
  {
   CURRENT = 0,
   M1 = 1,
   M5 = 5,
   M15 = 15,
   M30 = 30,
   H1 = 60,
   H4 = 240,
   D1 = 1440,
   W1 = 10080,
   MN = 43200
  };

enum randomTimeEntry 
  {
   RandomOn = 1,
   RandomOff = 0
  };
enum stopLosses
  {
   StopsOn = 1,
   StopsOff = 0
  };
enum takeProfit
  {
   LimitsOn = 1,
   LimitsOff = 0
  };
  
input int MagicNumber = 1234, StopInPips = 5, TakeProfitInPips=5;
input double LotSize = .1;
input chartTimeframe Timeframe = 0;
input randomTimeEntry RandomTimeEntry = 0;
input stopLosses StopLoss = 0;
input takeProfit TakeProfit = 0;

void OrderEntry(int timeframe, bool stop_loss, int stop_in_pips, bool take_profit, int take_profit_in_pips, double lot_size, int magic_number) 
  {
   int entry;
   double stop_price = 0; 
   double take_profit_price = 0;
   if(iClose(_Symbol,timeframe,1) > iClose(_Symbol,timeframe,2))
     {
      if(stop_loss)
        {
         stop_price = Ask - (stop_in_pips*_Point);
        }
      if(take_profit)
        {
         take_profit_price = Ask + (take_profit_in_pips*_Point);
        }
      entry = OrderSend(_Symbol,OP_BUY,lot_size,
      Ask,0,stop_price,take_profit_price,"Buy Entry",magic_number,0,clrGreen);
        {
         if(entry > -1)
           {
            Print("Trade not executed. Reason: ", GetLastError());
           }
         else
           {
            Print("Trade executed."); 
           }
        }
     }
   if(iClose(_Symbol,timeframe,1) < iClose(_Symbol,timeframe,2))
     {
      if(stop_loss)
        {
         stop_price = Bid + (stop_in_pips*_Point);
        }
      if(take_profit)
        {
         take_profit_price = Bid - (take_profit_in_pips*_Point);
        }
      entry = OrderSend(_Symbol,OP_SELL,lot_size,
      Bid,0,stop_price,take_profit_price,"Sell Entry",magic_number,0,clrRed);
        {
         if(entry > -1)
           {
            Print("Trade not executed. Reason: ", GetLastError());
           }
         else
           {
            Print("Trade executed.");
           }   
        }
     }
  }
  
void OrderExit(int timeframe, int magic_number)
  {
   int exit;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && 
         OrderMagicNumber()==magic_number)
           {
            if(OrderType()==OP_BUY)
              {
               if(iClose(_Symbol,timeframe,1) < iClose(_Symbol,
               timeframe,2))
                 {
                  exit = OrderClose(OrderTicket(),OrderLots(),
                  Bid,0,clrBlue);
                    {
                     if(!exit)
                       {
                        Print("Trade not executed. Reason: ", 
                        GetLastError());
                       }
                     else
                       {
                        Print("Trade executed.");
                       }
                    }
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(iClose(_Symbol,timeframe,1) > iClose(_Symbol,
               timeframe,2))
                 {
                  exit = OrderClose(OrderTicket(),OrderLots(),
                  Ask,0,clrBlue);
                    {
                     if(!exit)
                       {
                        Print("Trade not executed. Reason: ", 
                        GetLastError());
                       }
                     else
                       {
                        Print("Trade executed.");
                       }
                    }
                 }
              }    
           }
        }
     }
  }

bool Entropy(int timeframe)
  {
   datetime current_time = TimeCurrent();
   datetime trade_time;
   
   if(timeframe==0)
     {
      trade_time = iTime(_Symbol,Period(),0)+
      (MathRand()/3600)*Period();
     }
   else
     {
      trade_time = iTime(_Symbol,timeframe,0)+
      (MathRand()/3600)*timeframe;
     }
   if((current_time - trade_time) > 0)
     {
      return true;
     }
   return false;
  }

bool IsNewCandle()
  {
   static datetime saved_candle_time;
   if(Time[0] == saved_candle_time)
     {
      return(false);
     }
   else
     {
      saved_candle_time = Time[0];
     }
   return(true);
  } 
  
void OnTick()
  { 
   int timeframe = Timeframe;
   if(timeframe==0)
     {
      timeframe = Period();
     }
   static datetime time_to_trade_addition = ((MathRand()/
   3600)*timeframe);
   
   if(OrdersTotal()==0) 
     { 
      if(!RandomTimeEntry || MarketInfo(Symbol(),MODE_TIME) >= 
      (iTime(Symbol(),timeframe,0) + time_to_trade_addition))
        {
         OrderEntry(timeframe, StopLoss, StopInPips, TakeProfit, TakeProfitInPips, LotSize, MagicNumber);
        }
     }
   else 
     { 
      OrderExit(timeframe, MagicNumber);
      time_to_trade_addition = ((MathRand()/3600)*timeframe);
     }
  }
//+------------------------------------------------------------------+
