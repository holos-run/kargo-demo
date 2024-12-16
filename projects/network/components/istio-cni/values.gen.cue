package holos

// imported from the 1.23.1 cni chart
// cue import components/istio/cni/vendor/cni/values.yaml

Istio: Values: {
	// "defaults" is a workaround for Helm limitations. Users should NOT set ".defaults" explicitly, but rather directly set the fields internally.
	// For instance, instead of `--set defaults.foo=bar`, just set `--set foo=bar`.
	defaults: {
		cni: {
			hub:        ""
			tag:        ""
			variant:    ""
			image:      "install-cni"
			pullPolicy: ""

			// Same as `global.logging.level`, but will override it if set
			logging: {
				level: ""
			}

			// Configuration file to insert istio-cni plugin configuration
			// by default this will be the first file found in the cni-conf-dir
			// Example
			// cniConfFileName: 10-calico.conflist
			// CNI bin and conf dir override settings
			// defaults:
			cniBinDir:       "" // Auto-detected based on version; defaults to /opt/cni/bin.
			cniConfDir:      "/etc/cni/net.d"
			cniConfFileName: ""
			// This directory must exist on the node, if it does not, consult your container runtime
			// documentation for the appropriate path.
			cniNetnsDir: null // Defaults to '/var/run/netns', in minikube/docker/others can be '/var/run/docker/netns'.
			excludeNamespaces: ["kube-system"]

			// Allows user to set custom affinity for the DaemonSet
			affinity: {}

			// Custom annotations on pod level, if you need them
			podAnnotations: {}

			// Deploy the config files as plugin chain (value "true") or as standalone files in the conf dir (value "false")?
			// Some k8s flavors (e.g. OpenShift) do not support the chain approach, set to false if this is the case
			chained: true

			// Custom configuration happens based on the CNI provider.
			// Possible values: "default", "multus"
			provider: "default"

			// Configure ambient settings
			ambient: {
				// If enabled, ambient redirection will be enabled
				enabled: false
				// Set ambient config dir path: defaults to /etc/ambient-config
				configDir: ""
				// If enabled, and ambient is enabled, DNS redirection will be enabled
				dnsCapture: false
				// If enabled, and ambient is enabled, enables ipv6 support
				ipv6: true
			}
			repair: {
				enabled: true
				hub:     ""
				tag:     ""

				// Repair controller has 3 modes. Pick which one meets your use cases. Note only one may be used.
				// This defines the action the controller will take when a pod is detected as broken.
				// labelPods will label all pods with <brokenPodLabelKey>=<brokenPodLabelValue>.
				// This is only capable of identifying broken pods; the user is responsible for fixing them (generally, by deleting them).
				// Note this gives the DaemonSet a relatively high privilege, as modifying pod metadata/status can have wider impacts.
				labelPods: false
				// deletePods will delete any broken pod. These will then be rescheduled, hopefully onto a node that is fully ready.
				// Note this gives the DaemonSet a relatively high privilege, as it can delete any Pod.
				deletePods: false
				// repairPods will dynamically repair any broken pod by setting up the pod networking configuration even after it has started.
				// Note the pod will be crashlooping, so this may take a few minutes to become fully functional based on when the retry occurs.
				// This requires no RBAC privilege, but does require `securityContext.privileged/CAP_SYS_ADMIN`.
				repairPods:          true
				initContainerName:   "istio-validation"
				brokenPodLabelKey:   "cni.istio.io/uninitialized"
				brokenPodLabelValue: "true"
			}

			// Set to `type: RuntimeDefault` to use the default profile if available.
			seccompProfile: {}
			resources: requests: {
				cpu:    "100m"
				memory: "100Mi"
			}
			resourceQuotas: {
				enabled: false
				pods:    5000
			}

			// The number of pods that can be unavailable during rolling update (see
			// `updateStrategy.rollingUpdate.maxUnavailable` here:
			// https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/#DaemonSetSpec).
			// May be specified as a number of pods or as a percent of the total number
			// of pods at the start of the update.
			rollingMaxUnavailable: 1
		}

		// Revision is set as 'version' label and part of the resource names when installing multiple control planes.
		revision: ""

		// For Helm compatibility.
		ownerName: ""
		global: {
			// Default hub for Istio images.
			// Releases are published to docker hub under 'istio' project.
			// Dev builds from prow are on gcr.io
			hub: "docker.io/istio"

			// Default tag for Istio images.
			tag: "1.23.1"

			// Variant of the image to use.
			// Currently supported are: [debug, distroless]
			variant: ""

			// Specify image pull policy if default behavior isn't desired.
			// Default behavior: latest images will be Always else IfNotPresent.
			imagePullPolicy: ""

			// change cni scope level to control logging out of istio-cni-node DaemonSet
			logging: {
				level: "info"
			}
			logAsJson: false

			// ImagePullSecrets for all ServiceAccount, list of secrets in the same namespace
			// to use for pulling any images in pods that reference this ServiceAccount.
			// For components that don't use ServiceAccounts (i.e. grafana, servicegraph, tracing)
			// ImagePullSecrets will be added to the corresponding Deployment(StatefulSet) objects.
			// Must be set for any cluster configured with private docker registry.
			// - private-registry-key
			imagePullSecrets: []

			// Default resources allocated
			defaultResources: {
				requests: {
					cpu:    "100m"
					memory: "100Mi"
				}
			}
		}
	}
}
