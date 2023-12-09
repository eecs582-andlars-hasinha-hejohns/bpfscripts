# Requirements
We require the use of linux kernel v6.2.x or greater and bpftrace v0.19.0 to be able to run all of our scripts in this repo.

You should be able to install bpftrace as follows:  
`sudo apt install -y bpftrace`

# Usage
bpftrace requires root privilege to run so all the scripts in this repo require you to call them as follows:  
`sudo ./script_name.bt`  

When a script starts succesfully the following message should be seen:  
`Attaching X probes...`

Depending on which script you are running you may see occasional print outs when the scripts is running. To end the script and print the results you have to ctrl-c out of the program. At this point the script will print out all variables that it has been updating while running. 
