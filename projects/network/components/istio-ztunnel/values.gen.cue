package holos

// imported from the 1.23.1 ztunnel chart
// cue import components/istio/ztunnel/vendor/ztunnel/values.yaml

Istio: Values: {
	// "defaults" is a workaround for Helm limitations. Users should NOT set ".defaults" explicitly, but rather directly set the fields internally.
	// For instance, instead of `--set defaults.foo=bar`, just set `--set foo=bar`.
	defaults: {
		// Hub to pull from. Image will be `Hub/Image:Tag-Variant`
		hub: "docker.io/istio"
		// Tag to pull from. Image will be `Hub/Image:Tag-Variant`
		tag: "1.23.1"
		// Variant to pull. Options are "debug" or "distroless". Unset will use the default for the given version.
		variant: ""

		// Image name to pull from. Image will be `Hub/Image:Tag-Variant`
		// If Image contains a "/", it will replace the entire `image` in the pod.
		image: "ztunnel"

		// Labels to apply to all top level resources
		labels: {}
		// Annotations to apply to all top level resources
		annotations: {}

		// Additional volumeMounts to the ztunnel container
		volumeMounts: []

		// Additional volumes to the ztunnel pod
		volumes: []

		// Annotations added to each pod. The default annotations are required for scraping prometheus (in most environments).
		podAnnotations: {
			"prometheus.io/port":   "15020"
			"prometheus.io/scrape": "true"
		}

		// Additional labels to apply on the pod level
		podLabels: {}

		// Pod resource configuration
		resources: {
			requests: {
				cpu: "200m"
				// Ztunnel memory scales with the size of the cluster and traffic load
				// While there are many factors, this is enough for ~200k pod cluster or 100k concurrently open connections.
				memory: "512Mi"
			}
		}

		// List of secret names to add to the service account as image pull secrets
		imagePullSecrets: []

		// A `key: value` mapping of environment variables to add to the pod
		env: {}

		// Override for the pod imagePullPolicy
		imagePullPolicy: ""

		// Settings for multicluster
		multiCluster: {
			// The name of the cluster we are installing in. Note this is a user-defined name, which must be consistent
			// with Istiod configuration.
			clusterName: ""
		}

		// meshConfig defines runtime configuration of components.
		// For ztunnel, only defaultConfig is used, but this is nested under `meshConfig` for consistency with other
		// components.
		// TODO: https://github.com/istio/istio/issues/43248
		meshConfig: {
			defaultConfig: proxyMetadata: {}
		}

		// This value defines:
		// 1. how many seconds kube waits for ztunnel pod to gracefully exit before forcibly terminating it (this value)
		// 2. how many seconds ztunnel waits to drain its own connections (this value - 1 sec)
		// Default K8S value is 30 seconds
		terminationGracePeriodSeconds: 30

		// Revision is set as 'version' label and part of the resource names when installing multiple control planes.
		// Used to locate the XDS and CA, if caAddress or xdsAddress are not set explicitly.
		revision: ""

		// The customized CA address to retrieve certificates for the pods in the cluster.
		// CSR clients such as the Istio Agent and ingress gateways can use this to specify the CA endpoint.
		caAddress: ""

		// The customized XDS address to retrieve configuration.
		// This should include the port - 15012 for Istiod. TLS will be used with the certificates in "istiod-ca-cert" secret.
		// By default, it is istiod.istio-system.svc:15012 if revision is not set, or istiod-<revision>.<istioNamespace>.svc:15012
		xdsAddress: ""

		// Used to locate the XDS and CA, if caAddress or xdsAddress are not set.
		istioNamespace: "istio-system"

		// Configuration log level of ztunnel binary, default is info.
		// Valid values are: trace, debug, info, warn, error
		logLevel: "info"

		// Set to `type: RuntimeDefault` to use the default profile if available.
		// TODO Ambient inpod - for OpenShift, set to the following to get writable sockets in hostmounts to work, eventually consider CSI driver instead
		//seLinuxOptions:
		//  type: spc_t
		seLinuxOptions: {}
	}
}
