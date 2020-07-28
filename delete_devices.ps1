param([int[]]$taskid)

# Connexion to  Ivanti MBSDK
$myWS = New-WebServiceProxy -uri http://localhost/MBSDKService/MsgSDK.asmx?WSDL -UseDefaultCredential


# Log function

 Function LogWrite
{
Param ([string]$logstring)
Add-content $Logfile -value $logstring
}


Try
{
foreach ($task in $taskid)
{
# Grab date and path for log and report
$date = Get-Date -Format "ddMMyyyy" 
$file_path = "E:\LANDesk\Results\$task\$date.xml"
$Logfile = "E:\LANDesk\Results\script_suppression.log"

#grab task status
$myWs.GetTaskMachineStatus($task).DeviceData | Sort-Object -Property Status | Out-File (New-Item -Path $file_path -Force -Type File)
LogWrite "$(Get-Date) Rapport pour la tache $task cree dans le repertoire $file_path"

# generate task report
$result = $($myWs.GetTaskMachineStatus($task).DeviceData) | Group -Property Status | Select -Property Count,Name | Out-String
Add-Content -Path $file_path  $result

# grab devices in the task 
$devices = $myWS.GetTaskMachineStatus($task).DeviceData.Name
LogWrite "$(Get-Date) Peripheriques presents dans la tache $task : $devices"

foreach ($name in $devices)
{

# delete device in the task
  $myWS.RemoveDeviceFromScheduledTask($task,$name)
  LogWrite "$(Get-Date) Suppression du peripherique (tache : $task) : $name"
}
} 
}

Catch
{
 LogWrite "$(Get-Date) $_.Exception"
 Break
 }

