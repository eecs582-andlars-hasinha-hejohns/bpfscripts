# Requirements
We require the use of linux kernel v6.2.x or greater and bpftrace v0.19.0 to be able to run all of our scripts in this repo.

You should be able to install bpftrace as follows:  
`sudo apt install -y bpftrace`

# Usage
bpftrace requires root privilege to run so all the scripts in this repo require you to call them as follows:  
`sudo ./script_name.bt`  

When a script starts succesfully the following message should be seen:  
`Attaching X probes...`

Depending on which script you are running you may see occasional print outs when the scripts is running. To end the script and print the results you have to ctrl-c out of the program. At this point the script will print out all variables that it has been updating while running. Specifically when running scripts to monitor libc, you will have to sort through everything printed to the terminal to find all relevant information for the process you wanted to monitor. Some scripts enforce a command line argument to filter which PID to monitor.

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

## probe_SYSCALL and probe_uring_SYSCALL
These class of scripts provide sector measurement timing. Sectors are defined as follows:
* “To Kernel” - This is the amount of time in nanoseconds it takes from when a user enters the glibc/libmonkey syscall implementation to when it starts getting serviced in the kernel.
* “Service” - This is the amount of time in nanoseconds it takes from starting to service the request in the kernel to when the request is done servicing.
* “To User” - This is the amount of time in nanoseconds it takes from when the request is done being serviced in the kernel to when the user exits the glibc/libmonkey syscall implementation.

Each script should attach to 4 probe points, and will print out the following information when a user ctrl-c the program:
* total_to_kernel[process_name] corresponds to the total time spent in the "To Kernel" sector
* total_service[process_name] corresponds to the total time spent in the "Service" sector
* total_to_user[process_name] corresponds to the total time spent in the "To User" sector
* counter_to_kernel[process_name] represents the number of times the "To Kernel" sector was executed
* counter_service[process_name] represents the number of times the "Service" sector was executed
* counter_to_user[process_name] represents the number of times the "To User" sector was executed

***Note:*** All times are reported in nanoseconds.  

Average information for each sector is calculated manually as a post-processing step. The following subsections provide more details on ouput and usage.

### probe_SYSCALL
These class of scripts provide sector information for glibc, and are NOT meant to be used with libmonkey.so. They print out sector information for all processes running on your machine. You will have to post-process the output to get rid of any info/variables you do not wish to look at. Below is an example of how to use the script:  
`sudo ./probe_SYSCALL`

### probe_uring_SYSCALL
These class of scripts provide sector information for libmonkey.so, and are NOT meant to be used with glibc. They will only print out sector information for the process launched with libmonkey. However, instead of using the process name of the original process, these scripts will use the process name of the kernel thread to report the following variables: total_service, total_to_kernel, counter_service, counter_to_kernel. This script does not require the post-processing step to get rid of processes that are not of interest. This script requires that a user specify the relative path to libmonkey.so. Below is an example of how to use the script:  
`sudo ./probe_uring_SYSCALL ../relative/path/to/libmonkey.so`  

## round_trip.micro (deprecated)
This script measures how long it takes to make any of the following syscall: read, write, open, close. When the user ctrl-c out of the script it will print a histogram of times it took. It is meant to be run to measure a program making multiple (previously listed) syscalls. You have to call it with the PID of the process you want to monitor. Not to be used to measure libmonkey.so. Example usage:  
`sudo ./round_trip.micro.bt PROCESS_PID`  

## roundtrip.libc
This script is the improved version of 'round_trip.micro.bt', and has the same rules/expectations/usage when using. This script simplifies the implementation and monitoring of the syscalls when compared to 'round_trip.micro.bt'

## roundtrip.monkey
This script measures how long it takes to make any of the following syscall when using libmonkey: read, write, open, close. When the user ctrl-c out of the script it will print a histogram of times it took. It is meant to be run to measure a program making multiple (previously listed) syscalls. You have to call it with the PID of the process you want to monitor, as well as the relative path to libmonkey.so. Example usage:  
`sudo ./roundtrip.monkey.bt PROCESS_PID ../relative/path/to/libmonkey.so`  

## vfs_time
This script will create histograms for how long it takes vfs to service any request (vfs_open, vfs_close, etc.). User will have to ctrl-c the script to print the histograms.
