@{
    'LogPaths' = @{
        'Log' = '.\log\InfoLog.csv'
        'Warning' =  '.\log\WarningLog.csv'
        'Error' = '.\log\ErrorLog.csv'
    }
    #distribute number of cores from env variables among thread types
    'ThreadCounts' = @{
        'Loader' = 1
        'Worker' = 1
        'Recorder' = 1
    }
    #create extra threads for outputs; one per output stream
    'BonusThreads' = 4
}