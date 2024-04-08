# Rego Policy Enforcer for Kubernetes Seccomp Profiles 🛡️

Welcome to the Rego Policy Enforcer for Kubernetes Seccomp Profiles, a cutting-edge Open Policy Agent (OPA) project designed to enhance the security of your Kubernetes clusters. Crafted with passion and precision, this project aims to automate the enforcement of Seccomp profiles for Kubernetes workloads, ensuring that only approved profiles are used, thereby fortifying your cluster's defense mechanisms against potential threats. 🌟

## Features ✨

- **Automated Seccomp Profile Validation**: Leverages Rego policies to automatically validate Seccomp profiles against a predefined set of allowed profiles.
- **Istio Support**: Comes with specialized support for workloads running with Istio, allowing for nuanced policy enforcement that considers the presence of an Istio sidecar.
- **Flexible Configuration**: Define allowed Seccomp profiles with ease, supporting both pod-level and container-level specifications.
- **Extensive Kubernetes Workload Support**: Compatible with a wide range of Kubernetes workload kinds, including Deployments, DaemonSets, StatefulSets, and more.
- **Comprehensive Testing**: Includes a YAML test file for verifying policy behavior against different scenarios, ensuring robustness and reliability.

## Installation 🚀

To use this project, clone it into your local environment or directly into your cluster's management node:

```bash
git clone https://github.com/D-Kumar19/RegoPoilicies-Open-Policy-Agent.git
cd RegoPoilicies-Open-Policy-Agent/Seccomp\ Policy
```

## Usage 🛠️

### Defining Allowed Seccomp Profiles

Edit the `Seccomp.yaml` file to specify the allowed Seccomp profiles for your Kubernetes workloads:

```yaml
tests:
  - name: "Seccomp profile should be set to RuntimeDefault"
    type: "conftest"
    data:
      policyPaths:
        - "./seccomp_istio_disabled.rego"
        - "./utils.rego"
      data:
        parameters:
          allowedProfiles:
            - "RuntimeDefault"
```

### Running Policy Tests

Use the OPA command-line tool to execute the policy tests defined in `Seccomp.yaml`:

```bash
conftest test -p seccomp_istio_disabled.rego -p utils.rego <template_output>
conftest test -p seccomp_istio_enabled.rego -p utils.rego <template_output>
```

## Contributing 🤝

Your contributions are what make the community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

---