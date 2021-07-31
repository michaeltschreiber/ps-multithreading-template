Class LogRecord
{
    [string]$LogEntryType
    [string]$SourceId
    [string]$RecordId
    [string]$ThreadId
    [string]$Message
    [string]$ErrorMsg
    [string]$datetime
}
function Write-LogStream
{
    [CmdletBinding()]
    param(
        $LogCollection,
        [string] $LogEntryType = 'Log',
        #Source file or database name
        [string] $SourceId = '',
        #Record being processed
        [string] $RecordId = '',
        #Identifier of thread generating msg
        [string] $ThreadId = '',
        #Message to log
        [string] $Message = '',
        #Date of msg
        [datetime] $datetime = (get-date)
    )

    $LogRecord = New-Object LogRecord

    $LogRecord.LogEntryType = $LogEntryType
    $LogRecord.SourceId = $SourceId
    $LogRecord.RecordId = $RecordId
    $LogRecord.ThreadId = $ThreadId
    $LogRecord.Message  = $Message
    $LogRecord.datetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

    $LogCollection.Add($LogRecord)
}
function Write-ErrorStream
{
    param(
        $ErrorCollection,

        [System.Management.Automation.ErrorRecord] $ErrorRecord,

        [string] $LogEntryType = 'Error',
        #Source file or database name
        [string] $SourceId = '',
        #Record being processed
        [string] $RecordId = '',
        #Identifier of thread generating msg
        [string] $ThreadId = '',
        #Message to log
        [string] $Message = '',
        #Error Information, if any
        [string] $ErrorMsg = "$($ErrorRecord.Exception.GetType()) | $($ErrorRecord.Exception.Message) | $($ErrorRecord.Exception.InnerException.Message)",
        #Date of error
        [datetime] $datetime = (get-date)
    )

        $LogRecord = New-Object LogRecord

        $LogRecord.LogEntryType = $LogEntryType
        $LogRecord.SourceId = $SourceId
        $LogRecord.RecordId = $RecordId
        $LogRecord.Message  = $Message
        $LogRecord.ThreadId = $ThreadId
        $LogRecord.ErrorMsg = $ErrorMsg
        $LogRecord.datetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

        $ErrorCollection.Add($LogRecord)
}
function Write-WarningStream
{
    [CmdletBinding()]
    param(
        $WarningCollection,
        [string] $LogEntryType = 'Warning',
        #Source file or database name
        [string] $SourceId = '',
        #Record being processed
        [string] $RecordId = '',
        #Identifier of thread generating msg
        [string] $ThreadId = '',
        #Message to log
        [string] $Message = '',
        #Date of error
        [datetime] $datetime = (get-date)
    )

    $LogRecord = New-Object LogRecord

    $LogRecord.LogEntryType = $LogEntryType
    $LogRecord.SourceId = $SourceId
    $LogRecord.RecordId = $RecordId
    $LogRecord.ThreadId = $ThreadId
    $LogRecord.Message  = $Message
    $LogRecord.datetime = $datetime.ToString("yyyy-MM-dd HH:mm:ss")

    $WarningCollection.Add($LogRecord)

}