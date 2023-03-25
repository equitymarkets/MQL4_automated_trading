/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define dim 122221        

input double lot = .1;

input long quick_vol = 15;
input long med_vol = 30;
input long long_vol = 1440;
input int iad_break = 0;

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
   long quick = iVolume(Symbol(),quick_vol,1)/quick_vol;
   long med = iVolume(Symbol(),med_vol,1)/med_vol;
   long big = iVolume(Symbol(),long_vol,1)/long_vol;
   
   double double_lot = lot * 2;
   
   //Price
   double price_0 = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   

   
   double iad_1 = iAD(Symbol(),0,1);
   double iad_2 = iAD(Symbol(),0,2);
   
   //Momentum
   long volume_0 = iVolume(Symbol(),0,0);
   long volume_1 = iVolume(Symbol(),0,1);
   long volume_2 = iVolume(Symbol(),0,2);
   double quick_volume_1 = iVolume(Symbol(),quick_vol,1);
   //Trend 
   
   //Oscillator
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891   
   
   
   if(!CheckOpenOrders())
     {
      if(quick > med && med > big)
        {
         if(price_1 > price_2)
           {
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",dim,0,clrNONE);
           }
        
         if(price_1 < price_2)
           {
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",dim,0,clrNONE);
           }
        }
     }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891     
   if(CheckOpenOrders())
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == dim)
              {
               if(OrderType() == OP_BUY && price_1 < price_2)
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && price_1 > price_2)
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
     }
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
