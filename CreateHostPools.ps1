Function CreateWVDHostPools {
    Param (
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $False)]
        [String]$ResourceGroupName,
        [Parameter(Mandatory = $True, Position = 2, ValueFromPipeline = $False)]
        [string[]]$HostPools
    )
 
    $Location = "WestEurope"
 
    $ExistingResourceGroups = Get-AzResourceGroup
 
    if ($ExistingResourceGroups.name -notcontains $ResourceGroupName) {
 
        Write-Host "ResourceGroup $($ResourceGroupName) does not exist. Creating new ResourceGroup"
 
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        
    }
 
    foreach ($HostPoolName in $HostPools){
 
    New-AzWvdWorkspace -ResourceGroupName $ResourceGroupName `
                        -Name "$($HostPoolName)-Workspace" `
                        -Location $Location `
                        -FriendlyName "$($HostPoolName)-Workspace" `
                        -ApplicationGroupReference $null `
                        -Description "$($HostPoolName)-Workspace"
 
    New-AzWvdHostPool   -Name $HostPoolName `
                        -ResourceGroupName $ResourceGroupName `
                        -Location $Location `
                        -HostPoolType Pooled `
                        -PreferredAppGroupType 'Desktop' `
                        -LoadBalancerType DepthFirst `
                        -MaxSessionLimit '12' `
    
    $HostPool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName
 
    New-AzWvdApplicationGroup   -Name "$($HostPoolName)-DAG" `
                                -ResourceGroupName $ResourceGroupName `
                                -ApplicationGroupType 'Desktop' `
                                -HostPoolArmPath $HostPool.id `
                                -Location $Location
 
    $DAG = Get-AzWvdApplicationGroup -Name "$($HostPoolName)-DAG" -ResourceGroupName $ResourceGroupName
 
    Register-AzWvdApplicationGroup  -ResourceGroupName $ResourceGroupName `
                                    -WorkspaceName "$($HostPoolName)-Workspace" `
                                    -ApplicationGroupPath $DAG.id
    
    }
}
