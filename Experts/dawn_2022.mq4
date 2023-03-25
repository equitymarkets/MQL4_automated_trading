
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
#property strict

#define dawn_2022 033122              

input double lot = .25;

input int volume_timeframe = 30; 
input int ATR_timeframe = 240, ATR_fast = 5, ATR_slow = 21;

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
   //Price
   double price_0 = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
      
   //Momentum
   long volume_0 = iVolume(Symbol(),volume_timeframe,0);
   long volume_1 = iVolume(Symbol(),volume_timeframe,1);
   long volume_2 = iVolume(Symbol(),volume_timeframe,2);
   
   //Volume
   double OBV_1 = iOBV(Symbol(),volume_timeframe,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),volume_timeframe,PRICE_CLOSE,2);
   
   //Trend 
   double ATR_fast_calc_1 = iATR(Symbol(),ATR_timeframe,ATR_fast,1);
   double ATR_slow_calc_1 = iATR(Symbol(),ATR_timeframe,ATR_slow,1);
   
   double ATR_fast_calc_2 = iATR(Symbol(),ATR_timeframe,ATR_fast,2);
   double ATR_slow_calc_2 = iATR(Symbol(),ATR_timeframe,ATR_slow,2);
   
   //Oscillator
   
   //Trade
   double double_lot = lot * 2;



   if(!CheckOpenOrders())
     {
      if(ATR_fast_calc_1 > ATR_slow_calc_1 && ATR_fast_calc_1 > ATR_fast_calc_2 && ATR_slow_calc_1 > ATR_slow_calc_2)
        {
         if(OBV_1 > OBV_2 && OBV_1 > 0)      //?OBV_1 or OBV_2??
           {
            if(price_1 > price_2)
              {
               double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",dawn_2022,0,clrNONE);
              }
           }
         if(OBV_1 < OBV_2 && OBV_1 < 0)   
           {    
            if(price_1 < price_2)
              {
               double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",dawn_2022,0,clrNONE);
              }
           }
        }
     }
     
   if(CheckOpenOrders())
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == dawn_2022)
              {
               if(OrderType() == OP_BUY && price_1 < price_2 && ATR_fast_calc_1 < ATR_slow_calc_1 && ATR_fast_calc_1 < ATR_fast_calc_2 && ATR_slow_calc_1 < ATR_slow_calc_2)
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                    
                 }
               if(OrderType() == OP_SELL && price_1 > price_2 && ATR_fast_calc_1 < ATR_slow_calc_1 && ATR_fast_calc_1 < ATR_fast_calc_2 && ATR_slow_calc_1 < ATR_slow_calc_2)
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
     }


      
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
