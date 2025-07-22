{{/*
    Updates the Quay image tag in dynamic.plugins.package values - development env only
*/}}
{{- define "deployment.quay-image-tag" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "%s" (.Values.global.imageTagInfo) -}}
    {{- end -}}
{{- end -}}

{{/*
    Updates the extraContainers image
*/}}
{{- define "deployment.container-image" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "%s" "ghcr.io/ansible/community-ansible-dev-tools:latest" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "%s" "registry.redhat.io/ansible-automation-platform-25/ansible-dev-tools-rhel8:latest" -}}
    {{- end -}}
{{- end -}}

{{- define "deployment.test.imagePullSecret" }}
    {{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (index .Values "redhat-developer-hub" "testImageCredentials" "registry") (printf "%s:%s" (index .Values "redhat-developer-hub" "testImageCredentials" "username") (index .Values "redhat-developer-hub" "testImageCredentials" "password") | b64enc) | b64enc }}
{{- end }}

{{- define "deployment.test.registryCredentials" }}
    {{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (index .Values "redhat-developer-hub" "registryCredentials" "registry") (printf "%s:%s" (index .Values "redhat-developer-hub" "registryCredentials" "username") (index .Values "redhat-developer-hub" "registryCredentials" "password") | b64enc) | b64enc }}
{{- end }}

{{- define "plugins.load.auth" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-auth-backend-module-rhaap-provider" (include "deployment.quay-image-tag" .) -}}    
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-auth-backend-module-rhaap-provider-dynamic-1.5.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.catalog" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-catalog-backend-module-rhaap" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic-1.5.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.self-service" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-backstage-self-service" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-backstage-self-service-dynamic-1.5.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.scaffolder" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-scaffolder-backend-module-backstage-rhaap" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic-1.5.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.auth" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-h+s6pxr1gL7DPl1+bBxzYkmx4nGHY0zHgNr4jtBNgrhVkI75UHup3CICc1560xxMq6uYcUnkwubM0YOfVsAqeA==" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.catalog" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-1gP6riit1IfcRJHlRyLenfC+QAUXuHmrmepTZ5S1JDlNSzSV2++WviuYhjQANZKHHkZfijhY5mXMhz4MTVHQnQ==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.self-service" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-Oph6PeckgNgCQZOgJ3uz11KGhBSx0hcA9kYUBlqHwbiXg9y4rVtyyNfAfYvP2d8GMRIAJfOcbgV47kMwsMThCA==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.scaffolder" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-PMLit2Wm9GeHP46pcdYkPs2PG4/z39+hPTBSawIiURyow+Ks4/efsCsSg1IuOLDlHE0lF+FZoQl+YcfTVE2PDA==" -}}    
    {{- end -}}
{{- end -}}

{{- define "catalog.providers.env" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "development" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "production" -}}
    {{- end -}}
{{- end -}}
