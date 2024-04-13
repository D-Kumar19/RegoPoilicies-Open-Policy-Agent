package ResourceBlockRegulator

import data.utils
import future.keywords.in
import future.keywords.if

container := utils.get_containers(input.kind)

deny[msg]{
    some con in container

    not con.resources
    msg := sprintf("%v:%v  %v resources block is not defined. Should be defined!", [input.kind, input.metadata.name, con.name])
}


deny[msg]{
    some con in container

    not con.resources.requests
    msg := sprintf("%v:%v  %v resources.requests block is not defined. Should be defined!", [input.kind, input.metadata.name, con.name])
}


deny[msg]{
    some con in container

    not con.resources.limits
    msg := sprintf("%v:%v  %v resources.limits block is not defined. Should be defined!", [input.kind, input.metadata.name, con.name])
}
