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
#define legacy 070407


input int MA_mid = 21, time_1 = 60;
input double lots = .1;
input bool weekend_break = false;

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
  
void OnTick()
  {
   double ima1 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1);
   double ima2 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,2);
   double close_price1 = (iClose(Symbol(),time_1,1));
   double close_price2 = (iClose(Symbol(),time_1,2));
  
   static bool trade_allowed = false, paper_buy = false, paper_sell = false;
   static double paper_buy_price, paper_sell_price, actual_buy_open, actual_sell_open;
   
   if(weekend_break)
     {
      if(iTime(Symbol(),time_1,0) - iTime(Symbol(),time_1,1) > 25200) 
        {
         trade_allowed = false;
        }
      if(!trade_allowed && !paper_buy) 
           {
            if((close_price1 > close_price2) && (ima1 >= ima2) && (close_price1 >= ima1))
              {
               paper_buy = true;
              
               if(paper_buy) 
                 {
                  paper_buy_price = close_price1;
                 }
              }
           }
      if(paper_buy) 
        {
         if(close_price1 <= ima1)
           {
            paper_buy = false;
              {
               if(!paper_buy) 
                 {
                  if(close_price1 > paper_buy_price)
                    {
                     trade_allowed = true;
                    }
                 }
              }
           }
        }
      if(!trade_allowed && !paper_sell) 
        {
         if((close_price1 < close_price2) && (ima1 <= ima2) && (close_price1 <= ima1))
           {
            paper_sell = true;
           
            if(paper_sell) 
              {
               paper_sell_price = close_price1;
              }
           }
        }
      if(paper_sell) 
        {
         if(close_price1 >= ima1)
           {
            paper_sell = false;
              {
               if(!paper_sell) 
                 {
                  if(close_price1 < paper_sell_price)
                    {
                     trade_allowed = true;
                    }
                 }
              }
           }
        }
      if(!CheckOpenOrders())
        {
         if(trade_allowed)
           {
            if((close_price1 > close_price2) && (ima1 >= ima2) && (close_price1 >= ima1))
              {
               actual_buy_open = OrderSend(Symbol(),OP_BUY,lots,Ask,0,0,0,NULL,legacy,0,clrNONE);
               
              }
           }
        }
      if(!CheckOpenOrders())
        {
         if(trade_allowed)
           {
            if((close_price1 < close_price2) && (ima1 <= ima2) && (close_price1 <= ima1))
              {
               actual_sell_open = OrderSend(Symbol(),OP_SELL,lots,Bid,0,0,0,NULL,legacy,0,clrNONE);
              }
           }
        }
      for(int i=0; i<OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
           { 
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == legacy)
              {
               if(OrderType()==OP_BUY && (close_price1 <= ima1))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1) 
                    {
                     if(long_close>-1) 
                       {
                        double actual_buy_close = close_price1;
                        if(OrderProfit() > 0) 
                          {
                           trade_allowed = true;
                          }
                       }
                    }
                 }
               if(OrderType()==OP_SELL && (close_price1 >= ima1))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1)
                    {
                     if(short_close>-1)
                       {
                        double actual_sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
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
     
   if(!weekend_break)
     {
      if(!CheckOpenOrders())
        {
         if((close_price1 > close_price2) && (ima1 >= ima2) && (close_price1 >= ima1))
           {
            actual_buy_open = OrderSend(Symbol(),OP_BUY,lots,Ask,0,0,0,NULL,legacy,0,clrNONE);
           }
         if((close_price1 < close_price2) && (ima1 <= ima2) && (close_price1 <= ima1))
           {
            actual_sell_open = OrderSend(Symbol(),OP_SELL,lots,Bid,0,0,0,NULL,legacy,0,clrNONE);
           }
        }
      for(i; i<OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
           { 
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == legacy)
              {
               if(OrderType()==OP_BUY && (close_price1 <= ima1))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType()==OP_SELL && (close_price1 >= ima1))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
     } 
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
