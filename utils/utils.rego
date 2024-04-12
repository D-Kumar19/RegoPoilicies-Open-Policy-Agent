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
