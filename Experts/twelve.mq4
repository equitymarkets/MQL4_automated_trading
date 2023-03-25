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

#define twelve 120721

input double lot = .1;
input int MA_1 = 21;
input int MA_2 = 55;
input int CCI_period = 21;
input int CCI_pos_break = 144;
input int CCI_neg_break = -144;

bool CheckOpenOrders(){ 
        
        for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
                OrderSelect( i, SELECT_BY_POS, MODE_TRADES ); 
                if (OrderSymbol() == Symbol()) return(true); 
        } 
        
        return(false); 
  }

double pips;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     {
      double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(tick == .00001 || tick == .001)
        {
         pips = tick * 10;
        }
      else
         pips = tick;
     }
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
   double double_lot = lot * 2;

   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);

   double CCI_0 = iCCI(Symbol(),0,CCI_period,PRICE_CLOSE,0);
   double CCI_1 = iCCI(Symbol(),0,CCI_period,PRICE_CLOSE,1);
   double CCI_2 = iCCI(Symbol(),0,CCI_period,PRICE_CLOSE,2);

   double MA_low = iMA(Symbol(),0,MA_1,0,MODE_SMA,PRICE_CLOSE,1);
   double MA_high = iMA(Symbol(),0,MA_2,0,MODE_SMA,PRICE_CLOSE,1);

   if(CheckOpenOrders() == false && price_1 > price_2 && MA_low > MA_high && CCI_0 < CCI_pos_break)

     {
      double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,twelve,0,clrNONE);
     }



   if(CheckOpenOrders() == false && price_1 < price_2 && MA_low < MA_high && CCI_0 > CCI_neg_break)

     {
      double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,twelve,0,clrNONE);
     }

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == twelve)
           {
            if((OrderType() == OP_BUY) && price_1 < price_2 && MA_low < MA_high && CCI_1 < CCI_2)
              {
               double buy_close = OrderClose(OrderTicket(),lot,Bid,0,clrNONE);
              }
         
            if((OrderType() == OP_SELL) && price_1 > price_2 && MA_low > MA_high && CCI_1 > CCI_2)
              {
               double sell_close = OrderClose(OrderTicket(),lot,Ask,0,clrNONE);
              }
           }
        }
      }






}
//+------------------------------------------------------------------+
