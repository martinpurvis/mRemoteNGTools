# About
You can use the `ConvertTo-mRemoteNG.ps1` script to make it a bit easier to bulk import Connections and Containers into mRemoteNG with support for nested folders.

# Templates
- `template_basic.csv` - Ideal for a single site organisation.
- `template_advanced.csv` - Ideal for multi-site organisation.

# Usage
1. Download the repo.
2. Edit `template_basic.csv` **OR** `template_advanced.csv` and amend the rows to suit your server/network environment and save it.
3. Run the `ConvertTo-mRemoteNG.ps1` script either by right-clicking and selecting `'Run with PowerShell'` or by running it in a PowerShell prompt with `.\ConvertTo-mRemoteNG.ps1`.
4. A file picker window will open, select the template you amended and click Open.
5. A file picker window will open, save the converted file out to something like `MyCompany.csv`.
6. Open mRemoteNG and go to `File > Import > Import from File...` and import the converted file.

# Notes
- Any row with a Parent value left blank is assigned to the root node rather than a folder.
- Folders can be nested, just use a unique name.
- The script assigns a unique id for each row automatically.
