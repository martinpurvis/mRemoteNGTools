Add-Type -AssemblyName System.Windows.Forms

function Import-CsvFile {
    [System.Windows.Forms.OpenFileDialog]$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $openFileDialog.Multiselect = $false

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return Import-Csv -Path $openFileDialog.FileName
    } else {
        Write-Host "No file selected."
        return $null
    }
}

function Generate-RandomGuid {
    # Generate a random GUID matching the specific format
    $randomGuid = [guid]::NewGuid().ToString()

    # Return the randomized GUID
    return $randomGuid
}

function Process-CsvContents {
    param (
        [Parameter(Mandatory = $true)]
        [array]$csvData
    )

    # Rule 1: Process each row
    foreach ($row in $csvData) {
        # Rule 1: Assign a random GUID to rows missing an Id
        if (-not $row.Id) {
            $row.Id = Generate-RandomGuid
        }

        # Rule 2: Assign a default root node GUID to rows missing a Parent
        if (-not $row.Parent) {
            $row.Parent = "10f3a9f5-175c-4947-9b8f-c1eb53390e09" # root node
        }

        # Rule 3: Identify rows with NodeType 'Container'
        if ($row.NodeType -eq 'Container') {
            # Add a PossibleParents property if not already existing
            if (-not $row.PossibleParents) {
                $row | Add-Member -MemberType NoteProperty -Name PossibleParents -Value @() 
            }

            # Rule 4: Containers can have Connections or Containers as children (but not themselves)
            foreach ($childRow in $csvData) {
                if ($childRow.NodeType -in @('Container', 'Connection') -and $childRow.Name -ne $row.Name) {
                    $row.PossibleParents += $childRow.Name
                }
            }
        }
    }

    # Rule 5: Convert the Parent Name to corresponding GUID
    foreach ($row in $csvData) {
        if ($row.Parent) {
            $container = $csvData | Where-Object { $_.Name -eq $row.Parent }
            if ($container) {
                $row.Parent = $container.Id
            }
        }
    }

    # Return the modified rows
    return $csvData
}

function Export-CsvFile {
    param (
        [Parameter(Mandatory = $true)]
        [array]$csvData
    )

    [System.Windows.Forms.SaveFileDialog]$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $saveFileDialog.DefaultExt = "csv"

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Prepare the CSV data by removing the quotes and using semicolons as the delimiter
        $csvData | ConvertTo-Csv -NoTypeInformation | ForEach-Object {
            $_ -replace '"', '' -replace ',', ';'
        } | Set-Content -Path $saveFileDialog.FileName

        Write-Host "Data exported to: $($saveFileDialog.FileName)"
    } else {
        Write-Host "Export cancelled."
    }
}


# Main execution
$csvData = Import-CsvFile

if ($csvData) {
    # Process the CSV contents
    $processedData = Process-CsvContents -csvData $csvData

    # Export the processed data to a new CSV file
    Export-CsvFile -csvData $processedData
}
