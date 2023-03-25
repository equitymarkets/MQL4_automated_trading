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

#define fader 0300
#define trend 0301

extern double lot = .5;
extern short hour_begin = 4, hour_end = 23, timeframe = 240, stop_loss = 30, limit_entry = 30;
extern bool time = true, random = false, stops = false, limits = false, weekend_breaker = false;
extern short what_minute = 0;
extern bool fades = false, trends = true;
extern short smooth_price_period = 2, fast_MA_period = 5, slow_MA_period = 21;

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
   
   //Price
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   double price_3 = iClose(Symbol(),timeframe,3);
   double smoothed_price_0 = iMA(Symbol(),timeframe,smooth_price_period,0,MODE_SMA,PRICE_CLOSE,0);
   double smoothed_price_1 = iMA(Symbol(),timeframe,smooth_price_period,0,MODE_SMA,PRICE_CLOSE,1);
   double smoothed_price_2 = iMA(Symbol(),timeframe,smooth_price_period,0,MODE_SMA,PRICE_CLOSE,2);
   
   //Momentum
   double fast_MA_0 = iMA(Symbol(),timeframe,fast_MA_period,0,MODE_SMA,PRICE_CLOSE,0);
   double fast_MA_1 = iMA(Symbol(),timeframe,fast_MA_period,0,MODE_SMA,PRICE_CLOSE,1);
   double fast_MA_2 = iMA(Symbol(),timeframe,fast_MA_period,0,MODE_SMA,PRICE_CLOSE,2);
   double slow_MA_0 = iMA(Symbol(),timeframe,slow_MA_period,0,MODE_SMA,PRICE_CLOSE,0);
   double slow_MA_1 = iMA(Symbol(),timeframe,slow_MA_period,0,MODE_SMA,PRICE_CLOSE,0);
   double slow_MA_2 = iMA(Symbol(),timeframe,slow_MA_period,0,MODE_SMA,PRICE_CLOSE,0);
   
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   //static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   if(price_0 > price_1 && price_1 > price_2 && smoothed_price_0 > smoothed_price_1 && smoothed_price_1 > smoothed_price_2 && (fast_MA_0 + fast_MA_1 + fast_MA_2)/3 > slow_MA_1 && Minute() >= what_minute) bool trends_buy = true;  
   if(price_0 > price_1 && price_1 > price_2 && price_2 < price_3 && Minute() >= what_minute) bool faders_buy = true;
   if(price_0 < price_1 && price_1 < price_2 && smoothed_price_0 < smoothed_price_1 && smoothed_price_1 < smoothed_price_2 && (fast_MA_0 + fast_MA_1 + fast_MA_2)/3 < slow_MA_1 && Minute() >= what_minute) bool trends_sell = true;
   if(price_0 < price_1 && price_1 < price_2 && price_2 > price_3 && Minute() >= what_minute) bool faders_sell = true;
   
   if(price_0 < price_1 && price_1 < price_2 && price_2 < price_3 && Minute() >= what_minute) bool trends_buy_closer = true;
   if(price_0 > price_1 && price_1 > price_2 && price_2 > price_3 && Minute() >= what_minute) bool faders_buy_closer = true;
   if(price_0 > price_1 && price_1 > price_2 && price_2 > price_3 && Minute() >= what_minute) bool trends_sell_closer = true;
   if(price_0 < price_1 && price_1 < price_2 && price_2 < price_3 && Minute() >= what_minute) bool faders_sell_closer = true;
   
    
   /*if(weekend_breaker)        //breaker is for testing only
     {
      if(!trade_allowed && !paper_buy) 
        {
         if(faders_buy)   //paper buy
           {
            paper_buy = true;
            paper_buy_price = price_1;
           }
         if(faders_buy)   //paper buy
           {
            trends_buy = true;
            paper_buy_price = price_1;
           }
        }
      if(paper_buy) 
        {
         if(faders_buy_closer)                        //paper close
           {
            paper_buy = false;
            if(price_1 > paper_buy_price)             //profit?
              {
               trade_allowed = true;
              }
           }
         if(trends_buy_closer)                        //paper close
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
         if(sell_closer)                        //paper close
           {
            paper_sell = false;
            if(price_1 < paper_sell_price)            //profit?
              {
               trade_allowed = true;
              }
           }
        }
     }*/
  
   if(!weekend_breaker || trade_allowed)
     {
      if(!CheckOpenOrders())
        {
         if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
           {
            if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
              {
               if(trends)
                 {
                  if(trends_buy)
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,trend,0,clrNONE); 
                    }
                  if(!CheckOpenOrders())
                    {
                     if(trends_sell)
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
                        sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,trend,0,clrNONE); 
                       }
                    }
                 }
              
               if(fades)
                 {
                  if(faders_buy)
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,fader,0,clrNONE);
                    }
                  if(!CheckOpenOrders())
                    {
                     if(faders_sell)
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
                        sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,fader,0,clrNONE);
                       }
                    }
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == fader)
              {
               if(OrderType() == OP_BUY && faders_buy_closer)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && faders_sell_closer)
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
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == trend)
              {
               if(OrderType() == OP_BUY && trends_buy_closer)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && trends_sell_closer)
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
