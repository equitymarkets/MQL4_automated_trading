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

#define agg 121321

input double lot = .1;
input int RSI_period = 14;
input double RSI_top = 70;
input double RSI_middle = 50;
input double RSI_bottom = 30;
input double middle_adj = 0;        //adjusts middle value, buy or sell adjustment
input double stop_loss = 50;
input short timeframe = 240;
input int MA_1 = 21;
input int MA_2 = 55;

bool CheckOpenOrders(){ 
        
        for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
                OrderSelect( i, SELECT_BY_POS, MODE_TRADES ); 
                if (OrderSymbol() == Symbol()) return(true); 
        } 
        
        return(false); 
  }
bool TimeCheck()
     {
      //datetime close = OrderCloseTime(), now = TimeCurrent();
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == agg)
             {
              //datetime close = OrderCloseTime(), now = TimeCurrent();
              if((TimeCurrent() - OrderCloseTime()) > 3600) return(true);
              
             }
         //else return(false);    
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
   else pips = tick; 
     }  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double double_lot = lot * 2;
   
   double price = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   double MA_low = iMA(Symbol(),timeframe,MA_1,0,MODE_SMA,PRICE_CLOSE,1);
   double MA_high = iMA(Symbol(),timeframe,MA_2,0,MODE_SMA,PRICE_CLOSE,1); 
   
   if(CheckOpenOrders() == false && price_1 > price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<RSI_top)
     {
      if(MA_low > MA_high)
        {
         if(iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<RSI_bottom)
           {
            double buy = OrderSend(Symbol(),OP_BUY,double_lot,Ask,0,Ask - (stop_loss * pips),0,NULL,agg,0,clrNONE);
           }
         else
           {
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,agg,0,clrNONE);
           }
       }
      Sleep(100000);
     } 
   if(CheckOpenOrders() == false && price_1 < price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>RSI_bottom)
     {
      if(MA_low < MA_high)
        {
         if(iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>RSI_top)
           {
            double sell = OrderSend(Symbol(),OP_SELL,double_lot,Bid,0,Bid + (stop_loss * pips),0,NULL,agg,0,clrNONE);
           }
         else
           {
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,agg,0,clrNONE);
           }
        }
      Sleep(100000); 
     }              
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == agg)
           {
            if((OrderType() == OP_BUY) && price_1 < price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>(RSI_middle + middle_adj) && MA_low < MA_high)
              {
               double buy_close = OrderClose(OrderTicket(),lot,Bid,0,clrNONE);
              }             
            if((OrderType() == OP_SELL) && price_1 > price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<(RSI_middle - middle_adj) && MA_low > MA_high)
              {
               double sell_close = OrderClose(OrderTicket(),lot,Ask,0,clrNONE);
              }
           }   
        }
     }
  }
//+------------------------------------------------------------------+
