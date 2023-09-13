#!/usr/bin/env python3

import os
import subprocess

# Function to get the path to the docker-compose.yaml file
def get_compose_file_path():
    path = input("Enter the path to the docker-compose.yaml file (press Enter for current directory): ").strip()
    return path if path else "docker-compose.yaml"

# Initialize the path to the docker-compose.yaml file
compose_file_path = get_compose_file_path()

# Define a list to keep track of running services
running_services = []

# Function to check if a service is already running
def is_service_running(service_name):
    return service_name in running_services

# Function to start a service
def start_service(service_name):
    if not is_service_running(service_name):
        print(f"Starting {service_name}...")
        subprocess.run(["docker", "compose", "-f", compose_file_path, "up", "-d", service_name])
        running_services.append(service_name)
    else:
        print(f"{service_name} is already running.")

# Function to stop a service
def stop_service(service_name):
    if is_service_running(service_name):
        print(f"Stopping {service_name}...")
        subprocess.run(["docker", "compose", "-f", compose_file_path, "down", "-v", "--remove-orphans", service_name])
        running_services.remove(service_name)
    else:
        print(f"{service_name} is not running.")

# Main program
if __name__ == "__main__":
    while True:
        print("Options:")
        print("1. Start Controller, Teleop, RSP, Lidar")
        print("2. Start AMCL and Navigation")
        print("3. Start Mapping and Navigation")
        print("4. Stop AMCL and Mapping")
        print("5. Change docker-compose.yaml file path")
        print("6. Quit")

        choice = input("Enter your choice: ")

        if choice == "1":
            start_service("controller")
            start_service("teleop")
            start_service("rsp")
            start_service("lidar")
        elif choice == "2":
            start_service("amcl")
            start_service("navigation")
        elif choice == "3":
            start_service("mapping")
            start_service("navigation")
        elif choice == "4":
            stop_service("amcl")
            stop_service("mapping")
        elif choice == "5":
            compose_file_path = get_compose_file_path()
        elif choice == "6":
            break
        else:
            print("Invalid choice. Please try again.")
