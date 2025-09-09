//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                                       dashboard_monitoring.mq4 |
//|                                                                                 laserdesign.io |
//|                                                                     https://www.laserdesign.io |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#include <Controls/Button.mqh>
#include <Controls/Dialog.mqh>
#include <Controls/Label.mqh>
#include <Controls/Edit.mqh>

//Container
CButton obj_Btn_MAIN;

#define Btn_MAIN "Btn_MAIN"

//Pair Notation
CLabel obj_Lbl_PAIR;
CEdit obj_Edit_PAIR;

#define Lbl_PAIR "Lbl_PAIR"
#define Edit_PAIR "Edit_PAIR"

//Active Buys/Sells
CLabel obj_Lbl_BUY;
CLabel obj_Lbl_SELL;
CEdit obj_Edit_BUY;
CEdit obj_Edit_SELL;

#define Lbl_BUY "Lbl_BUY"
#define Lbl_SELL "Lbl_SELL"
#define Edit_BUY "Edit_BUY"
#define Edit_SELL "Edit_SELL"

//Total P/L
CLabel obj_Lbl_PROFIT;
CEdit obj_Edit_PROFIT;

#define Lbl_PROFIT "Lbl_PROFIT"
#define Edit_PROFIT "Edit_PROFIT"

//Open Groups
CLabel obj_Lbl_GROUPS;
CEdit obj_Edit_GROUPS;

#define Lbl_GROUPS "Lbl_GROUPS"
#define Edit_GROUPS "Edit_GROUPS"

//Account Equity
CLabel obj_Lbl_EQUITY;
CEdit obj_Edit_EQUITY;

#define Lbl_EQUITY "Lbl_EQUITY"
#define Edit_EQUITY "Edit_EQUITY"

//Account Balance
CLabel obj_Lbl_BALANCE;
CEdit obj_Edit_BALANCE;

#define Lbl_BALANCE "Lbl_BALANCE"
#define Edit_BALANCE "Edit_BALANCE"

CLabel obj_Lbl_DRAWDOWN;
CEdit obj_Edit_DRAWDOWN;

#define Lbl_DRAWDOWN "Lbl_DRAWDOWN" 
#define Edit_DRAWDOWN "Edit_DRAWDOWN"

//Main Application
CAppDialog obj_Main_APP;

#define Main_APP "Main_APP"

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                                 Expert initialization function |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
  
int OnInit()
  {
   DashCreate();
   
   return(INIT_SUCCEEDED);
  }
   
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                                 Expert on chart event function |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   obj_Main_APP.ChartEvent(id,lparam,dparam,sparam);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                               Expert deinitialization function |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   obj_Main_APP.Destroy();
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                                           Expert tick function |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
   
  {
   DashUpdate();
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//|                                                                               Custom functions |
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

int BuyCounter() 
  {
   int buy_orders_count = 0;

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType() == OP_BUY)
           {
            buy_orders_count++;
           }
        }
     }
   return buy_orders_count;
  }

int SellCounter()
  {
   int sell_orders_count = 0;
   
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType() == OP_SELL)
           {
            sell_orders_count++;
           }
        }
     }
   return sell_orders_count;
  }

double TotalPandL() 
  {
   double p_and_l = 0;
   
   for(int i = OrdersHistoryTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS, MODE_HISTORY))
        {
         p_and_l = p_and_l + OrderProfit();
        }
     }
   return NormalizeDouble(p_and_l,2);
  } 

int CountPairs()
  {
   int pairs_count = 0;

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSymbol() != _Symbol)
        {
         pairs_count++;
        }      
     }
   return pairs_count;
  }
  
double GetMaxDrawdown()
{
   static double equity_peak   = 0;
   static double max_drawdown  = 0;

   double equity = AccountEquity();

   // Update peak equity if a new high is reached
   if(equity > equity_peak)
      equity_peak = equity;

   // Calculate drawdown from the current peak
   double drawdown = equity_peak - equity;

   // Update max drawdown if this one is larger
   if(drawdown > max_drawdown)
      max_drawdown = drawdown;

   return NormalizeDouble(max_drawdown,2);  // absolute peak-to-trough drawdown
}

