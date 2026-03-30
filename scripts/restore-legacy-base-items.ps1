$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$itemsDir = Join-Path $projectRoot 'assets\minecraft\items'
$geyserDir = Join-Path $projectRoot 'geysermc'

$mappings = @(
    @{ Base='diamond_pickaxe'; Entries=@(@{Id=1; Model='enderguns:weapon/aa_12'; Name='aa_12'; Icon='eg_aa_12'}) },
    @{ Base='iron_hoe'; Entries=@(@{Id=1; Model='enderguns:weapon/ak_47'; Name='ak_47'; Icon='eg_ak_47'}) },
    @{ Base='wooden_axe'; Entries=@(@{Id=1; Model='enderguns:weapon/cz_550'; Name='cz_550'; Icon='eg_cz_550'}) },
    @{ Base='diamond_shovel'; Entries=@(@{Id=1; Model='enderguns:weapon/desert_eagle'; Name='desert_eagle'; Icon='eg_desert_eagle'}) },
    @{ Base='golden_hoe'; Entries=@(@{Id=1; Model='enderguns:weapon/fal'; Name='fal'; Icon='eg_fal'}) },
    @{ Base='golden_shovel'; Entries=@(@{Id=1; Model='enderguns:weapon/five_seven'; Name='five_seven'; Icon='eg_five_seven'}) },
    @{ Base='stone_shovel'; Entries=@(@{Id=1; Model='enderguns:weapon/g17'; Name='g17'; Icon='eg_g17'}) },
    @{ Base='wooden_pickaxe'; Entries=@(@{Id=1; Model='enderguns:weapon/m1014'; Name='m1014'; Icon='eg_m1014'}) },
    @{ Base='diamond_hoe'; Entries=@(@{Id=1; Model='enderguns:weapon/m16'; Name='m16'; Icon='eg_m16'}) },
    @{ Base='iron_shovel'; Entries=@(@{Id=1; Model='enderguns:weapon/m1911'; Name='m1911'; Icon='eg_m1911'}) },
    @{ Base='iron_axe'; Entries=@(@{Id=1; Model='enderguns:weapon/m39'; Name='m39'; Icon='eg_m39'}) },
    @{ Base='wooden_shovel'; Entries=@(@{Id=1; Model='enderguns:weapon/m9'; Name='m9'; Icon='eg_m9'}) },
    @{ Base='diamond_axe'; Entries=@(@{Id=1; Model='enderguns:weapon/m98b'; Name='m98b'; Icon='eg_m98b'}) },
    @{ Base='wooden_hoe'; Entries=@(@{Id=1; Model='enderguns:weapon/mp7'; Name='mp7'; Icon='eg_mp7'}) },
    @{ Base='golden_axe'; Entries=@(@{Id=1; Model='enderguns:weapon/msr'; Name='msr'; Icon='eg_msr'}) },
    @{ Base='stone_hoe'; Entries=@(@{Id=1; Model='enderguns:weapon/p90'; Name='p90'; Icon='eg_p90'}) },
    @{ Base='stone_pickaxe'; Entries=@(@{Id=1; Model='enderguns:weapon/remington_870'; Name='remington_870'; Icon='eg_remington_870'}) },
    @{ Base='blaze_rod'; Entries=@(@{Id=1; Model='enderguns:weapon/rocket_launcher'; Name='rocket_launcher'; Icon='eg_rocket_launcher'}) },
    @{ Base='iron_pickaxe'; Entries=@(@{Id=1; Model='enderguns:weapon/spas_12'; Name='spas_12'; Icon='eg_spas_12'}) },
    @{ Base='golden_pickaxe'; Entries=@(@{Id=1; Model='enderguns:weapon/striker'; Name='striker'; Icon='eg_striker'}) },
    @{ Base='stone_axe'; Entries=@(@{Id=1; Model='enderguns:weapon/sv98'; Name='sv98'; Icon='eg_sv98'}) },
    @{ Base='paper'; Entries=@(@{Id=1; Model='enderguns:utilities/bandage'; Name='bandage'; Icon='eg_bandage'}, @{Id=2; Model='enderguns:utilities/advanced_medikit'; Name='advanced_medikit'; Icon='eg_advanced_medikit'}) },
    @{ Base='glowstone_dust'; Entries=@(@{Id=1; Model='enderguns:utilities/flashbang'; Name='flashbang'; Icon='eg_flashbang'}) },
    @{ Base='snowball'; Entries=@(@{Id=1; Model='minecraft:item/snowball/1'; Name='bullet'; Icon='eg_bullet'}) },
    @{ Base='slime_ball'; Entries=@(@{Id=1; Model='enderguns:utilities/grenade'; Name='grenade'; Icon='eg_grenade'}) },
    @{ Base='gold_nugget'; Entries=@(@{Id=1; Model='enderguns:ammo/pistol_ammo'; Name='pistol_ammo'; Icon='eg_pistol_ammo'}) },
    @{ Base='flint'; Entries=@(@{Id=1; Model='enderguns:ammo/rifle_ammo'; Name='rifle_ammo'; Icon='eg_rifle_ammo'}) },
    @{ Base='wheat_seeds'; Entries=@(@{Id=1; Model='enderguns:ammo/shotgun_ammo'; Name='shotgun_ammo'; Icon='eg_shotgun_ammo'}) },
    @{ Base='clay_ball'; Entries=@(@{Id=1; Model='enderguns:ammo/sniper_ammo'; Name='sniper_ammo'; Icon='eg_sniper_ammo'}) },
    @{ Base='ghast_tear'; Entries=@(@{Id=1; Model='enderguns:ammo/rocket_launcher_ammo'; Name='rocket_launcher_ammo'; Icon='eg_rocket_launcher_ammo'}) }
)

