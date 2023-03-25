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
#property link      "https://www.metatrader5.com/en/terminal/help/charts_analysis/indicators"   //reference

#define fan 120821

input double lot = .5;
input int MA_1 = 5,MA_2 = 21,MA_3 = 55, RSI_timeframe = 240, RSI_top = 55,RSI_bottom = 45, vol_timeframe = 240;
input bool double_orders = true;
input int lot_doubler = 2;

extern double stop_loss = 50;
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

void NormalizeTicks()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick; 
  }    

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   double tick=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips=tick*10;
     }
   else pips = tick;
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double double_lot = lot * lot_doubler;
   double buy, sell;
   double price = iClose(Symbol(),0,0); 
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double fast_MA = iMA(Symbol(),0,MA_1,0,MODE_SMA,PRICE_CLOSE,1);
   double inter_MA = iMA(Symbol(),0,MA_2,0,MODE_SMA,PRICE_CLOSE,1);
   double slow_MA = iMA(Symbol(),0,MA_3,0,MODE_SMA,PRICE_CLOSE,1);
   
   double RSI_1 = iRSI(Symbol(),RSI_timeframe,14,PRICE_CLOSE,1);
   
   long volume_1 = iVolume(Symbol(),vol_timeframe,1);
   long volume_2 = iVolume(Symbol(),vol_timeframe,2);
   
   if(!CheckOpenOrders())
     {
      if(volume_1 > volume_2)
        {
         if(price_1 >= price_2)
           {
            if(fast_MA > slow_MA && RSI_1 < RSI_top)
              {
               if(double_orders && fast_MA > inter_MA && inter_MA > slow_MA) 
                 {
                  buy = OrderSend(Symbol(),OP_BUY,double_lot,Ask,0,0,0," ",fan,0,clrNONE);
                 }
               else
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",fan,0,clrNONE);
                 }
              }
           }
         if(price_1 < price_2)
           {
            if(fast_MA < slow_MA && RSI_1 > RSI_bottom)
              {
               if(double_orders && fast_MA < inter_MA && inter_MA < slow_MA) 
                 {
                  sell = OrderSend(Symbol(),OP_SELL,double_lot,Bid,0,0,0," ",fan,0,clrNONE);
                 }
               else
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",fan,0,clrNONE);
                 }
              }
           }
        }
     }      

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == fan)
           {
            if(price_1 < price_2)
              {
               if(OrderType() == OP_BUY && fast_MA < inter_MA && inter_MA < slow_MA && price_1 < slow_MA)
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
              }
            if(price_1 > price_2)
              {
               if(OrderType() == OP_SELL && fast_MA > inter_MA && inter_MA > slow_MA && price_1 > slow_MA)
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
     }
  }

