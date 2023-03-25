//REFACTOR AROUND TRADE DECISIONS 
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

#define heat 012022     

input double lot = .1;
input int timeframe = 240, fast_MA = 21, slow_MA = 55, lookback_period = 144;
input int moving_average_type = 0;                  //0=Simple, 1=Exponential, 2=Smoothed, 3=Linear
input bool time_randomizer = false;
input int RSI_period = 14;

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

bool Randomizer()
  {
   if(iTime(Symbol(),1,0) > (iTime(Symbol(),timeframe,0) + NormalizeDouble((MathRand()/2.8),0)))
     {
      return(true);
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
   double double_lot = lot * 2;

   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double MA_fast = iMA(Symbol(),timeframe,fast_MA,0,moving_average_type,PRICE_CLOSE,1);
   double MA_slow = iMA(Symbol(),timeframe,slow_MA,0,moving_average_type,PRICE_CLOSE,1);
   
   static int random_long = NormalizeDouble(MathRand()/2.8, 0); 
   static int random_short = NormalizeDouble(MathRand()/2.8, 0); 
   double buy, sell;
   int i, j;
   
   double comp_array[1][5];
   int comp_array_size = lookback_period;
   ArrayResize(comp_array,comp_array_size);
   for(i = 0; i < lookback_period; i++)
     {
      for(j = 0; j < 5; j++)
        {
         switch(j)
           {
            case 0: comp_array[i][j] = iClose(Symbol(),timeframe,1); break;
            case 1: comp_array[i][j] = iMA(Symbol(),timeframe,fast_MA,0,moving_average_type,PRICE_CLOSE,1); break;
            case 2: comp_array[i][j] = iMA(Symbol(),timeframe,slow_MA,0,moving_average_type,PRICE_CLOSE,1); break;
            case 3: comp_array[i][j] = iVolume(Symbol(),timeframe,1); break;
            case 4: comp_array[i][j] = iRSI(Symbol(),timeframe,RSI_period,PRICE_CLOSE,1); break;
           }
        }
     }
   
   double RSI_array[];
   int RSI_array_size = lookback_period;
   ArrayResize(RSI_array,RSI_array_size);
   for(i = 0; i < lookback_period; i++)
     {
      RSI_array[i] = iRSI(Symbol(),timeframe,14,PRICE_CLOSE,i);
     }

   double MA_array[];
   int MA_array_size = lookback_period;
   ArrayResize(MA_array,MA_array_size);
   for(int k = 0; k < lookback_period; k++)
     {
      MA_array[k] = iMA(Symbol(),timeframe,fast_MA,0,moving_average_type,PRICE_CLOSE,k);
     }
   
   double price_array[];
   int price_array_size = lookback_period;
   ArrayResize(price_array,price_array_size);
   for(int l = 0; l < lookback_period; l++)
     {
      price_array[l] = iClose(Symbol(),timeframe,l);
     }
      
   if(!CheckOpenOrders())
     {
      if(!time_randomizer)
        {
         if(price_1 > price_2 && price_1 > MA_fast)
           {
            buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",heat,0,clrNONE);
           }
         if(price_1 < price_2 && price_1 < MA_fast)
           {
            sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",heat,0,clrNONE);
           }       
        }
      else
        {
         if(price_1 > price_2 && price_1 > MA_fast)
           {
            if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",heat,0,clrNONE);
                 {
                  if(buy > -1)
                    {
                     random_long = MathRand()/2.8;
                    }
                 }
              }
           }
         if(price_1 < price_2 && price_1 < MA_fast)
           {
            if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",heat,0,clrNONE);
                 {
                  if(sell > -1)
                    {
                     random_short = MathRand()/2.8;
                    }
                 }
              }
           }
        }
     }
     
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == heat)
              {
               if(OrderType() == OP_BUY && price_1 < price_2 && price_1 < MA_fast)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL && price_1 > price_2 && price_1 > MA_fast)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }
  
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
