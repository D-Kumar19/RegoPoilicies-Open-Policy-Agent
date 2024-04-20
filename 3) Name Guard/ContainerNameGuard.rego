package ContainerNameGuard

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)


deny[msg] {
    some con in container

    not con.name
    msg := sprintf("%v in %v: Container name is empty. Names must be non-empty!", [con.name, input.metadata.name])
}


deny[msg] {
    some con in container

    name := con.name
    expectedStartName := data.containerNamePrefix

    not re_match(sprintf("^%s", [expectedStartName]), name)
    msg := sprintf("%v in %v: Invalid container name '%v'. Container name must start with '%v'.", [name, input.metadata.name, name, expectedStartName])
}


# Enforces name length and character constraints
deny[msg] {
    some con in container

    name := con.name
    not re_match(`^(?!-)[a-z0-9-]{1,63}(?<!-)$`, name)
    msg := sprintf("%v in %v: Invalid container name '%v'. Names must be 1-63 characters long, and cannot start or end with a dash!", [name, input.metadata.name, name])
}


# Ensures no consecutive dashes in names
deny[msg] {
    some con in container

    name := con.name
    not re_match(`^(?!.*--)[a-z0-9-]+$`, name)
    msg := sprintf("%v in %v: Invalid container name '%v'. Names must not contain consecutive dashes!", [name, input.metadata.name, name])
}
