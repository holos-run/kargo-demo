package holos

import (
	ci "cert-manager.io/clusterissuer/v1"
	"example.com/holos/pkg/config/certmanager"
)

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

Component: #Kubernetes & {
	Name: "local-ca"

	Resources: ClusterIssuer: LocalCA: ci.#ClusterIssuer & {
		metadata: name:      "local-ca"
		metadata: namespace: certmanager.Config.namespace

		// The secret name must align with the local cluster guide at
		// https://holos.run/docs/guides/local-cluster/
		spec: ca: secretName: "local-ca"
	}
}