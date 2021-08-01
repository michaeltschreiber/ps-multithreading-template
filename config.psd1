@{
    'LogPaths' = @{
        'Log' = '.\log\InfoLog.csv'
        'Warning' =  '.\log\WarningLog.csv'
        'Error' = '.\log\ErrorLog.csv'
    }
    #distribute number of cores from env variables among thread types
    'ThreadCounts' = @{
        'Loader' = 1
        'Worker' = 14
        'Recorder' = 1
    }
    #create extra threads for log outputs; one per output stream
    'BonusThreads' = 3
    #Loader-Specific Configuration Info
    'Loader' = @{

    }
    #Worker-Specific Configuration Info
    'Worker' = @{

    }
    #Recorder-Specific Configuration Info
    'Recorder' = @{

    } 
}