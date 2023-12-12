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

# Sample Program
Navigate to 'sample_program' directory and build by calling 'make'. This is a simple program that you can test all scripts in this repo with. There are two ways of running the program:  
* `./sample_program` - this method will use standard glibc
* `LD_PRELOAD=../relative/path/to/libmonkey.so ./sample_program` - this method will use our modified syscalls

# Sector Benchmarking
Navigate to 'sector_benchmark' directory and build by calling 'make'. This program is what was used to generate sector, number of syscalls, and start time microbenchmark results. It repeatedly calls open, read, write, and close to simulate a basic long running file workload. There are two ways of running the program:  
* `./benchmark_sector` - this method will use standard glibc
* `LD_PRELOAD=../relative/path/to/libmonkey.so ./benchmark_sector` - this method will use our modified syscalls

# Script Overview
The following subsections explain what each file/script does.

## monitor_syscalls
This script will monitor the number of times each of the following syscalls is made by a specific process: open, read, write, fsync, close, mmap, io_uring_setup, and io_uring_enter. Addtionally, it will provide the amount of time that it takes a process to hit the main function. For this feature to work, a program must call the `getpid()` upon entry to the `main()` function. The final output will resemble to following format:  
`@sys_enter_SYSCALL[process_name]: number_of_times_called`  
`@time_to_main[process_name]: time_in_nanoseconds`  

## monkey-vfs-times
**Usage:** You have to provde a relative path libmonkey.so as an argument to the script. Running this script will look like the following:  
`sudo ./monkey-vfs-times.bt ../relative/path/to/libmonkey.so`  

This script will monitor the following information for the following syscalls: open, read, write, fsycn, close.  
* User enters modified syscall implementation
* Kernel thread starts servicing io request
* Kernel thread finishes servicing io request
* User exits modified syscall implementation
  
As the script is running (prior to ctrl-c) it will print out all of the information above in the following format:  
`[cpu_number][pid][tid][process_name] {'u->', '<-u', 'k->', '<-k'} probe_name/function_name`  
Once a user ctrl-c out of the script it will print timing information in the form of histograms.  
  
***Note:*** this is for use with our modified syscalls

## monkey-vfs-time.pre + Makefile
This generates the monkey-vfs-times.bt script. We use this hack to avoid having to copy-paste a bunch of probes and make use of a macro instead.  

***Note:*** You should not have to use these files  

## probe_open
This script measures how long it takes from the following point to the following point:
* User application calling unmodified glibc `open()` syscall
* Kernel calling the kernel-implementation of opening somthing: `do_sys_openat2()`

The output will be as follows:  
`@total[process_name] = time_in_nanoseconds`  
`@counter[process_name] = times_called`  

To get the average one has to manually divide the total and counter values.

## round_trip.micro.bt (deprecated)
This script measures how long it takes to make any of the following syscall: read, write, open, close. When the user ctrl-c out of the script it will print a histogram of times it took. It is meant to be run to measure a program making multiple (previously listed) syscalls. You have to call it with the PID of the process you want to monitor. Not to be used to measure libmonkey.so. Example usage:  
`sudo ./round_trip.micro.bt PROCESS_PID`  

## roundtrip.libc.bt
This script is the improved version of 'round_trip.micro.bt', and has the same rules/expectations/usage when using. This script simplifies the implementation and monitoring of the syscalls when compared to 'round_trip.micro.bt'

## vfs_time
This script will create histograms for how long it takes vfs to service any request (vfs_open, vfs_close, etc.). User will have to ctrl-c the script to print the histograms.
