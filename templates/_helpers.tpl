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

{{- define "plugins.load.auth" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-auth-backend-module-rhaap-provider-dynamic" (include "deployment.quay-image-tag" .) -}}    
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-auth-backend-module-rhaap-provider-dynamic-1.4.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.catalog" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic-1.4.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.self-service" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-backstage-self-service" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-backstage-self-service-dynamic-1.4.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.scaffolder" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic-1.4.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.auth" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-uZBSEJAJZd74+VuAUdsiKuCL6GY6EgVdDyxa0NzgiNsYDKQKCvcPtr3Deyw8gxdvnQW5dppl7vCFxlfhdOPO/g==" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.catalog" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-TdmN9P7kIJs5AP0y03ER0wC3Urj6Y0/qPzIBeBUym7MTm6fjLAp6s6TZOiDm5SwUW+KT8V7FyadrsPDnWvlzFA==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.self-service" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-wO3WLQm69ssomXiSI5c06NHgcIM0a2UxbH+HDHcKqlnILjfjQCWAj+uWHANRoE7+MYpqdBpCXez2T8GmQxCWEg==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.scaffolder" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-XjV8HiZCQkjq8nmhF2L0JmQWUWRDRWdWdNnVGNvv1V/K7g5jQtXCXc+uZV4XMshqTuHR+FqjKDFk7aWi6RwNtg==" -}}    
    {{- end -}}
{{- end -}}

{{- define "templates.branch" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "devel" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "main" -}}
    {{- end -}}
{{- end -}}

{{- define "catalog.providers.env" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "development" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "production" -}}
    {{- end -}}
{{- end -}}
