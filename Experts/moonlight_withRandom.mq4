//original legacy system but with smoothed price instead of price, H4, and ATR gate
/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//confidence and gate basic model
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define moonlight 052322

extern double lot = .5;
extern short hour_begin = 10, hour_end = 15, timeframe = 240, gate_timeframe = 60, stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false;
extern short what_minute = 4;
extern short MA_method = 0, smoothed_price_period = 2, MA_period = 21;
extern short ATR_gate_period = 14;

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
   Comment("moonlight.ex4");
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("moonlight.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   
   //smoothed price line - confidence
   double smoothed_price_1 = iMA(Symbol(),timeframe,smoothed_price_period,0,MA_method,PRICE_CLOSE,1);
   double smoothed_price_2 = iMA(Symbol(),timeframe,smoothed_price_period,0,MA_method,PRICE_CLOSE,2);
   double smoothed_price_3 = iMA(Symbol(),timeframe,smoothed_price_period,0,MA_method,PRICE_CLOSE,3);
   //moving average - confidence
   double MA_1 = iMA(Symbol(),timeframe,MA_period,0,MA_method,PRICE_CLOSE,1);
   double MA_2 = iMA(Symbol(),timeframe,MA_period,0,MA_method,PRICE_CLOSE,2);
   double MA_3 = iMA(Symbol(),timeframe,MA_period,0,MA_method,PRICE_CLOSE,3);
   
   //gate
   double price_gate_0 = iClose(Symbol(),gate_timeframe,0);
   double price_gate_1 = iClose(Symbol(),gate_timeframe,1);
   double price_gate_2 = iClose(Symbol(),gate_timeframe,2);
   
   double ATR_0 = iATR(Symbol(),gate_timeframe,ATR_gate_period,0);
   double ATR_1 = iATR(Symbol(),gate_timeframe,ATR_gate_period,1);
   double ATR_2 = iATR(Symbol(),gate_timeframe,ATR_gate_period,2);
   double ATR_3 = iATR(Symbol(),gate_timeframe,ATR_gate_period,3);
   
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
     
   if(smoothed_price_1 > smoothed_price_2 && smoothed_price_1 >= MA_1 && MA_1 >= MA_2 && Minute() >= what_minute) bool buyer = true;
   if(smoothed_price_1 < smoothed_price_2 && smoothed_price_1 <= MA_1 && MA_1 <= MA_2 && Minute() >= what_minute) bool seller = true;
   if(smoothed_price_1 <= MA_1 && Minute() >= what_minute) bool buy_closer = true;
   if(smoothed_price_1 >= MA_1 && Minute() >= what_minute)bool sell_closer = true;
    
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
         if(buy_closer)                        //paper close
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
     }
  
   if(!weekend_breaker || trade_allowed)
     {
      if(!CheckOpenOrders())
        {
         static int random_trade_time = rand()%(5 * 60);
         if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
           {
            if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
              {
               if(buyer)
                 {
                  if((ATR_0 + ATR_1 + ATR_2)/3 > (ATR_1 + ATR_2 + ATR_3)/3 && price_gate_1 > price_gate_2)
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,moonlight,0,clrNONE);
                    }
                 }
               if(seller)
                 {
                  if((ATR_0 + ATR_1 + ATR_2)/3 > (ATR_1 + ATR_2 + ATR_3)/3 && price_gate_1 < price_gate_2)
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
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,moonlight,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && (OrderMagicNumber() == moonlight || OrderMagicNumber() == 012822))
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if((ATR_0 + ATR_1 + ATR_2)/3 < (ATR_1 + ATR_2 + ATR_3)/3 && price_gate_1 < price_gate_2)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     random_trade_time = rand()%(5 * 60);
                     if(OrderProfit() > 0) 
                       {
                        trade_allowed = true;
                       }
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  if((ATR_0 + ATR_1 + ATR_2)/3 < (ATR_1 + ATR_2 + ATR_3)/3 && price_gate_1 > price_gate_2)
                    {
                     sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                     random_trade_time = rand()%(5 * 60);
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
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
