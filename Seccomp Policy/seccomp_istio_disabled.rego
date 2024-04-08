package seccomp_istio_disabled

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)

deny[msg] {
    allowed_profiles := get_allowed_profiles

    some con in container
    all_profiles := get_all_profiles(con)
    not utils.allowed_profile(all_profiles.profile, allowed_profiles)
    msg := sprintf("Seccomp profile '%v' is not allowed for podspec/containers '%v'. Found at: '%v'. Allowed profiles: '%v'", [all_profiles.profile, con.name, all_profiles.location, allowed_profiles])
}


# Gets the allowed profiles
get_allowed_profiles[allowed] {
    allowed := data.parameters.allowedProfiles[_]
}


# Gets all the used profiles of seccomp at pod/container level
get_all_profiles(container) = profile {
    profile := utils.get_pod_profiles(container)
}
else = profile {
    profile := utils.get_container_profiles(container)
}
