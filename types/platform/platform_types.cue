// package platform defines the platform configuration types.  Also known as the
// platform domain model.
package platform

import (
	"strings"

	holos_core "github.com/holos-run/holos/api/core/v1alpha5:core"
	k8s_core "k8s.io/api/core/v1"
	httproute "gateway.networking.k8s.io/httproute/v1"
)

// #Name represents an identifier.
#Name: string & strings.MinRunes(2) & strings.MaxRunes(63)

// Optionally constrain names. For example, dns label plus dots.
#Name: =~"^[a-zA-Z0-9][a-zA-Z0-9-.]{0,61}[a-zA-Z0-9]$|^[a-zA-Z0-9]$"

// #Key represents an arbitrary unique field label.
#Key: string & strings.MinRunes(2) & strings.MaxRunes(63)

// #Organization represents organizational configuration data.
#Organization: {
	// displayName represents the organization name, e.g. Example Company.
	displayName: string
	// domain represents the organization domain, e.g. example.com.
	domain: string
	// repoURL represents the holos git repository url.
	repoURL: string
}

// #Stack represents a software stack, a collection of components configured to
// work together.
#Stack: {
	metadata: name: #Name
	// components for Platform.spec.components
	components: #Components
	// optional namespaces for the namespaces component
	namespaces?: #Namespaces
}

// #Stacks represents a collection of software stacks organized by name.
#Stacks: [NAME=#Name]: #Stack & {
	metadata: name: NAME
}

// #StackBuilder builds a #Stack in the stack file from parameters.  Useful to
// build and configure stacks consistently.
#StackBuilder: {
	parameters: {
		name:       #Name
		components: #Components
	}
	stack: #Stack & {
		metadata: name: parameters.name
		let STACK_NAME = metadata.name

		for KEY, COMPONENT in parameters.components {
			components: "stacks:\(STACK_NAME):components:\(KEY)": COMPONENT & {
				name: KEY
				// Labels to select specific stacks when rendering.
				labels: "holos.run/stack.name":     STACK_NAME
				labels: "holos.run/component.name": name
				// Pass the stack name as a parameter for use with componentconfig.argocd.cue
				parameters: stack: STACK_NAME
				// Configure how the holos cli displays the rendered ... in ... log lines.
				annotations: "app.holos.run/description": "\(name) for stack \(STACK_NAME)"
			}
		}
	}
}

// #Component represents a Holos component.
#Component: holos_core.#Component
#Components: [#Key]: #Component

// #Namespace represents a Kubernetes Namespace resource.
#Namespace: k8s_core.#Namespace & {
	metadata: name: string
	metadata: labels: "kubernetes.io/metadata.name": metadata.name
}
#Namespaces: [NAME=#Name]: #Namespace & {
	metadata: name: NAME
}

// #Stages represents a collection of #Stage values organized by name.
#Stages: [NAME=#Name]: #Stage & {
	metadata: name: NAME
}

// #Stage represents a deployment stage, often called an environment.  Examples
// are dev, test, uat, prod-east, prod-west.
#Stage: {
	// name represents the stage name, e.g. "dev" or "prod-us-east"
	metadata: name: #Name

	// prior represents the prior stage in the promotion process or the special
	// value "direct" if there is no prior stage.
	prior: #Name | *"direct"

	// tier represents the tier of the stage, usually prod or nonprod.
	tier: "prod" | "nonprod"

	// parameters represents parameters to compose with associated components.
	component: parameters: [string]: string
}

// #GatewayNamespace represents the kubernetes namespace where ingress gateway
// api resources are located.  For example, HTTPRoute resources.  This is
// usually the namespace containing the default Gateway resource per the v1
// Gateway API.
#GatewayNamespace: "istio-ingress"
// TODO(jeff): uncomment once https://github.com/cue-lang/cue/issues/3905 is resolved.
// #GatewayNamespace: string | *"istio-ingress"

// #HTTPRoutes represents a collection of HTTPRoute resources.
#HTTPRoutes: [NAME=#Name]: #HTTPRoute & {
	metadata: name: NAME
}
#HTTPRoute: httproute.#HTTPRoute & {
	metadata: namespace: #GatewayNamespace
}
