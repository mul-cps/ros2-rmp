#!/usr/bin/env python3

import subprocess

# Define the stacks
stack1 = ["controller", "teleop", "rsp", "lidar"]
stack2 = stack1 + ["mapping", "navigation"]
stack3 = stack1 + ["amcl", "navigation"]

# Function to start a stack
def start_stack(stack):
    print(f"Starting {', '.join(stack)}...")
    subprocess.run(["docker", "compose", "up", "-d"] + stack)

# Function to stop a stack
def stop_stack(stack):
    print(f"Stopping {', '.join(stack)}...")
    subprocess.run(["docker", "compose", "down", "-v", "--remove-orphans"] + stack)

# Main program
if __name__ == "__main__":
    while True:
        print("Options:")
        print("1. Start Stack 1")
        print("2. Start Stack 2")
        print("3. Start Stack 3")
        print("4. Stop Stack 1")
        print("5. Stop Stack 2")
        print("6. Stop Stack 3")
        print("7. Quit")

        choice = input("Enter your choice: ")

        if choice == "1":
            stop_stack(stack2 + stack3)  # Stop stack2 and stack3 to avoid interference
            start_stack(stack1)
        elif choice == "2":
            stop_stack(stack1 + stack3)  # Stop stack1 and stack3 to avoid interference
            start_stack(stack2)
        elif choice == "3":
            stop_stack(stack1 + stack2)  # Stop stack1 and stack2 to avoid interference
            start_stack(stack3)
        elif choice == "4":
            stop_stack(stack1)
        elif choice == "5":
            stop_stack(stack2)
        elif choice == "6":
            stop_stack(stack3)
        elif choice == "7":
            break
        else:
            print("Invalid choice. Please try again.")
