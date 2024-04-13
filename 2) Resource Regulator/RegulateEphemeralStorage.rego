package RegulateEphemeralStorage

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)

deny[msg]{
    some con in container

    not con.resources.requests["ephemeral-storage"]
    msg := sprintf("%v:%v:%v  %v resources.requests.ephemeral-storage is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


deny[msg]{
    some con in container

    not con.resources.limits["ephemeral-storage"]
    msg := sprintf("%v:%v:%v  %v resources.limits.ephemeral-storage is not defined. Should be defined!", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.requests["ephemeral-storage"], data.requests_ephemeral_storage)
    msg := sprintf("%v:%v:%v  %v resources.ephemeral-storage is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.requests])
}


deny[msg]{
    some con in container

    not compare_resources(con.resources.requests["ephemeral-storage"], data.limits_ephemeral_storage)
    msg := sprintf("%v:%v:%v  %v resources.ephemeral-storage is not defined correctly", [input.kind, input.metadata.name, con.name, con.resources.limits])
}


deny[msg] {
    some con in container

    requests_ephemeral_storage := con.resources.requests["ephemeral-storage"]
    limits_ephemeral_storage := con.resources.limits["ephemeral-storage"]

    not compare_resources(requests_ephemeral_storage, limits_ephemeral_storage)
    msg := sprintf("%v:%v Container %v has different values for ephemeral storage requests and limits", [input.kind, input.metadata.name,con.name])
}


# Function which will convert the ephemeral storage to a common format and compare
compare_resources(found_resources, expected_resources) {
    normalized_found_ephemeral_storage := utils.normalize_memory(found_resources)
    normalized_expected_ephemeral_storage := utils.normalize_memory(expected_resources)
    normalized_found_ephemeral_storage == normalized_expected_ephemeral_storage
}
