{{/*
    Updates the Quay image tag in dynamic.plugins.package values - development env only
*/}}
{{- define "portal.quay-image-tag" -}}
    {{- printf "%s" (.Values.global.imageTagInfo) -}}
{{- end -}}

{{/*
    Updates the extraContainers image
*/}}
{{- define "portal.container-image" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "%s" "ghcr.io/ansible/community-ansible-dev-tools:latest" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "%s" "registry.redhat.io/ansible-automation-platform-25/ansible-dev-tools-rhel8:latest" -}}
    {{- end -}}
{{- end -}}
