package main

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)

deny[msg]{
    some con in container

    not con.resources.requests.cpu
    msg := sprintf("%v:%v:%v  %v resources.requests.cpu is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


deny[msg]{
    some con in container

    not con.resources.limits.cpu
    msg := sprintf("%v:%v:%v  %v resources.limits.cpu is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.requests.cpu, data.requests_cpu)
    msg := sprintf("%v:%v:%v  %v resources.requests.cpu is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.limits.cpu, data.limits_cpu)
    msg := sprintf("%v:%v:%v  %v resources.limits.cpu is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg]{
    some con in container

    con.resources.limits.cpu
    msg := sprintf("%v:%v %v Limits for cpu shouldn't be set by default", [input.kind, input.metadata.name, con.name])
}

# Function which will convert the cpu to a common format and compare
compare_resources(found_resources, expected_resources) {
    normalized_found_cpu := utils.normalize_cpu(found_resources)
    normalized_expected_cpu := utils.normalize_cpu(expected_resources)
    normalized_found_cpu == normalized_expected_cpu
}
