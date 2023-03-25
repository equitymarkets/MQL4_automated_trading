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


#define CFT 020222 

input double lot = .1;
input double number_1 = 10;   //one timeframing with smoothed 0-bar midchart vs fast MA mid chart 1-bar
input double number_2 = 10;   //3MA mid chart 0-bar vs 3MA long chart 1-bar 
input double number_3 = 10;   //smoothed on-balance volume and RSI criterion
input double number_4 = 10;   //fast MA 1-bar vs slow MA 1-bar
input double number_5 = 10;   //fast MA mid chart 1-bar vs slow MA mid 1-bar
input double number_6 = 10;   //smoothed fast MA mid chart 0-bar vs fast MA long chart 1-bar
input double number_7 = 10;   //MACD criterion bar 1 vs bar 2
input double number_8 = 10;   //smoothed bollinger top mid chart vs breakpoint and smoothed small price mid chart 0-bar vs bollinger top mid chart
input double confidence_breakpoint = 50;
input double confidence_divisor = 2.3;
input bool time_randomizer = false, stops = false;
input int stop_loss = 30;
input short long_chart = 1440, mid_chart = 240, short_chart = 60;
input short MA_fast = 34, MA_slow = 70, signal_period = 3;
input int bollinger_count = 21;
input short smoothedPriceMASmall = 2, smoothedPriceMALarge = 3, smoothedPriceMAType = 0, ma_method = 0;
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
double BollingerCycle()
  {
   double counter;
   for(int i = 0; i < bollinger_count; i++)
     {
      counter = counter + (iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,i) - iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,i));
     }
   double counter_mean = counter/bollinger_count;
   return(counter_mean); 
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
//---
   
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   int i;
   
   double double_lot = lot * 2;
   double quad_lot = lot * 4;
   
   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double priceSmoothedSmall_mid_0 = iMA(Symbol(),mid_chart,smoothedPriceMASmall,0,smoothedPriceMAType,PRICE_CLOSE,0);
   double priceSmoothedLarge_mid_0 = iMA(Symbol(),mid_chart,smoothedPriceMALarge,0,smoothedPriceMAType,PRICE_CLOSE,0);
   double priceSmoothedLarge_long_1 = iMA(Symbol(),long_chart,smoothedPriceMALarge,0,smoothedPriceMAType,PRICE_CLOSE,1);

   double priceMid_Low_0 = iLow(Symbol(),mid_chart,0);
   double priceMid_Low_1 = iLow(Symbol(),mid_chart,1);
   double priceMid_Low_2 = iLow(Symbol(),mid_chart,2);
   double priceMid_Low_3 = iLow(Symbol(),mid_chart,3);
   double priceMid_High_0 = iHigh(Symbol(),mid_chart,0);
   double priceMid_High_1 = iHigh(Symbol(),mid_chart,1);
   double priceMid_High_2 = iHigh(Symbol(),mid_chart,2);
   double priceMid_High_3 = iHigh(Symbol(),mid_chart,3);
   
   double OBV_0 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,0);
   double OBV_1 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,2);
   double OBV_3 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,3);
   double RSI_0 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,0);
   double RSI_1 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,1);
   double RSI_2 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,2);
   double RSI_3 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,3);
   double fastMA_short_0 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,0);
   double fastMA_short_1 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_short_2 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double slowMA_short_0 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,0);
   double slowMA_short_1 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_short_2 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   
   double fastMA_mid_0 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,0);
   double fastMA_mid_1 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_mid_2 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);

   double fastMA_long_1 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   
   double slowMA_mid_1 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_mid_2 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   
   double MACD_1 = iMACD(Symbol(),mid_chart,MA_fast,MA_slow,signal_period,PRICE_CLOSE,MODE_SIGNAL,1);
   double MACD_2 = iMACD(Symbol(),mid_chart,MA_fast,MA_slow,signal_period,PRICE_CLOSE,MODE_SIGNAL,2);
   
   double buy, sell;
   
   double bollingerTop_mid_1 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,1);
   double bollingerTop_mid_0 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,0);
   double bollingerBottom_mid_1 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,1);
   double bollingerBottom_mid_0 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,0);
   
   double confidence_total = number_1 + number_2 + number_3 + number_4 + number_5 + number_6 + number_7 + number_8;
   
   double bollinger_breakpoint = BollingerCycle();
   
   static double random_long = MathRand()/2.8, random_short = MathRand()/2.8;
   double breakpoint = confidence_breakpoint/confidence_divisor;
   
   
   
   short confidence_level = 0;
   //1 //one timeframing with smoothed 0-bar midchart vs fast MA mid chart 1-bar
   if(priceMid_Low_0 > priceMid_Low_1 && priceMid_Low_1 > priceMid_Low_2 && priceMid_Low_2 > priceMid_Low_3 && priceSmoothedSmall_mid_0 > fastMA_mid_1)
     {
      confidence_level = confidence_level + number_1;
     }
   if(priceMid_High_0 < priceMid_High_1 && priceMid_High_1 < priceMid_High_2 && priceMid_High_2 < priceMid_High_3 && priceSmoothedSmall_mid_0 < fastMA_mid_1)
     {
      confidence_level = confidence_level - number_1;
     }
   //2 3MA mid chart 0-bar vs 3MA long chart 1-bar 
   if(priceSmoothedLarge_mid_0 > priceSmoothedLarge_long_1)
     {
      confidence_level = confidence_level + number_2;
     } 
   if(priceSmoothedLarge_mid_0 < priceSmoothedLarge_long_1)
     {
      confidence_level = confidence_level - number_2;
     }
   //3 smoothed on-balance volume and RSI criterion
   if((OBV_0 + OBV_1)/2 > (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 > 50 && (RSI_0 + RSI_1)/2 < 70) 
     {
      confidence_level = confidence_level + number_3;
     }
   if((OBV_0 + OBV_1)/2 < (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 < 50 && (RSI_0 + RSI_1)/2 > 30) 
     {
      confidence_level = confidence_level - number_3;
     }
   //4 fast MA short chart 1-bar vs slow MA short chart 1-bar
   if(fastMA_short_1 > slowMA_short_1)
     {
      confidence_level = confidence_level + number_4; 
     }
   if(fastMA_short_1 < slowMA_short_1)
     {
      confidence_level = confidence_level - number_4; 
     }
   //5 fast MA mid chart 1-bar vs slow MA mid 1-bar
   if(fastMA_mid_1 > slowMA_mid_1)
     {
      confidence_level = confidence_level + number_5;
     }
   if(fastMA_mid_1 < slowMA_mid_1)
     {
      confidence_level = confidence_level - number_5;
     }
   //6 smoothed fast MA mid chart 0-bar vs fast MA long chart 1-bar
   if(((fastMA_mid_0 + fastMA_mid_1)/2) > fastMA_long_1)
     {
      confidence_level = confidence_level + number_6;
     }
   if(((fastMA_mid_0 + fastMA_mid_1)/2) < fastMA_long_1)
     {
      confidence_level = confidence_level - number_6;
     }
   //7 MACD criterion bar 1 vs bar 2
   if(MACD_1 > MACD_2)
     {
      confidence_level = confidence_level + number_7;
     }
   if(MACD_1 < MACD_2)
     {
      confidence_level = confidence_level - number_7;
     }
   //8 smoothed bollinger top mid chart vs breakpoint and smoothed small price mid chart 0-bar vs bollinger top mid chart
   if((((bollingerTop_mid_1 + bollingerTop_mid_0)/2 - (bollingerBottom_mid_1 + bollingerBottom_mid_0)/2) > bollinger_breakpoint) && priceSmoothedSmall_mid_0 > bollingerTop_mid_1)
     {
      confidence_level = confidence_level + number_8;
     }
   if((((bollingerTop_mid_1 + bollingerTop_mid_0)/2 - (bollingerBottom_mid_1 + bollingerBottom_mid_0)/2) > bollinger_breakpoint) && priceSmoothedSmall_mid_0 < bollingerBottom_mid_1)
     {
      confidence_level = confidence_level - number_8;
     }
   //9
   /*if(((price - price_1) > (bollinger_breakpoint/2)) && (OBV_0 > OBV_1))
     {
     }
   if(((price - price_1) < -(bollinger_breakpoint/2)) && (OBV_0 < OBV_1)) 
     {
     }*/
   if(!CheckOpenOrders())
     {
      if(!stops)
        {
         if(!time_randomizer)
           {
            if(confidence_level > confidence_breakpoint)
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
              }
            if(confidence_level < -confidence_breakpoint)
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
              }       
           }
         else 
           {
            if(confidence_level > confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),mid_chart,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/2.8;
                       }
                    }
                 }
              }
            if(confidence_level < -confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),mid_chart,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
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
            if(confidence_level > confidence_breakpoint)
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",CFT,0,clrNONE);
              }
            if(confidence_level < -confidence_breakpoint)
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",CFT,0,clrNONE);
              }       
           }
         else 
           {
            if(confidence_level > confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),mid_chart,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",CFT,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/2.8;
                       }
                    }
                 }
              }
            if(confidence_level < -confidence_breakpoint)
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),mid_chart,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",CFT,0,clrNONE);
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
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if(OrderType() == OP_BUY && confidence_level < (confidence_breakpoint/confidence_divisor))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && confidence_level > (confidence_breakpoint/confidence_divisor))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891