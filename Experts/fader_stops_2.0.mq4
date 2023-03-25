//FIND STOP ORDERS FOR PROFIT QUERY

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

#define fader 011122                

input double lot = .1;
input int stop_loss = 50;
input int minDelay = 1;
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
//sandbox

bool OrderDelay(int magic)
  {
   int duration = 60 * minDelay;
   for(int i = (OrdersHistoryTotal()-1); i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         datetime close = OrderCloseTime();
         int open = close + duration;
         if(TimeCurrent() < open && OrderProfit() < 0)
           {
            return(false);
           }
        }
     }
   return(true);
  }
//
void NormalizeTicks()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick; 
  }    

bool Legacy() 
  {
   if(iTime(Symbol(),0,0)-iTime(Symbol(),0,1) > 25200)
     {
      return(false);
     }
   return(true);
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
   double double_lot = lot * 2;

   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double band_bottom = iBands(Symbol(),0,14,2,0,PRICE_CLOSE,2,1);
   double band_top = iBands(Symbol(),0,14,2,0,PRICE_CLOSE,1,1);
   double band_middle = iBands(Symbol(),0,14,2,0,PRICE_CLOSE,0,1);
   
   static bool buy_allowed = true, sell_allowed = true;
   
   if(!CheckOpenOrders())
     {
      if(buy_allowed && OrderDelay(fader))
        {
         if(price_1 < band_bottom)
           {
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",fader,0,clrNONE);
              
           }
        }      
     
      if(sell_allowed && OrderDelay(fader))
        {
         if(price_1 > band_top)
           {
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",fader,0,clrNONE);
            
           }
        }
     }
     
   if(CheckOpenOrders())
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == fader)
              {
               if(OrderType() == OP_BUY && price_1 > band_middle)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                    
                     if(OrderProfit() < 0)
                       {
                        buy_allowed = false;
                       }
                    
                 }
               if(OrderType() == OP_SELL && price_1 < band_middle)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                    
                     if(OrderProfit() < 0)
                       {
                        sell_allowed = false;
                       }
                    
                 }
              }      
           }
        }
     }


      
  }
//+------------------------------------------------------------------+
