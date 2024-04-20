package utils

import future.keywords.in

#####################################################################
# Function for checking if an object is a workload of podspec kind:
#####################################################################
is_workload{
    input.kind in ["DaemonSet", "Deployment", "Job", "Pod", "StatefulSet", "CronJob", "ReplicaSet", "ReplicationController"]
}


#####################################################################
# Functions for getting all the containers:
#####################################################################
get_containers(workload) = containers{
    workload == "Pod"
    containers := getPodContainers
}
get_containers(workload) = containers{
    workload_set := {"DaemonSet", "Deployment", "Job", "StatefulSet", "ReplicaSet", "ReplicationController"}
    workload_set[workload]
    containers := getDeploymentContainers
}
get_containers(workload) = containers{
    workload == "CronJob"
    containers = getCronJobContainers
}

# Pod
getPodContainers[c] {
    c := input.spec.containers[_]
}
getPodContainers[c] {
    c := input.spec.initContainers[_]
}
getPodContainers[c] {
    c := input.spec.ephemeralContainers[_]
}

# ReplicaSet, Deployment, StatefulSet, Job, DaemonSet, ReplicationController
getDeploymentContainers[c] {
    c := input.spec.template.spec.containers[_]
}
getDeploymentContainers[c] {
    c := input.spec.template.spec.initContainers[_]
}
getDeploymentContainers[c] {
    c := input.spec.template.spec.ephemeralContainers[_]
}

# CronJob
getCronJobContainers[c] {
    c := input.spec.jobTemplate.spec.template.spec.containers[_]
}
getCronJobContainers[c] {
    c := input.spec.jobTemplate.spec.template.spec.initContainers[_]
}
getCronJobContainers[c] {
    c := input.spec.jobTemplate.spec.template.spec.ephemeralContainers[_]
}


#####################################################################
# Functions for getting all the profiles having securityContext:
#####################################################################
securitycontext_pod {
    input.spec.securityContext.seccompProfile
}
else {
    input.spec.template.spec.securityContext.seccompProfile
}
else {
    input.spec.jobTemplate.spec.template.spec.securityContext.seccompProfile
}


securitycontext_container(container) {
    container.securityContext.seccompProfile
}


get_pod_profiles(container) = {"profile": profile, "location": location} {
    not securitycontext_container(container)
    profile := input.spec.securityContext.seccompProfile.type
    location := "Pod securityContext"
}


get_container_profiles(container) = {"profile": profile, "location": location} {
    not securitycontext_container(container)
    profile := input.spec.template.spec.securityContext.seccompProfile.type
    location := "Workload Controller securityContext"
}
else = {"profile": profile, "location": location} {
    not securitycontext_container(container)
    profile := input.spec.jobTemplate.spec.template.securityContext.seccompProfile.type
    location := "CrobJob securityContext"
}
else = {"profile": profile, "location": location} {
    securitycontext_container(container)
    profile := container.securityContext.seccompProfile.type
    location := "Container securityContext"
}
else = {"profile": "not configured", "location": "No explicit profile found"} {
    not securitycontext_pod
    not securitycontext_container(container)
}


#####################################################################
# Functions for compare used profile and allowed profile:
#####################################################################
allowed_profile(profile, allowed) {
    profile == allowed[_]
}


#####################################################################
# Functions for converting cpu, memory, ephemeral storage to bytes:
#####################################################################
memory_multipliers := {
    "E": 1000000000000000000000,  # 10 ** 21
    "P": 1000000000000000000,     # 10 ** 18
    "T": 1000000000000000,        # 10 ** 15
    "G": 1000000000000,           # 10 ** 12
    "M": 1000000000,              # 10 ** 9
    "k": 1000000,                 # 10 ** 6
    "":  1000,                    # 10 ** 3
    "m": 1,                       # 10 ** 0
    "Ki": 1024000,                # 1000 * 2 ** 10
    "Mi": 1048576000,             # 1000 * 2 ** 20
    "Gi": 1073741824000,          # 1000 * 2 ** 30
    "Ti": 1099511627776000,       # 1000 * 2 ** 40
    "Pi": 1125899906842624000,    # 1000 * 2 ** 50
    "Ei": 1152921504606846976000  # 1000 * 2 ** 60
}


get_memory_multiple(suffix) = multiplier {
    multiplier := memory_multipliers[suffix]
}


# If memory is a string with at least one character and the last character is a multiple, return the last character.
# Else if memory is a string with more than one character and the last two characters are multiples, return the last two characters.
# Else, if memory is a string (including the case where it's an empty string), return an empty suffix.
get_suffix(memory) = suffix {
    is_string(memory)
    count(memory) > 0
    last_char := substring(memory, count(memory) - 1, 1)
    get_memory_multiple(last_char)
    suffix := last_char
}
else = suffix {
    is_string(memory)
    count(memory) > 1
    last_two_chars := substring(memory, count(memory) - 2, 2)
    get_memory_multiple(last_two_chars)
    suffix := last_two_chars
}
else = "" {
    is_string(memory)
}


# If cpu is a number, multiply it by 1000.
# Else, if cpu ends with "m", remove the "m" and convert to a number.
# Else, if cpu matches the regular expression for a decimal or integer, convert it to a number and multiply by 1000.
normalize_cpu(cpu) = normalized_cpu {
    is_number(cpu)
    normalized_cpu := cpu * 1000
}
else = normalized_cpu {
    endswith(cpu, "m")
    normalized_cpu := to_number(replace(cpu, "m", ""))
}
else = normalized_cpu {
    re_match("^[0-9]+(\\.[0-9]+)?$", cpu)
    normalized_cpu := to_number(cpu) * 1000
}


# If memory is a number, multiply it by 1000.
# Else, if memory is a string:
    # Extract the suffix using get_suffix.
    # Remove the suffix from memory to get the raw value.
    # Check if it correctly follows the format.
    # Convert raw to a number and multiply it by the result of get_memory_multiple(suffix).
normalize_memory(memory) = normalized_memory {
    is_number(memory)
    normalized_memory := memory * 1000
}
else = normalized_memory {
    is_string(memory)
    suffix := get_suffix(memory)
    raw := replace(memory, suffix, "")
    re_match("^[0-9]+(\\.[0-9]+)?$", raw)
    normalized_memory := to_number(raw) * get_memory_multiple(suffix)
}
