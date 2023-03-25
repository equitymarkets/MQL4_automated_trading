//remove " || dawn " around line 163 //note: uses 1 hour for rand value
/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#define oppo 043021

input double lot = .1, MACD_change = .005;
input short timeframe = 240, stop_loss = 50, fast_period = 8, slow_period = 10, signal_period = 3;
input short what_minute = 0;
input bool time_randomizer = false, stops = false;
double pips;

bool CheckOpenOrders()
  { 
   for( int i = 0 ; i < OrdersTotal() ; i++ ) 
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
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   double MACD_0 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,0);
   double MACD_1 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,1);
   double MACD_2 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,2);
   
   
   double buy, sell;
   static double random_long = MathRand()/9.3, random_short = MathRand()/9.3;
   int i;
   if(!CheckOpenOrders())
     {
      if(!stops)
        {
         if(!time_randomizer)
           {
            if((MACD_1 > MACD_2 && Minute() >= what_minute))
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",oppo,0,clrNONE);
              }
            if((MACD_1 < MACD_2 && Minute() >= what_minute))
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",oppo,0,clrNONE);
              }       
           }
         else 
           {
            if((MACD_1 > MACD_2))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",oppo,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/9.3;
                       }
                    }
                 }
              }
            if((MACD_1 < MACD_2))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",oppo,0,clrNONE);
                    {
                     if(sell > -1)
                       {
                        random_short = MathRand()/9.3;
                       }
                    }
                 }
              }
           }
        }
      else
        {
         if(!time_randomizer)
           {
            if((MACD_1 > MACD_2 && Minute() >= what_minute))
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",oppo,0,clrNONE);
              }
            if((MACD_1 < MACD_2 && Minute() >= what_minute))
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",oppo,0,clrNONE);
              }       
           }
         else 
           {
            if((MACD_1 > MACD_2))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",oppo,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/9.3;
                       }
                    }
                 }
              }
            if((MACD_1 < MACD_2))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",oppo,0,clrNONE);
                    {
                     if(sell > -1)
                       {
                        random_short = MathRand()/9.3;
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
            if((OrderSymbol() == Symbol() && OrderMagicNumber() == oppo) || (OrderSymbol() == Symbol() && OrderMagicNumber() == 103106))
              {
               if(OrderType() == OP_BUY && price_1 < price_2 && (MACD_1 < MACD_2) && Minute() >= what_minute)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && price_1 > price_2 && (MACD_1 > MACD_2) && Minute() >= what_minute)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891