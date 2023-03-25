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
input bool time_randomizer = false, stops = false;
input int stop_loss = 30;
input short long_chart = 1440, mid_chart = 240, short_chart = 60;
input short MA_fast = 34, MA_slow = 70, signal_period = 3;
input short smoothedPriceMASmall = 2, smoothedPriceMALarge = 3, smoothedPriceMAType = 0, ma_method = 0;
input int bollinger_count = 21;
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

double BollingerCycle()
  {
   double counter;
   for(int i = 2; i < bollinger_count + 2; i++)
     {
      counter = counter + (iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,i) - iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,i));
     }
   double counter_mean = counter/bollinger_count;
   return(counter_mean); 
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
   double priceMid_High_0 = iLow(Symbol(),mid_chart,0);
   double priceMid_High_1 = iLow(Symbol(),mid_chart,1);
   double priceMid_High_2 = iLow(Symbol(),mid_chart,2);
   double priceMid_High_3 = iLow(Symbol(),mid_chart,3);
   double OBV_0 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,0);
   double OBV_1 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,2);
   double OBV_3 = iOBV(Symbol(),mid_chart,PRICE_CLOSE,3);
   double RSI_0 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,0);
   double RSI_1 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,1);
   double RSI_2 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,2);
   double RSI_3 = iRSI(Symbol(),mid_chart,14,PRICE_CLOSE,3);
   double fastMA_short_1 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_short_2 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
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
   
   double bollingerTop_mid_1 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,1);
   double bollingerTop_mid_0 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,1,0);
   double bollingerBottom_mid_1 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,1);
   double bollingerBottom_mid_0 = iBands(Symbol(),mid_chart,14,1,0,PRICE_CLOSE,2,0);
   
   double bollinger_breakpoint = BollingerCycle();
   
   double buy, sell;
   static double random_long = MathRand()/2.8, random_short = MathRand()/2.8;
   
   short confidence_level = 0;
   
   //1
   /*if(!CheckOpenOrders())
     {
      if(priceMid_Low_0 > priceMid_Low_1 && priceMid_Low_1 > priceMid_Low_2 && priceMid_Low_2 > priceMid_Low_3 && priceSmoothedSmall_mid_0 > fastMA_mid_1)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(priceMid_High_0 < priceMid_High_1 && priceMid_High_1 < priceMid_High_2 && priceMid_High_2 < priceMid_High_3 && priceSmoothedSmall_mid_0 < fastMA_mid_1)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
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
               if(OrderType() == OP_BUY && priceMid_Low_0 < priceMid_Low_2 && priceSmoothedSmall_mid_0 < fastMA_mid_1)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && priceMid_High_0 > priceMid_High_2 && priceSmoothedSmall_mid_0 > fastMA_mid_1)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }*/
   //2
   /*if(!CheckOpenOrders())
     {
      if(priceSmoothedLarge_mid_0 > priceSmoothedLarge_long_1 && price_1 > price_2)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(priceSmoothedLarge_mid_0 < priceSmoothedLarge_long_1 && price_1 < price_2)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
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
               if(OrderType() == OP_BUY && priceSmoothedLarge_mid_0 < priceSmoothedLarge_long_1 && price_1 < price_2)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && priceSmoothedLarge_mid_0 > priceSmoothedLarge_long_1  && price_1 > price_2)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }*/
   //3
   /*if(!CheckOpenOrders())
     {
      if((OBV_0 + OBV_1)/2 > (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 > 50 && (RSI_0 + RSI_1)/2 < 70)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if((OBV_0 + OBV_1)/2 < (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 < 50 && (RSI_0 + RSI_1)/2 > 30) 
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
        }
     }
   for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if((OrderType() == OP_BUY && ((OBV_0 + OBV_1)/2 < (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 < 50)) || (OrderType() == OP_BUY && ((OBV_0 + OBV_1)/2 < (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 > 70)))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if((OrderType() == OP_SELL && ((OBV_0 + OBV_1)/2 > (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 > 50)) || (OrderType() == OP_SELL && ((OBV_0 + OBV_1)/2 > (OBV_2 + OBV_3)/2 && (RSI_0 + RSI_1)/2 < 30)))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }*/
   //4
   /*if(!CheckOpenOrders())
     {
      if(fastMA_short_1 > slowMA_short_1)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE); 
        }
      if(fastMA_short_1 < slowMA_short_1)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
        }
     }
   for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if(OrderType() == OP_BUY && fastMA_short_1 < slowMA_short_1)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && fastMA_short_1 > slowMA_short_1)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }*/
   //5
   /*if(!CheckOpenOrders())
     {
      if(fastMA_mid_1 > slowMA_mid_1)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(fastMA_mid_1 < slowMA_mid_1)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
        }
     }
   for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if(OrderType() == OP_BUY && fastMA_mid_1 < slowMA_mid_1)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && fastMA_mid_1 > slowMA_mid_1)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }*/
   //6
   if(!CheckOpenOrders())
     {
      if(((fastMA_mid_0 + fastMA_mid_1)/2) > fastMA_long_1)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(((fastMA_mid_0 + fastMA_mid_1)/2) < fastMA_long_1)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
        }
     }
   for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if((OrderType() == OP_BUY && (fastMA_mid_0 + fastMA_mid_1)/2 < fastMA_long_1))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if((OrderType() == OP_SELL && (fastMA_mid_0 + fastMA_mid_1)/2 > fastMA_long_1))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
   //7
   /*if(!CheckOpenOrders())
     {
      if(MACD_1 > MACD_2)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(MACD_1 < MACD_2)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
        } 
     }
    for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == CFT)
              {
               if(OrderType() == OP_BUY && MACD_1 < MACD_2)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && MACD_1 > MACD_2)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        } */
   //8
   /*if(!CheckOpenOrders())
     {
      if((((bollingerTop_mid_1 + bollingerTop_mid_0)/2 - (bollingerBottom_mid_1 + bollingerBottom_mid_0)/2) > bollinger_breakpoint) && priceSmoothedSmall_mid_0 > bollingerTop_mid_1)
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if((((bollingerTop_mid_1 + bollingerTop_mid_0)/2 - (bollingerBottom_mid_1 + bollingerBottom_mid_0)/2) > bollinger_breakpoint) && priceSmoothedSmall_mid_0 < bollingerBottom_mid_1)
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);
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
               if(OrderType() == OP_BUY && priceSmoothedSmall_mid_0 < iMA(Symbol(),mid_chart,14,0,MODE_SMA,PRICE_CLOSE,1))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && priceSmoothedSmall_mid_0 > iMA(Symbol(),mid_chart,14,0,MODE_SMA,PRICE_CLOSE,1))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        } 
     }*/
   //9
   /*if(!CheckOpenOrders())
     {
      if(((price - price_1) > (bollinger_breakpoint * 1.25)) && (OBV_0 > OBV_1))
        {
         buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",CFT,0,clrNONE);
        }
      if(((price - price_1) < -(bollinger_breakpoint * 1.25)) && (OBV_0 < OBV_1)) 
        {
         sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",CFT,0,clrNONE);  
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
               if(OrderType() == OP_BUY && ((price - price_1) < (bollinger_breakpoint * 1.25)) && (OBV_0 < OBV_1))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && ((price - price_1) > -(bollinger_breakpoint * 1.25)) && (OBV_0 > OBV_1))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }*/
    
  } 
     
     /*Alert(priceSmoothedSmall_mid_0);
     Sleep(10000);
     Alert(iMA(Symbol(),mid_chart,14,0,MODE_SMA,PRICE_CLOSE,1));
     Sleep(10000);  */  


//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891