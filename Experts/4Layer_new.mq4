//To-Do; fix volume custom and alert test,
/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2022, laserdesign.io"                                             //0
#property link      "https://www.laserdesign.io"                                                 //0
#property version   "1.00"

#define layer 122006
extern double lot = 1;
extern int moving_average_calc = 21;

//ADX
extern int ADX_timeFrame = 240;
extern int ADXma = 14;
extern double ADXbreak = 25;
extern double ADXbreakaddition = 0;
extern double ADXbreaksubtraction = 5;
//MA
extern int MA_timeframe = 60;
extern int moving_average_low = 21;
extern int moving_average_mid = 55;
//extern int moving_average_high = 13;
//extern int moving_average_upper = 21;
//Volume
extern int VMA_Period=13;
extern int VMA_Method=0;
extern int VMA_Shift=0;

double pips;

bool CheckOpenOrders()
  { 
   for( int i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == layer) return(true); 
     } 
      return(false); 
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
int OnInit()                                                                                     //0 
  {                                                                                              //0
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {   
      pips = tick * 10;
     }
   else pips = tick;
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   //Layer_1: Volume(momentum)
   int volume_array[];
   int volume_array_size = Bars;
   ArrayResize(volume_array,volume_array_size);
   for(int i = 0; i < Bars; i++)
     {
      volume_array[i] = iVolume(Symbol(),240,i);
      Alert(volume_array[i]);
      Sleep(3000);
     }
     
   //Layer_2: MA Crossover(trend)
   double moving_average_low_calc = iMA(Symbol(),MA_timeframe,moving_average_low,0,MODE_SMA,PRICE_CLOSE,1);
   double moving_average_mid_calc = iMA(Symbol(),MA_timeframe,moving_average_mid,0,MODE_SMA,PRICE_CLOSE,1);
   //double moving_average_high_calc = iMA(Symbol(),MA_timeframe,moving_average_high,0,MODE_SMA,PRICE_CLOSE,1);
   //double moving_average_upper_calc = iMA(Symbol(),MA_timeframe,moving_average_upper,0,MODE_SMA,PRICE_CLOSE,1);
   
   //Layer_4: RSI(oscillator)
   int RSI_array[];
   int RSI_array_size = Bars;
   ArrayResize(RSI_array,RSI_array_size);
   for(int j = 0; j < Bars; j++)
     {
      RSI_array[j] = iRSI(Symbol(),240,14,PRICE_CLOSE,j);
     }
   Alert(RSI_array[3]);
   Sleep(3000);
   /*double ADX0 = iADX(Symbol(),ADX_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,0);
   double ADX1 = iADX(Symbol(),ADX_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   double ADX2 = iADX(Symbol(),ADX_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,2);
   double ADX3 = iADX(Symbol(),ADX_timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,3);*/
   
   double VMA = iCustom(Symbol(),0,"moving_average_volume",VMA_Period, VMA_Method,VMA_Shift,MODE_MAIN,0);
   if(!CheckOpenOrders() && ADX1 > ADXbreak)
      if(iClose(Symbol(),0,1) > iClose(Symbol(),0,2) && moving_average_low_calc > moving_average_mid_calc)
         double trendBuy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,layer,0,Green);
      else 
      if(iClose(Symbol(),0,1) < iClose(Symbol(),0,2) && moving_average_low_calc < moving_average_mid_calc)
         double trendSell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,layer,0,Red);      
      else
         Sleep(5000);
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891 
   if(CheckOpenOrders())
     {  
      for(int j = 0; j < OrdersTotal(); i++) 
           {
            if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == layer)
                 {
                  if((OrderType() == OP_BUY) && iClose(Symbol(),0,1) < iClose(Symbol(),0,2) && moving_average_low_calc < moving_average_mid_calc)
                    {
                     double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                    } 
                  if((OrderType() == OP_SELL) && iClose(Symbol(),0,1) > iClose(Symbol(),0,2) && moving_average_low_calc > moving_average_mid_calc)
                    {
                     double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                    }
                                   
                 }   
              }
           }
     }
  }