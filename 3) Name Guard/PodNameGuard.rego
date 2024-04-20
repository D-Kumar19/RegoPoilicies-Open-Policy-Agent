package PodNameGuard

import data.utils
import future.keywords.in


deny[msg] {
    name:= input.metadata.name

    not name
    msg := sprintf("Pod name: %v is empty. Names must be non-empty!", [input.metadata.name])
}


deny[msg] {
    name := input.metadata.name
    expectedStartName := data.podNamePrefix

    not re_match(sprintf("^%s", [expectedStartName]), name)
    msg := sprintf("Invalid pod name '%v'. Pod name must start with '%v'.", [name, expectedStartName])
}


# Enforces name length and character constraints
deny[msg] {
    name := input.metadata.name

    not re_match(`^(?!-)[a-z0-9-]{1,63}(?<!-)$`, name)
    msg := sprintf("Invalid pod name '%v'. Names must be 1-63 characters long, and cannot start or end with a dash!", [name])
}


# Ensures no consecutive dashes in names
deny[msg] {
    name := input.metadata.name

    not re_match(`^(?!.*--)[a-z0-9-]+$`, name)
    msg := sprintf("Invalid pod name '%v'. Names must not contain consecutive dashes!", [name])
}
