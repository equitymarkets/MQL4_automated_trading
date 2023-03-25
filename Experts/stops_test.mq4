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

#define stop 060122

extern bool time = false, random = false, stops = true, limits = false, weekend_breaker = false;
extern bool stop_extremes = true;     //must also select stops to true!
extern double stop_extremes_adj = 4;
extern short hour_begin = 10, hour_end = 15, timeframe = 240, stop_loss = 30, limit_entry = 30;
extern short what_minute = 0, array_lookback_period = 100;
extern double lot = .5;
extern short hour_minute_shift = 13;
extern int addition = 4;


int 
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
   
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   
   
   
   /*double one_dim[];
   double four_dim[][10][5][2];
   
   int one_dim_size = 25;
   int reserve = 20;
   int four_dim_size = 5;
   
   int size;
   
   ArrayResize(one_dim,one_dim_size);
   ArrayResize(four_dim,four_dim_size);
   
   Print("+==============================================+");
   Print("Array sizes:");
   Print("1. One-dimensional array");
   
   size =ArraySize(one_dim);
   
   PrintFormat("Zero dimension size = %d, Array size = %d",one_dim_size,size);
   Print("2. Multidimensional array");
   size = ArraySize(four_dim);
   PrintFormat("Zero dimension size = %d, Array size = %d",four_dim_size, size);
   int d_1 = ArrayRange(four_dim, 1);
   int d_2 = ArrayRange(four_dim, 2);
   int d_3 = ArrayRange(four_dim, 3);
   Print("Check:");
   Print("Zero dimension = Array size / (First dimension * Second dimension * Third dimension)");
   PrintFormat("%d = %d / (%d * %d * %d)", size/(d_1*d_2*d_3),size,d_1, d_2, d_3);
   Print("3. One-dimensional array with memory backup");
   one_dim_size *= 2;
   ArrayResize(one_dim,one_dim_size,reserve);
   size = ArraySize(one_dim);
   PrintFormat("Size with backup = %d, Actual array size = %d", one_dim_size + reserve, size);
    
   Sleep(30000); */ 
   
   
   
   
   /*if(Minute() >= what_minute) bool confidence = true;
     
   if(iLow(Symbol(),timeframe,iLowest(Symbol(),timeframe,MODE_LOW,2,0)) > (iLow(Symbol(),timeframe,iLowest(Symbol(),timeframe,MODE_LOW,20,0)))) bool buyer = true;
   if(price_0 < price_1 && price_1 < price_2) bool seller = true;
   if(price_1 < price_2 && Minute() >= what_minute) bool buy_closer = true;
   if(price_1 > price_2 && Minute() >= what_minute)bool sell_closer = true;
   
   if(confidence)
     { 
      if(weekend_breaker)        //breaker is for testing only
        {
         if(!trade_allowed)
           {
            if(!paper_buy) 
              {
               if(buyer)   //paper buy
                 {
                  paper_buy = true;
                  paper_buy_price = price_1;
                 }
              }
            else
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
            if(!paper_sell) 
              {
               if(seller)   //paper sell
                 {
                  paper_sell = true;
                  paper_sell_price = price_1;
                 }
              }
            else
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
                        if(stop_extremes)
                          {
                           stop_trade = (iLow(Symbol(),timeframe,iLowest(Symbol(),timeframe,MODE_LOW,10,0)) - (stop_extremes_adj * pips));
                          }  
                        else stop_trade = Ask - (stop_loss * pips);
                       }
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,stops,0,clrNONE);
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
                        if(stop_extremes)
                          {
                           stop_trade = (iHigh(Symbol(),timeframe,iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) + (stop_extremes_adj * pips));
                          }
                        else stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,stops,0,clrNONE);
                    }
                 }
              }
           }
        }
     }
   /*if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == stops)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
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
     }*/
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
