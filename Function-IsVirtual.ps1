function IsVirtual {
  $wmibios = Get-WmiObject Win32_BIOS -ErrorAction Stop | Select-Object version,serialnumber 
  $wmisystem = Get-WmiObject Win32_ComputerSystem -ErrorAction Stop | Select-Object model,manufacturer
  $ResultProps = @{
    ComputerName = $computer 
    BIOSVersion = $wmibios.Version 
    SerialNumber = $wmibios.serialnumber 
    Manufacturer = $wmisystem.manufacturer 
    Model = $wmisystem.model 
    IsVirtual = $false 
    VirtualType = $null 
  }

  if ($wmibios.SerialNumber -like "*VMware*") {
    $ResultProps.IsVirtual = $true
    $ResultProps.VirtualType = "Virtual - VMWare"
  }
  else {
    switch -wildcard ($wmibios.Version) {
      'VIRTUAL' { 
        $ResultProps.IsVirtual = $true 
        $ResultProps.VirtualType = "Virtual - Hyper-V" 
      } 
      'A M I' {
        $ResultProps.IsVirtual = $true 
        $ResultProps.VirtualType = "Virtual - Virtual PC" 
      } 
      '*Xen*' { 
        $ResultProps.IsVirtual = $true 
        $ResultProps.VirtualType = "Virtual - Xen" 
      }
    }
  }

  if (-not $ResultProps.IsVirtual) {
    if ($wmisystem.manufacturer -like "*Microsoft*") { 
      $ResultProps.IsVirtual = $true 
      $ResultProps.VirtualType = "Virtual - Hyper-V" 
    } 
    elseif ($wmisystem.manufacturer -like "*VMWare*") { 
      $ResultProps.IsVirtual = $true 
      $ResultProps.VirtualType = "Virtual - VMWare" 
    } 
    elseif ($wmisystem.model -like "*Virtual*") { 
      $ResultProps.IsVirtual = $true
      $ResultProps.VirtualType = "Unknown Virtual Machine"
    }
  }
  $results += New-Object PsObject -Property $ResultProps
  return $ResultProps.IsVirtual
}
