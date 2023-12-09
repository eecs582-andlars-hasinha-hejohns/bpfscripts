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

# Script Overview
The following subsections explain what each file/script does.

## monitor_syscalls
This script will monitor the number of times each of the following syscalls is made by a specific process: open, read, write, fsync, close, mmap, io_uring_setup, and io_uring_enter. Addtionally, it will provide the amount of time that it takes a process to hit the main function. For this feature to work, a program must call the `getpid()` upon entry to the `main()` function. The final output will resemble to following format:  
`@sys_enter_SYSCALL[process_name]: number_of_times_called`  
`@time_to_main[process_name]: time_in_nanoseconds`  

## monitor-vfs-time
This script will monitor the following information for the following syscalls: open, read, write, fsycn, close.  
* User enters modified syscall implementation
* Kernel thread starts servicing io request
* Kernel thread finishes servicing io request
* User exits modified syscall implementation
  
As the script is running (prior to ctrl-c) it will print out all of the information above in the following format:  
`[cpu_number][pid][tid][process_name] {'u->', '<-u', 'k->', '<-k'} probe_name/function_name`  
Once a user ctrl-c out of the script it will print timing information in the form of histograms.  
  
***Note:*** this is for use with our modified syscalls
