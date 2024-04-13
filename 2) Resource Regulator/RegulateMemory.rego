package RegulateMemory

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)

deny[msg]{
    some con in container

    not con.resources.requests.memory
    msg := sprintf("%v:%v:%v  %v resources.requests.memory is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


deny[msg]{
    some con in container

    not con.resources.limits.memory
    msg := sprintf("%v:%v:%v  %v resources.limits.memory is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.requests.memory, data.requests_memory)
    msg := sprintf("%v:%v:%v  %v resources.limits.memory is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.limits.memory, data.limits_memory)
    msg := sprintf("%v:%v:%v  %v resources.requests.memory is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


# Function which will convert the memory to a common format and compare
compare_resources(found_resources, expected_resources) {
    normalized_found_memory := utils.normalize_memory(found_resources)
    normalized_expected_memory := utils.normalize_memory(expected_resources)
    normalized_found_memory == normalized_expected_memory
}
