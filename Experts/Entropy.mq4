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

extern int timeframe = 5;          //5, 15, 30, 60, 240, 1440
 
bool trade_init = false;
  
int Entropy(int minutes)
  {
   int time_addition = rand()%(minutes * 60);
   return(time_addition);
  }
   
int OnInit()
  {
   Alert(Entropy(timeframe));
   Alert(rand()%(timeframe * 60));
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   
  }

