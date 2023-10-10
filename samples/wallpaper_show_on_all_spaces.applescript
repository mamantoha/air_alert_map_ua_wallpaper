tell application id "com.apple.systempreferences"
	-- activate
	reveal pane id "com.apple.Wallpaper-Settings.extension"
	-- set aList to properties of current pane
	-- {class:pane, name:"Wallpaper", id:"com.apple.Wallpaper-Settings.extension"}
end tell

delay 1 -- Add a short delay to ensure the pane is fully loaded

tell application "System Events"
	tell process "System Settings"
		set theWindow to window "Wallpaper"
		
		set directChildren to UI elements of theWindow
		set groupElements to UI elements of group 1 of theWindow
		set splitterGroupElements to UI elements of splitter group 1 of group 1 of theWindow
		set group1Elements to UI elements of group 2 of splitter group 1 of group 1 of theWindow
		set group2Elements to UI elements of group 1 of group 2 of splitter group 1 of group 1 of theWindow
		set scrollAreaElements to UI elements of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of theWindow
		set groupElements to UI elements of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of theWindow
		
		set checkboxState to value of checkbox "Show on all Spaces" of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "Wallpaper"
		
		if checkboxState is 0 then
			click checkbox "Show on all Spaces" of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "Wallpaper"
		end if
	end tell
end tell

tell application "System Settings" to quit

