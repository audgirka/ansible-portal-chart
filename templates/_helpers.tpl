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
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-auth-backend-module-rhaap-provider-dynamic-1.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.catalog" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic-1.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.self-service" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-backstage-self-service" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-backstage-self-service-dynamic-1.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.scaffolder" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic-1.3.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.auth" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-mOMblKSGx9rACYY0WRsxJowlg8Q5OtfWYwfpJD2Th+/xTBWa+XgZ2DZOaBTWWywQA9ruaVRWzma/8UEVnnn1hA==" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.catalog" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-Ccr03pVrsSzfzejdQXRlK/xWAiq4FkdpqHHyAuG2JgNupdCq6/RDSSOwkRZl3zHGCm8aJg+HLIwEn30qhLlIFg==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.self-service" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-BSN+MIohESCFSRJzSmtQzC/+IkX6Atceq8vPVO4ivIx/nUzkW9SDRJi75QTay6bGsTLPPLu9sK69/kx84OjbQw==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.scaffolder" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-QQJyJLk6KWDGJ6A/MbJGEfrAcGYXWbtY+8hUl4lYE5CuNy89Ecs9iZgQ0+6mDWEK8Dgvxfy0HRyyW0+MNDqNTA==" -}}    
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
