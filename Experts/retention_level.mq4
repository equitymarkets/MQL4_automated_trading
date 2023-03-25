/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define retention 041422

extern double lot = .25;
extern short hour_begin = 10, hour_end = 15, timeframe = 240, stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false;
extern short crossover_timeframe = 1, fan_timeframe = 5, one_time_framing_timeframe = 15;
extern short retention_break = 10;
extern short ima_fast_period = 21, ima_slow_period = 55;
int i;
double pips;

bool CheckOpenOrders()
  { 
   for(i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol()) return(true); 
     } 
      return(false); 
  }

void OrderHistory()
  {
   for(i = 0; i < OrdersHistoryTotal(); i++)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
           {
            Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
           }
        }
     }
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   Comment("EA.ex4");
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("EA.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   double one_time_price_0 = iLow(Symbol(),one_time_framing_timeframe,0);
   double one_time_price_1 = iLow(Symbol(),one_time_framing_timeframe,1);
   double one_time_price_2 = iLow(Symbol(),one_time_framing_timeframe,2);
   double one_time_price_3 = iLow(Symbol(),one_time_framing_timeframe,3);
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   double OBV_0 = iOBV(Symbol(),timeframe,PRICE_CLOSE,0);
   double OBV_1 = iOBV(Symbol(),timeframe,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),timeframe,PRICE_CLOSE,2);
   
   double fan_2_0 = iMA(Symbol(),fan_timeframe,2,0,MODE_SMA,PRICE_CLOSE,0);
   double fan_2 = iMA(Symbol(),fan_timeframe,2,0,MODE_SMA,PRICE_CLOSE,1);
   double fan_3_0 = iMA(Symbol(),fan_timeframe,3,0,MODE_SMA,PRICE_CLOSE,0);
   double fan_3 = iMA(Symbol(),fan_timeframe,3,0,MODE_SMA,PRICE_CLOSE,1);
   double fan_5_0 = iMA(Symbol(),fan_timeframe,5,0,MODE_SMA,PRICE_CLOSE,0);
   double fan_5 = iMA(Symbol(),fan_timeframe,5,0,MODE_SMA,PRICE_CLOSE,1);
   double fan_8_0 = iMA(Symbol(),fan_timeframe,8,0,MODE_SMA,PRICE_CLOSE,0);
   double fan_8 = iMA(Symbol(),fan_timeframe,8,0,MODE_SMA,PRICE_CLOSE,1);
   double fan_13_0 = iMA(Symbol(),fan_timeframe,13,0,MODE_SMA,PRICE_CLOSE,0);
   double fan_13 = iMA(Symbol(),fan_timeframe,13,0,MODE_SMA,PRICE_CLOSE,1);
   
   double crossover_fast_1 = iMA(Symbol(),crossover_timeframe,100,0,MODE_SMA,PRICE_CLOSE,1);
   double crossover_fast_2 = iMA(Symbol(),crossover_timeframe,100,0,MODE_SMA,PRICE_CLOSE,2);
   double crossover_slow_1 = iMA(Symbol(),crossover_timeframe,200,0,MODE_SMA,PRICE_CLOSE,1);
   
   double ima_fast = iMA(Symbol(),timeframe,ima_fast_period,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_slow = iMA(Symbol(),timeframe,ima_slow_period,0,MODE_SMA,PRICE_CLOSE,1);
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   int retention_level = 0;
   
   if(fan_2_0 > fan_2 && fan_2 > fan_3)
     {
      retention_level = retention_level + 1;
     }
   if(fan_3_0 > fan_3 && fan_3 > fan_5)
     {
      retention_level = retention_level + 1;
     }
   if(fan_5_0 > fan_5 && fan_5 > fan_8)
     {
      retention_level = retention_level + 1;
     }
   if(fan_8_0 > fan_8 && fan_8 > fan_13)
     {
      retention_level = retention_level + 1;
     } 
   if(fan_2 > fan_3 && fan_3 > fan_5 && fan_5 > fan_8 && fan_8 > fan_13)
     {
      retention_level = retention_level + 3;
     }
   
   if(crossover_fast_1 > crossover_fast_2)
     {
      retention_level = retention_level + 2;
     }
   if(crossover_fast_1 > crossover_slow_1)
     {
      retention_level = retention_level + 3;
     }
     
   if(one_time_price_0 > one_time_price_1 && one_time_price_1 > one_time_price_2 && one_time_price_2 > one_time_price_3)
     {
      retention_level = retention_level + 5;
     }
   if(iLow(Symbol(),timeframe,0) > iLow(Symbol(),timeframe,1) && iLow(Symbol(),timeframe,1) > iLow(Symbol(),timeframe,2) && iLow(Symbol(),timeframe,2) > iLow(Symbol(),timeframe,3))
     {
      retention_level = retention_level + 3;
     } 
   
   if(fan_2_0 < fan_2 && fan_2 < fan_3)
     {
      retention_level = retention_level - 1;
     }
   if(fan_3_0 < fan_3 && fan_3 < fan_5)
     {
      retention_level = retention_level - 1;
     }
   if(fan_5_0 < fan_5 && fan_5 < fan_8)
     {
      retention_level = retention_level - 1;
     }
   if(fan_8_0 < fan_8 && fan_8 < fan_13)
     {
      retention_level = retention_level - 1;
     } 
   if(fan_2 < fan_3 && fan_3 < fan_5 && fan_5 < fan_8 && fan_8 < fan_13)
     {
      retention_level = retention_level - 3;
     }
   
   if(crossover_fast_1 < crossover_fast_2)
     {
      retention_level = retention_level - 2;
     }
   if(crossover_fast_1 < crossover_slow_1)
     {
      retention_level = retention_level - 3;
     }
     
   if(one_time_price_0 < one_time_price_1 && one_time_price_1 < one_time_price_2 && one_time_price_2 < one_time_price_3)
     {
      retention_level = retention_level - 5;
     }
   if(iHigh(Symbol(),timeframe,0) < iHigh(Symbol(),timeframe,1) && iHigh(Symbol(),timeframe,1) < iHigh(Symbol(),timeframe,2) && iHigh(Symbol(),timeframe,2) < iHigh(Symbol(),timeframe,3))
     {
      retention_level = retention_level - 3;
     }    
   Alert(retention_level);

   
   
   if(OBV_1 > OBV_2 && ima_fast > ima_slow) bool buyer = true;
   if(OBV_1 < OBV_2 && ima_fast < ima_slow) bool seller = true;
   if(OBV_1 < OBV_2 && ima_fast < ima_slow) bool buy_closer = true;
   if(OBV_1 > OBV_2 && ima_fast > ima_slow) bool sell_closer = true;
   
   
    
   if(weekend_breaker)        //breaker is for testing only
     {
      if(!trade_allowed && !paper_buy) 
        {
         if(buyer)   //paper buy
           {
            paper_buy = true;
            paper_buy_price = price_1;
           }
        }
      if(paper_buy) 
        {
         if(buy_closer && retention_level < retention_break)                        //paper close
           {
            paper_buy = false;
            if(price_1 > paper_buy_price)             //profit?
              {
               trade_allowed = true;
              }
           }
        }
      if(seller) 
        {
         if(price_0 < price_1 && price_1 < price_2)   //paper sell
           {
            paper_sell = true;
            paper_sell_price = price_1;
           }
        }
      if(paper_sell) 
        {
         if(sell_closer && retention_level > -retention_break)                        //paper close
           {
            paper_sell = false;
            if(price_1 < paper_sell_price)            //profit?
              {
               trade_allowed = true;
              }
           }
        }
     }
  
   if(!weekend_breaker || trade_allowed)
     {
      if(!CheckOpenOrders())
        {
         if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
           {
            if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
              {
               if(buyer)
                 {
                  if(limits) 
                    { 
                     buy_order = OP_BUYLIMIT;
                     buy_limit = Ask - (limit_entry * pips);
                    }
                  if(stops) 
                    {
                     stop_trade = Ask - (stop_loss * pips);
                    }
                  buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,retention,0,clrNONE);
                 }
               if(seller)
                 {
                  if(limits)
                    {
                     sell_order = OP_SELLLIMIT;
                     sell_limit = Bid + (limit_entry * pips);
                    }
                  if(stops)
                    {
                     stop_trade = Bid + (stop_loss * pips);
                    }
                  sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,retention,0,clrNONE);
                 }
              }
           }
        }
     }
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == retention)
              {
               if(OrderType() == OP_BUY && buy_closer && retention_level < retention_break)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer && retention_level > -retention_break)
                 {
                  sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
              }      
           }
        }
     }
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891