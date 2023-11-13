# This script will process through the array($pcss) of Prism Central Servers, gathering VM information from each, and output to CSV
#   !It requires the nutanix modules to be installed and will attempt to do so.!
#   
#   The nutanix modules require powershell 6 or higher.  This was developed on PS v7.39 x64 & x86.  Both archtectures are recommended.
#
#   Modify $pcss and $outputFile as desired before running.
#
#   Suggested modifications: for automation, move authentication to passthrough from the scheduling agent.
#
#  v0.1 - Draft
#  Written by Paul Dickson



# Array of Prism Central servers to connect to:
$pcss=@("prismcentral.home.local")

#$pcss=@("server1",
#        "server2")

# File to output to as CSV
$outputFile="$env:userprofile\Desktop\NutanixVMs.csv"

# Install official Nutanix powershell modules from psgallery
install-module nutanix.cli
install-module nutanix.prism.common
install-module nutanix.prism.ps.cmds  

# Import the installed modules into the running configuration
import-module nutanix.cli
import-module nutanix.prism.common
import-module nutanix.prism.ps.cmds 

# Get the credentials you wish to connect to the prism central servers with
function get-Creds { 
    $script:cred=Get-Credential -message "Enter the credentials to connect to the Prism Central server(s)"
}
get-Creds

# Establish connection to Prism Central Server
function connectPC{
    Connect-PrismCentral -AcceptInvalidSSLCerts -server $prismCentral -Credential $script:cred -ForcedConnection -ea Stop
}

# format data for output
function select-VMInfo{
    $vm | select vmname, description, hostname, pchostname,powerstate, @{N="IPAddresses";E={$_.ipaddresses}},hypervisorType,numVCpus,@{N="Memory(GB)";E={($_.memoryCapacityInBytes)/1GB}} 
}


$firstExport=$true
foreach ($prismCentral in $pcss){
    # Connect to $prismCentral server
    write-host Connecting to PrismCentral server: $prismCentral
    try{
        connectPC
    }
    catch{
        while ($true){
            $_
            Write-error "Credentials provided failed while connecting to $prismCentral.  Try again."
            get-Creds
            try{
                connectPC
                # if connection was successful, break while loop.
                break
            }catch{
                # Connection failed.  Do nothing and begin while loop again.
            }
        }
    }
    write-host "Connected!" -ForegroundColor Green

    # Report details of each $vm
    $vms = get-vm
    foreach ($vm in $vms){
        $result=select-VMInfo
        $result
        if ($firstExport){
            # Export with column headers/titles, and over-write any existing file
            $result | ConvertTo-Csv | out-file "$outputFile"
            $firstExport=$false
        }else{
            # Export without column headers
            $result | ConvertTo-Csv | select -skip 1 | out-file -append "$outputFile"
        }
    }

    Disconnect-PrismCentral -Servers $prismCentral
}


