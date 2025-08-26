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
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-auth-backend-module-rhaap-provider-dynamic-2.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.catalog" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-backstage-plugin-catalog-backend-module-rhaap" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-backstage-plugin-catalog-backend-module-rhaap-dynamic-2.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.self-service" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-backstage-self-service" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-backstage-self-service-dynamic-2.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.load.scaffolder" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "oci://quay.io/ansible/ansible-backstage-plugins:%s!ansible-plugin-scaffolder-backend-module-backstage-rhaap" (include "deployment.quay-image-tag" .) -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "http://plugin-registry:8080/ansible-plugin-scaffolder-backend-module-backstage-rhaap-dynamic-2.0.0.tgz" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.auth" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-SeRm5aFsDbL0j4Z7Rpj5xjLHDAs8gT+F4zHc+aaXwRGOGagy2NW3IxN2HPQq2HWqo09ZVIuROzqJxRi+QzTPPQ==" -}}
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.catalog" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-M1aTRLle/KAyi8Aq4p+4q4tbnSsp2Ms9i0BB+aTZdbMsqwKeLZ7c0nPGMVQ9qXQ53uwY78CxEaus/uL4Xj6EbQ==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.self-service" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-1JBxUJikEtxiZa7Phh4wcF8s5JRWSY9/85FkgBLYaQtjEU7bgK+5bQG+8Qr0t0IGEbt65d36wQUz6JBqo47A4Q==" -}}    
    {{- end -}}
{{- end -}}

{{- define "plugins.integrity.scaffolder" -}}
    {{- if .Values.global._environment._production -}}
        {{- printf "sha512-0Z/mSHJescwId7ZJqo9hqaAoBM2aRf61De3gq80WsUt0xB87sSxSm+NfZfICE1IiUJo8m5/d5KqD+VIDCMKuRw==" -}}    
    {{- end -}}
{{- end -}}

{{- define "catalog.providers.env" -}}
    {{- if .Values.global._environment._development -}}
        {{- printf "development" -}}
    {{- else if .Values.global._environment._production -}}
        {{- printf "production" -}}
    {{- end -}}
{{- end -}}
