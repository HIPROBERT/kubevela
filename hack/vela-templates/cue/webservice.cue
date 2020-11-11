output: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	spec: {
		selector: matchLabels: {
			"app.oam.dev/component": context.name
		}

		template: {
			metadata: labels: {
				"app.oam.dev/component": context.name
			}

			spec: {
				containers: [{
					name:  context.name
					image: parameter.image

					if parameter["cmd"] != _|_ {
						command: parameter.cmd
					}

					if parameter["env"] != _|_ {
						env: parameter.env
					}

					if context["config"] != _|_ {
						env: [
							for k, v in context.config {
								name:  k
								value: v
							},
						]
					}

					ports: [{
						containerPort: parameter.port
					}]

					if parameter["cpuRequests"] != _|_ {
						resources: {
							limits:
								cpu: parameter.cpuRequests
							requests:
								cpu: parameter.cpuRequests
						}
					}
				}]
		}
		}
	}
}
parameter: {
	// +usage=Which image would you like to use for your service
	// +short=i
	image: string

	cmd?: [...string]

	// +usage=Which port do you want customer traffic sent to
	// +short=p
	port: *80 | int

	env?: [...{
		name:   string
		value?: string
		valueFrom?: {
			secretKeyRef: {
				name: string
				key:  string
			}
		}
	}]
	// +usage=CPU core requests for the workload, specify like '0.5', '1'.
	// +alias=cpu-requests
	cpuRequests?: string
}
