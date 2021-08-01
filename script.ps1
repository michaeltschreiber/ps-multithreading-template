#requires -version 5.1
#requires -Module ThreadJob

#region Config
$script:config = Import-PowerShellDataFile -Path .\config.psd1
$ThreadId = [System.AppDomain]::GetCurrentThreadId()
#endregion Config

#region Import
. .\LogFunctions.ps1
#endregion Import

#region Classes

#endregion Classes

#region Functions

#endregion Functions

#region Procedure
# Define Input Queue
$InputQueue = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

# Define Output Queue
$OutputQueue = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

# Define Logger Queues
$LogCollection      = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}
$ErrorCollection    = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}
$WarningCollection  = [System.Collections.Concurrent.BlockingCollection[psobject]]@{}

# Start Info Logger Thread
$LoggerThread = Start-ThreadJob -Name "InfoLogger" -ArgumentList $LogCollection, $script:config -ScriptBlock {
    $LogCollection = $args[0]
    $config = $args[1]

    foreach ($logrecord in $LogCollection.GetConsumingEnumerable() )
    {
        Export-Csv -InputObject $logrecord -Path $config.logpaths.log -NoTypeInformation -Encoding UTF8 -Append
    }
}

# Start Error Logger Thread
$ErrorThread = Start-ThreadJob -Name "ErrorLogger" -ArgumentList $ErrorCollection, $script:config -ScriptBlock {
    $ErrorCollection = $args[0]
    $config = $args[1]

    foreach ($logrecord in $ErrorCollection.GetConsumingEnumerable() )
    {
        Export-Csv -InputObject $logrecord -Path $config.logpaths.error -NoTypeInformation -Encoding UTF8 -Append
    }
}

# Start Warning Logger Thread
$WarningThread = Start-ThreadJob -Name "WarningLogger" -ArgumentList $WarningCollection, $script:config -ScriptBlock {
    $WarningCollection = $args[0]
    $config = $args[1]

    foreach ($logrecord in $WarningCollection.GetConsumingEnumerable() )
    {
        Export-Csv -InputObject $logrecord -Path $config.logpaths.warning -NoTypeInformation -Encoding UTF8 -Append
    }
}

# Define Loader Threads : Adds Work Items to Input Queue (typical to use a single loader or manually divide input and assign chunks)

$LoaderThreads = [System.Collections.ArrayList]@()
for ($i = 1, $i -le $script:config.ThreadCounts.Loader, $i++)
{
    $ThreadId = "LoaderThread_$i"
    $LoaderThread = Start-ThreadJob -Name $ThreadId -StreamingHost $Host -InputObject $XXX -ArgumentList $ThreadId, $LogCollection, $WarningCollection, $ErrorCollection, $script:config, $InputQueue -ScriptBlock {
        $ThreadId = $args[0]
        $LogCollection = $args[1]
        $WarningCollection = $args[2]
        $ErrorCollection = $args[3]
        $config = $args[4]
        $InputQueue = $args[5]

        #todo
        # Process $Input

    [void] $LoaderThreads.Add($LoaderThread)
    }
}
# Define Worker Threads: Takes Objects From Input Queue and emits objects in output queue
$WorkerThreads = [System.Collections.ArrayList]@()
for ($i = 1, $i -le $script:config.ThreadCounts.Worker, $i++)
{
    $ThreadId = "WorkerThread_$i"
    $WorkerThread = Start-ThreadJob -Name $ThreadId -StreamingHost $Host -ArgumentList $ThreadId, $LogCollection, $WarningCollection, $ErrorCollection, $script:config, $InputQueue, $OutputQueue -ScriptBlock {
        $ThreadId = $args[0]
        $LogCollection = $args[1]
        $WarningCollection = $args[2]
        $ErrorCollection = $args[3]
        $config = $args[4]
        $InputQueue = $args[5]
        $OutputQueue = $args[6]

        #todo
    }

    [void] $WorkerThreads.Add($WorkerThread)
}

# Define Recorder Thread : Takes Objects From Output Queue and write to back-end datastore (typical to use a single recorder thread, e.g. for writing to SQLite db)
$RecorderThreads = [System.Collections.ArrayList]@()
for ($i = 1, $i -le $script:config.ThreadCounts.Recorder, $i++)
{
    $ThreadId = "RecorderThread_$i"
    $RecorderThread = Start-ThreadJob -Name $ThreadId -StreamingHost $Host -ArgumentList $ThreadId, $LogCollection, $WarningCollection, $ErrorCollection, $script:config, $OutputQueue -ScriptBlock {
        $ThreadId = $args[0]
        $LogCollection = $args[1]
        $WarningCollection = $args[2]
        $ErrorCollection = $args[3]
        $config = $args[4]
        $OutputQueue = $args[5]

        #todo
    }

    [void] $RecorderThreads.add($RecorderThread)
}

# Test log
# Write-LogStream -LogCollection $LogCollection -SourceId 'test' -RecordId 'test' -threadid $ThreadId -message 'this is a test'

# Test warning
# Write-WarningStream -WarningCollection $WarningCollection -SourceId 'test' -RecordId 'test' -threadid $ThreadId -message 'this is a test'

# Test error
# try { 1/0 }
# catch { Write-ErrorStream -ErrorCollection $ErrorCollection -sourceid 'test' -recordid 'test' -threadid $threadId -message 'this is a test' -ErrorRecord $_ }

# Close input queue after loader threads are complete #todo add check for all input records loaded
$LoaderThreads | Wait-Job
$InputQueue.CompleteAdding()

# Close output queue after worker threads are complete
$WorkerThreads | Wait-Job
$OutPutQueue.CompleteAdding()

# Wait for all threads to complete
$RecorderThreads | Wait-Job

# Close Log Collections and Wait for Logger Thread to Finish
$LogCollection.CompleteAdding()
$ErrorCollection.CompleteAdding()
$WarningCollection.CompleteAdding()

Wait-Job $LoggerThread
Wait-Job $ErrorThread
Wait-Job $WarningThread

#endregion Procedure