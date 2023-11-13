# NutanixInventory
Output inventory of Nutanix VMs to CSV

! This script will attempt to install the official Nutanix powershell modules.  Those modules require powershell 6+.

This script was developed using powershell 7.3.9 with both the x64 and x86 packages installed from Microsoft: 
https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#installing-the-msi-package


Change $pccs to a list of your PrismCentral servers.
Change $outputFile if you don't want the CSV output to your desktop.

Run at your own risk.
