##EA.MQ4 Source Code and Executatable

EA.mq4  is the source code for most of the files and has recently been refactored for a smoother user experience. It is designed as a template, but currently uses a simple trading rule as an example-enter trades when price exceeds the previous bar, price exceeds the 21-period moving average, and current 21-period moving average exceeds prior 21-period moving average. It takes long and short trades based on this criteria.

The Random Time variable, if switched on, selects a random time in the first 6th of the new bar to execute the trade (minutes 0 - 9 in an hourly bar). In this way, 90% of trades are not made the first second upon receiving a signal from a closing bar.

Stops and take profits can be switched on or off.

The Paper Trade Tester, if switched on, tests to make sure a strategy is working before allowing live trades, then resets each week.

Happy Trading!