void DashCreate()
  {
   //Create Application
   obj_Main_APP.Create(0,Main_APP,0,15,15,0,0);
   obj_Main_APP.Run();
   
   //Main Container   
   obj_Main_APP.Add(obj_Btn_MAIN);
   obj_Btn_MAIN.Create(0,Btn_MAIN,0,15,15,0,0);
   obj_Btn_MAIN.Size(300,335);
   obj_Btn_MAIN.ColorBackground(clrLightGray);
   
   //Pair Notation
   obj_Lbl_PAIR.Create(0,Lbl_PAIR,0,20,25,0,0);
   obj_Lbl_PAIR.Text("Pair: ");
   obj_Lbl_PAIR.FontSize(18);
   obj_Lbl_PAIR.Font("Arial");
   
   obj_Edit_PAIR.Create(0,Edit_PAIR,0,210,25,0,0);
   obj_Edit_PAIR.Text(_Symbol);
   obj_Edit_PAIR.Size(100,35);
   obj_Edit_PAIR.Color(clrBlack);
   obj_Edit_PAIR.ColorBackground(clrLightBlue);
   obj_Edit_PAIR.Font("Times new roman");
   obj_Edit_PAIR.FontSize(16);
   
   //Active Buys/Sells
   obj_Lbl_BUY.Create(0,Lbl_BUY,0,20,65,0,0);
   obj_Lbl_BUY.Text("Active Buys: ");
   obj_Lbl_BUY.FontSize(18);
   obj_Lbl_BUY.Font("Arial");
   
   obj_Lbl_SELL.Create(0,Lbl_SELL,0,20,105,0,0);
   obj_Lbl_SELL.Text("Active Sells: ");
   obj_Lbl_SELL.FontSize(18);
   obj_Lbl_SELL.Font("Arial");
   
   //Total Profit
   obj_Lbl_PROFIT.Create(0,Lbl_PROFIT,0,20,145,0,0);
   obj_Lbl_PROFIT.Text("Closed P/L: ");
   obj_Lbl_PROFIT.FontSize(18);
   obj_Lbl_PROFIT.Font("Arial");
   
   //Open Groups
   obj_Lbl_GROUPS.Create(0,Lbl_GROUPS,0,20,185,0,0);
   obj_Lbl_GROUPS.Text("Open Groups: ");
   obj_Lbl_GROUPS.FontSize(18);
   obj_Lbl_GROUPS.Font("Arial");
   
   //Account Equity
   obj_Lbl_EQUITY.Create(0,Lbl_EQUITY,0,20,225,0,0);
   obj_Lbl_EQUITY.Text("Account Equity: ");
   obj_Lbl_EQUITY.FontSize(18);
   obj_Lbl_EQUITY.Font("Arial");
   
   //Account Balance
   obj_Lbl_BALANCE.Create(0,Lbl_BALANCE,0,20,265,0,0);
   obj_Lbl_BALANCE.Text("Account Balance: ");
   obj_Lbl_BALANCE.FontSize(18);
   obj_Lbl_BALANCE.Font("Arial");
   
   obj_Lbl_DRAWDOWN.Create(0,Lbl_DRAWDOWN,0,20,305,0,0);
   obj_Lbl_DRAWDOWN.Text("Max Drawdown: ");
   obj_Lbl_DRAWDOWN.Font("Arial");
   obj_Lbl_DRAWDOWN.FontSize(18);
  }

void DashUpdate()
  {
   obj_Edit_BUY.Create(0,Edit_BUY,0,210,65,0,0);
   obj_Edit_BUY.Text(string(BuyCounter()));
   obj_Edit_BUY.Size(100,35);
   obj_Edit_BUY.Color(clrBlack);
   obj_Edit_BUY.ColorBackground(clrHoneydew);
   obj_Edit_BUY.Font("Times new roman");
   obj_Edit_BUY.FontSize(16);

   obj_Edit_SELL.Create(0,Edit_SELL,0,210,105,0,0);
   obj_Edit_SELL.Text(string(SellCounter()));
   obj_Edit_SELL.Size(100,35);
   obj_Edit_SELL.Color(clrBlack);
   obj_Edit_SELL.ColorBackground(clrMistyRose);
   obj_Edit_SELL.Font("Times new roman");
   obj_Edit_SELL.FontSize(16);
   
   obj_Edit_PROFIT.Create(0,Edit_PROFIT,0,210,145,0,0);
   obj_Edit_PROFIT.Text(string(TotalPandL()));
   obj_Edit_PROFIT.Size(100,35);
   obj_Edit_PROFIT.Color(clrBlack);
   obj_Edit_PROFIT.ColorBackground(TotalPandL()>0 ? clrHoneydew : clrMistyRose);
   obj_Edit_PROFIT.Font("Times new roman");
   obj_Edit_PROFIT.FontSize(16);
   
   obj_Edit_GROUPS.Create(0,Edit_GROUPS,0,210,185,0,0);
   obj_Edit_GROUPS.Text(string(CountPairs()));
   obj_Edit_GROUPS.Size(100,35);
   obj_Edit_GROUPS.Color(clrBlack);
   obj_Edit_GROUPS.ColorBackground(clrLightBlue);
   obj_Edit_GROUPS.Font("Times new roman");
   obj_Edit_GROUPS.FontSize(16);
   
   obj_Edit_EQUITY.Create(0,Edit_EQUITY,0,210,225,0,0);
   obj_Edit_EQUITY.Text(string(AccountEquity()));
   obj_Edit_EQUITY.Size(100,35);
   obj_Edit_EQUITY.Color(clrBlack);
   obj_Edit_EQUITY.ColorBackground(clrHoneydew);
   obj_Edit_EQUITY.Font("Times new roman");
   obj_Edit_EQUITY.FontSize(16);
   
   obj_Edit_BALANCE.Create(0,Edit_BALANCE,0,210,265,0,0);
   obj_Edit_BALANCE.Text(string(AccountBalance()));
   obj_Edit_BALANCE.Size(100,35);
   obj_Edit_BALANCE.Color(clrBlack);
   obj_Edit_BALANCE.ColorBackground(clrHoneydew);
   obj_Edit_BALANCE.Font("Times new roman");
   obj_Edit_BALANCE.FontSize(16);
   
   obj_Edit_DRAWDOWN.Create(0,Edit_DRAWDOWN,0,210,305,0,0);
   obj_Edit_DRAWDOWN.Text(string(GetMaxDrawdown()));
   obj_Edit_DRAWDOWN.Size(100,35);
   obj_Edit_DRAWDOWN.Color(clrBlack);
   obj_Edit_DRAWDOWN.ColorBackground(clrMistyRose);
   obj_Edit_DRAWDOWN.Font("Times new roman");
   obj_Edit_DRAWDOWN.FontSize(16);
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891