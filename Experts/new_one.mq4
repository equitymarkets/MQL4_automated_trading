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

#define new_one 020422

extern double lot = .1;
extern short hour_begin = 9, hour_end = 11, timeframe = 60, stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false;

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
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("new_one.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy, sell, buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   double price_3 = iClose(Symbol(),timeframe,3);
   
   static double random_trade_time = MathRand()/2.8;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string order = OP_BUY;
   
   if(!CheckOpenOrders())
     {
      if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
        {
         if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
           {
            if(price_0 < price_1 && price_1 < price_2 && price_2 > price_3)
              {
               if(limits) 
                 { 
                  order = OP_BUYLIMIT;
                  buy_limit = Ask - (limit_entry * pips);
                 }
               if(stops) 
                 {
                  stop_trade = Ask - (stop_loss * pips);
                 }
               buy = OrderSend(Symbol(),order,lot,buy_limit,0,stop_trade,0,NULL,new_one,0,clrNONE);
              }
            if(price_0 > price_1 && price_1 > price_2 && price_2 < price_3)
              {
               if(limits)
                 {
                  order = OP_SELLLIMIT;
                  sell_limit = Bid + (limit_entry * pips);
                 }
               if(stops)
                 {
                  stop_trade = Bid + (stop_loss * pips);
                 }
               sell = OrderSend(Symbol(),order,lot,sell_limit,0,stop_trade,0,NULL,new_one,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == new_one)
              {
               if(OrderType() == OP_BUY && Hour() == 16 && price_1 > price_2)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && Hour() == 16 && price_1 < price_2)
                 {
                  sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
