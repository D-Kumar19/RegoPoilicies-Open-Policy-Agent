package seccomp_istio_enabled

import data.utils
import future.keywords.in

container := utils.get_containers(input.kind)

deny[msg] {
    is_istio_enabled
    allowed_profiles := get_allowed_pod_profiles

    some con in container
    all_profiles := utils.get_pod_profiles(con)
    not utils.allowed_profile(all_profiles.profile, allowed_profiles)
    msg := sprintf("Seccomp profile '%v' is not allowed for podspec '%v'. Found at: '%v'. Allowed profiles: '%v'", [all_profiles.profile, con.name, all_profiles.location, allowed_profiles])
}


deny[msg] {
    is_istio_enabled
    allowed_profiles := get_allowed_container_profiles

    some con in container
    all_profiles := utils.get_container_profiles(con)
    not utils.allowed_profile(all_profiles.profile, allowed_profiles)
    msg := sprintf("Seccomp profile '%v' is not allowed for workload '%v'. Found at: '%v'. Allowed profiles: '%v'", [all_profiles.profile, con.name, all_profiles.location, allowed_profiles])
}


# Gets the pod profiles when istio is enabled
get_allowed_pod_profiles[allowed] {
    allowed := data.parameters.allowedProfiles.istioEnabled.podspec[_]
}


# Gets the container profiles when istio is enabled
get_allowed_container_profiles[allowed] {
    allowed := data.parameters.allowedProfiles.istioEnabled.containers[_]
}


# checks if istio is enabled or not
is_istio_enabled {
    input.metadata.annotations["sidecar.istio.io/inject"] == "true"
}
else {
    input.spec.template.metadata.annotations["sidecar.istio.io/inject"] == "true"
}
else {
    input.spec.jobTemplate.spec.template.metadata.annotations["sidecar.istio.io/inject"] == "true"
}
