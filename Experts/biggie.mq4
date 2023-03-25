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

#define biggie 053022

extern double lot = .5;
extern short hour_begin = 10, hour_end = 15, timeframe = 60, stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false;
extern short what_minute = 0, lookback_period = 5;


extern bool stop_extremes = false;     //must also select stops to true!
extern double stop_extremes_adj = 4;

//ATR as a component of confidence
extern short ATR_timeframe = 30, ATR_period = 14;
//OBV as a component of confidence
extern short OBV_timeframe = 30;
extern string OBV_price_type = PRICE_MEDIAN;
extern short custom_bar_MA_fast = 21, custom_bar_MA_slow = 55;
extern int average_array_length = 300;
double pips;

double sum_fast, sum_slow, custom_MA_fast, custom_MA_slow;

int i, j, k;



extern short hour_to_test = 23;

double ATV_array[][2];

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
   //Confidence calculation
   int ATV_array_size = lookback_period;
   ArrayResize(ATV_array,ATV_array_size);
   for(i = 0; i < lookback_period; i++)
     {
      
      double ATR = iATR(Symbol(),ATR_timeframe,ATR_period,i);        //match these upon time frame
      int OBV = iOBV(Symbol(),OBV_timeframe,OBV_price_type,i);       //now both should be =
        {
         for(j = 0; j <= 1; j++)
           {
            int bar_time = iTime(Symbol(),ATR_timeframe,i);
            if(j == 0) ATV_array[i][j] = (ATR * OBV);
            if(j == 1) ATV_array[i][j] = TimeHour(bar_time);
           }
        }
     }

   if(ATV_array[1][0] > 0 && ATV_array[1][0] > ATV_array[2][0] && price_1 > price_2 && Minute() >= what_minute) bool buyer = true;
   if(ATV_array[1][0] < 0 && ATV_array[1][0] < ATV_array[2][0] && price_1 < price_2 && Minute() >= what_minute) bool seller = true;
   if(ATV_array[1][0] < ATV_array[2][0] && price_1 < price_2 && Minute() >= what_minute) bool buy_closer = true;
   if(ATV_array[1][0] > ATV_array[2][0] && price_1 > price_2 && Minute() >= what_minute) bool sell_closer = true;   
   //060122 splitting fast into slow etc.
   short fast_timeframe = 15;
   short slow_timeframe = 60;
   double fast = iClose(Symbol(),fast_timeframe,1);
   double slow = iClose(Symbol(),slow_timeframe,1);
   double fast_MA = iMA(Symbol(),fast_timeframe,80,0,MODE_SMA,PRICE_CLOSE,1);
   double slow_MA = iMA(Symbol(),slow_timeframe,20,0,MODE_SMA,PRICE_CLOSE,1);
   
   if(Minute() >= what_minute) bool confidence = true;
     
   
   
   
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,biggie,0,clrNONE);
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
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,biggie,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == biggie)
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
     }      
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
