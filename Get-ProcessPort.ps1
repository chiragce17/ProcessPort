function Get-ProcessPorts {
     
   [cmdletbinding()]
   Param(
      [parameter(Mandatory = $True, ValueFromPipeLine = $True)]
      [AllowEmptyCollection()]
      [string[]]$ProcessName
   )

   Begin {
       
      Write-Verbose "Declaring empty array to store the output"
      $portout = @()
                  
   }

   Process {
         
      try {
        
         Write-Verbose "Processes to get the port information"      
         $processes = Get-Process $ProcessName  -ErrorAction Ignore

         foreach ($proc in $processes) {
             

            # Get the port for the process.
            $mports = Netstat -ano | findstr $proc.ID
             
            if ($mports) {

               # Separate each instance 
               foreach ($sport in $mports) {

                  # Split the netstat output and remove empty lines from the output.
                  $out = $sport.Split('') | where { $_ -ne "" }

                  $LCount = $out[1].LastIndexOf(':')

                  $RCount = $out[2].LastIndexOf(':')
                
                
                  $portout += [PSCustomObject]@{
                                  
                     'Process'       = $proc.Name
                     'PID'           = $proc.ID
                     'Protocol'      = $out[0]
                     'LocalAddress'  = $out[1].SubString(0, $LCount)
                     'LocalPort'     = $out[1].SubString($Lcount + 1, ($out[1].Length - $Lcount - 1))
                     'RemoteAddress' = $out[2].SubString(0, $RCount)
                     'RemotePort'    = $out[2].SubString($RCount + 1, ($out[2].Length - $Rcount - 1))
                     'Connection'    = $(
                        # Checking if the connection contains any empty string.
                        if (!($out[3] -match '\d')) { $out[3] }      
                     )
                                  
                  }

               }
            }  #If loop ends 
            
            else {
               Write-Host "`nProcess $($Proc.Name) with PID : $($proc.ID) doesn't have any active ports" -BackgroundColor DarkRed
              
            }
             
           
         } #Foreach loop ends 

         $portout |  ft -AutoSize

      } #Try block ends

      catch {
         Write-Host "$($_.Exception.Message)" -BackgroundColor DarkRed
      }

   }

   End {
      
      Write-Verbose "End of the program"
   }
}

