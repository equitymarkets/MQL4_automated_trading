# MQL4/5_automated_trading

EA.mq4 (available in the EA directory) is the source code for most of the files and has recently been refactored for a smoother user experiance. It is designed as a template, but currently uses a simple trading rule as an example-enter trades when price exceeds the previous bar, price exceeds the 21-period moving average, and current 21-period moving average exceeds prior 21-period moving average. It takes long and short trades based on this criteria.  

The Random Time variable, if switched on, selects a random time in the first 6th of the new bar to execute the trade (minutes 0 - 9 in an hourly bar). In this way, 90% of trades are not made the first second upon receiving a signal from a closing bar. 

Stops and take profits can be switched on or off. 

Fibonaccis as inputs seem to show better results. 

I have more stuff in progress. 

Feel free to use but please share if you can tweak them to get better results. I'd be happy to collaborate with you if you're serious about developing a strategy. 

Use at your own risk. Most of these are templates at best, and I will be not responsible for anybody's losses from using these. 

Make sure you use Magic Numbers. 
