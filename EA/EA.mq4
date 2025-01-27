//+------------------------------------------------------------------+
//|                                                      EA_new2.mq4 |
//|                                                   laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "laserdesign.io"
#property link      "https://www.laserdesign.io"
#property strict

input group "Trade Settings";

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
   TakeProfitOn = 1,
   TakeProfitOff = 0
  };
enum paperTradeTest
  {
   WeekendPaperTraderOn = 1,
   WeekendPaperTraderOff = 0
  };

input int MagicNumber = 1234, StopInPoints = 60, 
TakeProfitInPoints = 60;
input double LotSize = .1;
input int MovingAverage = 21;
input int MovingAverageType = MODE_SMA;

input chartTimeframe Timeframe = 0;
input randomTimeEntry RandomTimeEntry = 0;
input stopLosses StopLoss = 0;
input takeProfit TakeProfit = 0;
input paperTradeTest PaperTradeTest = 0;

void OrderEntry(int timeframe, bool stop_loss, 
int stop_in_points, bool take_profit, int take_profit_in_points, 
double lot_size, int moving_average, 
int moving_average_type, int magic_number) 
  {
   double ima_1 = iMA(_Symbol,timeframe,moving_average,0,
   moving_average_type,PRICE_CLOSE,1);

   double ima_2 = iMA(_Symbol,timeframe,moving_average,0,
   moving_average_type,PRICE_CLOSE,2);

   double close_price_1 = (iClose(_Symbol,timeframe,1));
   double close_price_2 = (iClose(_Symbol,timeframe,2));
  
   int entry;
   double stop_price = 0; 
   double take_profit_price = 0;

   if(close_price_1 > close_price_2 && ima_1 >= ima_2 && close_price_1 >= ima_1)  
     {
      if(stop_loss)
        {
         stop_price = Ask - (stop_in_points*_Point);
        }
      if(take_profit)
        {
         take_profit_price = Ask + (take_profit_in_points*_Point);
        }
        
      entry = OrderSend(_Symbol,OP_BUY,lot_size,
      Ask,0,stop_price,take_profit_price,"Buy Entry",
      magic_number,0,clrGreen);
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
   if(close_price_1 < close_price_2 && ima_1 <= ima_2 && close_price_1 <= ima_1) 
     {
      if(stop_loss)
        {
         stop_price = Bid + (stop_in_points*_Point);
        }
      if(take_profit)
        {
         take_profit_price = Bid - (take_profit_in_points*_Point);
        }
      entry = OrderSend(_Symbol,OP_SELL,lot_size,
      Bid,0,stop_price,take_profit_price,"Sell Entry",
      magic_number,0,clrRed);
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

  
bool OrderExit(int timeframe, int moving_average, 
int moving_average_type,int magic_number)
  {
   int exit;
   double close_price_1 = (iClose(_Symbol,timeframe,1));
   double ima_1 = iMA(_Symbol,timeframe,moving_average,0,
   moving_average_type,PRICE_CLOSE,1);

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol && 
         OrderMagicNumber()==magic_number)
           {
            if(OrderType()==OP_BUY)
              {
               if(close_price_1 <= ima_1)
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
                        if(OrderProfit() > 0)
                          {
                           return true;
                          }
                        Print("Trade executed.");
                       }
                    }
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(close_price_1 >= ima_1)
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
                        if(OrderProfit() > 0)
                          {
                           return true;
                          }
                        Print("Trade executed.");
                       }
                    }
                 }
              }    
           }
        }
     }
   return false;
  }
  
bool PaperTradeTester(int timeframe,
int moving_average,int moving_average_type)
  {  
   double ima_1 = iMA(_Symbol,timeframe,moving_average,0,
   moving_average_type,PRICE_CLOSE,1);

   double ima_2 = iMA(_Symbol,timeframe,moving_average,0,
   moving_average_type,PRICE_CLOSE,2);

   double close_price_1 = (iClose(_Symbol,timeframe,1));
   double close_price_2 = (iClose(_Symbol,timeframe,2));

   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
     
   if(paper_buy == false) 
     {
      if(close_price_1 > close_price_2 && ima_1 >= ima_2 && close_price_1 >= ima_1) 
        {
         paper_buy = true;
         paper_buy_price = close_price_1;
        }
     }
   if(paper_buy == true) 
     {
      if(close_price_1 < ima_1)
        {
         paper_buy = false;
         if(close_price_1 > paper_buy_price)
           {
            return true;
           }
        }
     }
   
   if(paper_sell == false) 
     {
      if(close_price_1 < close_price_2 && ima_1 <= ima_2 && close_price_1 <= ima_1) 
        {
         paper_sell = true;
         if(paper_sell == true) 
           {
            paper_sell_price = close_price_1;
           }
        }
     }
     
   if(paper_sell == true) 
     {
      if(close_price_1 > ima_1)
        {
         paper_sell = false;
         if(close_price_1 < paper_sell_price)
           {
            return true;
           }
        }
     }
   return false;
  }
  
void OnTick()
  { 
   int timeframe = Timeframe;
   if(timeframe==0)
     {
      timeframe = Period();
     }
     
   static bool trade_allowed = false;
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   if(PaperTradeTest)
     {
      if(trade_allowed == false)
        {
         bool paper_test = PaperTradeTester(timeframe,MovingAverage,MovingAverageType);
         if(paper_test==true)
           {
            trade_allowed=true;
           }
        }
     }
   
   static datetime time_to_trade_addition = ((MathRand()/
   3600)*timeframe);
   
   if(OrdersTotal()==0) 
     {
      if(!PaperTradeTest || trade_allowed)
        { 
         if(!RandomTimeEntry || MarketInfo(Symbol(),MODE_TIME) >= 
         (iTime(Symbol(),timeframe,0) + time_to_trade_addition))
           {
            OrderEntry(timeframe, StopLoss, StopInPoints, TakeProfit, 
            TakeProfitInPoints, LotSize, 
            MovingAverage, MovingAverageType, MagicNumber);
           }
        }
     }
   else 
     { 
      bool profitable_exit = OrderExit(timeframe, MovingAverage, MovingAverageType, 
      MagicNumber);
      if(profitable_exit) 
        { 
         trade_allowed=true; 
         time_to_trade_addition = ((MathRand()/3600)*timeframe);
        }
     }
  }
//+------------------------------------------------------------------+