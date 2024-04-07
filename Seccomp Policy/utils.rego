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
