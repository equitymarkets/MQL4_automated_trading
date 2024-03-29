//working on legacy function, strict compile vs not with both weekend breaker 
//and time comment
/*
 L        A     SSSS EEEE RRR   DD   EEEE SSSS  IIIII  GG  N   N     IIIII  OO
 L       A A    S    E    R  R  D D  E    S       I   G  G NN  N       I   O  O
 L      AAAAA    SS  EEE  RRR   D D  EEE   SS     I   G    N NNN       I   O  O
 L     A     A     S E    R  R  D D  E       S    I   G GG N  NN       I   O  O
 LLLL A       A SSSS EEEE R   R DD   EEEE SSSS  IIIII  GG  N   N  O  IIIII  OO
*/
//345678911234567892123456789312345678941234567895123456789612345678971234567898
//Checklist - place X next to each task when complete:                         
//__benchmarks against buy_or_sell_tester.ex4 
//__no extreme same-day loss correlation with currently running EAs
//__tests with positive 1, 2, 3, 4, 5 month periods 
//__continuous high-water marks
//__includes small losses 

#property copyright "Copyright 2023, laserdesign.io"
#property link      "https://www.laserdesign.io"
#define ea 111111                //Change to the magic number

extern bool time = false, random = false, stops = false, 
            limits = false, weekend_breaker = false, atv = false;
extern bool stop_extremes = false;     //must also select stops to true!
extern bool limit_edge = false;         //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern int hour_begin = 10, hour_end = 15, timeframe = 240, stop_loss = 30,    
            limit_entry = 30;
extern int what_minute = 0, array_lookback_period = 100;
extern double lot = .5;
extern int ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, 
            ATV_break = 600;
extern static bool trade_allowed = false;

double pips;

int i;
   
//345678911234567892123456789312345678941234567895123456789612345678971234567898

double CalculateSpread(double bid, double ask)
  {
   return(ask-bid);
  }
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
         Alert( "Order ", i, " time was ",  
         OrderCloseTime() - OrderOpenTime());
        }
     }
  }
  
double ATV_0(short atr_timeframe, short obv_timeframe, short atr_period)
  {
   double ATR_0 = iATR(Symbol(),atr_timeframe,atr_period,0);
   double OBV_0 = iOBV(Symbol(),obv_timeframe,PRICE_CLOSE,0); 
   return(ATR_0 * OBV_0);
  } 

int Entropy(int minutes)
  {
   int time_addition = rand()%(minutes * 60);
   return(time_addition);
  }

bool IsNewCandle()
  {
   static datetime saved_candle_time;
   if(Time[0] == saved_candle_time)
     {
      return(false);
     }
   else
      saved_candle_time = Time[0];
   return(true);
  }     

int OnInit()
  {
   
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   pips = ((tick == .00001 || tick == .001) ? (tick * 10) : tick);
   Comment(WindowExpertName() + " initialized ");
   return(INIT_SUCCEEDED);
  }
  
//345678911234567892123456789312345678941234567895123456789612345678971234567898

void OnDeinit(const int reason)
  {
   Alert(WindowExpertName() + " deinitialized!");
  }

//345678911234567892123456789312345678941234567895123456789612345678971234567898

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);

   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   double price_array[];           //remove if not needed
   int price_array_size = array_lookback_period;
   ArrayResize(price_array,array_lookback_period);
   
   for(i = 0; i < array_lookback_period; i++)   //sub any data
     {
      price_array[i] = iClose(Symbol(),timeframe,i);
     }
  
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
     
   if(Minute() >= what_minute) bool confidence = true;
     
   if(price_0 > price_1 && price_1 > price_2) bool buyer = true;
   if(price_0 < price_1 && price_1 < price_2) bool seller = true;
   if(price_1 < price_2) bool buy_closer = true;
   if(price_1 > price_2) bool sell_closer = true;
   
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
                  //change to closing value re what_minute var
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
//345678911234567892123456789312345678941234567895123456789612345678971234567898     
      if(!weekend_breaker || trade_allowed)
        {
         if(!CheckOpenOrders())
           {
            //static int random_trade_time = rand()%(timeframe * 60);
            static int random_trade_time = Entropy(timeframe);
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= 
               (iTime(Symbol(),timeframe,0) + random_trade_time))
              {
               if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
                 {
                  if(buyer)
                    {
                     if(limits) 
                       { 
                        buy_order = OP_BUYLIMIT;
                        if(limit_edge_adj)
                          {
                           buy_limit = (iLow(Symbol(),timeframe,
                              iLowest(Symbol(),timeframe,MODE_LOW,10,0)) + 
                              (limit_edge_adj * pips));
                          }
                        else buy_limit = Ask - (limit_entry * pips);
                       }
                     if(stops) 
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iLow(Symbol(),timeframe,
                           iLowest(Symbol(),timeframe,MODE_LOW,10,0)) - 
                           (stop_extremes_adj * pips));
                          }  
                        else stop_trade = Ask - (stop_loss * pips);
                       }
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,
                     stop_trade,0,NULL,ea,0,clrNONE);
                    }
                  if(seller)
                    {
                     if(limits)
                       {
                        sell_order = OP_SELLLIMIT;
                        if(limit_edge)
                          {
                           sell_limit = (iHigh(Symbol(),timeframe,
                           iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) - 
                           (limit_edge_adj * pips));
                          }
                        else sell_limit = Bid + (limit_entry * pips);
                       }
                     if(stops)
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iHigh(Symbol(),timeframe,
                           iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) + 
                           (stop_extremes_adj * pips));
                          }
                        else stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,
                     stop_trade,0,NULL,ea,0,clrNONE);
                    }
                 }
              }
           }
        }
     }
//345678911234567892123456789312345678941234567895123456789612345678971234567898
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == ea)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < 
                  ATV_break)
                    {
                     buy_close = OrderClose(OrderTicket(),
                     OrderLots(),Bid,0,clrNONE);
                     random_trade_time = rand()%(timeframe * 60);
                     if(OrderProfit() > 0) 
                       {
                        trade_allowed = true;
                       }
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > 
                  -ATV_break)
                    {
                     sell_close = OrderClose(OrderTicket(),
                     OrderLots(),Ask,0,clrNONE);
                     random_trade_time = rand()%(timeframe * 60);
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
 
//345678911234567892123456789312345678941234567895123456789612345678971234567898
