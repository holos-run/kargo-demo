package holos

import (
	"example.com/holos/pkg/config/kargo"
	"example.com/holos/pkg/config/externalsecrets"
)

// Mix the resource definitions in to the component definitions.  We keep the
// imported definitions open to other composed resource definitions so they are
// not mutually exclusive with one another.  The overall #Resources definition
// should be closed, so we embed imported definitions using ...
#Resources: {
	{
		kargo.#Resources
		...
	}
	{
		externalsecrets.#Resources
		...
	}
}
