---
title: Tailscale VPN
layout: default
---

## Downtime Batch Scripting

A limit of self hosting solutions is downtime : with cloud service providers your applications/servers can stay up at all times with minimal costs/resources, as cloud services have extremely optimized scaling. In order for self hosted solutions to be available the server or virtualizing machine must remain on. To minimize costs, scripts can routinely and safely turn off servers and virtual machines at night (when downtime is acceptable) and turn back on in the morning. 

On windows, these scripts are written in batch (the windows terminal language) and routinely exect via Task Schedular. The following steps detail the scripts and the Schedule

1. **Write the Scripts**
For peak reliability use 4 scripts: 

    - a. PC wake up script 
  	- b. VM start script
    - c. VM stop script 
    - d. PC sleep script.
    
2. **Schedule the Scripts as Tasks**
Each script will be routinely executed via Windows Task Scheduler as Tasks. On the left folder menu, select the Task Scheduler Library folder as the destination for the Tasks. 3 tasks will be created, 1 for scripts a and b each,  and 1 task that executes both of scritps c and d. Select Action > Create Task.

	- General Tab  : Name the task, add a description (optional), Select "Run wether user is logged on or not" and "Run with highest privileges". Keep your normal user account as the user to run the task.
	- Triggers Tab : Select New, select Daily and set the time to execute (a. 6:55 am b. 7:00 am c/d. 11.00pm).
	- Actions Tab : Select New, Select Browse and select the appropriate script file. (for task 3, add both scripts c and d. Be sure the VM stop script (c) runs before the PC sleep script (d))
	- Conditions Tab : Select Wake the computer to run this task (only task a really needs this, but all 3 can have it enabled just in case). Optionally, deselect "Start the task only if the computer is on AC power" and "Stop if the computer switches to battery power"
	- Settings Tab : Set "Stop the task if it runs longer than" to "5 minutes". Also select "If the running task does not end when requested, force it to stop. Be sure "If the task is already running, then the following rule applies" is set to "Do not start a new instance" (this prevents potential memory leaks, important).
  
3. **Test each Task**
Right click a task a click "Run" to test each task. Check the log file to make sure tests are working properly.

4. **Ensure BIOS RTC alarm is enabled**
Depending on the BIOS, the RTC alarm needs to be enabled to allow a computer to schedule wake from sleep. Some BIOS will require a specific alarm time which can be set to be just before the PC wake script to ensure the PC wakes and can start the scripts