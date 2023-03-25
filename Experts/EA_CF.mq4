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


#define cf 111111                   //PLEASE CHANGE

input double lot = .1;
input int timeframe = 240;
input bool time_randomizer = false, stops = false;
input int stop_loss = 30;
input int midToLongPrice = 10, shortToShortFastSlowMA = 10, midToFastSlow = 10, longToLongFastSlowMA = 10,
      shortToLongVol = 10, midToFastMAPrice = 10, midToMidRSI = 10, lowAndHigh = 10;
input short long_chart = 1440, mid_chart = 240, short_chart = 60, MA_fast = 34, MA_slow = 70;
input short confidence_breakpoint = 50;
input short ma_method = 0, RSI_period = 14, RSI_bottom = 30, RSI_middle = 50, RSI_top = 70;
input double volume_multipier = 2.25;               //multiply by existing volume quotient
input double volume_gate_multiplier = 1.2;
input double confidence_divisor = 2.5;
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
  
void OrderHistory()
  {
   for(int i = 0; i < OrdersHistoryTotal(); i++)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
           {
            Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
           }
        }
     }
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Size
   double double_lot = lot * 2; 
   double quad_lot = lot * 4;
   //Price
   double price_long_0 = iClose(Symbol(),long_chart,0);
   double price_long_1 = iClose(Symbol(),long_chart,1);
   double price_long_2 = iClose(Symbol(),long_chart,2);
   double price_long_3 = iClose(Symbol(),long_chart,3);
   double price_mid_0 = iClose(Symbol(),mid_chart,0);
   double price_mid_1 = iClose(Symbol(),mid_chart,1);
   double price_mid_2 = iClose(Symbol(),mid_chart,2);
   double price_mid_3 = iClose(Symbol(),mid_chart,3);
   double price_short_0 = iClose(Symbol(),short_chart,0);
   double price_short_1 = iClose(Symbol(),short_chart,1);
   double price_short_2 = iClose(Symbol(),short_chart,2);
   double price_short_3 = iClose(Symbol(),short_chart,3);
   //Indicators
   double fastMA_long_1 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_long_2 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_long_3 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double fastMA_mid_1 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_mid_2 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_mid_3 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double fastMA_short_1 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_short_2 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_short_3 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double slowMA_long_1 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_long_2 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_long_3 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   double slowMA_mid_1 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_mid_2 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_mid_3 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   double slowMA_short_1 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_short_2 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_short_3 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   //Volume
   long volume_long_0 = iVolume(Symbol(),long_chart,0);
   long volume_long_1 = iVolume(Symbol(),long_chart,1);
   long volume_long_2 = iVolume(Symbol(),long_chart,2);
   long volume_long_3 = iVolume(Symbol(),long_chart,3);
   long volume_mid_0 = iVolume(Symbol(),mid_chart,0);
   long volume_mid_1 = iVolume(Symbol(),mid_chart,1);
   long volume_mid_2 = iVolume(Symbol(),mid_chart,2);
   long volume_mid_3 = iVolume(Symbol(),mid_chart,3);
   long volume_short_0 = iVolume(Symbol(),short_chart,0);
   long volume_short_1 = iVolume(Symbol(),short_chart,1);
   long volume_short_2 = iVolume(Symbol(),short_chart,2);
   long volume_short_3 = iVolume(Symbol(),short_chart,3);
   //Oscillator
   double RSI_long_1 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_long_2 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_long_3 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,3);
   double RSI_mid_1 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_mid_2 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_mid_3 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,3);
   double RSI_short_1 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_short_2 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_short_3 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,3);
  
   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double buy, sell;
   int i;
   static double random_long = MathRand()/2.8, random_short = MathRand()/2.8;
   
   short confidence_level = 0;
   //1 midToLongPrice
      if(iMA(Symbol(),mid_chart,3,0,ma_method,PRICE_CLOSE,0)>(iMA(Symbol(),long_chart,3,0,ma_method,PRICE_CLOSE,1)))
        {
         confidence_level = confidence_level + midToLongPrice;
        }
      if(iMA(Symbol(),mid_chart,3,0,ma_method,PRICE_CLOSE,0)<(iMA(Symbol(),long_chart,3,0,ma_method,PRICE_CLOSE,1)))
        {
         confidence_level = confidence_level - midToLongPrice;
        }
      //2 shortToShortFastSlowMA
      if(fastMA_short_1 > slowMA_short_1)
        {
         confidence_level = confidence_level + shortToShortFastSlowMA;
        }
      if(fastMA_short_1 < slowMA_short_1)
        {
         confidence_level = confidence_level - shortToShortFastSlowMA;
        }
      //3 midToMidFastSlow
      if(fastMA_mid_1 > slowMA_mid_1)
        {
         confidence_level = confidence_level + midToFastSlow;
        }
      if(fastMA_mid_1 < slowMA_mid_1)
        {
         confidence_level = confidence_level - midToFastSlow;
        }
      //4 longToLongFastSlowMA
      if(iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,0) > slowMA_long_1)
        {
         confidence_level = confidence_level + longToLongFastSlowMA;
        }
      if(iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,0) < slowMA_long_1)
        {
         confidence_level = confidence_level - longToLongFastSlowMA;
        }
      //5 shortToLongVol
      if((volume_mid_0 > (volume_long_1/6 * volume_multipier)) && iMA(Symbol(),short_chart,3,0,ma_method,PRICE_CLOSE,0) > price_mid_1 && price_mid_1 > price_mid_2)
        {
         confidence_level = confidence_level + shortToLongVol;
        }
      if((volume_mid_0 > (volume_long_1/6 * volume_multipier)) && iMA(Symbol(),short_chart,3,0,ma_method,PRICE_CLOSE,0) < price_mid_1 && price_mid_1 < price_mid_2)
        {
         confidence_level = confidence_level - shortToLongVol;
        }
      //6 midToFastMAPrice
      if(iMA(Symbol(),mid_chart,2,0,ma_method,PRICE_CLOSE,0) > fastMA_mid_1 && price_short_1 > price_short_2)
        {
         confidence_level = confidence_level + midToFastMAPrice;
        }
      if(iMA(Symbol(),mid_chart,2,0,ma_method,PRICE_CLOSE,0) < fastMA_mid_1 && price_short_1 < price_short_2)
        {
         confidence_level = confidence_level - midToFastMAPrice;
        }
      //7 midToMidRSI
      if(RSI_mid_1 > RSI_middle && RSI_mid_1 < RSI_top)
        {
         confidence_level = confidence_level + midToMidRSI;
        }
      if(RSI_mid_1 < RSI_middle && RSI_mid_1 > RSI_bottom)
        {
         confidence_level = confidence_level - midToMidRSI;
        }
      //8 lowAndHigh
      if(iLow(Symbol(),short_chart,0) > iLow(Symbol(),short_chart,1) && iLow(Symbol(),short_chart,1) > iLow(Symbol(),short_chart,2) && iLow(Symbol(),short_chart,2) > iLow(Symbol(),short_chart,3))
        {
         confidence_level = confidence_level + lowAndHigh;
        }
      if(iHigh(Symbol(),short_chart,0) < iHigh(Symbol(),short_chart,1) && iHigh(Symbol(),short_chart,1) < iHigh(Symbol(),short_chart,2) && iHigh(Symbol(),short_chart,2) < iHigh(Symbol(),short_chart,3))
        {
         confidence_level = confidence_level - lowAndHigh;
        }
     
   if(!CheckOpenOrders())
     {
      if(!stops)
        {
         if(!time_randomizer)
           {
            if(confidence_level > 0 && confidence_level >= confidence_breakpoint)
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",cf,0,clrNONE);
              }
            if(price_1 < price_2 && confidence_level < 0 && confidence_level <= confidence_breakpoint)
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",cf,0,clrNONE);
              }       
           }
         else 
           {
            if(confidence_level > 0 && confidence_level >= confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",cf,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/2.8;
                       }
                    }
                 }
              }
            if(confidence_level < 0 && confidence_level <= confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",cf,0,clrNONE);
                    {
                     if(sell > -1)
                       {
                        random_short = MathRand()/2.8;
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
            if(confidence_level > 0 && confidence_level >= confidence_breakpoint)
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",cf,0,clrNONE);
              }
            if(price_1 < price_2 && confidence_level < 0 && confidence_level <= confidence_breakpoint)
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",cf,0,clrNONE);
              }       
           }
         else 
           {
            if(confidence_level > 0 && confidence_level >= confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",cf,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/2.8;
                       }
                    }
                 }
              }
            if(confidence_level < 0 && confidence_level <= confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",cf,0,clrNONE);
                    {
                     if(sell > -1)
                       {
                        random_short = MathRand()/2.8;
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == cf)
              {
               if(OrderType() == OP_BUY && confidence_level < (confidence_breakpoint/confidence_divisor) && price_1 < price_2)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && confidence_level > (confidence_breakpoint/confidence_divisor) && price_1 > price_2)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }
//+------------------------------------------------------------------+
