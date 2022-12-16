Set WshShell = WScript.CreateObject("WScript.Shell")

# Open the default settings window
WshShell.Run "ms-settings:defaultapps"
WScript.Sleep 1500 # Wait until open (adjust if necessary)

# Adjust number of tabs until you reach the browser choice setting
WshShell.SendKeys "{TAB}" 
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"
WshShell.SendKeys "{TAB}"

# Open the browser choice menu
WshShell.SendKeys "{ENTER}" 
#WshShell.SendKeys " " 
WScript.Sleep 500 # Wait until open

WshShell.SendKeys "{TAB}" # Move down one selection
WshShell.SendKeys " " ' Set current selection as default browser

WScript.Sleep 500 # Wait until open
# Uncomment the line below to automatically close the settings window
WshShell.SendKeys "%{F4}" 
WScript.Quit
