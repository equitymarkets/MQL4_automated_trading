//+------------------------------------------------------------------+
//|                                                         Boll.mq4 |
//|                                  Copyright 2020, laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesing.io"
#property version   "1.00"
#property strict

extern double lot = 1;
extern int moving_average_calc = 21;
extern double high_band_value = 1;
extern double low_band_value = .3;
extern double stop_loss = 50;
extern double take_profit = 250;
extern int long_chart = 240;
extern int mid_chart = 60;
extern int short_chart = 5;
extern int mini_chart = 1;
extern double limit_pips = 1;
extern double vix_value = .75;
extern int vix_chart = 60;
extern int vix_shift = 0;
double pips;
int MagicNumber = 0101;

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   
   Comment("Layers EA initialized.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double Boll_higher = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,1,1);
   double Boll_middle = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,0,1);
   double Boll_lower = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,2,1);
   double band1 = ((Boll_higher - Boll_lower)/Boll_middle)*100;
   double vixfix = iCustom(Symbol(),vix_chart,"William Vix-Fix.ex4",0,vix_shift);
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_mini = iVolume(Symbol(),mini_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   Alert(Boll_lower);
   
//   if(OrdersTotal() < 1 && band1 < low_band_value)
//      
//      if((iClose(Symbol(),0,1) < Boll_lower))
//         double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0100,0,clrNONE);
//   if(OrdersTotal() < 1 && band1 < low_band_value)
//      if((iClose(Symbol(),0,1) > Boll_higher))
//         
//            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0100,0,clrNONE);      
   if(OrdersTotal() < 1 && band1 > high_band_value && vixfix > vix_value)
     {
      if(iClose(Symbol(),0,1) > Boll_higher && (iClose(Symbol(),0,1) > iClose(Symbol(),0,2)))
         if(vol_mini > vol_short/5)
            double buy = OrderSend(Symbol(),OP_BUY,lot,Ask - (limit_pips * pips),0,Ask - (stop_loss * pips),Ask + (take_profit * pips),NULL,0200,0,clrNONE);
   
      if(iClose(Symbol(),0,1) < Boll_lower  && (iClose(Symbol(),0,1) < iClose(Symbol(),0,2)))
         if(vol_mini > vol_short/5)
            double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),Bid - (take_profit * pips),NULL,0200,0,clrNONE);     
     }    
         
         
         
         
         
   //Closing Orders
      for(int i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0100)
              {
               if((OrderType() == OP_BUY) && (iClose(Symbol(),0,1) > Boll_middle))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 } 
               if((OrderType() == OP_SELL) && (iClose(Symbol(),0,1) < Boll_middle))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }   
           }
        }
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber() == 0200)
              {
               if((OrderType() == OP_BUY) && (iClose(Symbol(),0,1) < Boll_middle))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 } 
               if((OrderType() == OP_SELL) && (iClose(Symbol(),0,1) > Boll_middle))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               
              }
               
           }
        }
}
//+--------------------------------------------------------------+