$activeBases = $mappings | ForEach-Object { $_.Base }
Get-ChildItem $itemsDir -File -Filter *.json | Where-Object { $_.BaseName -notin $activeBases } | Remove-Item -Force

foreach ($mapping in $mappings) {
    $entries = @(
        foreach ($entry in $mapping.Entries) {
            [ordered]@{
                threshold = [double]$entry.Id
                model = [ordered]@{
                    type = 'minecraft:model'
                    model = $entry.Model
                }
            }
        }
    )

    $obj = [ordered]@{
        model = [ordered]@{
            type = 'minecraft:range_dispatch'
            property = 'minecraft:custom_model_data'
            fallback = [ordered]@{
                type = 'minecraft:model'
                model = 'minecraft:item/' + $mapping.Base
            }
            entries = $entries
        }
    }

    $path = Join-Path $itemsDir ($mapping.Base + '.json')
    Set-Content -Path $path -Value ($obj | ConvertTo-Json -Depth 10)
}

$cmdRegistry = [ordered]@{}
$geyserItems = [ordered]@{}

foreach ($mapping in $mappings) {
    $cmds = [ordered]@{}
    $gEntries = @(
        foreach ($entry in $mapping.Entries) {
            $cmds[[string]$entry.Id] = $entry.Name
            [ordered]@{
                name = $entry.Icon
                allow_offhand = $true
                icon = $entry.Icon
                custom_model_data = $entry.Id
            }
        }
    )

    $cmdRegistry['minecraft:' + $mapping.Base] = $cmds
    $geyserItems['minecraft:' + $mapping.Base] = $gEntries
}

Set-Content -Path (Join-Path $geyserDir 'cmd_registry.json') -Value ($cmdRegistry | ConvertTo-Json -Depth 10)
Set-Content -Path (Join-Path $geyserDir 'geyser_mappings.json') -Value (([ordered]@{
    format_version = '1'
    items = $geyserItems
}) | ConvertTo-Json -Depth 10)

Write-Output 'Legacy base item mappings restored.'



